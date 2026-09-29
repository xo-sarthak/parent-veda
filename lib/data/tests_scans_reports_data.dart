import '../localization/app_language.dart';

// =============================================================================
//  Tests, Scans & Reports - content library (Section 16)
// -----------------------------------------------------------------------------
//  A browsable, educational library for the merged "Tests, Scans & Reports"
//  tool. Two libraries:
//    1. kTestsScans   - the common pregnancy tests/scans (India context), each
//                       with What it is / Why / When / Preparation / Procedure /
//                       Understanding Your Report (parameter-by-parameter) /
//                       Medical Disclaimer.
//    2. kFindings     - common findings/conditions, each with What is it /
//                       Why does it happen / Symptoms / Diagnosis / Pregnancy
//                       implications / Management / When to contact doctor /
//                       FAQ / Medical Disclaimer.
//
//  EDUCATIONAL ONLY. Reassurance-first, India-context copy. Values vary by
//  individual and by lab; always consult your doctor. This complements (and
//  supersedes) the older report_findings_data.dart / scan_guide_data.dart seed.
//
//  English-first: content is authored in English. LocalizedText is intentionally
//  NOT used here so the library reads as a single clean model; Hindi can be
//  layered later the same way the older seeds mirror en into hi.
// =============================================================================

/// Which part of pregnancy a test/finding usually belongs to. Drives the top
/// filter chips: All / Trimester 1 / Trimester 2 / Trimester 3 / Any Time.
LocalizedText _t(String en, String hi) => LocalizedText(en: en, hi: hi);

/// A search alias that is the same in both scripts - acronyms and report
/// words a mother types in Latin either way (iugr, fgr, tsh, previa).
/// Deliberately not _t(x, x): an identical pair reads as finished
/// translation work to anything counting pairs.
LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

enum TrimesterTag { t1, t2, t3, anytime }

extension TrimesterTagLabel on TrimesterTag {
  LocalizedText get chipLabel => switch (this) {
        TrimesterTag.t1 => _t('Trimester 1', 'तिमाही 1'),
        TrimesterTag.t2 => _t('Trimester 2', 'तिमाही 2'),
        TrimesterTag.t3 => _t('Trimester 3', 'तिमाही 3'),
        TrimesterTag.anytime => _t('Any Time', 'कभी भी'),
      };

  /// Short badge shown on a card.
  LocalizedText get badge => switch (this) {
        TrimesterTag.t1 => _t('Trimester 1', 'तिमाही 1'),
        TrimesterTag.t2 => _t('Trimester 2', 'तिमाही 2'),
        TrimesterTag.t3 => _t('Trimester 3', 'तिमाही 3'),
        TrimesterTag.anytime => _t('Throughout', 'पूरे सफ़र में'),
      };
}

/// The standard educational disclaimer shown on EVERY detail page.
const LocalizedText kMedicalDisclaimer =
    LocalizedText(
  en: "This page explains. It isn't medical advice, a diagnosis or a "
      "prediction. Normal values vary from person to person and from lab to "
      "lab, and one reading is only one part of the picture. Always go "
      "through your report with your own doctor, who knows your full history.",
  hi: 'यह जानकारी सिर्फ़ समझाने के लिए है — न यह चिकित्सकीय सलाह है, न निदान, न कोई भविष्यवाणी। सामान्य values हर व्यक्ति और हर lab में अलग होती हैं, और अकेली एक reading पूरी तस्वीर का बस एक हिस्सा है। अपनी रिपोर्ट हमेशा अपने डॉक्टर के साथ बैठकर पढ़िए, जो आपका पूरा इतिहास जानते हैं।',
);

// ---------------------------------------------------------------------------
//  Models
// ---------------------------------------------------------------------------

/// One parameter on a report (e.g. Hb, TSH, BPD, Placenta), explained fully so a
/// mother sees the WHOLE picture rather than half-knowledge.
class ReportParameter {
  const ReportParameter({
    required this.name,
    required this.measures,
    required this.whyImportant,
    this.typicalRange,
    this.ifLow,
    this.ifHigh,
    this.note,
  });

  /// e.g. "Hb (Haemoglobin)".
  final LocalizedText name;

  /// What it measures.
  final LocalizedText measures;

  /// Why it is important.
  final LocalizedText whyImportant;

  /// Typical pregnancy range (optional - some parameters are descriptive, not
  /// numeric, e.g. placenta position).
  final LocalizedText? typicalRange;

  /// What a LOW value can mean (optional).
  final LocalizedText? ifLow;

  /// What a HIGH value can mean (optional).
  final LocalizedText? ifHigh;

  /// A general note for descriptive (non-numeric) parameters.
  final LocalizedText? note;
}

/// A single pregnancy test or scan.
class TestScanInfo {
  const TestScanInfo({
    required this.id,
    required this.name,
    this.altName,
    required this.tag,
    required this.whatItIs,
    required this.why,
    required this.when,
    required this.preparation,
    required this.procedure,
    required this.understandingReport,
    this.parameters = const [],
    this.interpretation = const LocalizedText(en: '', hi: ''),
    this.interpretPointers = const [],
    this.disclaimer = kMedicalDisclaimer,
    this.aliases = const [],
    this.shortAnswer,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText? altName;
  final TrimesterTag tag;

  /// "The short answer" box at the top of the scan's read: two or three
  /// sentences that say what the test is for and what she should know
  /// first. Added 2026-09-29 (pregnancy gap analysis, "How reads are
  /// written"). Optional; `pvReadFromScan` passes it to `PvRead.shortAnswer`.
  /// English only (new copy is English, CLAUDE.md 2026-08-27).
  final LocalizedText? shortAnswer;

  final LocalizedText whatItIs; // What it is
  final LocalizedText why; // Why it's done
  final LocalizedText when; // When (gestational timing)
  final LocalizedText preparation; // Preparation
  final LocalizedText procedure; // Procedure

  /// Free-text lead-in for "Understanding your report parameters".
  final LocalizedText understandingReport;

  /// The parameter-by-parameter breakdown under that heading.
  final List<ReportParameter> parameters;

  /// THE CLOSING SUMMARY — "How do I interpret the test results".
  ///
  /// Asked for by the review, and the gap it fills is real: the parameters
  /// above explain each line of a report one at a time, and a parent finishes
  /// them knowing what nine numbers mean and still not knowing what the REPORT
  /// says. This is the cumulative read — what a normal result means, what an
  /// abnormal one can point at, and what to do next.
  ///
  /// Written to a strict rule, because this is the most dangerous copy in the
  /// feature: it names what a finding CAN indicate, never what it does
  /// indicate, and every one of them ends at the same place — the doctor
  /// interprets the actual result. The app explains a report; it never reads
  /// one. See CLAUDE.md's clinical invariants.
  ///
  /// Optional. A test without it simply does not render the section.
  final LocalizedText interpretation;

  /// Short pointers under the summary — the "what can throw this off" and
  /// "what happens next" lines that a paragraph buries.
  final List<LocalizedText> interpretPointers;

  final LocalizedText disclaimer;
  final List<LocalizedText> aliases;
}

/// A question/answer pair for a finding's FAQ.
class Faq {
  const Faq(this.q, this.a);
  final LocalizedText q;
  final LocalizedText a;
}

/// A common finding or condition.
class FindingInfo {
  const FindingInfo({
    required this.id,
    required this.name,
    this.altName,
    required this.tag,
    required this.whatIsIt,
    required this.whyHappens,
    required this.symptoms,
    required this.diagnosis,
    required this.implications,
    required this.management,
    required this.whenToContact,
    this.faqs = const [],
    this.disclaimer = kMedicalDisclaimer,
    this.aliases = const [],
  });

  final String id;
  final LocalizedText name;
  final LocalizedText? altName;
  final TrimesterTag tag;

  final LocalizedText whatIsIt; // What is it?
  final LocalizedText whyHappens; // Why does it happen?
  final List<LocalizedText> symptoms; // Symptoms
  final LocalizedText diagnosis; // Diagnosis
  final LocalizedText implications; // Pregnancy implications
  final LocalizedText management; // Management
  final List<LocalizedText> whenToContact; // When to contact doctor
  final List<Faq> faqs; // FAQ

  final LocalizedText disclaimer;
  final List<LocalizedText> aliases;
}

// ===========================================================================
//  1. TESTS & SCANS
// ===========================================================================

final List<TestScanInfo> kTestsScans = [
  // -- Booking blood panel ---------------------------------------------------
  TestScanInfo(
    id: 'blood_tests',
    shortAnswer: _same(
        "These blood tests check your blood count, iron, thyroid, blood group, sugar and a few infections. Most come back in range, and when one doesn't, it usually means a tablet or a repeat test. Your doctor reads them together."),
    name: _t('Blood Tests', 'ख़ून की जाँचें'),
    altName: _t('Booking / Routine Antenatal Panel', 'पहली विज़िट / रूटीन Antenatal Panel'),
    tag: TrimesterTag.anytime,
    whatItIs:
        _t("A set of blood tests done through pregnancy. There's a bigger "
           "panel at your first (booking) visit and a few repeats later. "
           "Together they check your blood count, iron stores, key vitamins "
           "and minerals, thyroid, blood group and blood sugar.", 'गर्भावस्था के दौरान होने वाली ख़ून की जाँचों का एक समूह — पहली विज़िट पर एक बड़ा panel और आगे चलकर कुछ दोबारा। मिलकर ये आपका blood count, iron का भंडार, ज़रूरी vitamins और minerals, thyroid, blood group और blood sugar जाँचती हैं।'),
    why:
        _t('Pregnancy asks a lot more of your body. These tests find small, '
           'fixable things early, like low iron or a thyroid that needs a '
           'little help, so you and your baby stay well through the months '
           'ahead.', 'गर्भावस्था आपके शरीर से ज़्यादा माँगती है। ये जाँचें छोटी, आसानी से ठीक हो जाने वाली बातें जल्दी पकड़ लेती हैं — जैसे iron की कमी या thyroid को थोड़े सहारे की ज़रूरत — ताकि आने वाले महीनों में आप और आपका शिशु दोनों ठीक रहें।'),
    when:
        _t('The full panel is usually taken at your first antenatal visit, '
           'in the first trimester. Haemoglobin and a few others are '
           'repeated in the second and third trimesters, and more often if a '
           'value needs watching.', 'पूरा panel आमतौर पर पहली antenatal विज़िट पर होता है (पहली तिमाही)। Haemoglobin और कुछ और जाँचें दूसरी और तीसरी तिमाही में दोहराई जाती हैं, और किसी value पर नज़र रखनी हो तो उससे भी ज़्यादा बार।'),
    preparation:
        _t('Most of these need no special preparation. If a fasting blood '
           'sugar or lipid test is included, you may be asked not to eat for '
           '8-10 hours (water is fine). Your lab or doctor will tell you if '
           'you need to fast.', 'ज़्यादातर जाँचों के लिए कोई ख़ास तैयारी नहीं चाहिए। अगर fasting blood sugar या lipid test शामिल है, तो 8-10 घंटे कुछ न खाने को कहा जा सकता है (पानी चलेगा)। fasting चाहिए या नहीं, यह आपकी lab या डॉक्टर बता देंगे।'),
    procedure:
        _t('A nurse or technician takes a small sample of blood from a vein '
           'in your arm. It takes a minute or two. You can eat and carry on '
           'as normal afterwards, and results usually come in a day or two.', 'nurse या technician आपकी बाँह की नस से ख़ून का छोटा सा sample लेते हैं। एक-दो मिनट लगते हैं। उसके बाद आप खा सकती हैं और दिन सामान्य रूप से चला सकती हैं; रिपोर्ट आमतौर पर एक-दो दिन में आ जाती है।'),
    understandingReport:
        _t("Your report lists several values, each with the lab's usual "
           "range beside it. Ranges differ a little between labs, and "
           "pregnancy shifts some of them. Here's what the common ones mean.", 'आपकी रिपोर्ट में कई values होती हैं, हर एक के साथ lab की reference range। हर lab की range थोड़ी अलग होती है, और गर्भावस्था कुछ को बदल भी देती है। आम values का मतलब यह है।'),
    parameters: [
      ReportParameter(
        name: _same('Hb (Haemoglobin)'),
        measures:
            _t('The protein in your red blood cells that carries oxygen '
               'around your body and to your baby.', 'red blood cells में मौजूद वह protein जो आपके शरीर में और शिशु तक oxygen पहुँचाता है।'),
        whyImportant:
            _t("Good haemoglobin means your blood is carrying oxygen well, "
               "and you're less likely to feel very tired or breathless.", 'haemoglobin ठीक हो तो आपका ख़ून oxygen अच्छी तरह पहुँचाता है और बहुत थकान या साँस फूलने की शिकायत कम होती है।'),
        typicalRange:
            _t("In pregnancy, about 11 g/dL or above is usually thought of "
               "as enough. That's a little lower than outside pregnancy, "
               "because your blood volume goes up.", 'गर्भावस्था में लगभग 11 g/dL या उससे ऊपर आमतौर पर पर्याप्त माना जाता है (गर्भावस्था के बाहर से थोड़ा कम, क्योंकि ख़ून की मात्रा बढ़ जाती है)।'),
        ifLow:
            _t("Low Hb is anaemia. It's very common in pregnancy and is "
               "usually from low iron. Iron-rich food and iron tablets "
               "usually bring it up.", 'Hb कम होना anaemia है — गर्भावस्था में बहुत आम, और आमतौर पर iron की कमी से। iron वाले खाने और supplements से यह ठीक हो जाता है।'),
        ifHigh:
            _t("A high Hb is less common. Your doctor may just check whether "
               "you're drinking enough and look at the whole picture.", 'Hb ज़्यादा होना कम देखने को मिलता है; डॉक्टर बस आपके पानी के स्तर और पूरी तस्वीर को देख लेंगे।'),
      ),
      ReportParameter(
        name: _same('Serum Iron'),
        measures: _t('How much iron is in your blood right now.', 'इस वक़्त आपके ख़ून में घूम रहे iron की मात्रा।'),
        whyImportant:
            _t('Your body needs iron to make haemoglobin, and your baby '
               'needs it to grow and for their brain to develop.', 'haemoglobin बनाने और शिशु की बढ़त तथा दिमाग़ के विकास के लिए iron ही बुनियादी ईंट है।'),
        typicalRange:
            _t("Read against the lab's range. It can go up and down with "
               "recent meals, so it's read alongside ferritin.", 'lab की range के साथ बताई जाती है; हाल के खाने से यह ऊपर-नीचे हो सकती है और इसे ferritin के साथ पढ़ा जाता है।'),
        ifLow: _t('Low serum iron points towards low iron.', 'serum iron कम होना iron की कमी की ओर इशारा करता है।'),
        ifHigh:
            _t("A high value is uncommon, and it's read with your other iron "
               "tests.", 'value ज़्यादा आना कम होता है और इसे बाक़ी iron जाँचों के साथ पढ़ा जाता है।'),
      ),
      ReportParameter(
        name: _same('Ferritin'),
        measures: _t('The iron your body has stored, like a reserve tank.', 'आपके शरीर में जमा iron — यानी "reserve tank"।'),
        whyImportant:
            _t('Ferritin shows your iron reserves before haemoglobin drops, '
               'so it catches low iron early.', 'haemoglobin गिरने से पहले ही ferritin जमा iron दिखा देता है, इसलिए कमी जल्दी पकड़ में आ जाती है।'),
        typicalRange:
            _t('Above about 30 ng/mL is usually thought of as enough stored '
               'iron in pregnancy.', 'गर्भावस्था में लगभग 30 ng/mL से ऊपर का भंडार आमतौर पर पर्याप्त माना जाता है।'),
        ifLow:
            _t("Low ferritin means your iron stores are running down. It's "
               "the earliest sign of low iron, and iron tablets usually sort "
               "it out.", 'ferritin कम होने का मतलब है iron का भंडार घट रहा है — कमी का सबसे पहला संकेत, जो iron से आसानी से सँभल जाता है।'),
        ifHigh:
            _t("Ferritin can go up for a while with an infection or "
               "inflammation, so it's read with the rest of your results.", 'infection या सूजन में ferritin कुछ समय के लिए बढ़ सकता है, इसलिए इसे पूरे संदर्भ में देखा जाता है।'),
      ),
      ReportParameter(
        name: _same('Calcium'),
        measures: _t('How much calcium is in your blood.', 'आपके ख़ून में calcium का स्तर।'),
        whyImportant:
            _t("Calcium helps build your baby's bones and teeth, and looks "
               "after your own bones, muscles and nerves.", 'calcium शिशु की हड्डियों और दाँतों के साथ आपकी अपनी हड्डियों, मांसपेशियों और नसों को सँभालता है।'),
        typicalRange: _t("Read against the lab's range (often around "
                         "8.5-10.5 mg/dL).", 'lab की range के साथ बताई जाती है (अक्सर लगभग 8.5-10.5 mg/dL)।'),
        ifLow:
            _t("If it's low, you may be told to eat more calcium-rich food "
               "or take a tablet, often with vitamin D.", 'calcium कम हो तो calcium वाले खाने या supplement की सलाह मिल सकती है, अक्सर vitamin D के साथ।'),
        ifHigh: _t('A high value is uncommon, and your doctor would look '
                   'into it.', 'value ज़्यादा आना कम होता है और डॉक्टर बस इसे देख लेंगे।'),
      ),
      ReportParameter(
        name: _same('Vitamin D'),
        measures: _t('Your vitamin D level (25-hydroxy vitamin D).', 'आपका vitamin D स्तर (25-hydroxy vitamin D)।'),
        whyImportant:
            _t("Vitamin D helps your body use calcium for your baby's bones. "
               "Low levels are very common in India.", 'vitamin D शरीर को calcium इस्तेमाल करने में मदद करता है, जो शिशु की हड्डियों के लिए ज़रूरी है। भारत में इसकी कमी बहुत आम है।'),
        typicalRange:
            _t('Around 30 ng/mL or above is usually thought of as enough. '
               'Below 20 is often called deficient.', 'लगभग 30 ng/mL या उससे ऊपर आमतौर पर पर्याप्त माना जाता है; 20 से नीचे को अक्सर कमी कहा जाता है।'),
        ifLow:
            _t('Low vitamin D is common and easy to correct with a '
               'supplement your doctor prescribes and some safe time in the '
               'sun.', 'vitamin D की कमी आम है और डॉक्टर के लिखे supplement तथा थोड़ी सुरक्षित धूप से आसानी से ठीक हो जाती है।'),
        ifHigh:
            _t('Very high levels only happen with too many supplements, so '
               'doses are kept sensible.', 'बहुत ज़्यादा स्तर तभी होता है जब supplement ज़रूरत से ज़्यादा लिया जाए, इसलिए dose सोच-समझकर रखी जाती है।'),
      ),
      ReportParameter(
        name: _same('TSH (Thyroid)'),
        measures:
            _t("Thyroid Stimulating Hormone. It's a signal that shows how "
               "well your thyroid gland is working.", 'Thyroid Stimulating Hormone — एक संकेत जो बताता है कि आपकी thyroid ग्रंथि कैसे काम कर रही है।'),
        whyImportant:
            _t("A thyroid in balance supports your energy and your baby's "
               "brain development, especially early in pregnancy.", 'thyroid संतुलित हो तो आपकी ऊर्जा और शिशु के दिमाग़ के विकास, दोनों को सहारा मिलता है — ख़ासकर शुरुआती गर्भावस्था में।'),
        typicalRange:
            _t('Pregnancy has its own targets, often roughly 0.1-4.0 mIU/L, '
               'with cut-offs for each trimester that your doctor uses.', 'गर्भावस्था के अपने लक्ष्य होते हैं, अक्सर लगभग 0.1-4.0 mIU/L, और डॉक्टर हर तिमाही के अलग cut-off इस्तेमाल करते हैं।'),
        ifLow:
            _t('A low TSH can point to an overactive thyroid '
               '(hyperthyroidism), which your doctor will look into.', 'TSH कम होना thyroid के ज़्यादा सक्रिय होने (hyperthyroidism) की ओर इशारा कर सकता है, जिसे डॉक्टर आगे जाँचेंगे।'),
        ifHigh:
            _t("A high TSH points to an underactive thyroid "
               "(hypothyroidism). It's common and easy to support with a "
               "small daily tablet.", 'TSH ज़्यादा होना thyroid के कम सक्रिय होने (hypothyroidism) की ओर इशारा करता है — आम बात, और रोज़ की एक छोटी tablet से आसानी से सँभल जाती है।'),
      ),
    ],
    interpretation:
        _t("Most first-visit blood tests come back in range, and that's what "
           "the lab is checking: enough haemoglobin and iron to carry oxygen "
           "for two, a thyroid working normally, and no infection that needs "
           "treating early. A value outside the range is common in "
           "pregnancy. It usually means a supplement or a repeat test, not a "
           "problem with your baby.", 'पहली विज़िट की ज़्यादातर जाँचें range के अंदर ही आती हैं, और lab यही देख रही होती है: दो लोगों तक oxygen पहुँचाने के लिए पर्याप्त haemoglobin और iron, ठीक चल रही thyroid, और कोई ऐसा infection नहीं जिसका इलाज पहले ज़रूरी हो। कोई value range से बाहर आना गर्भावस्था में आम है और आमतौर पर इसका मतलब एक supplement या दोबारा जाँच होता है, शिशु में कोई दिक़्क़त नहीं।'),
    interpretPointers: [
      _t("Low haemoglobin or ferritin most often means you need iron. It's "
         "the most common abnormal result in Indian pregnancies, and one of "
         "the easiest to treat.", 'haemoglobin या ferritin कम होने का मतलब अक्सर बस इतना है कि iron चाहिए — भारत में गर्भावस्था का सबसे आम असामान्य नतीजा, और सबसे आसानी से ठीक होने वालों में।'),
      _t('A thyroid value outside the range is usually managed with a daily '
         'tablet and a repeat test a few weeks later.', 'thyroid की value range से बाहर हो तो आमतौर पर रोज़ की एक tablet और कुछ हफ़्तों बाद दोबारा जाँच से बात सँभल जाती है।'),
      _t('Eating before a fasting test, a recent illness, or not drinking '
         'enough can each throw a result off enough to need a repeat.', 'fasting जाँच से पहले कुछ खा लेना, हाल की कोई बीमारी, या पानी की कमी — इनमें से कोई भी नतीजे को इतना बदल सकता है कि जाँच दोबारा करनी पड़े।'),
      _t('Your doctor reads these together, not one at a time. One number '
         'outside the range rarely means anything on its own.', 'डॉक्टर इन सबको एक साथ पढ़ते हैं, एक-एक करके नहीं। अकेला एक number range से बाहर होने का अपने आप में शायद ही कोई मतलब होता है।'),
      // Added 2026-09-29 (gap analysis, Understand a scan, P3): some Indian
      // doctors still offer the quadruple marker in the second trimester.
      _same("Some doctors offer a quadruple marker (\"quad\") blood test at "
          "about 15 to 20 weeks, often if the NT scan was missed. Like the "
          "double marker, it gives a chance, not a diagnosis. A higher chance "
          "leads to a talk about a further test, and most babies in that "
          "group are fine."),
    ],
  ),

  // -- Dating scan -----------------------------------------------------------
  TestScanInfo(
    id: 'dating_scan',
    shortAnswer: _same(
        "Your first scan checks the pregnancy is in the womb, looks for a heartbeat and measures your baby to set your due date. If it's very early, the heartbeat may not show yet, and a repeat scan is the usual next step. Your doctor decides when."),
    name: _same('Dating Scan'),
    altName: _t('Viability / First-Trimester Ultrasound', 'Viability / पहली तिमाही का Ultrasound'),
    tag: TrimesterTag.t1,
    whatItIs:
        _t('Your first ultrasound in pregnancy. It checks the pregnancy is '
           'in the right place, looks for a heartbeat, sees how many babies '
           'there are, and measures your baby to give an accurate due date.', 'गर्भावस्था का आपका पहला ultrasound। यह पक्का करता है कि गर्भ सही जगह ठहरा है, धड़कन देखता है, कितने शिशु हैं यह बताता है, और शिशु को नापकर सही due date देता है।'),
    why:
        _t('It shows your pregnancy has started well and sets your due date '
           'accurately. Every later scan and test is timed from it.', 'यह स्वस्थ शुरुआत की पुष्टि करता है और आपकी due date सही तय करता है — आगे का हर scan और जाँच इसी से समय पर होते हैं।'),
    when:
        _t("Usually between about 6 and 9 weeks, sometimes up to 13 weeks. "
           "You may have an earlier scan if you have pain, bleeding, or "
           "aren't sure of your dates.", 'आमतौर पर लगभग 6 से 9 हफ़्तों के बीच, कभी-कभी 13 हफ़्तों तक। दर्द हो, ख़ून आए, या तारीख़ों को लेकर संशय हो तो scan जल्दी भी किया जा सकता है।'),
    preparation:
        _t('For an early internal (transvaginal) scan you may not need a '
           'full bladder. For a scan on your tummy you may be asked to drink '
           'water and hold your urine, so the womb is easier to see. Wear '
           'comfortable, two-piece clothes.', 'शुरुआती (transvaginal) scan के लिए शायद bladder भरा होना ज़रूरी न हो। पेट के ऊपर से होने वाले scan के लिए पानी पीकर पेशाब रोकने को कहा जा सकता है, ताकि बच्चेदानी साफ़ दिखे। आरामदेह, दो हिस्सों वाले कपड़े पहनिए।'),
    procedure:
        _t("A probe sends harmless sound waves to make a picture. It goes on "
           "your tummy with gel, or early on it may be a slim internal "
           "probe. It's painless and takes about 10-20 minutes.", 'एक probe (या तो gel लगाकर आपके पेट पर, या शुरुआत में एक पतला अंदरूनी probe) बिना नुक़सान वाली ध्वनि तरंगों से तस्वीर बनाता है। इसमें दर्द नहीं होता और लगभग 10-20 मिनट लगते हैं।'),
    understandingReport:
        _t("The report notes a few early measurements and what they saw. "
           "Here's what they mean.", 'रिपोर्ट में शुरुआत के कुछ माप और observations लिखे होते हैं। उनका मतलब यह है।'),
    parameters: [
      ReportParameter(
        name: _same('Gestational sac'),
        measures: _t('The fluid-filled space your baby grows in.', 'पानी से भरी वह जगह जिसमें आपका शिशु बढ़ता है।'),
        whyImportant:
            _t('Seeing it inside the womb confirms the pregnancy is in the '
               'right place.', 'इसका बच्चेदानी के अंदर दिखना पुष्टि करता है कि गर्भ सही जगह ठहरा है।'),
        note: _t('A normal early finding. Its size helps confirm your dates.', 'शुरुआत की एक सामान्य बात; इसका आकार तारीख़ें पक्की करने में मदद करता है।'),
      ),
      ReportParameter(
        name: _same('CRL (Crown-Rump Length)'),
        measures: _t("Your baby's length from head to bottom.", 'सिर से कूल्हे तक आपके शिशु की लंबाई।'),
        whyImportant:
            _t('This is the most accurate way to date a pregnancy this early.', 'इतनी जल्दी गर्भावस्था की तारीख़ तय करने का यही सबसे सटीक तरीक़ा है।'),
        note: _t('Used to set or confirm your due date.', 'इसी से आपकी अनुमानित due date तय या पक्की की जाती है।'),
      ),
      ReportParameter(
        name: _same('FHR / Cardiac activity'),
        measures: _t("Your baby's heartbeat.", 'आपके शिशु की धड़कन।'),
        whyImportant: _t('A heartbeat is a reassuring sign of a healthy '
                         'start.', 'धड़कन का दिखना स्वस्थ शुरुआत का भरोसा देने वाला संकेत है।'),
        typicalRange:
            _t('Often seen from around 6 weeks. A rate of roughly 110-160 '
               'beats per minute is usual as pregnancy goes on.', 'अक्सर लगभग 6 हफ़्तों से दिखने लगती है; गर्भावस्था आगे बढ़ने पर लगभग 110-160 धड़कन प्रति मिनट सामान्य है।'),
        note:
            _t("Before about 6 weeks it can just be too early to see. That "
               "isn't a reason to worry on its own, and your doctor will say "
               "what happens next.", 'लगभग 6 हफ़्तों से पहले इसका न दिखना सिर्फ़ जल्दी होने की बात हो सकती है — अपने आप में चिंता की वजह नहीं।'),
      ),
      ReportParameter(
        name: _same('EDD (Estimated Due Date)'),
        measures: _t('The date your baby is expected, worked out from the '
                     'measurements.', 'मापों से निकली आपकी अनुमानित delivery की तारीख़।'),
        whyImportant:
            _t('It sets the timing of every scan, test and milestone that '
               'follows.', 'आगे का हर scan, जाँच और पड़ाव इसी तारीख़ के हिसाब से तय होता है।'),
        note: _t('It may be moved a little from the date worked out from '
                 'your period.', 'आपके period से निकली तारीख़ से यह थोड़ी अलग हो सकती है।'),
      ),
    ],
    interpretation:
        _t("A normal dating scan means one pregnancy, in the right place, "
           "with a heartbeat and a size that gives a due date. From here, "
           "the scan date is the one that counts. It's measured, while a "
           "date from your last period is estimated, and this is the most "
           "accurate dating scan you'll have.", 'सामान्य dating scan का मतलब है — एक गर्भ, सही जगह, धड़कन के साथ, और ऐसा आकार जिससे due date निकल आती है। यहाँ से scan वाली तारीख़ ही मानी जाती है — वह नापी गई है, जबकि पिछले period से निकली तारीख़ सिर्फ़ अंदाज़ा है, और यही सबसे सटीक dating scan आपको मिलेगा।'),
    interpretPointers: [
      _t('If the scan date and your period date are more than about a week '
         'apart, the scan usually wins and your notes are updated.', 'अगर scan की तारीख़ आपके period वाली तारीख़ से लगभग एक हफ़्ते से ज़्यादा अलग हो, तो आमतौर पर scan की मानी जाती है और आपके records बदल दिए जाते हैं।'),
      _t("No heartbeat at a very early scan often means it's just too early. "
         "A repeat scan in one to two weeks is the normal next step, not bad "
         "news. Your doctor decides when.", 'बहुत शुरुआती scan में धड़कन न दिखने का मतलब अक्सर सिर्फ़ इतना होता है कि अभी जल्दी है। एक-दो हफ़्ते बाद दोबारा scan सामान्य अगला क़दम है, बुरी ख़बर नहीं।'),
      _t('A very early scan, the way your womb is tilted, or a full bladder '
         'can all make measuring harder.', 'बहुत जल्दी किया गया scan, बच्चेदानी का कुछ अलग झुकाव, या भरा हुआ bladder — ये सब नापना मुश्किल कर सकते हैं।'),
      _t("Your sonographer won't usually talk about findings during the "
         "scan. The report goes to your doctor, who explains it.", 'scan के दौरान sonographer आमतौर पर नतीजों पर बात नहीं करते। रिपोर्ट आपके डॉक्टर के पास जाती है, वही इसे समझाते हैं।'),
    ],
  ),

  // -- NT scan ---------------------------------------------------------------
  TestScanInfo(
    id: 'nt_scan',
    shortAnswer: _same(
        "The NT scan and the double marker blood test give a chance for some chromosomal conditions. It's a screening result, not a diagnosis. A higher chance leads to a conversation about a further test, and most babies in that group are fine."),
    name: _same('NT Scan'),
    altName: _same('Nuchal Translucency + Double Marker'),
    tag: TrimesterTag.t1,
    whatItIs:
        _t('A screening test in the first three months. An ultrasound '
           'measures a small pocket of fluid at the back of your baby\'s '
           'neck (the nuchal translucency). It\'s usually combined with a '
           'blood test (the "double marker") and your age.', 'पहली तिमाही की एक screening जाँच। ultrasound में शिशु की गर्दन के पीछे भरे थोड़े से पानी (nuchal translucency) को नापा जाता है, और उसके साथ आमतौर पर एक ख़ून की जाँच ("double marker") और आपकी उम्र जोड़ी जाती है।'),
    why:
        _t("Together these give a chance (a likelihood) for conditions such "
           "as Down's syndrome. It's a screening test. It estimates a "
           "probability, and it doesn't diagnose anything.", 'ये मिलकर Down\'s syndrome जैसी स्थितियों की एक संभावना (chance) बताते हैं। यह screening जाँच है — यह संभावना का अंदाज़ा लगाती है, किसी बात का निदान नहीं करती।'),
    when:
        _t('Between 11 weeks and 13 weeks 6 days, when the NT measurement is '
           'most reliable.', '11 हफ़्ते से 13 हफ़्ते 6 दिन के बीच, जब NT का माप सबसे भरोसेमंद होता है।'),
    preparation:
        _t("A moderately full bladder can help the scan. You can usually "
           "give the blood sample for the double marker on the same day, and "
           "you don't need to fast.", 'bladder थोड़ा भरा हो तो scan में मदद मिलती है। double marker के लिए ख़ून का sample आमतौर पर उसी दिन दिया जा सकता है; fasting की ज़रूरत नहीं।'),
    procedure:
        _t("A scan on your tummy measures the neck fluid and confirms your "
           "dates, and a simple blood test is taken for the markers. It's "
           "painless and takes about 20-30 minutes in all.", 'पेट के ऊपर से होने वाला सामान्य ultrasound गर्दन का पानी नापता है और तारीख़ें पक्की करता है, साथ में markers के लिए ख़ून का एक आसान sample। दर्द नहीं होता, कुल मिलाकर लगभग 20-30 मिनट।'),
    understandingReport:
        _t("Your result puts the scan and blood values together into one "
           "overall chance. Here's what the pieces mean.", 'आपका नतीजा scan और ख़ून की values को मिलाकर एक कुल संभावना बताता है। हर हिस्से का मतलब यह है।'),
    parameters: [
      ReportParameter(
        name: _same('NT measurement (mm)'),
        measures: _t("The fluid at the back of your baby's neck.", 'आपके शिशु की गर्दन के पीछे का पानी।'),
        whyImportant: _t("It's the main scan measurement used in the "
                         "calculation.", 'गणना में इस्तेमाल होने वाला यह मुख्य scan marker है।'),
        typicalRange: _t('Most babies measure under about 3.0-3.5 mm.', 'ज़्यादातर शिशुओं का माप लगभग 3.0-3.5 mm से नीचे रहता है।'),
        ifHigh:
            _t("A higher value raises the calculated chance, but it doesn't "
               "confirm anything. Many babies with a slightly higher NT are "
               "perfectly well.", 'value ज़्यादा होने से निकाली गई संभावना बढ़ जाती है, पर इससे कुछ भी पक्का नहीं होता — थोड़े ज़्यादा NT वाले कई शिशु पूरी तरह स्वस्थ होते हैं।'),
      ),
      ReportParameter(
        name: _same('Nasal bone'),
        measures: _t('Whether the nasal bone can be seen (present or absent).', 'nasal bone दिख रहा है या नहीं (present या absent)।'),
        whyImportant: _t("It's one of several small signs that are looked at "
                         "together.", 'यह उन कई soft markers में से एक है जिन्हें साथ मिलाकर देखा जाता है।'),
        note:
            _t("If the nasal bone isn't seen, the calculated chance can go "
               "up a little. On its own it is not a diagnosis.", 'nasal bone न दिखे तो निकाली गई संभावना थोड़ी बढ़ सकती है; अकेले इसका मतलब कोई निदान नहीं।'),
      ),
      ReportParameter(
        name: _same('Free β-hCG / PAPP-A'),
        measures: _t('Two pregnancy hormones or proteins measured in the '
                     'blood sample.', 'ख़ून के sample से निकले गर्भावस्था के दो hormones/proteins।'),
        whyImportant: _t('They go into your overall screening chance.', 'ये आपकी कुल screening संभावना में जुड़ते हैं।'),
        note:
            _t('Usually reported as "MoM" (multiples of the median) rather '
               'than plain numbers.', 'आमतौर पर सीधे numbers के बजाय "MoM" (multiples of the median) में बताए जाते हैं।'),
      ),
      ReportParameter(
        name: _t('Risk / chance (e.g. 1 in 1500)', 'Risk / chance (जैसे 1 in 1500)'),
        measures: _t('Your combined screening result.', 'आपका मिला-जुला screening नतीजा।'),
        whyImportant: _t('It tells you whether a further test is worth '
                         'thinking about.', 'यह बताता है कि आगे कोई जाँच सोचने लायक़ है या नहीं।'),
        note:
            _t('A "low chance" (a big number, like 1 in 1500) is reassuring. '
               'A "higher chance" may lead to an offer of NIPT or a '
               'diagnostic test. It\'s a next step, not a conclusion.', '"low chance" (बड़ा number, जैसे 1 in 1500) भरोसा देने वाला है। "higher chance" पर NIPT या कोई diagnostic जाँच सुझाई जा सकती है — यह अगला क़दम है, कोई नतीजा नहीं।'),
      ),
    ],
    interpretation:
        _t("This scan gives a chance, not an answer, and that difference is "
           "the whole point. A low-chance result means the chance of a "
           "chromosomal condition is small, not that it's zero. A "
           "high-chance result isn't a finding either. Most babies in that "
           "group turn out to be fine, and it's an invitation to a further "
           "test.", 'यह scan एक संभावना बताता है, जवाब नहीं — और यही इसकी पूरी बात है। low-chance नतीजे का मतलब है कि किसी chromosomal स्थिति की संभावना कम है — यह नहीं कि शून्य है। high-chance भी कोई नतीजा नहीं; उस समूह के ज़्यादातर शिशु ठीक ही निकलते हैं, और यह आगे एक जाँच का न्योता भर है।'),
    interpretPointers: [
      _t('The result is a probability, written as a ratio. Both 1 in 900 and '
         '1 in 90 are ordinary results from a normal scan.', 'नतीजा एक संभावना है, अनुपात में लिखी हुई। 1 in 900 और 1 in 90, दोनों एक सामान्य scan के आम नतीजे हैं।'),
      _t("A raised neck measurement on its own is not a diagnosis of anything.", 'nuchal माप का बढ़ा होना अकेले में किसी बात का निदान नहीं।'),
      _t("Your baby's position, where you are in the 11-13 week window, and "
         "your own build can each affect the measurement.", 'शिशु की स्थिति, 11-13 हफ़्ते की खिड़की में आप कहाँ हैं, और आपका अपना शरीर — इनमें से हर एक माप पर असर डाल सकता है।'),
      _t('If the chance comes back raised, NIPT or a diagnostic test is '
         'usually the next conversation, and your doctor will walk you '
         'through it.', 'संभावना बढ़ी हुई आए तो आमतौर पर अगली बात NIPT या किसी diagnostic जाँच की होती है — जिसे आपके डॉक्टर आपको पूरा समझाएँगे।'),
    ],
  ),

  // -- NIPT ------------------------------------------------------------------
  TestScanInfo(
    id: 'nipt',
    shortAnswer: _same(
        "NIPT is an optional blood test that screens for some chromosomal conditions from 10 weeks. A low-chance result is very reassuring. A high-chance result always needs a diagnostic test before anything is decided."),
    name: _same('NIPT'),
    altName: _same('Non-Invasive Prenatal Test'),
    tag: TrimesterTag.t1,
    whatItIs:
        _t("A blood test that looks at tiny pieces of your baby's DNA in "
           "your blood, to screen for common chromosomal conditions such as "
           "Down's syndrome.", 'एक उन्नत ख़ून की जाँच, जो आपके ख़ून में घूम रहे शिशु के DNA के छोटे टुकड़ों को देखकर Down\'s syndrome जैसी आम chromosomal स्थितियों की screening करती है।'),
    why:
        _t('It\'s a more precise screening test than the combined NT test. '
           'It may be offered as a first choice, or after a "higher chance" '
           'NT result, to give clearer information before you decide about '
           'any diagnostic test.', 'यह मिली-जुली NT जाँच से ज़्यादा सटीक screening है। यह पहली पसंद के तौर पर भी दी जा सकती है, या NT में "higher chance" आने के बाद — ताकि कोई diagnostic जाँच तय करने से पहले तस्वीर साफ़ हो।'),
    when:
        _t("From 10 weeks on, when there's enough of your baby's DNA in your "
           "blood. It can be done any time after that.", '10 हफ़्तों के बाद से (आपके ख़ून में शिशु का DNA पर्याप्त होना चाहिए)। उसके बाद यह किसी भी समय की जा सकती है।'),
    preparation:
        _t("No preparation and no fasting. It's a simple blood test from "
           "your arm.", 'न कोई तैयारी, न fasting। बाँह से ख़ून का एक आसान sample भर है।'),
    procedure:
        _t('One blood sample is taken and sent to a specialist lab. Results '
           'usually take about a week to ten days.', 'ख़ून का एक sample लेकर विशेष lab भेजा जाता है। नतीजे आमतौर पर एक हफ़्ते से दस दिन में आते हैं।'),
    understandingReport:
        _t("NIPT is reported as a screening result, not a yes or no "
           "diagnosis. Here's how to read it.", 'NIPT का नतीजा screening के रूप में आता है, हाँ/ना वाले निदान के रूप में नहीं। इसे ऐसे पढ़िए।'),
    parameters: [
      ReportParameter(
        name: _same('Low risk / High risk'),
        measures:
            _t('The screening result for each condition tested (for example, '
               'trisomy 21).', 'जाँची गई हर स्थिति का screening नतीजा (जैसे trisomy 21)।'),
        whyImportant: _t('It helps decide whether a diagnostic test is worth '
                         'talking about.', 'यह बताता है कि किसी diagnostic जाँच पर बात करना ज़रूरी है या नहीं।'),
        note:
            _t('A "low risk" result is very reassuring. A "high risk" result '
               'still needs a diagnostic test (like amniocentesis) to '
               'confirm it. Screening isn\'t the final answer.', '"low risk" नतीजा बहुत भरोसा देने वाला है। "high risk" आने पर भी पुष्टि के लिए एक diagnostic जाँच (जैसे amniocentesis) चाहिए — screening आख़िरी जवाब नहीं है।'),
      ),
      ReportParameter(
        name: _same('Fetal fraction'),
        measures: _t("How much of your baby's DNA was in the sample.", 'sample में आपके शिशु का DNA कितना था।'),
        whyImportant:
            _t('There needs to be enough of it for a reliable result.', 'भरोसेमंद नतीजे के लिए fetal fraction का पर्याप्त होना ज़रूरी है।'),
        note:
            _t("If it's too low, the test may just be repeated. It doesn't "
               "mean anything is wrong.", 'बहुत कम हो तो जाँच बस दोबारा कर ली जाती है — इसका मतलब यह नहीं कि कुछ ग़लत है।'),
      ),
      ReportParameter(
        name: _t("Baby's sex (not reported in India)", 'Fetal sex (वैकल्पिक)'),
        measures: _t('Not part of an NIPT report in India.', 'जाँचा गया हो तो आपके शिशु का लिंग।'),
        whyImportant:
            _t('Labs here leave it out by law.', 'कभी-कभी चिकित्सकीय रूप से मायने रखता है (sex-linked स्थितियों के लिए)।'),
        note:
            _t("The PCPNDT Act means no lab or doctor in India tells anyone "
               "the baby's sex, so your report won't show it. It's the same "
               "for every woman, and it says nothing about your baby.", 'ध्यान दें: भारत में PCPNDT Act के तहत शिशु का लिंग बताना मना है, इसलिए यहाँ की labs इसे नहीं बतातीं।'),
      ),
    ],
    interpretation:
        _t("NIPT screens very accurately, and that still is not a "
           "diagnosis. A low-chance result is strongly reassuring for the "
           "conditions it looks at. A high-chance result has to be confirmed "
           "by a diagnostic test before anything is decided, and some of "
           "them turn out to be false alarms.", 'NIPT बहुत ऊँची सटीकता से screening करता है, फिर भी यह निदान नहीं है। जिन स्थितियों को यह देखता है, उनके लिए low-chance नतीजा गहरा भरोसा देता है। high-chance नतीजे पर कोई निष्कर्ष निकालने से पहले diagnostic जाँच से पुष्टि करनी होती है, और इनमें से कुछ झूठे अलार्म निकलते हैं।'),
    interpretPointers: [
      _t("It screens for certain conditions only. A low-chance result says "
         "nothing about anything it didn't test for.", 'यह सिर्फ़ कुछ तय स्थितियों की screening करता है। जो जाँचा ही नहीं गया, low-chance नतीजा उसके बारे में कुछ नहीं कहता।'),
      _t("Now and then there's no result, usually because there was too "
         "little of the baby's DNA in the sample. Repeating it a week or two "
         "later usually solves it.", 'कभी-कभी कोई नतीजा नहीं आता — आमतौर पर sample में शिशु का DNA कम होने से, और एक-दो हफ़्ते बाद दोबारा करने से बात बन जाती है।'),
      _t('Twins, an IVF pregnancy, a very early sample and a higher weight '
         'can each affect whether a result can be given at all.', 'जुड़वाँ, IVF से हुई गर्भावस्था, बहुत जल्दी लिया गया sample और माँ का ज़्यादा वज़न — इनमें से हर एक इस बात पर असर डाल सकता है कि नतीजा आ भी पाएगा या नहीं।'),
      _t('No decision should ever rest on NIPT alone. Confirmation comes '
         'from a diagnostic test, arranged and explained by your doctor.', 'कोई भी फ़ैसला अकेले NIPT पर नहीं टिकना चाहिए। पुष्टि diagnostic जाँच से होती है, जिसे आपके डॉक्टर करवाते और समझाते हैं।'),
    ],
  ),

  // -- Anomaly / TIFFA scan --------------------------------------------------
  TestScanInfo(
    id: 'anomaly_scan',
    shortAnswer: _same(
        "The anomaly scan at 18 to 22 weeks is the detailed look at how your baby is forming, from head to toe. It also checks the placenta and fluid. It's the most thorough scan you'll have, and it takes the longest."),
    name: _same('Anomaly Scan'),
    altName: _t('TIFFA / Level 2 / 20-Week Scan', 'TIFFA / Level 2 / 20 हफ़्ते का Scan'),
    tag: TrimesterTag.t2,
    whatItIs:
        _t("A detailed scan (Targeted Imaging for Fetal Anomalies) that "
           "looks closely at your baby's brain, face, spine, heart, chest, "
           "tummy, kidneys and limbs. It also checks the placenta, the fluid "
           "and how your baby is growing.", 'एक विस्तृत ultrasound (Targeted Imaging for Fetal Anomalies), जो आपके शिशु के दिमाग़, चेहरे, रीढ़, दिल, छाती, पेट, गुर्दों और हाथ-पैरों को क़रीब से देखता है, और साथ में placenta, पानी तथा शिशु की बढ़त भी जाँचता है।'),
    why:
        _t("It's the main check of how your baby's body is forming, and it "
           "reassures you and your doctor that the organs are developing as "
           "expected. It also records where the placenta is and your baby's "
           "growth measurements.", 'यह आपके शिशु के शारीरिक विकास की मुख्य जाँच है, और आपको तथा डॉक्टर को भरोसा देती है कि अंग उम्मीद के मुताबिक़ बन रहे हैं। इसमें placenta की स्थिति और बढ़त के माप भी दर्ज होते हैं।'),
    when:
        _t("Between 18 and 22 weeks, when the organs are big enough to see "
           "clearly and there's still room to see everything.", '18 से 22 हफ़्तों के बीच, जब अंग साफ़ दिखने लायक़ बड़े हो चुके होते हैं पर सब कुछ देखने की जगह भी बची होती है।'),
    preparation:
        _t('A moderately full bladder can help the early views. Wear '
           'comfortable, two-piece clothes. This scan takes longer than the '
           'others, so give yourself time.', 'bladder थोड़ा भरा हो तो शुरुआती views में मदद मिलती है। दो हिस्सों वाले, आरामदेह कपड़े पहनिए। यह scan बाक़ियों से लंबा चलता है, इसलिए समय लेकर जाइए।'),
    procedure:
        _t('A scan on your tummy with gel, moving the probe to look at each '
           'part in turn. It usually takes 30-45 minutes. If your baby is '
           'lying awkwardly, the sonographer may pause and ask you to move '
           'or walk about.', 'gel लगाकर पेट के ऊपर से ultrasound, जिसमें probe घुमाकर एक-एक हिस्सा देखा जाता है। आमतौर पर 30-45 मिनट लगते हैं; शिशु किसी टेढ़ी स्थिति में लेटा हो तो sonographer रुककर आपको हिलने या थोड़ा चलने को कह सकते हैं।'),
    understandingReport:
        _t("The report lists what they saw, organ by organ, plus your baby's "
           "growth measurements (biometry). Here are the measurements you'll "
           "see.", 'रिपोर्ट में एक-एक अंग की observations के साथ बढ़त के माप (biometry) होते हैं। जो माप आपको दिखेंगे, वे ये हैं।'),
    parameters: [
      ReportParameter(
        name: _same('BPD (Biparietal Diameter)'),
        measures: _t("The width of your baby's head, from side to side.", 'आपके शिशु के सिर की चौड़ाई, एक तरफ़ से दूसरी तरफ़।'),
        whyImportant: _t('One of the main measurements used to follow head '
                         'growth.', 'सिर की बढ़त पर नज़र रखने वाले मुख्य मापों में से एक।'),
        note:
            _t("Compared with the expected size for your weeks. It's read as "
               "a trend, not a single number.", 'आपके हफ़्तों के हिसाब से उम्मीद के आकार से मिलाया जाता है; इसे अकेले एक number की तरह नहीं, रुझान की तरह पढ़िए।'),
      ),
      ReportParameter(
        name: _same('HC (Head Circumference)'),
        measures: _t("The distance around your baby's head.", 'आपके शिशु के सिर की गोलाई।'),
        whyImportant: _t('Helps confirm the head is growing as expected.', 'यह पक्का करने में मदद करता है कि सिर उम्मीद के मुताबिक़ बढ़ रहा है।'),
        note: _t('Used with BPD to follow head growth and dating.', 'सिर की बढ़त और तारीख़ें आँकने के लिए BPD के साथ इस्तेमाल होता है।'),
      ),
      ReportParameter(
        name: _same('AC (Abdominal Circumference)'),
        measures: _t("The distance around your baby's tummy.", 'आपके शिशु के पेट की गोलाई।'),
        whyImportant:
            _t('The most useful single measure of how well your baby is '
               'growing and being nourished.', 'शिशु की कुल बढ़त और पोषण का सबसे काम का अकेला माप।'),
        note:
            _t('The estimated weight is worked out mainly from AC, together '
               'with the other measurements.', 'अनुमानित वज़न मुख्य रूप से AC और बाक़ी मापों को मिलाकर निकाला जाता है।'),
      ),
      ReportParameter(
        name: _same('FL (Femur Length)'),
        measures: _t("The length of your baby's thigh bone.", 'आपके शिशु की जाँघ की हड्डी की लंबाई।'),
        whyImportant: _t("Shows how your baby's long bones are growing.", 'यह आपके शिशु की लंबी हड्डियों की बढ़त दिखाता है।'),
        note: _t('Read alongside HC and AC to build up the growth picture.', 'बढ़त की पूरी तस्वीर बनाने के लिए इसे HC और AC के साथ पढ़ा जाता है।'),
      ),
      ReportParameter(
        name: _same('Placenta'),
        measures: _t('Where the placenta is attached (for example anterior, '
                     'posterior or fundal).', 'placenta कहाँ लगा है (जैसे anterior, posterior, fundal)।'),
        whyImportant:
            _t('Its position matters for planning your delivery if it sits '
               'low, near the cervix.', 'अगर यह नीचे cervix के पास बैठा हो तो delivery की योजना के लिए इसकी स्थिति मायने रखती है।'),
        note:
            _t("If it's low now, a later scan usually shows it has moved up "
               "as your womb grows. That's the common outcome.", 'अभी नीचे है तो आगे के scan में आमतौर पर दिखता है कि बच्चेदानी बढ़ने के साथ यह ऊपर खिसक गया — यही आम नतीजा है।'),
      ),
      ReportParameter(
        name: _same('Amniotic Fluid (AFI)'),
        measures: _t('How much fluid there is around your baby.', 'आपके शिशु के आसपास पानी की मात्रा।'),
        whyImportant:
            _t('The fluid cushions your baby and reflects their wellbeing '
               'and kidney function.', 'यह पानी शिशु को गद्दी देता है और उसकी सेहत तथा गुर्दों के काम को दर्शाता है।'),
        typicalRange:
            _t('An AFI of roughly 8-18 cm is usually thought of as normal in '
               'the second half of pregnancy.', 'गर्भावस्था के दूसरे आधे हिस्से में लगभग 8-18 cm का AFI आमतौर पर सामान्य माना जाता है।'),
        ifLow:
            _t('A lower level (oligohydramnios) may mean drinking more '
               'fluids and closer checks.', 'स्तर कम (oligohydramnios) हो तो ज़्यादा पानी पीने और नज़दीकी निगरानी की सलाह मिल सकती है।'),
        ifHigh:
            _t('A higher level (polyhydramnios) is often mild and just '
               'followed up.', 'स्तर ज़्यादा (polyhydramnios) हो तो अक्सर यह हल्का होता है और बस उस पर नज़र रखी जाती है।'),
      ),
    ],
    interpretation:
        _t("A normal anomaly scan means everything that can be seen at this "
           "stage looks as expected: brain, heart, spine, kidneys, limbs, "
           "and where the placenta is sitting. It can't rule everything out. "
           "Some conditions can't be seen before birth and some develop "
           "later. It's the most detailed look you get, not a complete one.", 'सामान्य anomaly scan का मतलब है कि इस पड़ाव पर जो दिख सकता है — दिमाग़, दिल, रीढ़, गुर्दे, हाथ-पैर, और placenta कहाँ बैठा है — वह सब उम्मीद के मुताबिक़ लगता है। यह हर बात को नकार नहीं सकता: कुछ स्थितियाँ जन्म से पहले दिखती ही नहीं और कुछ बाद में बनती हैं। यह सबसे विस्तृत नज़र है, पूरी नहीं।'),
    interpretPointers: [
      _t("Soft markers are small findings that often mean nothing on their "
         "own. They're noted so they can be watched.", 'soft markers छोटी-मोटी बातें हैं जिनका अकेले अक्सर कोई मतलब नहीं होता। इन्हें दर्ज इसलिए किया जाता है ताकि नज़र रखी जा सके।'),
      _t("A low-lying placenta at this scan usually moves up as your womb "
         "grows, and it's checked again later.", 'इस scan में placenta नीचे हो तो बच्चेदानी बढ़ने के साथ आमतौर पर ऊपर खिसक जाता है, और बाद में बस दोबारा देख लिया जाता है।'),
      _t("Your baby's position, your build, and where you are in the 18-22 "
         "week window can each limit what can be seen. An incomplete scan is "
         "often just booked again.", 'शिशु की स्थिति, आपका अपना शरीर, और 18-22 हफ़्ते की खिड़की में आप कहाँ हैं — इनमें से हर एक दिखने वाली चीज़ों को सीमित कर सकता है। scan अधूरा रह जाए तो अक्सर बस दोबारा तारीख़ ले ली जाती है।'),
      _t('Anything flagged goes to your doctor, who will make a plan with '
         'you. Wait for that conversation rather than searching the words.', 'जो भी बात उठाई जाती है, वह एक योजना के साथ आपके डॉक्टर तक जाती है। उन शब्दों को इंटरनेट पर खोजने के बजाय उस बातचीत का इंतज़ार कीजिए।'),
    ],
  ),

  // -- OGTT / glucose --------------------------------------------------------
  TestScanInfo(
    id: 'ogtt',
    shortAnswer: _same(
        "The sugar test checks for pregnancy diabetes, usually at 24 to 28 weeks. You drink a glucose drink and give blood samples over two hours. If it's raised, it's common, it isn't your fault, and it's usually managed with food changes."),
    name: _same('OGTT (Glucose Test)'),
    altName: _same('Glucose Tolerance Test / GTT'),
    tag: TrimesterTag.t2,
    whatItIs:
        _t('A blood test that checks how your body handles sugar in '
           'pregnancy. You drink a measured glucose drink and your blood '
           'sugar is checked at set times.', 'ख़ून की एक जाँच, जो देखती है कि गर्भावस्था में आपका शरीर शक्कर को कैसे सँभालता है। आप एक नापा हुआ glucose घोल पीती हैं और तय समय पर आपका blood sugar जाँचा जाता है।'),
    why:
        _t("It screens for gestational diabetes (raised blood sugar in "
           "pregnancy). It's common, usually has no symptoms, and is very "
           "manageable when it's found early.", 'यह gestational diabetes (गर्भावस्था में शक्कर का बढ़ना) की screening करती है, जो आम है, आमतौर पर बिना किसी लक्षण के होती है, और जल्दी पकड़ में आ जाए तो बहुत आसानी से सँभल जाती है।'),
    when:
        _t("Usually between 24 and 28 weeks. It may be done earlier if, for "
           "example, diabetes runs in your family or you've had a large baby "
           "before.", 'आमतौर पर 24 से 28 हफ़्तों के बीच। परिवार में diabetes का इतिहास या पिछली बार बड़ा शिशु जैसी बातें हों तो यह पहले भी की जा सकती है।'),
    preparation:
        _t('For the standard test you fast overnight (about 8-10 hours, '
           'water is fine). Carry something to eat for afterwards. Allow 2-3 '
           'hours, because you wait between samples.', 'सामान्य जाँच के लिए रात भर खाली पेट रहना होता है (लगभग 8-10 घंटे; पानी चलेगा)। बाद में खाने के लिए कुछ साथ रखिए। samples के बीच इंतज़ार के लिए 2-3 घंटे का समय लेकर चलिए।'),
    procedure:
        _t('A fasting blood sample is taken first. Then you drink the '
           'glucose (often 75 g), and more samples are taken at 1 hour and 2 '
           'hours. In India the single-step DIPSI method (75 g, one sample '
           'at 2 hours, no fasting) is also widely used.', 'पहले खाली पेट ख़ून का sample लिया जाता है। फिर आप glucose (अक्सर 75 g) पीती हैं और 1 घंटे तथा 2 घंटे पर और samples लिए जाते हैं। भारत में single-step DIPSI तरीक़ा (75 g, सिर्फ़ 2 घंटे वाला एक sample, बिना खाली पेट) भी ख़ूब इस्तेमाल होता है।'),
    understandingReport:
        _t("Your report shows your blood sugar at each time point against "
           "the lab's cut-offs. Here's what they mean.", 'आपकी रिपोर्ट हर समय-बिंदु की blood sugar value lab के cut-off के साथ दिखाती है। उनका मतलब यह है।'),
    parameters: [
      ReportParameter(
        name: _same('Fasting glucose'),
        measures: _t('Your blood sugar before the glucose drink.', 'glucose पीने से पहले आपका blood sugar।'),
        whyImportant: _t('A raised fasting value is one way gestational '
                         'diabetes is picked up.', 'fasting value का बढ़ा होना GDM पकड़ में आने के तरीक़ों में से एक है।'),
        typicalRange:
            _t('Below about 92 mg/dL is commonly thought of as normal for '
               'the fasting value (cut-offs vary by method).', 'fasting value के लिए आमतौर पर लगभग 92 mg/dL से नीचे सामान्य माना जाता है (cut-off हर protocol में अलग होते हैं)।'),
        ifHigh: _t('A raised value may point to gestational diabetes.', 'value बढ़ी हो तो यह gestational diabetes की ओर इशारा कर सकती है।'),
      ),
      ReportParameter(
        name: _t('1-hour value', '1 घंटे की value'),
        measures: _t('Your blood sugar one hour after the drink.', 'पीने के एक घंटे बाद आपका blood sugar।'),
        whyImportant: _t('Shows the highest rise in sugar.', 'दिखाता है कि शक्कर सबसे ऊपर कहाँ तक गई।'),
        typicalRange: _t('Below about 180 mg/dL is often thought of as '
                         'normal.', 'अक्सर लगभग 180 mg/dL से नीचे सामान्य माना जाता है।'),
        ifHigh: _t('A raised value counts towards a diagnosis of gestational '
                   'diabetes.', 'value बढ़ी हो तो यह GDM के निदान में जुड़ती है।'),
      ),
      ReportParameter(
        name: _t('2-hour value', '2 घंटे की value'),
        measures: _t('Your blood sugar two hours after the drink.', 'पीने के दो घंटे बाद आपका blood sugar।'),
        whyImportant: _t('Shows how well your body has brought the sugar '
                         'back down.', 'दिखाता है कि आपके शरीर ने शक्कर को कितनी अच्छी तरह वापस नीचे लाया।'),
        typicalRange:
            _t('Below about 153 mg/dL (or 140 mg/dL by DIPSI) is often '
               'thought of as normal.', 'अक्सर लगभग 153 mg/dL (या DIPSI से 140 mg/dL) से नीचे सामान्य माना जाता है।'),
        ifHigh:
            _t("A raised value points to gestational diabetes. It's "
               "manageable with food changes, checking your sugar and "
               "sometimes medicine.", 'value बढ़ी हो तो यह gestational diabetes की ओर इशारा करती है — जो खानपान, निगरानी और कभी-कभी दवा से सँभल जाती है।'),
      ),
      ReportParameter(
        name: _same('HbA1c'),
        measures: _t('Your average blood sugar over the past few weeks.', 'पिछले कुछ हफ़्तों का आपका औसत blood sugar।'),
        whyImportant: _t('Sometimes added to give a fuller picture.', 'पूरी तस्वीर के लिए कभी-कभी इसे भी जोड़ लिया जाता है।'),
        note: _t("It isn't the main test for gestational diabetes, but it's "
                 "useful background.", 'GDM की मुख्य जाँच यह नहीं है, पर पृष्ठभूमि समझने में काम आती है।'),
      ),
    ],
    interpretation:
        _t("A normal result means your body is handling the sugar as "
           "expected. A raised value means gestational diabetes. It's "
           "common, it comes from the pregnancy and not from anything you "
           "did, and most of the time it's managed with food changes and "
           "checking your sugar alone.", 'सामान्य नतीजे का मतलब है कि आपका शरीर शक्कर के इस भार को उम्मीद के मुताबिक़ सँभाल रहा है। value बढ़ी हो तो यह gestational diabetes है — जो आम है, गर्भावस्था की वजह से है न कि आपके किए किसी काम की, और ज़्यादातर मामलों में सिर्फ़ खानपान और निगरानी से सँभल जाती है।'),
    interpretPointers: [
      _t('Only one of the timed values needs to be above the cut-off for the '
         'test to be positive.', 'जाँच positive होने के लिए तय समय वाली values में से सिर्फ़ एक का सीमा से ऊपर होना काफ़ी है।'),
      _t('Not fasting properly, being unwell on the day, or vomiting the '
         'drink will spoil the test, and it will need repeating.', 'ठीक से खाली पेट न रहना, उस दिन तबीयत ख़राब होना, या घोल पीकर उल्टी हो जाना — इनसे जाँच बेकार हो जाती है और दोबारा करनी पड़ती है।'),
      _t('A positive result leads to a food plan and checking your sugar at '
         'home first. Only a few women need insulin.', 'नतीजा positive आए तो पहले एक diet plan और घर पर blood sugar की निगरानी शुरू होती है। बहुत कम महिलाओं को insulin की ज़रूरत पड़ती है।'),
      _t('It usually goes away after birth, but it does raise your risk '
         'later on, so your doctor will usually arrange a follow-up test a '
         'few months after delivery.', 'जन्म के बाद यह आमतौर पर चली जाती है, पर आगे का ख़तरा बढ़ा देती है, इसलिए डॉक्टर आमतौर पर प्रसव के कुछ महीने बाद एक follow-up जाँच करवाते हैं।'),
    ],
  ),

  // -- Growth scan -----------------------------------------------------------
  TestScanInfo(
    id: 'growth_scan',
    shortAnswer: _same(
        "A growth scan measures your baby's size and the fluid around them in the last three months. The weight is an estimate. The trend across scans matters more than any one number."),
    name: _same('Growth Scan'),
    altName: _t('Third-Trimester Ultrasound', 'तीसरी तिमाही का Ultrasound'),
    tag: TrimesterTag.t3,
    whatItIs:
        _t("A scan, usually from around 28 weeks and only when your doctor "
           "advises it. It measures your baby's size, the fluid around them, "
           "which way they're lying, and the blood flow in the cord and "
           "placenta (Doppler).", 'एक ultrasound, आमतौर पर लगभग 28 हफ़्तों से और तभी जब सलाह दी जाए, जो आपके शिशु का आकार, उसके आसपास का पानी, उसकी स्थिति, और गर्भनाल तथा placenta में ख़ून के बहाव (Doppler) को नापता है।'),
    why:
        _t("It checks your baby is growing steadily and getting enough "
           "nourishment as your due date gets closer. It's useful if there's "
           "any question about growth, fluid or blood pressure.", 'यह देखता है कि due date पास आते हुए आपका शिशु लगातार बढ़ रहा है और उसे पर्याप्त पोषण मिल रहा है — बढ़त, पानी या blood pressure को लेकर कोई सवाल हो तो यह काम आता है।'),
    when:
        _t('Usually from 28 weeks on, repeated every 2-4 weeks if your '
           'doctor is following growth closely.', 'आमतौर पर 28 हफ़्तों से आगे, और अगर डॉक्टर बढ़त पर क़रीब से नज़र रख रहे हों तो हर 2-4 हफ़्ते में दोबारा।'),
    preparation:
        _t('No special preparation and no fasting. Wear comfortable, '
           'two-piece clothes.', 'न कोई ख़ास तैयारी, न fasting। आरामदेह, दो हिस्सों वाले कपड़े पहनिए।'),
    procedure:
        _t("A scan on your tummy. The measurements are plotted on a growth "
           "chart so your baby's trend can be seen over time. It takes about "
           "20-30 minutes.", 'पेट के ऊपर से सामान्य ultrasound। माप एक growth chart पर लगाए जाते हैं ताकि समय के साथ आपके शिशु का रुझान दिख सके। लगभग 20-30 मिनट लगते हैं।'),
    understandingReport:
        _t("The report is mostly about size, fluid and blood flow. Here's "
           "what to look at.", 'रिपोर्ट में मुख्य रूप से आकार, पानी और ख़ून के बहाव की बात होती है। देखने लायक़ बातें ये हैं।'),
    parameters: [
      ReportParameter(
        name: _same('EFW (Estimated Fetal Weight)'),
        measures: _t("An estimate of your baby's weight from the "
                     "measurements.", 'मापों से निकला आपके शिशु के वज़न का अनुमान।'),
        whyImportant: _t('The number most people look at first.', 'वही number जिस पर सबकी नज़र सबसे पहले जाती है।'),
        note:
            _t("It's an estimate, not an exact weight. It can be off by "
               "around 10-15%. The trend across scans matters more than one "
               "value.", 'यह अनुमान है, पक्का आँकड़ा नहीं — इसमें लगभग 10-15% का फ़र्क़ आ सकता है। किसी एक value से ज़्यादा मायने scans के रुझान का है।'),
      ),
      ReportParameter(
        name: _t('Centile (e.g. 50th)', 'Centile (जैसे 50th)'),
        measures: _t('Where your baby sits compared with other babies at the '
                     'same number of weeks.', 'उतने ही हफ़्तों के बाक़ी शिशुओं के मुक़ाबले आपका शिशु कहाँ है।'),
        whyImportant: _t('Helps judge whether growth is on track.', 'यह आँकने में मदद करता है कि बढ़त सही राह पर है या नहीं।'),
        note:
            _t('Your baby following their own curve over time matters more '
               'than one centile. A small baby who is growing steadily is '
               'often just naturally small.', 'किसी एक centile से ज़्यादा मायने इसका है कि समय के साथ आपका शिशु अपनी ही curve पर चल रहा है। लगातार बढ़ता हुआ छोटा शिशु अक्सर बस स्वभाव से ही छोटा होता है।'),
      ),
      ReportParameter(
        name: _same('AFI / Liquor'),
        measures: _t('How much fluid there is around your baby.', 'आपके शिशु के आसपास पानी की मात्रा।'),
        whyImportant: _t("Reflects your baby's wellbeing and kidney function.", 'यह सेहत और गुर्दों के काम को दर्शाता है।'),
        typicalRange: _t('An AFI of roughly 8-18 cm is usually thought of as '
                         'normal.', 'लगभग 8-18 cm का AFI आमतौर पर सामान्य माना जाता है।'),
        ifLow: _t('A lower level may mean drinking more fluids and closer '
                  'checks.', 'स्तर कम हो तो ज़्यादा पानी पीने और नज़दीकी निगरानी की सलाह मिल सकती है।'),
        ifHigh: _t('A higher level is often mild and just followed up.', 'स्तर ज़्यादा हो तो अक्सर यह हल्का होता है और बस उस पर नज़र रखी जाती है।'),
      ),
      ReportParameter(
        name: _same('Doppler (PI / RI)'),
        measures: _t('Blood-flow readings in the cord and a few key blood '
                     'vessels.', 'गर्भनाल और मुख्य नसों में ख़ून के बहाव की readings।'),
        whyImportant:
            _t('Normal flow is reassuring about the placenta and how well '
               'your baby is being nourished.', 'बहाव सामान्य हो तो placenta और शिशु के पोषण को लेकर भरोसा मिलता है।'),
        note:
            _t('Reported as numbers called indices (PI/RI). Your doctor '
               'reads them against the expected range for your weeks.', 'ये indices (PI/RI) के रूप में बताए जाते हैं; डॉक्टर इन्हें आपके हफ़्तों की उम्मीद वाली range से मिलाकर पढ़ते हैं।'),
      ),
      ReportParameter(
        name: _same('Presentation'),
        measures: _t('Which way up your baby is lying (head down, called '
                     'cephalic, or breech).', 'आपका शिशु किस ओर लेटा है (cephalic / breech)।'),
        whyImportant: _t('It matters for planning your delivery closer to '
                         'your due date.', 'पूरे महीनों के पास आते-आते delivery की योजना के लिए यह मायने रखता है।'),
        note:
            _t('Many babies are still turning at this stage and settle head '
               'down (cephalic) by the end.', 'इस पड़ाव पर कई शिशु अब भी करवट बदल रहे होते हैं और पूरे महीनों तक सिर नीचे (cephalic) हो जाते हैं।'),
      ),
    ],
    interpretation:
        _t("A growth scan places your baby's estimated weight on a centile "
           "chart. Anywhere between the 10th and 90th centile is the "
           "expected range, and a small baby isn't automatically a worry. "
           "Some babies are just small. The trend across scans matters more "
           "than any single number.", 'growth scan शिशु के अनुमानित वज़न को centile chart पर रखता है। 10th और 90th centile के बीच कहीं भी होना उम्मीद वाली range है, और छोटा शिशु अपने आप में चिंता की बात नहीं — कुछ शिशु बस छोटे होते हैं। किसी एक number से कहीं ज़्यादा मायने scans के रुझान का है।'),
    interpretPointers: [
      _t("Estimated fetal weight has a real margin of error, commonly around "
         "10-15%. It's an estimate, not a weighing.", 'अनुमानित वज़न में सचमुच फ़र्क़ की गुंजाइश रहती है, आमतौर पर लगभग 10-15%। यह अनुमान है, तराज़ू पर तौलना नहीं।'),
      _t('A drop across centiles between two scans matters more than one '
         'measurement on its own.', 'दो scans के बीच centile का गिरना अकेले किसी एक माप से ज़्यादा मायने रखता है।'),
      _t("Your baby's position, lower fluid, and later weeks all make "
         "measuring less precise.", 'शिशु की स्थिति, पानी का कम होना, और गर्भावस्था के आख़िरी हफ़्ते — ये सब नापने की सटीकता घटा देते हैं।'),
      _t('If growth is a concern, your doctor will usually watch more '
         'closely, with more scans and Dopplers, rather than decide anything '
         'straight away.', 'बढ़त को लेकर चिंता हो तो डॉक्टर आमतौर पर तुरंत कोई फ़ैसला लेने के बजाय और क़रीब से निगरानी रखते हैं — और scans तथा Doppler।'),
    ],
  ),

  // -- Doppler ---------------------------------------------------------------
  TestScanInfo(
    id: 'doppler',
    shortAnswer: _same(
        "A Doppler checks the blood flow from the placenta to your baby. It adds a few minutes to a growth scan and is painless. Normal flow is reassuring, even when a baby measures small."),
    name: _same('Doppler Scan'),
    altName: _same('Colour Doppler / Umbilical Artery Doppler'),
    tag: TrimesterTag.t3,
    whatItIs:
        _t("A special scan setting that measures the speed and pattern of "
           "blood flow through the umbilical cord and your baby's key blood "
           "vessels.", 'ultrasound की एक ख़ास setting, जो गर्भनाल और आपके शिशु की मुख्य नसों में ख़ून के बहाव की रफ़्तार और तरीक़ा नापती है।'),
    why:
        _t("It checks the placenta is sending enough blood and nourishment "
           "to your baby. It's especially useful when a baby is measuring "
           "small or when your blood pressure is being watched.", 'यह जाँचता है कि placenta ख़ून और पोषण ठीक से पहुँचा रहा है। शिशु का नाप छोटा आ रहा हो या blood pressure पर नज़र रखी जा रही हो, तब यह ख़ासतौर पर काम आता है।'),
    when:
        _t('Usually in the last three months, often as part of a growth '
           'scan, and repeated as your doctor advises.', 'आमतौर पर तीसरी तिमाही में, अक्सर growth scan के ही हिस्से के तौर पर, और डॉक्टर की सलाह के मुताबिक़ दोबारा।'),
    preparation:
        _t("No preparation and no fasting. It's done as part of an ordinary "
           "scan, or just like one.", 'न कोई तैयारी, न fasting। यह सामान्य ultrasound के हिस्से के तौर पर, या बिल्कुल उसी तरह, किया जाता है।'),
    procedure:
        _t("The same probe as a regular scan, switched to Doppler mode. It's "
           "painless and adds only a few minutes.", 'वही probe जो सामान्य scan में होता है, बस Doppler mode पर। इसमें दर्द नहीं होता और scan में कुछ ही मिनट जुड़ते हैं।'),
    understandingReport:
        _t("Doppler is reported as flow numbers (indices). Here's what they "
           "show.", 'Doppler का नतीजा बहाव के indices में आता है। वे क्या दिखाते हैं, यह रहा।'),
    parameters: [
      ReportParameter(
        name: _same('Umbilical artery PI / RI'),
        measures: _t('How much resistance there is to blood flow in the cord.', 'गर्भनाल में ख़ून के बहाव के सामने आने वाली रुकावट।'),
        whyImportant: _t('A key sign of how well the placenta is working.', 'यह बताने वाला अहम संकेत कि placenta कितना अच्छा काम कर रहा है।'),
        note:
            _t('Read against the expected range for your weeks. Normal flow '
               'is reassuring.', 'आपके हफ़्तों की उम्मीद वाली range से मिलाकर पढ़ा जाता है; बहाव सामान्य हो तो भरोसा मिलता है।'),
      ),
      ReportParameter(
        name: _same('MCA (Middle Cerebral Artery)'),
        measures: _t("Blood flow to your baby's brain.", 'आपके शिशु के दिमाग़ तक ख़ून का बहाव।'),
        whyImportant:
            _t('Helps show how your baby is coping, together with the cord '
               'reading.', 'गर्भनाल की reading के साथ मिलकर यह आँकने में मदद करता है कि आपका शिशु कैसे सँभाल रहा है।'),
        note: _t('Read alongside the umbilical artery result.', 'इसे umbilical artery के नतीजे के साथ पढ़ा जाता है।'),
      ),
      ReportParameter(
        name: _same('End-diastolic flow'),
        measures: _t('Whether blood keeps flowing forward between heartbeats.', 'दो धड़कनों के बीच ख़ून आगे बहता रहता है या नहीं।'),
        whyImportant: _t('Forward flow is a reassuring sign.', 'आगे की ओर बहाव बना रहना भरोसा देने वाला संकेत है।'),
        note:
            _t("If it's reduced or absent, your doctor will watch more "
               "closely and guide the plan. It's a sign to watch, and it's "
               "acted on carefully.", 'यह कम हो या न हो, तो डॉक्टर और क़रीब से निगरानी रखेंगे और आगे की योजना बताएँगे — यह नज़र रखने का संकेत है, और इस पर सावधानी से क़दम उठाए जाते हैं।'),
      ),
    ],
    interpretation:
        _t("Doppler checks blood flow, not size: how well the placenta is "
           "feeding your baby. Normal flow is reassuring even when a baby "
           "measures small, which is why it's done alongside a growth scan. "
           "Abnormal flow is the finding that changes what happens next.", 'Doppler आकार नहीं, ख़ून का बहाव देखता है: placenta शिशु तक कितना अच्छा पहुँचा रहा है। शिशु का नाप छोटा हो तब भी बहाव सामान्य होना भरोसा देता है — इसीलिए इसे growth scan के साथ किया जाता है। बहाव असामान्य आना ही वह बात है जो आगे का रास्ता बदलती है।'),
    interpretPointers: [
      _t("A small baby with normal Dopplers is usually a baby who is small "
         "by nature. They're watched, not acted on.", 'छोटा शिशु और Doppler सामान्य — यह आमतौर पर स्वभाव से ही छोटा शिशु होता है; उस पर नज़र रखी जाती है, कोई क़दम नहीं उठाया जाता।'),
      _t("Abnormal or reversed flow means closer checks, and sometimes an "
         "earlier delivery. It's the finding a team acts on quickly.", 'बहाव असामान्य या उल्टा हो तो निगरानी और क़रीब से होती है, और कभी-कभी प्रसव पहले करना पड़ता है। यही वह बात है जिस पर टीम तेज़ी से क़दम उठाती है।'),
      _t('Your baby moving or breathing during the scan, and their position, '
         'can each affect the reading.', 'scan के दौरान शिशु का हिलना या साँस लेना, और उसकी स्थिति — इनमें से हर एक reading पर असर डाल सकता है।'),
      _t('Dopplers are read as a set, along with growth and fluid. None of '
         'the three decides anything by itself.', 'Doppler को बढ़त और पानी के साथ एक सेट की तरह पढ़ा जाता है। इन तीनों में से कोई एक अपने आप में कुछ तय नहीं करता।'),
    ],
  ),

  // -- GBS -------------------------------------------------------------------
  TestScanInfo(
    id: 'gbs',
    shortAnswer: _same(
        "This swab, around 35 to 37 weeks, checks for a common bacteria many healthy women carry. If it's positive, you're given antibiotics during labour to protect your baby. It isn't an infection in you."),
    name: _same('Group B Strep'),
    altName: _same('GBS Swab'),
    tag: TrimesterTag.t3,
    whatItIs:
        _t('A simple swab test for Group B Streptococcus, a common bacteria '
           'that many healthy women carry without any symptoms.', 'Group B Streptococcus के लिए एक आसान swab जाँच — यह एक आम बैक्टीरिया है, जो कई स्वस्थ महिलाओं में बिना किसी लक्षण के प्राकृतिक रूप से रहता है।'),
    why:
        _t("If you're carrying GBS near your due date, antibiotics during "
           "labour greatly reduce the small chance of passing it to your "
           "baby. Carrying it is common, and it isn't an infection in you.", 'अगर due date के आसपास आपमें GBS है, तो प्रसव के दौरान antibiotics इसके शिशु तक पहुँचने की छोटी सी आशंका को काफ़ी घटा देते हैं। इसका होना आम बात है और यह आपमें कोई infection नहीं है।'),
    when: _t('Usually around 35-37 weeks, close to your due date.', 'आमतौर पर लगभग 35-37 हफ़्तों पर, आपकी due date के क़रीब।'),
    preparation:
        _t("No preparation needed. Don't use vaginal creams or douches just "
           "before, because they can affect the sample.", 'कोई तैयारी नहीं चाहिए। ठीक पहले vaginal creams या douche इस्तेमाल मत कीजिए, इनसे sample पर असर पड़ सकता है।'),
    procedure:
        _t("A gentle swab of the lower vagina and the back passage (rectum). "
           "It's quick and painless, and you can often take the swab "
           "yourself if you'd rather.", 'vagina के निचले हिस्से और मलद्वार से हल्का सा swab — जल्दी हो जाता है और दर्द नहीं होता, और चाहें तो अक्सर आप ख़ुद भी swab ले सकती हैं।'),
    understandingReport:
        _t("The result is either positive or negative. Here's what each "
           "means.", 'नतीजा बस positive या negative आता है। दोनों का मतलब यह है।'),
    parameters: [
      ReportParameter(
        name: _same('Positive / Carrier'),
        measures: _t('GBS was found on this swab.', 'इस swab में GBS मिला।'),
        whyImportant: _t('It tells your team to plan a simple precaution '
                         'during labour.', 'यह आपकी टीम को बताता है कि delivery पर एक आसान सी एहतियात की योजना बनानी है।'),
        note:
            _t("It's common and isn't an infection in you. You'd be offered "
               "antibiotics during labour as a precaution.", 'यह आम है और आपमें कोई infection नहीं — एहतियातन प्रसव के दौरान आपको antibiotics दिए जाएँगे।'),
      ),
      ReportParameter(
        name: _same('Negative'),
        measures: _t("GBS wasn't found on this swab.", 'इस swab में GBS नहीं मिला।'),
        whyImportant: _t('No GBS precaution is needed from this result.', 'इस नतीजे के आधार पर GBS को लेकर कोई एहतियात ज़रूरी नहीं।'),
        note: _t('Reassuring. Your usual care carries on.', 'भरोसा देने वाली बात; सामान्य देखभाल जारी रहती है।'),
      ),
    ],
    interpretation:
        _t("This isn't a test for illness. Group B Strep is a bacteria many "
           "healthy women carry with no symptoms at all, and a positive "
           "result means antibiotics during labour to protect your baby at "
           "birth. Positive isn't an infection, and it isn't something you "
           "did.", 'यह बीमारी की जाँच नहीं है। Group B Strep एक बैक्टीरिया है जो कई स्वस्थ महिलाओं में बिना किसी लक्षण के रहता है, और positive नतीजे का मतलब बस इतना है कि जन्म के समय शिशु की सुरक्षा के लिए प्रसव के दौरान antibiotics दिए जाएँगे। positive होना infection नहीं है, और यह आपके किए किसी काम की वजह से भी नहीं है।'),
    interpretPointers: [
      _t('Around one in five women carry it. Carrying it changes the plan '
         'for labour and nothing else.', 'लगभग पाँच में से एक महिला में यह होता है। इसका होना सिर्फ़ प्रसव की योजना बदलता है, और कुछ नहीं।'),
      _t('A positive result means antibiotics through a drip once labour '
         'starts, which works very well to stop it passing to your baby.', 'positive नतीजे का मतलब है कि प्रसव शुरू होते ही drip से antibiotics दिए जाएँगे, जो इसे शिशु तक पहुँचने से रोकने में बहुत असरदार हैं।'),
      _t('It comes and goes, so a swab close to your due date is the useful '
         'one. An early result can be out of date by the time you give birth.', 'यह बैक्टीरिया आता-जाता रहता है, इसलिए due date के क़रीब लिया गया swab ही काम का होता है — बहुत पहले का नतीजा delivery तक पुराना पड़ सकता है।'),
      _t("Recent antibiotics can give a false negative, so tell your doctor "
         "if you've taken any.", 'हाल में लिए गए antibiotics से नतीजा झूठा negative आ सकता है, इसलिए अगर आपने कोई लिया हो तो डॉक्टर को बता दीजिए।'),
    ],
  ),
];

// ===========================================================================
//  2. FINDINGS & CONDITIONS
// ===========================================================================

final List<FindingInfo> kFindings = [
  // -- Low-lying placenta ----------------------------------------------------
  FindingInfo(
    id: 'low_lying_placenta',
    name: _t('Low-Lying Placenta', 'नीचे लगा हुआ Placenta'),
    tag: TrimesterTag.t2,
    whatIsIt:
        _t("Your placenta is sitting lower in your womb than usual, close to "
           "the cervix (the opening of the womb). It's often noted on the "
           "anomaly scan.", 'placenta बच्चेदानी में आम से नीचे बैठा है, cervix (बच्चेदानी के मुँह) के पास। यह अक्सर anomaly scan में दिखता है।'),
    whyHappens:
        _t("It's just where the placenta happened to attach early on. As the "
           "pregnancy goes on and your womb grows upward, the placenta "
           "usually moves higher and away from the cervix on its own.", 'यह बस इस बात पर है कि शुरुआत में placenta कहाँ जाकर टिका। गर्भावस्था आगे बढ़ने और बच्चेदानी के ऊपर की ओर बढ़ने के साथ placenta आमतौर पर ख़ुद ही ऊपर, cervix से दूर खिसक जाता है।'),
    symptoms: [
      _t("Usually none. It's a scan finding, not something you feel.", 'आमतौर पर कोई नहीं — यह scan में दिखने वाली बात है, महसूस होने वाली नहीं।'),
      _t('Sometimes painless bleeding. Always tell your doctor about any '
         'bleeding.', 'कभी-कभी बिना दर्द के ख़ून आना; ख़ून आए तो हमेशा अपने डॉक्टर को बताइए।'),
    ],
    diagnosis:
        _t('Seen on a scan, most often the 18-22 week anomaly scan. A later '
           'scan checks whether it has moved up.', 'ultrasound में दिखता है, सबसे ज़्यादा 18-22 हफ़्ते के anomaly scan में। आगे चलकर एक follow-up scan देखता है कि यह ऊपर खिसका या नहीं।'),
    implications:
        _t('In the large majority of women the placenta moves up and it '
           'makes no difference to delivery. It only changes the delivery '
           'plan if it stays low, near or over the cervix, later on '
           '(placenta previa).', 'ज़्यादातर मामलों में placenta ऊपर खिसक जाता है और delivery पर कोई असर नहीं पड़ता। सिर्फ़ तभी delivery की योजना बदलती है, जब यह आगे भी cervix के पास या उस पर बना रहे (placenta previa)।'),
    management:
        _t('A follow-up scan (often around 32 weeks) to check the position '
           'again. If there has been any bleeding, your doctor may advise '
           'avoiding heavy lifting or sex, and will plan your delivery from '
           'the later scan.', 'स्थिति दोबारा देखने के लिए एक follow-up scan (अक्सर लगभग 32 हफ़्तों पर)। अगर कभी ख़ून आया हो तो डॉक्टर भारी सामान उठाने या संबंध बनाने से मना कर सकते हैं, और बाद वाले scan के आधार पर delivery की योजना बनाएँगे।'),
    whenToContact: [
      _t("Any bleeding from the vagina, even if it's painless.", 'vagina से कैसा भी ख़ून आना, चाहे दर्द न हो।'),
      _t('Cramping or tightening with bleeding.', 'ख़ून के साथ मरोड़ या पेट का कसना।'),
      _t('Any sudden gush of fluid.', 'अचानक पानी का बह जाना।'),
    ],
    faqs: [
      Faq(_t('Will it move up?', 'क्या यह ऊपर खिसक जाएगा?'),
          _t("Most low-lying placentas do move up as the womb grows. That's "
             "the usual, expected outcome.", 'नीचे लगे ज़्यादातर placenta बच्चेदानी बढ़ने के साथ ऊपर खिसक जाते हैं। यही आम और अपेक्षित नतीजा है।')),
      Faq(_t("Does it mean I'll need a caesarean?", 'क्या इसका मतलब मुझे C-section करवाना पड़ेगा?'),
          _t("Not usually. Your doctor would only talk about a planned "
             "caesarean if it's still low over the cervix at the later scan.", 'आमतौर पर नहीं। सिर्फ़ तभी, जब बाद वाले scan में यह cervix पर ही नीचे बना रहे, आपके डॉक्टर पहले से तय C-section पर बात करेंगे।')),
      Faq(_t('Should I be on bed rest?', 'क्या मुझे bed rest पर रहना चाहिए?'),
          _t("Complete bed rest isn't usually advised. Your doctor will give "
             "you advice for your situation, especially if there has been "
             "any bleeding.", 'पूरा bed rest आमतौर पर नहीं कहा जाता। आपके डॉक्टर आपके हिसाब से सलाह देंगे, ख़ासकर अगर कभी ख़ून आया हो।')),
    ],
    aliases: [_same('placenta'), _t('low placenta', 'नीचे लगा placenta'), _t('placenta position', 'placenta की जगह')],
  ),

  // -- Placenta previa -------------------------------------------------------
  FindingInfo(
    id: 'placenta_previa',
    name: _same('Placenta Previa'),
    tag: TrimesterTag.t3,
    whatIsIt:
        _t("Your placenta is partly or fully covering the cervix in the "
           "later part of pregnancy. It's a low-lying placenta that has "
           "stayed low instead of moving up.", 'गर्भावस्था के आख़िरी हिस्से में placenta cervix को कुछ हद तक या पूरी तरह ढके हुए है। असल में यह नीचे लगा placenta ही है, जो ऊपर खिसकने के बजाय नीचे ही रह गया।'),
    whyHappens:
        _t("The placenta attached low and didn't move up as the womb grew. "
           "It's more likely after a previous caesarean, with twins, or with "
           "certain shapes of the womb.", 'placenta नीचे जाकर टिका और बच्चेदानी के बढ़ने पर ऊपर नहीं खिसका। पहले C-section हो चुका हो, जुड़वाँ गर्भ हो, या बच्चेदानी की बनावट कुछ ख़ास हो तो इसकी आशंका बढ़ जाती है।'),
    symptoms: [
      _t('Painless, bright-red bleeding from the vagina in the second half '
         'of pregnancy is the classic sign.', 'गर्भावस्था के दूसरे आधे हिस्से में vagina से बिना दर्द के चमकीला लाल ख़ून आना इसकी पहचान है।'),
      _t("Often there are no symptoms until a bleed, and sometimes it's only "
         "found on a scan.", 'अक्सर ख़ून आने तक कोई लक्षण नहीं; कभी-कभी पता सिर्फ़ scan में ही चलता है।'),
    ],
    diagnosis:
        _t("Confirmed on a scan, usually an internal (transvaginal) one. "
           "It's safe and gives the clearest view of where the placenta sits "
           "against the cervix.", 'ultrasound से पुष्टि होती है, आमतौर पर transvaginal scan से, जो सुरक्षित है और cervix के साथ placenta की स्थिति सबसे साफ़ दिखाता है।'),
    implications:
        _t("It needs a planned delivery, usually by caesarean, to avoid "
           "bleeding during labour. With today's monitoring and planning, "
           "it's managed safely.", 'इसमें प्रसव पहले से तय करना पड़ता है, आमतौर पर C-section से, ताकि प्रसव के दौरान ख़ून बहने से बचा जा सके। आज की निगरानी और योजना के साथ इसे सुरक्षित तरीक़े से सँभाला जाता है।'),
    management:
        _t("Closer checks, avoiding sex and heavy activity, and a planned "
           "caesarean (often before labour starts). If there's significant "
           "bleeding, you may be advised to stay in hospital to be watched.", 'क़रीब से निगरानी, संबंध और भारी काम से परहेज़, और पहले से तय C-section (अक्सर प्रसव शुरू होने से पहले)। ज़्यादा ख़ून आए तो निगरानी के लिए अस्पताल में भर्ती होने की सलाह दी जा सकती है।'),
    whenToContact: [
      _t('Any bleeding from the vagina. Call your doctor or go to hospital '
         'promptly.', 'vagina से कैसा भी ख़ून आना — तुरंत अपने डॉक्टर से संपर्क कीजिए या अस्पताल जाइए।'),
      _t('Contractions or tightening.', 'दर्द उठना या पेट का कसना।'),
      _t('Your baby moving less than usual.', 'शिशु की हलचल कम होना।'),
    ],
    faqs: [
      Faq(_t('Is my baby in danger?', 'क्या मेरा शिशु ख़तरे में है?'),
          _t('With planning and monitoring, most pregnancies with previa '
             'reach a safe delivery. The main aim is to avoid heavy '
             'bleeding, which is why a planned caesarean is used.', 'योजना और निगरानी के साथ previa वाली ज़्यादातर गर्भावस्थाएँ सुरक्षित प्रसव तक पहुँचती हैं। मुख्य मक़सद ज़्यादा ख़ून बहने से बचना है, इसीलिए पहले से तय C-section किया जाता है।')),
      Faq(_t('Can I still have a normal delivery?', 'क्या मैं फिर भी सामान्य प्रसव कर सकती हूँ?'),
          _t("If the placenta covers the cervix, a caesarean is the safe "
             "way. If it's close but not covering it, your doctor will "
             "advise you from its exact position.", 'अगर placenta cervix को ढके हुए है, तो सुरक्षित रास्ता C-section ही है। अगर यह सिर्फ़ पास है पर ढक नहीं रहा, तो डॉक्टर सटीक स्थिति देखकर सलाह देंगे।')),
      Faq(_t('What can I do at home?', 'घर पर मैं क्या कर सकती हूँ?'),
          _t('Rest as advised, avoid sex and heavy lifting, keep your scan '
             'appointments, and tell your doctor about any bleeding straight '
             'away.', 'सलाह के मुताबिक़ आराम कीजिए, संबंध और भारी सामान उठाने से बचिए, अपने scan की तारीख़ें मत छोड़िए, और ख़ून आए तो तुरंत बताइए।')),
    ],
    aliases: [_same('previa'), _t('placenta covering cervix', 'cervix को ढकता placenta')],
  ),

  // -- Anaemia ---------------------------------------------------------------
  FindingInfo(
    id: 'anaemia',
    name: _t('Anaemia', 'ख़ून की कमी (Anaemia)'),
    altName: _t('Low Haemoglobin', 'Haemoglobin की कमी'),
    tag: TrimesterTag.anytime,
    whatIsIt:
        _t("Your blood has fewer healthy red cells or less haemoglobin than "
           "it should. In pregnancy it's most often from low iron, and it's "
           "very common.", 'आपके ख़ून में स्वस्थ लाल कण या haemoglobin ज़रूरत से कम हैं। गर्भावस्था में यह सबसे ज़्यादा iron की कमी से होता है, और बहुत आम है।'),
    whyHappens:
        _t('Your body makes a lot more blood in pregnancy for your baby, '
           'which can dilute and use up your iron. A diet low in iron, '
           'pregnancies close together, or heavy periods before pregnancy '
           'add to it.', 'शिशु को सँभालने के लिए गर्भावस्था में आपका शरीर कहीं ज़्यादा ख़ून बनाता है, जिससे iron का भंडार पतला भी पड़ता है और ख़र्च भी होता है। iron कम वाला खानपान, दो गर्भों के बीच कम अंतर, या गर्भ से पहले ज़्यादा रक्तस्राव वाले period इसे और बढ़ा देते हैं।'),
    symptoms: [
      _t('Tiredness and low energy.', 'थकान और ऊर्जा की कमी।'),
      _t('Looking pale, or pale inner eyelids or nails.', 'चेहरे का पीला पड़ना; पलकों के अंदर या नाखूनों का फीका दिखना।'),
      _t('Feeling breathless with a little effort.', 'थोड़े से काम में साँस फूलना।'),
      _t('Dizziness or a fast heartbeat.', 'चक्कर आना या दिल का तेज़ धड़कना।'),
      _t('Mild anaemia often causes no clear symptoms at all.', 'हल्की कमी में अक्सर कोई साफ़ लक्षण होता ही नहीं।'),
    ],
    diagnosis:
        _t('A routine blood test (haemoglobin), usually with ferritin (your '
           'iron stores) and other red cell tests to confirm low iron.', 'ख़ून की एक सामान्य जाँच (haemoglobin), जिसके साथ आमतौर पर ferritin (iron का भंडार) और लाल कणों के कुछ और indices देखकर iron की कमी पक्की की जाती है।'),
    implications:
        _t("Mild anaemia is very common and usually gets better quickly with "
           "treatment. If it isn't treated, more severe anaemia can add to "
           "tiredness and, rarely, affect the pregnancy. That's why it's "
           "checked and corrected early.", 'हल्की कमी बहुत आम है और इलाज से जल्दी ठीक हो जाती है। अनदेखी रह जाए तो ज़्यादा कमी थकान बढ़ा सकती है और कभी-कभार गर्भावस्था पर असर डाल सकती है — इसीलिए इसे जल्दी जाँचा और ठीक किया जाता है।'),
    management:
        _t('Iron-rich foods (green leafy vegetables, dates, jaggery, dals, '
           'and eggs and meat if you eat them), an iron tablet, and vitamin '
           'C (like lemon or other citrus) to help your body take it in. '
           'Your levels are checked again after a few weeks. Very low levels '
           'may need iron through a drip.', 'iron वाला खाना (हरी पत्तेदार सब्ज़ियाँ, खजूर, गुड़, दालें, और मांसाहार लेने वालों के लिए अंडे और मीट), एक iron supplement, और अवशोषण बढ़ाने के लिए vitamin C (जैसे नींबू या खट्टे फल)। कुछ हफ़्तों बाद स्तर दोबारा जाँचा जाता है। बहुत कम होने पर iron नस के ज़रिए देना पड़ सकता है।'),
    whenToContact: [
      _t('Severe tiredness, fainting, or feeling breathless at rest.', 'बहुत ज़्यादा थकान, बेहोशी, या आराम करते हुए भी साँस फूलना।'),
      _t('A fast or pounding heartbeat.', 'दिल का तेज़ या ज़ोर-ज़ोर से धड़कना।'),
      _t('If iron tablets upset your stomach. Your doctor can change the '
         'type or dose.', 'iron की गोलियों से पेट ख़राब हो — डॉक्टर उनका प्रकार या dose बदल सकते हैं।'),
    ],
    faqs: [
      Faq(_t('Will it harm my baby?', 'क्या इससे मेरे शिशु को नुक़सान होगा?'),
          _t("Mild anaemia that's treated rarely causes problems. Your body "
             "puts your baby's iron needs first, which is part of why yours "
             "can run low.", 'हल्की कमी का इलाज हो जाए तो शायद ही कोई दिक़्क़त होती है। आपका शरीर पहले शिशु की iron की ज़रूरत पूरी करता है — यही एक वजह है कि आपका अपना स्तर गिर जाता है।')),
      Faq(_t('The iron tablets make me constipated. What can I do?', 'iron की गोलियों से मुझे क़ब्ज़ हो जाती है — मैं क्या करूँ?'),
          _t('This is common. More water, fibre and fruit help, and your '
             'doctor can switch you to a gentler iron tablet.', 'यह आम बात है। ज़्यादा पानी, रेशेदार खाना और फल मदद करते हैं, और डॉक्टर iron का कोई हल्का रूप भी दे सकते हैं।')),
      Faq(_t('Can I fix it with food alone?', 'क्या सिर्फ़ खाने से यह ठीक हो सकती है?'),
          _t('Food helps, but you need a lot of iron in pregnancy, so a '
             'tablet is usually needed alongside iron-rich food.', 'खानपान मदद करता है, पर गर्भावस्था में iron की ज़रूरत ज़्यादा होती है, इसलिए iron वाले खाने के साथ आमतौर पर supplement भी लेना पड़ता है।')),
    ],
    aliases: [_same('anemia'), _t('low hb', 'कम hb'), _t('low haemoglobin', 'haemoglobin की कमी'), _t('iron deficiency', 'iron की कमी')],
  ),

  // -- Breech ----------------------------------------------------------------
  FindingInfo(
    id: 'breech',
    name: _t('Breech Presentation', 'Breech स्थिति'),
    altName: _t('Breech Baby', 'Breech शिशु'),
    tag: TrimesterTag.t3,
    whatIsIt:
        _t('Your baby is lying bottom down or feet down instead of head '
           'down. Many babies are breech earlier on and turn head down '
           'before birth.', 'आपका शिशु सिर नीचे होने के बजाय कूल्हा या पैर नीचे किए लेटा है। कई शिशु शुरू में breech होते हैं और जन्म से पहले सिर नीचे कर लेते हैं।'),
    whyHappens:
        _t("Often there's no particular reason. It's just how your baby is "
           "lying. It can be more likely with extra or low fluid, a low "
           "placenta, twins, or the shape of the womb.", 'अक्सर कोई ख़ास वजह नहीं होती — बस शिशु ऐसे ही लेटा है। पानी ज़्यादा या कम हो, placenta नीचे हो, जुड़वाँ हों, या बच्चेदानी की बनावट अलग हो तो इसकी आशंका बढ़ जाती है।'),
    symptoms: [
      _t("Usually none. It's a position found when your doctor examines you "
         "or on a scan.", 'आमतौर पर कोई नहीं — यह जाँच या scan में पता चलने वाली स्थिति है।'),
      _t('You may feel kicks lower down, and a firm, round head up near your '
         'ribs.', 'आपको लातें नीचे की ओर महसूस हो सकती हैं और पसलियों के पास ऊपर एक सख़्त, गोल सिर।'),
    ],
    diagnosis:
        _t('Your doctor feels it by examining your tummy, and a scan '
           'confirms the exact position.', 'डॉक्टर आपके पेट को छूकर पहचानते हैं और ultrasound से पुष्टि होती है, जो सटीक स्थिति दिखाता है।'),
    implications:
        _t("Before about 36 weeks it often doesn't matter, because there's "
           "still time to turn. If your baby stays breech near your due "
           "date, your doctor will talk with you about options for a safe "
           "birth.", 'लगभग 36 हफ़्तों से पहले इससे अक्सर फ़र्क़ नहीं पड़ता, क्योंकि करवट बदलने का समय बाक़ी होता है। पूरे महीनों के क़रीब भी शिशु breech ही रहे, तो डॉक्टर सुरक्षित जन्म के विकल्पों पर बात करेंगे।'),
    management:
        _t('Waiting and watching, as many babies turn on their own. Near '
           'your due date, options may include ECV (a doctor gently turning '
           'the baby from outside), a planned caesarean, or in some cases a '
           'vaginal breech birth with an experienced team. Your doctor will '
           'guide you to the safest choice.', 'इंतज़ार और नज़र, क्योंकि कई शिशु ख़ुद ही करवट बदल लेते हैं। पूरे महीनों के पास विकल्पों में ECV (डॉक्टर बाहर से शिशु को धीरे-धीरे घुमाते हैं), पहले से तय C-section, या चुनिंदा मामलों में अनुभवी टीम के साथ breech में सामान्य प्रसव शामिल हो सकते हैं। आपके डॉक्टर आपके लिए सबसे सुरक्षित रास्ता बताएँगे।'),
    whenToContact: [
      _t('Your waters break while your baby is breech. Go to hospital, '
         'because the cord needs checking.', 'शिशु breech हो और आपका पानी टूट जाए — अस्पताल जाइए, क्योंकि गर्भनाल को जँचवाना ज़रूरी है।'),
      _t('Strong, regular contractions before your planned date.', 'तय तारीख़ से पहले तेज़, नियमित दर्द उठना।'),
      _t('Your baby moving less than usual.', 'शिशु की हलचल कम होना।'),
    ],
    faqs: [
      Faq(_t('Is there still time for my baby to turn?', 'क्या शिशु के करवट बदलने के लिए अभी समय है?'),
          _t('Yes. Many babies turn head down by 36-37 weeks. The chance '
             'gets smaller as your due date comes closer, but turning still '
             'happens.', 'हाँ — कई शिशु 36-37 हफ़्तों तक सिर नीचे कर लेते हैं। पूरे महीने पास आते-आते यह कम होता जाता है, पर तब भी होता है।')),
      Faq(_t("Are the exercises I've read about safe?", 'जिन exercises के बारे में मैंने पढ़ा है, क्या वे सुरक्षित हैं?'),
          _t('Some gentle position exercises are popular. Check with your '
             'doctor before trying anything, and never force a position.', 'कुछ हल्की positional तरकीबें चलन में हैं; कुछ भी आज़माने से पहले अपने डॉक्टर से पूछ लीजिए, और किसी स्थिति के लिए ज़ोर कभी मत लगाइए।')),
      Faq(_t('Does breech always mean a caesarean?', 'क्या breech का मतलब हमेशा C-section होता है?'),
          _t("No. ECV can turn many babies, and a vaginal breech birth is "
             "possible in the right situation. Your doctor will talk through "
             "what's safest for you.", 'नहीं। ECV से कई शिशु घूम जाते हैं, और सही हालात में breech में सामान्य प्रसव भी हो सकता है। आपके डॉक्टर बताएँगे कि आपके लिए सबसे सुरक्षित क्या है।')),
    ],
    aliases: [_t('breech baby', 'breech शिशु'), _t('baby position', 'शिशु की स्थिति'), _same('footling'), _t('bottom down', 'उल्टा शिशु')],
  ),

  // -- Low AFI ---------------------------------------------------------------
  FindingInfo(
    id: 'low_afi',
    name: _t('Low Amniotic Fluid', 'Amniotic fluid की कमी'),
    altName: _same('Oligohydramnios'),
    tag: TrimesterTag.t3,
    whatIsIt:
        _t("The fluid around your baby is on the lower side. Fluid levels "
           "can change from one scan to the next, so it's read with how your "
           "baby is growing and moving.", 'आपके शिशु के आसपास पानी की मात्रा कुछ कम है। पानी का स्तर एक scan से दूसरे scan में बदल सकता है, इसलिए इसे शिशु की बढ़त और हलचल के साथ मिलाकर देखा जाता है।'),
    whyHappens:
        _t("Sometimes there's no clear cause. It can be linked to going past "
           "your due date, the placenta working a little less well, a fluid "
           "leak, or how much you're drinking.", 'कभी-कभी कोई साफ़ वजह नहीं होती। यह due date निकल जाने, placenta के थोड़ा कम असरदार काम करने, पानी के रिसने, या आपके अपने पानी पीने से जुड़ा हो सकता है।'),
    symptoms: [
      _t("Usually none. It's a scan finding.", 'आमतौर पर कोई नहीं — यह scan में दिखने वाली बात है।'),
      _t('Your bump may measure small, or you may notice fluid leaking if '
         'your waters have broken.', 'आपको अपना पेट नाप में छोटा लग सकता है, या पानी टूट चुका हो तो रिसाव महसूस हो सकता है।'),
    ],
    diagnosis:
        _t('Measured on a scan as the AFI (amniotic fluid index) or the '
           'deepest pocket of fluid, and confirmed by checking again.', 'ultrasound में AFI (amniotic fluid index) या पानी की सबसे गहरी जेब नापकर, और दोबारा जाँचकर पुष्टि की जाती है।'),
    implications:
        _t('A small drop is often managed with drinking more and closer '
           'checks. Lower levels, especially near your due date, may lead '
           'your doctor to plan an earlier delivery to keep your baby safe.', 'थोड़ी कमी अक्सर पानी पीने और नज़दीकी निगरानी से सँभल जाती है। स्तर ज़्यादा कम हो, ख़ासकर पूरे महीनों के क़रीब, तो डॉक्टर शिशु की सुरक्षा के लिए प्रसव पहले करवाने की योजना बना सकते हैं।'),
    management:
        _t("Drinking plenty of water, more frequent scans, and checks on "
           "your baby's movements and heartbeat. Depending on your weeks and "
           "how your baby is doing, your doctor may advise delivery.", 'ख़ूब पानी पीना, ज़्यादा बार scan, और आपके शिशु की हलचल तथा धड़कन पर नज़र। आपके हफ़्तों और शिशु की हालत को देखते हुए डॉक्टर प्रसव की सलाह दे सकते हैं।'),
    whenToContact: [
      _t('A gush or steady trickle of fluid (your waters may have broken).', 'पानी का एकदम बह जाना या लगातार रिसना (आपका पानी टूट चुका हो सकता है)।'),
      _t('Your baby moving less or differently.', 'शिशु की हलचल कम होना या बदल जाना।'),
      _t('Any bleeding or strong contractions.', 'कैसा भी ख़ून आना या तेज़ दर्द उठना।'),
    ],
    faqs: [
      Faq(_t('Will drinking more water help?', 'क्या ज़्यादा पानी पीने से मदद मिलेगी?'),
          _t('Drinking well can help and is usually advised. Your doctor '
             'will still check the level again to be sure.', 'शरीर में पानी बनाए रखना मदद करता है और आमतौर पर यही सलाह दी जाती है। फिर भी डॉक्टर पक्का करने के लिए स्तर दोबारा जाँचेंगे।')),
      Faq(_t('Does low fluid mean something is wrong with my baby?', 'क्या पानी कम होने का मतलब मेरे शिशु में कुछ गड़बड़ है?'),
          _t("Not necessarily. Often the baby is well and just needs closer "
             "checks. The trend and your baby's movements matter most.", 'ज़रूरी नहीं। अक्सर शिशु ठीक होता है और बस नज़दीकी निगरानी चाहिए; सबसे ज़्यादा मायने रुझान और आपके शिशु की हलचल का है।')),
      Faq(_t('How often will it be checked?', 'यह कितनी बार जाँचा जाएगा?'),
          _t('That depends on the level and your weeks. It may be every few '
             'days to weekly, and your doctor will tell you the plan.', 'यह स्तर और आपके हफ़्तों पर निर्भर है — कुछ दिनों में एक बार से लेकर हफ़्ते में एक बार तक हो सकता है, और डॉक्टर आपको योजना बता देंगे।')),
    ],
    aliases: [_t('low fluid', 'पानी की कमी'), _same('oligohydramnios'), _t('afi low', 'afi कम'), _t('low water', 'गर्भ का पानी कम'), _same('liquor')],
  ),

  // -- Hypothyroidism --------------------------------------------------------
  FindingInfo(
    id: 'hypothyroid',
    name: _same('Hypothyroidism'),
    altName: _t('Underactive Thyroid', 'कम सक्रिय Thyroid'),
    tag: TrimesterTag.anytime,
    whatIsIt:
        _t("Your thyroid gland is making a little less thyroid hormone than "
           "your body needs. It's common in pregnancy and shows up as a "
           "raised TSH on your blood test.", 'आपकी thyroid ग्रंथि शरीर की ज़रूरत से थोड़ा कम thyroid hormone बना रही है। गर्भावस्था में यह आम है और ख़ून की जाँच में TSH बढ़ा हुआ दिखता है।'),
    whyHappens:
        _t("Often the thyroid can't keep up with the extra demand of "
           "pregnancy. Sometimes it's from an autoimmune cause (Hashimoto's) "
           "or low iodine. Many women first find out about it in pregnancy.", 'अक्सर thyroid गर्भावस्था की बढ़ी हुई माँग के साथ चल ही नहीं पाती, कभी किसी autoimmune वजह (Hashimoto\'s) या iodine की कमी से। कई महिलाओं को इसका पता गर्भावस्था में ही चलता है।'),
    symptoms: [
      _t('Tiredness and feeling cold.', 'थकान और ठंड लगना।'),
      _t('Weight gain or puffiness.', 'वज़न बढ़ना या शरीर पर सूजन।'),
      _t('Dry skin, constipation.', 'रूखी त्वचा, क़ब्ज़।'),
      _t('Mild cases often have no clear symptoms and are found on the blood '
         'test.', 'हल्के मामलों में अक्सर कोई साफ़ लक्षण नहीं होता और पता ख़ून की जाँच में चलता है।'),
    ],
    diagnosis:
        _t('A blood test showing a raised TSH (sometimes with T4 checked '
           'too). Pregnancy uses its own, tighter target ranges, especially '
           'in the first three months.', 'ख़ून की जाँच में TSH का बढ़ा होना (कभी-कभी T4 भी देखा जाता है)। गर्भावस्था की अपनी, ज़्यादा कसी हुई target ranges होती हैं, ख़ासकर पहली तिमाही में।'),
    implications:
        _t("Hypothyroidism that's well treated has little effect on "
           "pregnancy. Because thyroid hormone supports your baby's early "
           "brain development, doctors treat it promptly and keep your "
           "levels in the pregnancy range.", 'इलाज ठीक चल रहा हो तो hypothyroidism का गर्भावस्था पर ख़ास असर नहीं पड़ता। चूँकि thyroid hormone शिशु के शुरुआती दिमाग़ी विकास को सँभालता है, डॉक्टर इसका इलाज बिना देर किए करते हैं और स्तर गर्भावस्था वाले target में रखते हैं।'),
    management:
        _t('A small daily tablet of thyroid hormone (levothyroxine), taken '
           'on an empty stomach, with the dose adjusted as pregnancy goes '
           'on. TSH is checked regularly, often every 4-6 weeks early on.', 'thyroid hormone (levothyroxine) की रोज़ की एक छोटी tablet, ख़ाली पेट लेनी होती है, और गर्भावस्था बढ़ने के साथ dose बदलती रहती है। TSH नियमित रूप से दोबारा जाँचा जाता है, शुरुआत में अक्सर हर 4-6 हफ़्ते में।'),
    whenToContact: [
      _t('If you miss doses or run out of tablets.', 'अगर dose छूट जाए या गोलियाँ ख़त्म हो जाएँ।'),
      _t('Strong new symptoms, such as a racing heart (the dose may need '
         'looking at).', 'कोई नया तेज़ लक्षण, जैसे दिल का बहुत तेज़ धड़कना (हो सकता है dose देखनी पड़े)।'),
      _t('Before stopping or changing the dose yourself. Always check first.', 'dose ख़ुद से बंद या कम-ज़्यादा करने से पहले — हमेशा पहले पूछ लीजिए।'),
    ],
    faqs: [
      Faq(_t('Is the tablet safe for my baby?', 'क्या यह tablet मेरे शिशु के लिए सुरक्षित है?'),
          _t("Yes. Levothyroxine replaces the hormone your body should be "
             "making, and it's considered safe and important in pregnancy.", 'हाँ। Levothyroxine वही hormone देती है जो आपका शरीर बना रहा होता, और गर्भावस्था में इसे सुरक्षित और ज़रूरी माना जाता है।')),
      Faq(_t('Will I need it forever?', 'क्या यह मुझे हमेशा लेनी पड़ेगी?'),
          _t('Sometimes. Some women need it only in pregnancy, and others '
             'carry on after. Your doctor will check again after delivery.', 'कभी-कभी। कुछ महिलाओं को सिर्फ़ गर्भावस्था में इसकी ज़रूरत होती है; कुछ बाद में भी लेती रहती हैं। प्रसव के बाद डॉक्टर दोबारा जाँचेंगे।')),
      Faq(_t('Why do I have to take it on an empty stomach?', 'इसे ख़ाली पेट लेना क्यों ज़रूरी है?'),
          _t('Food, iron and calcium stop your body taking it in well. Take '
             'it first thing, and keep iron and calcium tablets a few hours '
             'apart from it.', 'खाना, iron और calcium इसका अवशोषण घटा देते हैं। इसे सुबह सबसे पहले लीजिए, और iron/calcium को कुछ घंटों के फ़ासले पर रखिए।')),
    ],
    aliases: [_same('thyroid'), _same('hypothyroid'), _t('high tsh', 'tsh ज़्यादा'), _t('underactive thyroid', 'कम सक्रिय thyroid')],
  ),

  // -- Hyperthyroidism -------------------------------------------------------
  FindingInfo(
    id: 'hyperthyroid',
    name: _same('Hyperthyroidism'),
    altName: _t('Overactive Thyroid', 'ज़्यादा सक्रिय Thyroid'),
    tag: TrimesterTag.anytime,
    whatIsIt:
        _t("Your thyroid gland is making more thyroid hormone than your body "
           "needs. It's less common than an underactive thyroid and shows up "
           "as a low TSH.", 'आपकी thyroid ग्रंथि शरीर की ज़रूरत से ज़्यादा thyroid hormone बना रही है। यह कम सक्रिय thyroid के मुक़ाबले कम आम है और जाँच में TSH कम दिखता है।'),
    whyHappens:
        _t("Most often it has an autoimmune cause (Graves' disease). Early "
           "pregnancy hormones can also raise thyroid activity a little for "
           "a while, sometimes with severe morning sickness.", 'सबसे ज़्यादा किसी autoimmune वजह से (Graves\' disease)। शुरुआती गर्भावस्था के hormones भी thyroid की सक्रियता को हल्का और कुछ समय के लिए बढ़ा सकते हैं, कभी-कभी तेज़ उल्टियों के साथ।'),
    symptoms: [
      _t('A fast or pounding heartbeat.', 'दिल का तेज़ या ज़ोर-ज़ोर से धड़कना।'),
      _t('Feeling hot, sweaty or anxious.', 'गर्मी लगना, पसीना आना या बेचैनी।'),
      _t("Losing weight even though you're eating well, or shaky hands.", 'अच्छा खाने के बावजूद वज़न घटना; हाथों का काँपना।'),
      _t('Severe nausea and vomiting (in the early, short-lived form).', 'तेज़ मिचली और उल्टियाँ (शुरुआती, कुछ समय वाले रूप में)।'),
    ],
    diagnosis:
        _t('A blood test showing a low TSH with raised thyroid hormones '
           '(T4/T3). Your doctor can tell true hyperthyroidism apart from '
           'the mild, short-lived rise of early pregnancy.', 'ख़ून की जाँच में TSH कम और thyroid hormones (T4/T3) बढ़े हुए। डॉक्टर असली hyperthyroidism को शुरुआती गर्भावस्था की हल्की, कुछ समय की बढ़त से अलग पहचानते हैं।'),
    implications:
        _t("Mild, short-lived cases often settle by the middle of pregnancy. "
           "True hyperthyroidism is treated to keep you and your baby well, "
           "and it's managed successfully with the right medicine and checks.", 'हल्के, कुछ समय वाले मामले अक्सर बीच की गर्भावस्था तक ख़ुद शांत हो जाते हैं। असली hyperthyroidism का इलाज किया जाता है ताकि आप और आपका शिशु दोनों ठीक रहें, और सही दवा तथा निगरानी से यह अच्छी तरह सँभल जाता है।'),
    management:
        _t('Anti-thyroid medicine chosen carefully for pregnancy, at the '
           'lowest dose that works, with regular blood tests. A hormone '
           'specialist (endocrinologist) is often involved.', 'गर्भावस्था के लिए सोच-समझकर चुनी गई anti-thyroid दवा, सबसे कम असरदार dose में, और साथ में नियमित ख़ून की जाँचें। अक्सर एक विशेषज्ञ (endocrinologist) भी साथ जुड़ते हैं।'),
    whenToContact: [
      _t('A very fast heartbeat, fever, or feeling very unwell.', 'दिल का बहुत तेज़ धड़कना, बुख़ार, या तबीयत का बहुत ख़राब लगना।'),
      _t("Vomiting that won't stop, and not being able to keep fluids down.", 'लगातार उल्टियाँ और पानी तक पेट में न टिकना।'),
      _t('Before changing or stopping medicine yourself.', 'दवा ख़ुद से बदलने या बंद करने से पहले।'),
    ],
    faqs: [
      Faq(_t('Will it settle on its own?', 'क्या यह अपने आप ठीक हो जाएगा?'),
          _t("The mild early-pregnancy kind often does by the middle of "
             "pregnancy. Graves' disease needs treatment, and the treatment "
             "works well.", 'शुरुआती गर्भावस्था वाला हल्का रूप अक्सर बीच की गर्भावस्था तक ख़ुद शांत हो जाता है। Graves\' disease का इलाज ज़रूरी है, जो अच्छा काम करता है।')),
      Faq(_t('Is the medicine safe?', 'क्या दवा सुरक्षित है?'),
          _t("The medicines used are chosen because they're safe in "
             "pregnancy, at the lowest dose that works, with regular checks.", 'जो दवाएँ दी जाती हैं, वे ख़ासतौर पर गर्भावस्था में सुरक्षा देखकर चुनी जाती हैं, सबसे कम असरदार dose में, और निगरानी के साथ।')),
      Faq(_t('Do I need a specialist?', 'क्या मुझे किसी विशेषज्ञ की ज़रूरत है?'),
          _t('Often, yes. Your obstetrician usually works with an '
             'endocrinologist to fine-tune your treatment.', 'अक्सर हाँ — इलाज को ठीक-ठीक बिठाने के लिए आपकी obstetrician आमतौर पर endocrinologist के साथ मिलकर काम करती हैं।')),
    ],
    aliases: [_same('thyroid'), _same('hyperthyroid'), _t('low tsh', 'tsh कम'), _t('overactive thyroid', 'ज़्यादा सक्रिय thyroid'), _same('graves')],
  ),

  // -- Gestational diabetes --------------------------------------------------
  FindingInfo(
    id: 'gdm',
    name: _same('Gestational Diabetes'),
    altName: _same('GDM'),
    tag: TrimesterTag.t2,
    whatIsIt:
        _t('Raised blood sugar that starts during pregnancy. Your body is '
           'finding it harder to keep sugar in the normal range, usually '
           'because pregnancy hormones make insulin work less well.', 'गर्भावस्था के दौरान शक्कर का बढ़ जाना। आपके शरीर को शक्कर सामान्य दायरे में रखने में कुछ दिक़्क़त हो रही है, आमतौर पर इसलिए कि गर्भावस्था के hormones insulin का काम कम असरदार बना देते हैं।'),
    whyHappens:
        _t("Hormones from the placenta make insulin work less well (insulin "
           "resistance). If your body can't make enough extra insulin to "
           "keep up, your blood sugar rises. It's more likely if diabetes "
           "runs in your family, with a higher weight, with PCOS, or if "
           "you've had a large baby before.", 'placenta से आने वाले गर्भावस्था के hormones insulin के काम को कम कर देते हैं (insulin resistance)। अगर आपका शरीर उतना ज़्यादा insulin नहीं बना पाता, तो शक्कर बढ़ जाती है। परिवार में इतिहास, ज़्यादा वज़न, PCOS, या पिछली बार बड़ा शिशु हो तो आशंका बढ़ जाती है।'),
    symptoms: [
      _t('Usually none, which is why the glucose test is routine.', 'आमतौर पर कोई नहीं — इसीलिए glucose की जाँच सबकी होती है।'),
      _t('Sometimes feeling more thirsty or passing more urine.', 'कभी-कभी ज़्यादा प्यास लगना या बार-बार पेशाब आना।'),
    ],
    diagnosis:
        _t('The glucose test (OGTT/GTT), usually at 24-28 weeks, which '
           'compares your blood sugar values with pregnancy cut-offs.', 'glucose की जाँच (OGTT/GTT), आमतौर पर 24-28 हफ़्तों पर, जिसमें आपकी blood sugar values गर्भावस्था के cut-off से मिलाई जाती हैं।'),
    implications:
        _t("Gestational diabetes that's well controlled usually means a "
           "healthy pregnancy and baby. Uncontrolled high sugar can make a "
           "baby grow large or affect the baby's sugar after birth. That's "
           "why control matters, and why it works so well.", 'GDM क़ाबू में रहे तो गर्भावस्था और शिशु आमतौर पर स्वस्थ रहते हैं। शक्कर बेक़ाबू रहे तो शिशु बड़ा हो सकता है या जन्म के बाद उसकी शक्कर पर असर पड़ सकता है — इसीलिए क़ाबू रखना मायने रखता है, और इसीलिए यह इतना अच्छा काम करता है।'),
    management:
        _t('Balanced meals (steady carbohydrates, more fibre, sensible '
           'portions), gentle activity like a walk after meals, and checking '
           'your sugar at home. Some women also need tablets or insulin. It '
           'most often goes away after birth, with a test later to confirm.', 'संतुलित खानपान (एक-सा carbohydrate, ज़्यादा रेशा, नपी हुई मात्रा), खाने के बाद टहलने जैसी हल्की गतिविधि, और घर पर blood sugar की निगरानी। कुछ माँओं को गोलियाँ या insulin भी चाहिए होता है। यह ज़्यादातर जन्म के बाद चली जाती है, और बाद में एक जाँच से पुष्टि कर ली जाती है।'),
    whenToContact: [
      _t('Sugar readings staying above your target even with food changes.', 'खानपान सँभालने पर भी शक्कर की readings आपके target से ऊपर बनी रहें।'),
      _t("Very high or very low readings, or feeling shaky or sweaty "
         "(possible low sugar if you're on medicine).", 'बहुत ज़्यादा या बहुत कम readings, या कँपकँपी/पसीना महसूस होना (दवा पर शक्कर कम हो सकती है)।'),
      _t('Your baby moving less than usual.', 'शिशु की हलचल कम होना।'),
    ],
    faqs: [
      Faq(_t('Did I cause this?', 'क्या यह मेरी वजह से हुआ?'),
          _t('No. Gestational diabetes comes mainly from pregnancy hormones '
             'and how your body responds, not from anything you did wrong.', 'नहीं। GDM मुख्य रूप से गर्भावस्था के hormones और आपके शरीर की प्रतिक्रिया से होता है, आपके किसी ग़लत काम से नहीं।')),
      Faq(_t('Will it go away after birth?', 'क्या यह जन्म के बाद चला जाएगा?'),
          _t('For most women, yes. A test after delivery confirms it, and it '
             'tells you about a higher future risk to keep an eye on.', 'ज़्यादातर महिलाओं में हाँ। प्रसव के बाद एक follow-up जाँच इसकी पुष्टि करती है, और आगे के लिए थोड़ा बढ़ा हुआ ख़तरा दर्ज कर देती है, जिस पर नज़र रखनी होती है।')),
      Faq(_t('Will I definitely need insulin?', 'क्या मुझे insulin ज़रूर लेना पड़ेगा?'),
          _t("Many women manage with food changes and activity alone. "
             "Medicine is added only if it's needed, and it's safe in "
             "pregnancy.", 'कई महिलाएँ सिर्फ़ खानपान और गतिविधि से सँभाल लेती हैं। दवा तभी जोड़ी जाती है जब ज़रूरत हो, और यह गर्भावस्था में सुरक्षित है।')),
    ],
    aliases: [_same('gdm'), _t('gestational diabetes', 'गर्भावस्था की diabetes'), _same('sugar'), _t('high sugar', 'शक्कर ज़्यादा'), _same('diabetes')],
  ),

  // -- Pre-eclampsia ---------------------------------------------------------
  FindingInfo(
    id: 'preeclampsia',
    name: _same('Pre-eclampsia'),
    altName: _t('High Blood Pressure in Pregnancy', 'गर्भावस्था में बढ़ा हुआ Blood Pressure'),
    tag: TrimesterTag.t3,
    whatIsIt:
        _t('A pregnancy condition with raised blood pressure, usually after '
           '20 weeks, often with protein in the urine or other signs that '
           'your body needs closer care.', 'गर्भावस्था की एक स्थिति जिसमें blood pressure बढ़ जाता है, आमतौर पर 20 हफ़्तों के बाद, और अक्सर पेशाब में protein या ऐसे और संकेत मिलते हैं जो बताते हैं कि आपके शरीर पर ज़्यादा ध्यान चाहिए।'),
    whyHappens:
        _t("It's thought to start with how the placenta's blood vessels "
           "formed early in pregnancy, which later affects your blood "
           "pressure and organs. It's more likely in a first pregnancy, if "
           "it runs in your family, with twins, or if you already have high "
           "blood pressure or diabetes.", 'माना जाता है कि इसकी शुरुआत इस बात से होती है कि गर्भावस्था के शुरू में placenta की नसें कैसे बनीं, जिसका असर आगे चलकर आपके blood pressure और अंगों पर पड़ता है। पहली गर्भावस्था, परिवार में इतिहास, जुड़वाँ, या पहले से बढ़ा blood pressure या diabetes हो तो आशंका ज़्यादा होती है।'),
    symptoms: [
      _t('Often none early on, which is why your blood pressure and urine '
         'are checked at every visit.', 'शुरू में अक्सर कोई नहीं — इसीलिए हर विज़िट पर blood pressure और पेशाब जाँचे जाते हैं।'),
      _t("A bad headache that won't go away.", 'तेज़ सिरदर्द जो जाता ही न हो।'),
      _t('Changes in your vision, like blurring or flashing lights.', 'नज़र में बदलाव — धुंधलापन या रोशनी के झटके दिखना।'),
      _t('Pain just below your ribs, on the right side.', 'पसलियों के ठीक नीचे, दाईं ओर दर्द।'),
      _t('Sudden swelling of your face, hands or feet.', 'चेहरे, हाथों या पैरों में अचानक सूजन।'),
    ],
    diagnosis:
        _t("Raised blood pressure readings plus protein in the urine and/or "
           "blood tests, at your routine antenatal checks. That's why those "
           "simple checks are done every time.", 'आपकी सामान्य antenatal जाँचों में blood pressure का बढ़ा आना, और साथ में पेशाब में protein और/या ख़ून की जाँचें। इन्हीं छोटी-छोटी जाँचों के लिए हर बार यह सब किया जाता है।'),
    implications:
        _t("When it's closely watched and managed, most women and babies do "
           "well. It's taken seriously because, untreated, it can affect "
           "your organs and your baby's growth. So the aim is to find it "
           "early and choose the right time for delivery, which is the "
           "treatment that ends it.", 'क़रीब से निगरानी और इलाज के साथ ज़्यादातर माँएँ और शिशु ठीक रहते हैं। इसे गंभीरता से इसलिए लिया जाता है कि बिना इलाज यह आपके अंगों और शिशु की बढ़त पर असर डाल सकती है — इसलिए मक़सद है जल्दी पकड़ना और प्रसव का सही समय चुनना, जो इसका पक्का इलाज है।'),
    management:
        _t("More frequent checks, blood pressure medicine if needed, blood "
           "tests, and checks on your baby's growth. Your doctor decides the "
           "timing and plan for a safe delivery, and rest and follow-up are "
           "part of it.", 'ज़्यादा बार जाँच, ज़रूरत हो तो blood pressure की दवा, ख़ून की जाँचें, और आपके शिशु की बढ़त पर नज़र। सुरक्षित प्रसव का समय और योजना आपके डॉक्टर तय करते हैं; आराम और follow-up भी इसी का हिस्सा हैं।'),
    whenToContact: [
      _t("A severe headache, or one that won't go away.", 'तेज़ सिरदर्द, या ऐसा सिरदर्द जो जाता न हो।'),
      _t('Changes in your vision, like blurring, spots or flashing lights.', 'नज़र में बदलाव — धुंधलापन, धब्बे या रोशनी के झटके।'),
      _t('Pain in your upper tummy, below the ribs.', 'पसलियों के नीचे, ऊपरी पेट में दर्द।'),
      _t('Sudden swelling of your face or hands, or your baby moving less '
         'than usual. Contact your doctor urgently.', 'चेहरे/हाथों में अचानक सूजन, या शिशु की हलचल कम होना — तुरंत अपने डॉक्टर से संपर्क कीजिए।'),
    ],
    faqs: [
      Faq(_t('Can I prevent it?', 'क्या मैं इसे रोक सकती हूँ?'),
          _t("If you're at higher risk, low-dose aspirin is sometimes "
             "advised from early pregnancy. Keeping every antenatal "
             "appointment is the best way to catch it early.", 'अगर आपका ख़तरा ज़्यादा हो तो कभी-कभी शुरुआती गर्भावस्था से कम dose की aspirin की सलाह दी जाती है। हर antenatal appointment पर जाना ही इसे जल्दी पकड़ने की असली कुंजी है।')),
      Faq(_t('Will I need an early delivery?', 'क्या मेरा प्रसव जल्दी करना पड़ेगा?'),
          _t('Sometimes. Delivery is the treatment that ends it, and your '
             'doctor weighs the timing carefully for you and your baby.', 'कभी-कभी। प्रसव ही इसका पक्का इलाज है, और आपके डॉक्टर आपके तथा शिशु के लिए समय बहुत सोच-समझकर तय करते हैं।')),
      Faq(_t('Does it go away after birth?', 'क्या यह जन्म के बाद चली जाती है?'),
          _t('It usually settles after delivery, though your blood pressure '
             'is watched for a while afterwards.', 'आमतौर पर प्रसव के बाद यह ठीक हो जाती है, हालाँकि blood pressure पर कुछ समय तक नज़र रखी जाती है।')),
    ],
    aliases: [_same('preeclampsia'), _t('pre eclampsia', 'गर्भावस्था का high bp'), _t('high bp', 'bp ज़्यादा'), _same('pih'), _t('protein in urine', 'पेशाब में protein'), _same('blood pressure')],
  ),

  // -- IUGR ------------------------------------------------------------------
  FindingInfo(
    id: 'iugr',
    name: _t('Growth Restriction', 'बढ़त में रुकावट'),
    altName: _same('IUGR / FGR'),
    tag: TrimesterTag.t3,
    whatIsIt:
        _t("Your baby is growing more slowly than expected and measuring "
           "smaller than they should for the number of weeks. It isn't a "
           "baby who is small by nature, but one whose growth has slowed.", 'आपका शिशु उम्मीद से धीमा बढ़ रहा है और हफ़्तों के हिसाब से नाप में छोटा है — यह स्वभाव से छोटे शिशु की बात नहीं, बल्कि उस शिशु की है जिसकी बढ़त धीमी पड़ गई है।'),
    whyHappens:
        _t("Most often the placenta isn't sending quite enough nourishment "
           "and oxygen. It can also be linked to high blood pressure, some "
           "infections, smoking, or (less often) a problem with the baby.", 'सबसे ज़्यादा तब, जब placenta पर्याप्त पोषण और oxygen नहीं पहुँचा पा रहा हो। यह बढ़े हुए blood pressure, कुछ infections, धूम्रपान, या (कम बार) शिशु से जुड़ी किसी बात से भी हो सकता है।'),
    symptoms: [
      _t('Usually none you can feel.', 'आमतौर पर ऐसा कुछ नहीं जो आपको महसूस हो।'),
      _t("Your bump may measure small when you're examined.", 'जाँच में आपका पेट नाप में छोटा लग सकता है।'),
      _t('Sometimes your baby moving less later on.', 'कभी-कभी आगे चलकर शिशु की हलचल कम होना।'),
    ],
    diagnosis:
        _t("Growth scans that plot your baby's size over time, with Doppler "
           "blood-flow checks and fluid measurements to see how your baby is "
           "coping. The trend matters more than a single scan.", 'growth scans, जो समय के साथ आपके शिशु का आकार chart पर लगाते हैं, साथ में Doppler से ख़ून के बहाव की जाँच और पानी का माप — ताकि देखा जा सके कि शिशु कैसे सँभाल रहा है। किसी एक scan से ज़्यादा मायने रुझान का है।'),
    implications:
        _t("With close monitoring, many babies are delivered safely at the "
           "right time. It's watched carefully because a baby getting less "
           "nourishment needs the right timing of delivery, and that's what "
           "the monitoring is for.", 'क़रीब से निगरानी के साथ कई शिशु सही समय पर सुरक्षित जन्म लेते हैं। इस पर ध्यान इसलिए रखा जाता है कि कम पोषण पा रहे शिशु के लिए प्रसव का सही समय चुनना ज़रूरी होता है — और निगरानी ठीक यही सुनिश्चित करती है।'),
    management:
        _t('More frequent growth and Doppler scans, checks on movements and '
           'heartbeat (sometimes CTG), managing any blood pressure, and '
           'planning delivery at the safest time. You may be advised to rest '
           'and to keep a close eye on movements.', 'ज़्यादा बार growth और Doppler scans, हलचल तथा धड़कन पर नज़र (कभी-कभी CTG), blood pressure को सँभालना, और सबसे सुरक्षित समय पर प्रसव की योजना। आपको आराम करने और हलचल पर क़रीब से नज़र रखने को कहा जा सकता है।'),
    whenToContact: [
      _t("Your baby moving less or differently. Tell your doctor promptly, "
         "don't wait.", 'शिशु की हलचल कम होना या बदल जाना — तुरंत बताइए, इंतज़ार मत कीजिए।'),
      _t('Any bleeding, strong contractions, or a headache or changes in '
         'your vision.', 'कैसा भी ख़ून आना, तेज़ दर्द उठना, या सिरदर्द/नज़र में बदलाव।'),
      _t("If you can't make a monitoring appointment, call soon to change it.", 'निगरानी वाली किसी appointment पर न जा पाएँ, तो जल्दी फ़ोन करके नई तारीख़ ले लीजिए।'),
    ],
    faqs: [
      Faq(_t('Is my baby just naturally small?', 'क्या मेरा शिशु बस स्वभाव से ही छोटा है?'),
          _t('Some small babies are small by nature and well. Growth '
             'restriction is when the growth trend slows and the Doppler and '
             'fluid suggest the placenta is the cause. Your doctor tells the '
             'two apart.', 'कुछ छोटे शिशु बस स्वभाव से छोटे और स्वस्थ होते हैं। बढ़त में रुकावट तब कही जाती है जब बढ़त का रुझान धीमा पड़े और Doppler/पानी बताएँ कि इसकी वजह placenta है — दोनों में फ़र्क़ आपके डॉक्टर पहचानते हैं।')),
      Faq(_t('What can I do to help?', 'मैं मदद के लिए क्या कर सकती हूँ?'),
          _t('Go to all your monitoring appointments, keep track of '
             'movements, avoid smoking and other people\'s smoke, rest, and '
             'follow your doctor\'s plan. No food "fixes" it, but good food '
             'and rest help.', 'हर निगरानी पर जाइए, हलचल पर नज़र रखिए, धूम्रपान और उसके धुएँ से दूर रहिए, आराम कीजिए, और अपने डॉक्टर की योजना मानिए। ऐसा कोई खाना नहीं जो इसे "ठीक" कर दे, पर अच्छा पोषण और आराम मदद करते हैं।')),
      Faq(_t('Will I need an early delivery?', 'क्या मेरा प्रसव जल्दी करना पड़ेगा?'),
          _t('Possibly. If monitoring shows your baby would be better born '
             'than staying in, your doctor will plan delivery at the safest '
             'time.', 'हो सकता है। अगर निगरानी बताए कि शिशु के लिए बाहर आना अंदर रहने से बेहतर है, तो आपके डॉक्टर सबसे सुरक्षित समय पर प्रसव की योजना बनाएँगे।')),
    ],
    aliases: [_same('iugr'), _same('fgr'), _t('growth restriction', 'बढ़त में रुकावट'), _t('small baby', 'छोटा शिशु'), _same('sga'), _t('baby small', 'शिशु छोटा')],
  ),
];

// ---------------------------------------------------------------------------
//  Lookup + search helpers
// ---------------------------------------------------------------------------

TestScanInfo? testScanById(String id) {
  for (final t in kTestsScans) {
    if (t.id == id) return t;
  }
  return null;
}

FindingInfo? findingById(String id) {
  for (final f in kFindings) {
    if (f.id == id) return f;
  }
  return null;
}

List<TestScanInfo> testsScansByTag(TrimesterTag? tag) => tag == null
    ? kTestsScans
    : kTestsScans.where((t) => t.tag == tag).toList();

List<FindingInfo> findingsByTag(TrimesterTag? tag) => tag == null
    ? kFindings
    : kFindings.where((f) => f.tag == tag).toList();
