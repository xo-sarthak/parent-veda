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
enum TrimesterTag { t1, t2, t3, anytime }

extension TrimesterTagLabel on TrimesterTag {
  String get chipLabel => switch (this) {
        TrimesterTag.t1 => 'Trimester 1',
        TrimesterTag.t2 => 'Trimester 2',
        TrimesterTag.t3 => 'Trimester 3',
        TrimesterTag.anytime => 'Any Time',
      };

  /// Short badge shown on a card.
  String get badge => switch (this) {
        TrimesterTag.t1 => 'Trimester 1',
        TrimesterTag.t2 => 'Trimester 2',
        TrimesterTag.t3 => 'Trimester 3',
        TrimesterTag.anytime => 'Throughout',
      };
}

/// The standard educational disclaimer shown on EVERY detail page.
const String kMedicalDisclaimer =
    'This information is educational only and is not medical advice, a diagnosis '
    'or a prediction. Normal values vary from person to person and from lab to '
    'lab, and a single reading is only one part of the picture. Always read your '
    'report together with your own doctor, who knows your full history.';

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
  final String name;

  /// What it measures.
  final String measures;

  /// Why it is important.
  final String whyImportant;

  /// Typical pregnancy range (optional - some parameters are descriptive, not
  /// numeric, e.g. placenta position).
  final String? typicalRange;

  /// What a LOW value can mean (optional).
  final String? ifLow;

  /// What a HIGH value can mean (optional).
  final String? ifHigh;

  /// A general note for descriptive (non-numeric) parameters.
  final String? note;
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
    this.disclaimer = kMedicalDisclaimer,
    this.aliases = const [],
  });

  final String id;
  final String name;
  final String? altName;
  final TrimesterTag tag;

  final String whatItIs; // What it is
  final String why; // Why it's done
  final String when; // When (gestational timing)
  final String preparation; // Preparation
  final String procedure; // Procedure

  /// Free-text lead-in for "Understanding Your Report".
  final String understandingReport;

  /// The parameter-by-parameter breakdown under "Understanding Your Report".
  final List<ReportParameter> parameters;

  final String disclaimer;
  final List<String> aliases;
}

/// A question/answer pair for a finding's FAQ.
class Faq {
  const Faq(this.q, this.a);
  final String q;
  final String a;
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
  final String name;
  final String? altName;
  final TrimesterTag tag;

  final String whatIsIt; // What is it?
  final String whyHappens; // Why does it happen?
  final List<String> symptoms; // Symptoms
  final String diagnosis; // Diagnosis
  final String implications; // Pregnancy implications
  final String management; // Management
  final List<String> whenToContact; // When to contact doctor
  final List<Faq> faqs; // FAQ

  final String disclaimer;
  final List<String> aliases;
}

// ===========================================================================
//  1. TESTS & SCANS
// ===========================================================================

final List<TestScanInfo> kTestsScans = [
  // -- Booking blood panel ---------------------------------------------------
  TestScanInfo(
    id: 'blood_tests',
    name: 'Blood Tests',
    altName: 'Booking / Routine Antenatal Panel',
    tag: TrimesterTag.anytime,
    whatItIs:
        'A group of blood tests done through pregnancy - a larger panel at your '
        'first (booking) visit and a few repeats later. Together they check your '
        'blood count, iron stores, key vitamins and minerals, thyroid, blood '
        'group and blood sugar.',
    why:
        'Pregnancy places extra demands on your body. These tests find simple, '
        'correctable things early - like low iron or a thyroid that needs '
        'support - so you and your baby stay well through the months ahead.',
    when:
        'A full panel is usually taken at the first antenatal visit (first '
        'trimester). Haemoglobin and a few others are repeated in the second and '
        'third trimesters, and more often if a value needs watching.',
    preparation:
        'Most of these need no special preparation. If a fasting blood sugar or '
        'lipid test is included, you may be asked not to eat for 8-10 hours '
        '(water is fine). Your lab or doctor will tell you if fasting is needed.',
    procedure:
        'A nurse or technician draws a small sample of blood from a vein in your '
        'arm. It takes a minute or two. You can eat and carry on as normal '
        'afterwards; results usually come within a day or two.',
    understandingReport:
        'Your report lists several values, each with the lab\'s reference range '
        'beside it. Ranges differ slightly between labs, and pregnancy shifts '
        'some of them. Here is what the common ones mean.',
    parameters: [
      ReportParameter(
        name: 'Hb (Haemoglobin)',
        measures:
            'The protein in red blood cells that carries oxygen around your body '
            'and to your baby.',
        whyImportant:
            'Good haemoglobin means your blood is carrying oxygen well and you '
            'are less likely to feel very tired or breathless.',
        typicalRange:
            'In pregnancy, roughly 11 g/dL or above is generally considered '
            'adequate (a little lower than outside pregnancy, because blood '
            'volume rises).',
        ifLow:
            'Low Hb is anaemia - very common in pregnancy and usually due to low '
            'iron. It is typically improved with iron-rich food and supplements.',
        ifHigh:
            'A higher Hb is less common; your doctor may simply check your '
            'hydration and overall picture.',
      ),
      ReportParameter(
        name: 'Serum Iron',
        measures: 'The amount of iron circulating in your blood right now.',
        whyImportant:
            'Iron is the building block your body needs to make haemoglobin and '
            'to support your baby\'s growth and brain development.',
        typicalRange:
            'Reported against the lab range; it can fluctuate with recent meals '
            'and is read alongside ferritin.',
        ifLow: 'Low serum iron points towards iron deficiency.',
        ifHigh:
            'A high value is uncommon and is interpreted with your other iron '
            'tests.',
      ),
      ReportParameter(
        name: 'Ferritin',
        measures: 'Your body\'s stored iron - the "reserve tank".',
        whyImportant:
            'Ferritin shows iron reserves before haemoglobin drops, so it catches '
            'low iron early.',
        typicalRange:
            'Above about 30 ng/mL is usually considered adequate stores in '
            'pregnancy.',
        ifLow:
            'Low ferritin means iron stores are running down - the earliest sign '
            'of iron deficiency, easily managed with iron.',
        ifHigh:
            'Ferritin can rise temporarily with infection or inflammation, so it '
            'is read in context.',
      ),
      ReportParameter(
        name: 'Calcium',
        measures: 'The level of calcium in your blood.',
        whyImportant:
            'Calcium supports your baby\'s bones and teeth and your own bone '
            'health, muscles and nerves.',
        typicalRange: 'Reported against the lab range (often around 8.5-10.5 mg/dL).',
        ifLow:
            'Low calcium may prompt advice on calcium-rich food or a supplement, '
            'often alongside vitamin D.',
        ifHigh: 'A high value is uncommon and would simply be looked into.',
      ),
      ReportParameter(
        name: 'Vitamin D',
        measures: 'Your vitamin D level (25-hydroxy vitamin D).',
        whyImportant:
            'Vitamin D helps your body use calcium for your baby\'s bones. Low '
            'levels are very common in India.',
        typicalRange:
            'Around 30 ng/mL or above is generally considered sufficient; below '
            '20 is often called deficient.',
        ifLow:
            'Low vitamin D is common and easily corrected with a supplement your '
            'doctor prescribes and some safe sun exposure.',
        ifHigh:
            'Very high levels only occur with over-supplementation, so doses are '
            'kept sensible.',
      ),
      ReportParameter(
        name: 'TSH (Thyroid)',
        measures:
            'Thyroid Stimulating Hormone - a signal that reflects how your '
            'thyroid gland is working.',
        whyImportant:
            'A well-balanced thyroid supports your energy and your baby\'s brain '
            'development, especially early in pregnancy.',
        typicalRange:
            'Pregnancy has its own targets, often roughly 0.1-4.0 mIU/L with '
            'trimester-specific cut-offs your doctor uses.',
        ifLow:
            'A low TSH can suggest an overactive thyroid (hyperthyroidism), which '
            'your doctor will assess further.',
        ifHigh:
            'A high TSH suggests an underactive thyroid (hypothyroidism) - common '
            'and easily supported with a small daily tablet.',
      ),
    ],
  ),

  // -- Dating scan -----------------------------------------------------------
  TestScanInfo(
    id: 'dating_scan',
    name: 'Dating Scan',
    altName: 'Viability / First-Trimester Ultrasound',
    tag: TrimesterTag.t1,
    whatItIs:
        'Your first ultrasound in pregnancy. It confirms the pregnancy is in the '
        'right place, checks for a heartbeat, sees how many babies there are, and '
        'measures your baby to give an accurate due date.',
    why:
        'It confirms a healthy start and sets your due date accurately, which '
        'every later scan and test is timed from.',
    when:
        'Usually between about 6 and 9 weeks, sometimes up to 13 weeks. An early '
        'scan may be done if you have pain, bleeding, or are unsure of dates.',
    preparation:
        'For an early (transvaginal) scan you may not need a full bladder. For an '
        'abdominal scan you may be asked to drink water and hold urine so the '
        'uterus is easier to see. Wear comfortable, two-piece clothing.',
    procedure:
        'A probe (either on your tummy with gel, or a slim internal probe early '
        'on) sends harmless sound waves to build an image. It is painless and '
        'takes about 10-20 minutes.',
    understandingReport:
        'The report notes a few early measurements and observations. Here is what '
        'they mean.',
    parameters: [
      ReportParameter(
        name: 'Gestational sac',
        measures: 'The fluid-filled space your baby grows in.',
        whyImportant:
            'Seeing it inside the uterus confirms the pregnancy is in the right '
            'place.',
        note: 'A normal early finding; its size helps confirm dates.',
      ),
      ReportParameter(
        name: 'CRL (Crown-Rump Length)',
        measures: 'Your baby\'s length from head to bottom.',
        whyImportant:
            'This is the most accurate way to date a pregnancy this early.',
        note: 'Used to set or confirm your estimated due date.',
      ),
      ReportParameter(
        name: 'FHR / Cardiac activity',
        measures: 'Your baby\'s heartbeat.',
        whyImportant: 'A heartbeat is a reassuring sign of a healthy start.',
        typicalRange:
            'Often visible from around 6 weeks; a rate of roughly 110-160 beats '
            'per minute is typical as pregnancy progresses.',
        note:
            'Before about 6 weeks it can simply be too early to see - not a cause '
            'for worry on its own.',
      ),
      ReportParameter(
        name: 'EDD (Estimated Due Date)',
        measures: 'Your expected delivery date, from the measurements.',
        whyImportant:
            'It anchors the timing of every future scan, test and milestone.',
        note: 'It may be adjusted slightly from the date based on your period.',
      ),
    ],
  ),

  // -- NT scan ---------------------------------------------------------------
  TestScanInfo(
    id: 'nt_scan',
    name: 'NT Scan',
    altName: 'Nuchal Translucency + Double Marker',
    tag: TrimesterTag.t1,
    whatItIs:
        'A first-trimester screening test. An ultrasound measures a small pocket '
        'of fluid at the back of your baby\'s neck (the nuchal translucency), '
        'usually combined with a blood test (the "double marker") and your age.',
    why:
        'Together these give a CHANCE (a likelihood) for conditions such as '
        'Down\'s syndrome. It is a screening test - it estimates a probability, '
        'it does not diagnose anything.',
    when:
        'Between 11 and 13 weeks 6 days, when the NT measurement is most reliable.',
    preparation:
        'A moderately full bladder can help the scan. The blood sample for the '
        'double marker can usually be given the same day; no fasting is needed.',
    procedure:
        'A standard abdominal ultrasound measures the neck fluid and confirms '
        'dates, plus a simple blood draw for the markers. Painless, about 20-30 '
        'minutes in total.',
    understandingReport:
        'Your result combines the scan and blood values into an overall chance. '
        'Here is what the pieces mean.',
    parameters: [
      ReportParameter(
        name: 'NT measurement (mm)',
        measures: 'The fluid at the back of your baby\'s neck.',
        whyImportant: 'It is the main scan marker used in the calculation.',
        typicalRange: 'Most babies measure under about 3.0-3.5 mm.',
        ifHigh:
            'A higher value raises the calculated chance but does NOT confirm '
            'anything - many babies with a slightly higher NT are perfectly well.',
      ),
      ReportParameter(
        name: 'Nasal bone',
        measures: 'Whether the nasal bone is seen (present or absent).',
        whyImportant: 'It is one of several soft markers considered together.',
        note:
            'An absent nasal bone can slightly raise the calculated chance; on '
            'its own it is not a diagnosis.',
      ),
      ReportParameter(
        name: 'Free β-hCG / PAPP-A',
        measures: 'Two pregnancy hormones/proteins from the blood sample.',
        whyImportant: 'They feed into your overall screening chance.',
        note:
            'Usually reported as "MoM" (multiples of the median) rather than raw '
            'numbers.',
      ),
      ReportParameter(
        name: 'Risk / chance (e.g. 1 in 1500)',
        measures: 'Your combined screening result.',
        whyImportant: 'It tells you whether a further test is worth considering.',
        note:
            'A "low chance" (a big number, like 1 in 1500) is reassuring. A '
            '"higher chance" may lead to an offer of NIPT or a diagnostic test - '
            'it is a next step, not a conclusion.',
      ),
    ],
  ),

  // -- NIPT ------------------------------------------------------------------
  TestScanInfo(
    id: 'nipt',
    name: 'NIPT',
    altName: 'Non-Invasive Prenatal Test',
    tag: TrimesterTag.t1,
    whatItIs:
        'An advanced blood test that looks at small fragments of your baby\'s DNA '
        'circulating in your blood, to screen for common chromosomal conditions '
        'such as Down\'s syndrome.',
    why:
        'It is a more precise screening test than the combined NT test. It may be '
        'offered as a first choice, or after a "higher chance" NT result, to give '
        'clearer information before deciding on any diagnostic test.',
    when:
        'From 10 weeks onward (there needs to be enough of your baby\'s DNA in '
        'your blood). It can be done at any point after that.',
    preparation:
        'No preparation and no fasting. It is a simple blood draw from your arm.',
    procedure:
        'One blood sample is taken and sent to a specialised lab. Results usually '
        'take about a week to ten days.',
    understandingReport:
        'NIPT is reported as a screening result, not a yes/no diagnosis. Here is '
        'how to read it.',
    parameters: [
      ReportParameter(
        name: 'Low risk / High risk',
        measures:
            'The screening result for each condition tested (e.g. trisomy 21).',
        whyImportant: 'It guides whether a diagnostic test is worth discussing.',
        note:
            'A "low risk" result is very reassuring. A "high risk" result still '
            'needs a diagnostic test (like amniocentesis) to confirm - screening '
            'is not the final answer.',
      ),
      ReportParameter(
        name: 'Fetal fraction',
        measures: 'How much of your baby\'s DNA was in the sample.',
        whyImportant:
            'Enough fetal fraction is needed for a reliable result.',
        note:
            'If it is too low, the test may simply be repeated - it does not mean '
            'anything is wrong.',
      ),
      ReportParameter(
        name: 'Fetal sex (optional)',
        measures: 'Your baby\'s sex, if analysed.',
        whyImportant:
            'Sometimes relevant medically (for sex-linked conditions).',
        note:
            'Note: in India, disclosing the baby\'s sex is not permitted under '
            'the PCPNDT Act, so labs here withhold it.',
      ),
    ],
  ),

  // -- Anomaly / TIFFA scan --------------------------------------------------
  TestScanInfo(
    id: 'anomaly_scan',
    name: 'Anomaly Scan',
    altName: 'TIFFA / Level 2 / 20-Week Scan',
    tag: TrimesterTag.t2,
    whatItIs:
        'A detailed ultrasound (Targeted Imaging for Fetal Anomalies) that looks '
        'closely at your baby\'s brain, face, spine, heart, chest, tummy, kidneys '
        'and limbs, and checks the placenta, the fluid and how your baby is '
        'growing.',
    why:
        'It is the main check of your baby\'s physical development, and reassures '
        'you and your doctor that organs are forming as expected. It also records '
        'the placenta position and growth measurements.',
    when:
        'Between 18 and 22 weeks, when the organs are large enough to see clearly '
        'but there is still room to view everything.',
    preparation:
        'A moderately full bladder can help early views. Wear two-piece, '
        'comfortable clothing. The scan takes longer than others, so allow time.',
    procedure:
        'An abdominal ultrasound with gel, moving the probe to view each part in '
        'turn. It usually takes 30-45 minutes; the sonographer may pause if your '
        'baby is lying in an awkward position and ask you to move or walk.',
    understandingReport:
        'The report lists organ-by-organ observations plus growth measurements '
        '(biometry). Here are the measurements you will see.',
    parameters: [
      ReportParameter(
        name: 'BPD (Biparietal Diameter)',
        measures: 'The width of your baby\'s head, side to side.',
        whyImportant: 'One of the core measurements used to track head growth.',
        note:
            'Compared against the expected size for your weeks; read as a trend, '
            'not a single number.',
      ),
      ReportParameter(
        name: 'HC (Head Circumference)',
        measures: 'The distance around your baby\'s head.',
        whyImportant: 'Helps confirm the head is growing as expected.',
        note: 'Used with BPD to assess head growth and dating.',
      ),
      ReportParameter(
        name: 'AC (Abdominal Circumference)',
        measures: 'The distance around your baby\'s tummy.',
        whyImportant:
            'The most useful single measure of your baby\'s overall growth and '
            'nourishment.',
        note:
            'Estimated weight is calculated mainly from AC together with the '
            'other measurements.',
      ),
      ReportParameter(
        name: 'FL (Femur Length)',
        measures: 'The length of your baby\'s thigh bone.',
        whyImportant: 'Reflects the growth of your baby\'s long bones.',
        note: 'Read alongside HC and AC to build the growth picture.',
      ),
      ReportParameter(
        name: 'Placenta',
        measures: 'Where the placenta is lying (e.g. anterior, posterior, fundal).',
        whyImportant:
            'Its position matters for delivery planning if it sits low near the '
            'cervix.',
        note:
            'If it is low now, a later scan usually shows it has moved up as the '
            'uterus grows - this is the common outcome.',
      ),
      ReportParameter(
        name: 'Amniotic Fluid (AFI)',
        measures: 'The amount of fluid around your baby.',
        whyImportant:
            'Fluid cushions your baby and reflects wellbeing and kidney function.',
        typicalRange:
            'An AFI of roughly 8-18 cm is commonly considered normal in the '
            'second half of pregnancy.',
        ifLow:
            'A lower level (oligohydramnios) may prompt extra hydration and '
            'closer monitoring.',
        ifHigh:
            'A higher level (polyhydramnios) is often mild and simply followed '
            'up.',
      ),
    ],
  ),

  // -- OGTT / glucose --------------------------------------------------------
  TestScanInfo(
    id: 'ogtt',
    name: 'OGTT (Glucose Test)',
    altName: 'Glucose Tolerance Test / GTT',
    tag: TrimesterTag.t2,
    whatItIs:
        'A blood test that checks how your body handles sugar during pregnancy. '
        'You drink a measured glucose solution and your blood sugar is checked at '
        'set times.',
    why:
        'It screens for gestational diabetes (raised blood sugar in pregnancy), '
        'which is common, usually has no symptoms, and is very manageable when '
        'found early.',
    when:
        'Usually between 24 and 28 weeks. It may be done earlier if you have risk '
        'factors such as a family history of diabetes or a previous large baby.',
    preparation:
        'For the standard test you fast overnight (about 8-10 hours; water is '
        'fine). Carry something to eat for afterwards. Allow 2-3 hours as you '
        'wait between samples.',
    procedure:
        'A fasting blood sample is taken first. You then drink the glucose (often '
        '75 g) and further samples are taken at 1 hour and 2 hours. In India the '
        'single-step DIPSI method (75 g, one 2-hour sample, non-fasting) is also '
        'widely used.',
    understandingReport:
        'Your report shows blood sugar values at each time point against the '
        'lab\'s cut-offs. Here is what they mean.',
    parameters: [
      ReportParameter(
        name: 'Fasting glucose',
        measures: 'Your blood sugar before the glucose drink.',
        whyImportant: 'A raised fasting value is one way GDM is picked up.',
        typicalRange:
            'Commonly below about 92 mg/dL is considered normal for the fasting '
            'value (cut-offs vary by protocol).',
        ifHigh: 'A raised value may point to gestational diabetes.',
      ),
      ReportParameter(
        name: '1-hour value',
        measures: 'Your blood sugar one hour after the drink.',
        whyImportant: 'Shows the peak rise in sugar.',
        typicalRange: 'Often below about 180 mg/dL is considered normal.',
        ifHigh: 'A raised value contributes to a GDM diagnosis.',
      ),
      ReportParameter(
        name: '2-hour value',
        measures: 'Your blood sugar two hours after the drink.',
        whyImportant: 'Shows how well your body has brought the sugar back down.',
        typicalRange:
            'Often below about 153 mg/dL (or 140 mg/dL by DIPSI) is considered '
            'normal.',
        ifHigh:
            'A raised value suggests gestational diabetes - manageable with diet, '
            'monitoring and sometimes medication.',
      ),
      ReportParameter(
        name: 'HbA1c',
        measures: 'Your average blood sugar over the past few weeks.',
        whyImportant: 'Sometimes added to give a fuller picture.',
        note: 'Not the main test for GDM but useful background context.',
      ),
    ],
  ),

  // -- Growth scan -----------------------------------------------------------
  TestScanInfo(
    id: 'growth_scan',
    name: 'Growth Scan',
    altName: 'Third-Trimester Ultrasound',
    tag: TrimesterTag.t3,
    whatItIs:
        'An ultrasound, usually from around 28 weeks and only when advised, that '
        'measures your baby\'s size, the fluid around them, the position, and the '
        'blood flow in the cord and placenta (Doppler).',
    why:
        'It checks your baby is growing steadily and getting enough nourishment '
        'as the due date nears - useful if there is any question about growth, '
        'fluid or blood pressure.',
    when:
        'Typically from 28 weeks onward, repeated every 2-4 weeks if your doctor '
        'is tracking growth closely.',
    preparation:
        'No special preparation and no fasting. Wear comfortable, two-piece '
        'clothing.',
    procedure:
        'A standard abdominal ultrasound. The measurements are plotted on a '
        'growth chart so your baby\'s trend can be seen over time. Takes about '
        '20-30 minutes.',
    understandingReport:
        'The report focuses on size, fluid and blood flow. Here is what to look '
        'at.',
    parameters: [
      ReportParameter(
        name: 'EFW (Estimated Fetal Weight)',
        measures: 'An estimate of your baby\'s weight from the measurements.',
        whyImportant: 'The headline number people focus on.',
        note:
            'It is an estimate, not an exact figure - it can be off by around '
            '10-15%. The trend over scans matters more than one value.',
      ),
      ReportParameter(
        name: 'Centile (e.g. 50th)',
        measures: 'Where your baby sits compared with others at the same weeks.',
        whyImportant: 'Helps judge whether growth is on track.',
        note:
            'Following your baby\'s OWN curve over time matters more than a single '
            'centile. A steadily-growing small baby is often simply naturally '
            'small.',
      ),
      ReportParameter(
        name: 'AFI / Liquor',
        measures: 'The amount of fluid around your baby.',
        whyImportant: 'Reflects wellbeing and kidney function.',
        typicalRange: 'An AFI of roughly 8-18 cm is commonly considered normal.',
        ifLow: 'A lower level may prompt hydration and closer monitoring.',
        ifHigh: 'A higher level is often mild and simply followed up.',
      ),
      ReportParameter(
        name: 'Doppler (PI / RI)',
        measures: 'Blood-flow readings in the cord and key vessels.',
        whyImportant:
            'Normal flow is reassuring about the placenta and your baby\'s '
            'nourishment.',
        note:
            'Reported as indices (PI/RI); your doctor reads them against the '
            'expected range for your weeks.',
      ),
      ReportParameter(
        name: 'Presentation',
        measures: 'Which way up your baby is lying (cephalic / breech).',
        whyImportant: 'Relevant for delivery planning closer to term.',
        note:
            'Many babies are still turning at this stage and settle head-down '
            '(cephalic) by term.',
      ),
    ],
  ),

  // -- Doppler ---------------------------------------------------------------
  TestScanInfo(
    id: 'doppler',
    name: 'Doppler Scan',
    altName: 'Colour Doppler / Umbilical Artery Doppler',
    tag: TrimesterTag.t3,
    whatItIs:
        'A special ultrasound setting that measures the speed and pattern of '
        'blood flow through the umbilical cord and your baby\'s key vessels.',
    why:
        'It checks that the placenta is delivering blood and nourishment well. '
        'It is especially useful when a baby is measuring small or when blood '
        'pressure is being watched.',
    when:
        'Usually in the third trimester, often as part of a growth scan, and '
        'repeated as your doctor advises.',
    preparation:
        'No preparation and no fasting. It is done as part of, or just like, a '
        'normal ultrasound.',
    procedure:
        'The same probe as a regular scan, switched to Doppler mode. It is '
        'painless and adds only a few minutes to a scan.',
    understandingReport:
        'Doppler is reported as flow indices. Here is what they reflect.',
    parameters: [
      ReportParameter(
        name: 'Umbilical artery PI / RI',
        measures: 'Resistance to blood flow in the cord.',
        whyImportant: 'A key indicator of how well the placenta is working.',
        note:
            'Read against the expected range for your weeks; normal flow is '
            'reassuring.',
      ),
      ReportParameter(
        name: 'MCA (Middle Cerebral Artery)',
        measures: 'Blood flow to your baby\'s brain.',
        whyImportant:
            'Helps assess how your baby is coping, together with the cord '
            'reading.',
        note: 'Interpreted alongside the umbilical artery result.',
      ),
      ReportParameter(
        name: 'End-diastolic flow',
        measures: 'Whether blood keeps flowing forward between heartbeats.',
        whyImportant: 'Present forward flow is a reassuring sign.',
        note:
            'If it is reduced or absent, your doctor will monitor more closely '
            'and guide the plan - it is a signal to watch, and it is acted on '
            'carefully.',
      ),
    ],
  ),

  // -- GBS -------------------------------------------------------------------
  TestScanInfo(
    id: 'gbs',
    name: 'Group B Strep',
    altName: 'GBS Swab',
    tag: TrimesterTag.t3,
    whatItIs:
        'A simple swab test for Group B Streptococcus, a common bacterium that '
        'many healthy women carry naturally without any symptoms.',
    why:
        'If you are carrying GBS near your due date, antibiotics during labour '
        'greatly reduce the small chance of passing it to your baby. Carrying it '
        'is common and is not an infection in you.',
    when: 'Usually around 35-37 weeks, close to your due date.',
    preparation:
        'No preparation needed. Avoid using vaginal creams or douches just '
        'before, as they can affect the sample.',
    procedure:
        'A gentle swab of the lower vagina and rectum - quick and painless, and '
        'you can often take the swab yourself if you prefer.',
    understandingReport:
        'The result is simply positive or negative. Here is what each means.',
    parameters: [
      ReportParameter(
        name: 'Positive / Carrier',
        measures: 'GBS was found on this swab.',
        whyImportant: 'It tells your team to plan a simple precaution at delivery.',
        note:
            'It is common and not an infection in you - you would be offered '
            'antibiotics during labour as a precaution.',
      ),
      ReportParameter(
        name: 'Negative',
        measures: 'GBS was not found on this swab.',
        whyImportant: 'No GBS precaution is needed based on this result.',
        note: 'Reassuring; routine care continues.',
      ),
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
    name: 'Low-Lying Placenta',
    tag: TrimesterTag.t2,
    whatIsIt:
        'The placenta is sitting lower in the uterus than usual, close to the '
        'cervix (the opening of the womb). It is often noted on the anomaly scan.',
    whyHappens:
        'It is simply where the placenta happened to implant early on. As '
        'pregnancy continues and the uterus grows upward, the placenta usually '
        'moves higher and away from the cervix on its own.',
    symptoms: [
      'Usually none - it is typically a scan finding, not something you feel.',
      'Occasionally painless bleeding; always report any bleeding to your doctor.',
    ],
    diagnosis:
        'Seen on ultrasound, most often the 18-22 week anomaly scan. A follow-up '
        'scan later in pregnancy checks whether it has moved up.',
    implications:
        'In the large majority of cases the placenta moves up and there is no '
        'effect on delivery. Only if it stays low near or over the cervix later '
        'on (placenta previa) does it change delivery plans.',
    management:
        'A follow-up scan (often around 32 weeks) to re-check the position. Your '
        'doctor may advise avoiding heavy lifting or intercourse if there has '
        'been any bleeding, and will make a delivery plan based on the later '
        'scan.',
    whenToContact: [
      'Any vaginal bleeding, even if painless.',
      'Cramping or tightening with bleeding.',
      'Any sudden gush of fluid.',
    ],
    faqs: [
      Faq('Will it move up?',
          'Most low-lying placentas do move up as the uterus grows. That is the usual, expected outcome.'),
      Faq('Does it mean I need a caesarean?',
          'Not usually. Only if it stays low over the cervix at the later scan would your doctor discuss a planned caesarean.'),
      Faq('Should I be on bed rest?',
          'Complete bed rest is not routinely advised. Your doctor will give personal advice, especially if there has been any bleeding.'),
    ],
    aliases: ['placenta', 'low placenta', 'placenta position'],
  ),

  // -- Placenta previa -------------------------------------------------------
  FindingInfo(
    id: 'placenta_previa',
    name: 'Placenta Previa',
    tag: TrimesterTag.t3,
    whatIsIt:
        'The placenta is partly or fully covering the cervix in the later part of '
        'pregnancy. It is essentially a low-lying placenta that has stayed low '
        'rather than moving up.',
    whyHappens:
        'The placenta implanted low and did not migrate upward as the uterus '
        'grew. It is more likely after a previous caesarean, in twin '
        'pregnancies, or with certain uterine features.',
    symptoms: [
      'Painless, bright-red vaginal bleeding in the second half of pregnancy is the classic sign.',
      'Often no symptoms until a bleed; sometimes found only on a scan.',
    ],
    diagnosis:
        'Confirmed on ultrasound, usually a transvaginal scan which is safe and '
        'gives the clearest view of the placenta\'s relationship to the cervix.',
    implications:
        'It needs a planned delivery, usually by caesarean, to avoid bleeding '
        'during labour. With modern monitoring and planning, it is managed '
        'safely.',
    management:
        'Closer monitoring, avoiding intercourse and heavy activity, and a '
        'planned caesarean (often before labour starts). If there is significant '
        'bleeding, hospital admission may be advised for observation.',
    whenToContact: [
      'Any vaginal bleeding - contact your doctor or go to hospital promptly.',
      'Contractions or tightening.',
      'Reduced baby movements.',
    ],
    faqs: [
      Faq('Is my baby in danger?',
          'With planning and monitoring, most pregnancies with previa reach a safe delivery. The main aim is to avoid heavy bleeding, which is why a planned caesarean is used.'),
      Faq('Can I still have a normal delivery?',
          'If the placenta covers the cervix, a caesarean is the safe route. If it is only close but not covering, your doctor will advise based on the exact position.'),
      Faq('What can I do at home?',
          'Rest as advised, avoid intercourse and heavy lifting, keep your scan appointments, and report any bleeding immediately.'),
    ],
    aliases: ['previa', 'placenta covering cervix'],
  ),

  // -- Anaemia ---------------------------------------------------------------
  FindingInfo(
    id: 'anaemia',
    name: 'Anaemia',
    altName: 'Low Haemoglobin',
    tag: TrimesterTag.anytime,
    whatIsIt:
        'Your blood has fewer healthy red cells or less haemoglobin than ideal. '
        'In pregnancy it is most often due to low iron, and it is very common.',
    whyHappens:
        'Your body makes a lot more blood in pregnancy to support your baby, '
        'which can dilute and use up your iron stores. Diets low in iron, close '
        'pregnancies, or heavy periods before pregnancy add to it.',
    symptoms: [
      'Tiredness and low energy.',
      'Looking pale; pale inner eyelids or nails.',
      'Breathlessness on mild effort.',
      'Dizziness or a fast heartbeat.',
      'Often mild anaemia causes no clear symptoms at all.',
    ],
    diagnosis:
        'A routine blood test (haemoglobin), usually supported by ferritin (iron '
        'stores) and other red-cell indices to confirm iron deficiency.',
    implications:
        'Mild anaemia is very common and usually improves quickly with treatment. '
        'If left unaddressed, more significant anaemia can add to tiredness and, '
        'rarely, affect the pregnancy - which is exactly why it is checked and '
        'corrected early.',
    management:
        'Iron-rich foods (green leafy vegetables, dates, jaggery, pulses, and for '
        'non-vegetarians eggs and meat), an iron supplement, and vitamin C (like '
        'lemon or citrus) to help absorption. Levels are re-checked after a few '
        'weeks. Very low levels may need iron given through a vein.',
    whenToContact: [
      'Severe tiredness, fainting, or breathlessness at rest.',
      'A fast or pounding heartbeat.',
      'If iron tablets upset your stomach - your doctor can adjust the type or dose.',
    ],
    faqs: [
      Faq('Will it harm my baby?',
          'Mild anaemia, treated, rarely causes problems. Your body prioritises your baby\'s iron needs, which is part of why yours can run low.'),
      Faq('The iron tablets make me constipated - what can I do?',
          'This is common. More water, fibre and fruit help, and your doctor can switch to a gentler iron formulation.'),
      Faq('Can I fix it with food alone?',
          'Diet helps, but pregnancy iron needs are high, so a supplement is usually needed alongside iron-rich food.'),
    ],
    aliases: ['anemia', 'low hb', 'low haemoglobin', 'iron deficiency'],
  ),

  // -- Breech ----------------------------------------------------------------
  FindingInfo(
    id: 'breech',
    name: 'Breech Presentation',
    altName: 'Breech Baby',
    tag: TrimesterTag.t3,
    whatIsIt:
        'Your baby is lying bottom-down or feet-down instead of head-down. Many '
        'babies are breech earlier on and turn head-down before birth.',
    whyHappens:
        'Often there is no particular reason - it is just how your baby is lying. '
        'It can be more likely with extra or low fluid, a low placenta, twins, or '
        'the shape of the uterus.',
    symptoms: [
      'Usually none - it is a position found on examination or scan.',
      'You may feel kicks lower down and a firm, round head up near your ribs.',
    ],
    diagnosis:
        'Felt by your doctor examining your tummy and confirmed on ultrasound, '
        'which shows the exact position.',
    implications:
        'Before about 36 weeks it often does not matter, as there is still time '
        'to turn. If your baby stays breech near term, your doctor will discuss '
        'options for a safe birth.',
    management:
        'Watchful waiting, as many babies turn on their own. Near term, options '
        'may include ECV (a doctor gently turning the baby from outside), a '
        'planned caesarean, or in selected cases a vaginal breech birth with an '
        'experienced team. Your doctor will guide the safest choice for you.',
    whenToContact: [
      'Your waters break while the baby is breech - go to hospital, as the cord needs checking.',
      'Strong regular contractions before your planned date.',
      'Reduced baby movements.',
    ],
    faqs: [
      Faq('Is there still time for the baby to turn?',
          'Yes - many babies turn head-down by 36-37 weeks. The chance falls as term approaches but turning still happens.'),
      Faq('Are the exercises I read about safe?',
          'Some gentle positional techniques are popular; check with your doctor before trying anything, and never force a position.'),
      Faq('Does breech always mean a caesarean?',
          'No. ECV can turn many babies, and vaginal breech birth is possible in the right situation. Your doctor will talk through what is safest for you.'),
    ],
    aliases: ['breech baby', 'baby position', 'footling', 'bottom down'],
  ),

  // -- Low AFI ---------------------------------------------------------------
  FindingInfo(
    id: 'low_afi',
    name: 'Low Amniotic Fluid',
    altName: 'Oligohydramnios',
    tag: TrimesterTag.t3,
    whatIsIt:
        'The amount of fluid around your baby is on the lower side. Fluid levels '
        'can change from one scan to the next, so it is read alongside how your '
        'baby is growing and moving.',
    whyHappens:
        'Sometimes there is no clear cause. It can relate to the due date '
        'passing, the placenta working a little less efficiently, a leak of '
        'fluid, or your own hydration.',
    symptoms: [
      'Usually none - it is a scan finding.',
      'You may notice your bump measuring small, or leaking fluid if the waters have broken.',
    ],
    diagnosis:
        'Measured on ultrasound as the AFI (amniotic fluid index) or the deepest '
        'pocket of fluid, and confirmed by re-checking.',
    implications:
        'Mild reductions are often managed with hydration and closer monitoring. '
        'Lower levels, especially near term, may lead your doctor to plan an '
        'earlier delivery to keep your baby safe.',
    management:
        'Drinking plenty of water, more frequent scans and monitoring of your '
        'baby\'s movements and heartbeat. Depending on your weeks and how your '
        'baby is doing, your doctor may advise delivery.',
    whenToContact: [
      'A gush or steady trickle of fluid (your waters may have broken).',
      'Reduced or changed baby movements.',
      'Any bleeding or strong contractions.',
    ],
    faqs: [
      Faq('Will drinking more water help?',
          'Staying well hydrated can help and is usually advised. Your doctor will still re-check the level to be sure.'),
      Faq('Does low fluid mean something is wrong with my baby?',
          'Not necessarily. Often the baby is well and simply needs closer monitoring; the trend and your baby\'s movements matter most.'),
      Faq('How often will it be checked?',
          'That depends on the level and your weeks - it may be every few days to weekly, and your doctor will tell you the plan.'),
    ],
    aliases: ['low fluid', 'oligohydramnios', 'afi low', 'low water', 'liquor'],
  ),

  // -- Hypothyroidism --------------------------------------------------------
  FindingInfo(
    id: 'hypothyroid',
    name: 'Hypothyroidism',
    altName: 'Underactive Thyroid',
    tag: TrimesterTag.anytime,
    whatIsIt:
        'Your thyroid gland is making a little less thyroid hormone than your '
        'body needs. It is common in pregnancy and shows as a raised TSH on your '
        'blood test.',
    whyHappens:
        'Often the thyroid simply cannot keep up with pregnancy\'s extra demand, '
        'sometimes due to an autoimmune cause (Hashimoto\'s) or low iodine. Many '
        'women first learn of it in pregnancy.',
    symptoms: [
      'Tiredness and feeling cold.',
      'Weight gain or puffiness.',
      'Dry skin, constipation.',
      'Often mild cases have no clear symptoms and are found on the blood test.',
    ],
    diagnosis:
        'A blood test showing raised TSH (with T4 sometimes checked). Pregnancy '
        'uses its own, tighter target ranges, especially in the first trimester.',
    implications:
        'Well-treated hypothyroidism has little effect on pregnancy. Because '
        'thyroid hormone supports your baby\'s early brain development, doctors '
        'treat it promptly and keep levels in the pregnancy target.',
    management:
        'A small daily tablet of thyroid hormone (levothyroxine), taken on an '
        'empty stomach, with the dose adjusted as pregnancy progresses. TSH is '
        're-checked regularly, often every 4-6 weeks early on.',
    whenToContact: [
      'If you miss doses or run out of tablets.',
      'Strong new symptoms such as a racing heart (may mean the dose needs review).',
      'Before stopping or changing the dose yourself - always check first.',
    ],
    faqs: [
      Faq('Is the tablet safe for my baby?',
          'Yes. Levothyroxine replaces the hormone your body should be making and is considered safe and important in pregnancy.'),
      Faq('Will I need it forever?',
          'Sometimes. Some women need it only in pregnancy; others continue after. Your doctor will re-check after delivery.'),
      Faq('Why must I take it on an empty stomach?',
          'Food, iron and calcium reduce absorption. Take it first thing, and keep iron/calcium a few hours apart.'),
    ],
    aliases: ['thyroid', 'hypothyroid', 'high tsh', 'underactive thyroid'],
  ),

  // -- Hyperthyroidism -------------------------------------------------------
  FindingInfo(
    id: 'hyperthyroid',
    name: 'Hyperthyroidism',
    altName: 'Overactive Thyroid',
    tag: TrimesterTag.anytime,
    whatIsIt:
        'Your thyroid gland is making more thyroid hormone than your body needs. '
        'It is less common than an underactive thyroid and shows as a low TSH.',
    whyHappens:
        'Most often an autoimmune cause (Graves\' disease). Early pregnancy '
        'hormones can also mildly and temporarily raise thyroid activity, '
        'sometimes with severe morning sickness.',
    symptoms: [
      'A fast or pounding heartbeat.',
      'Feeling hot, sweaty or anxious.',
      'Weight loss despite eating well; trembling hands.',
      'Severe nausea and vomiting (in the early, temporary form).',
    ],
    diagnosis:
        'A blood test showing low TSH with raised thyroid hormones (T4/T3). Your '
        'doctor distinguishes true hyperthyroidism from the mild, temporary rise '
        'of early pregnancy.',
    implications:
        'Mild, temporary cases often settle by mid-pregnancy. True '
        'hyperthyroidism is treated to keep you and your baby well, and is '
        'managed successfully with the right medication and monitoring.',
    management:
        'Anti-thyroid medication chosen carefully for pregnancy, at the lowest '
        'effective dose, with regular blood tests. A specialist '
        '(endocrinologist) is often involved.',
    whenToContact: [
      'A very fast heartbeat, fever, or feeling severely unwell.',
      'Persistent vomiting and inability to keep fluids down.',
      'Before changing or stopping medication yourself.',
    ],
    faqs: [
      Faq('Will it settle on its own?',
          'The mild early-pregnancy form often does by mid-pregnancy. Graves\' disease needs treatment, which works well.'),
      Faq('Is the medication safe?',
          'The medicines used are chosen specifically for pregnancy safety, at the lowest dose that works, with monitoring.'),
      Faq('Do I need a specialist?',
          'Often yes - your obstetrician usually works with an endocrinologist to fine-tune treatment.'),
    ],
    aliases: ['thyroid', 'hyperthyroid', 'low tsh', 'overactive thyroid', 'graves'],
  ),

  // -- Gestational diabetes --------------------------------------------------
  FindingInfo(
    id: 'gdm',
    name: 'Gestational Diabetes',
    altName: 'GDM',
    tag: TrimesterTag.t2,
    whatIsIt:
        'Raised blood sugar that appears during pregnancy. Your body is having '
        'some trouble keeping sugar in the normal range, usually because '
        'pregnancy hormones make insulin work less well.',
    whyHappens:
        'Pregnancy hormones from the placenta reduce how well insulin works '
        '(insulin resistance). If your body cannot make enough extra insulin to '
        'keep up, blood sugar rises. It is more likely with a family history, '
        'higher weight, PCOS, or a previous large baby.',
    symptoms: [
      'Usually none - which is exactly why the glucose test is routine.',
      'Occasionally increased thirst or passing more urine.',
    ],
    diagnosis:
        'The glucose test (OGTT/GTT), usually at 24-28 weeks, comparing your '
        'blood sugar values against pregnancy cut-offs.',
    implications:
        'Well-controlled GDM usually leads to a healthy pregnancy and baby. '
        'Uncontrolled high sugar can make a baby grow large or affect the baby\'s '
        'sugar after birth - which is why control matters, and why it works so '
        'well.',
    management:
        'A balanced diet (steady carbohydrates, more fibre, portion control), '
        'gentle activity like walking after meals, and home blood-sugar '
        'monitoring. Some mothers also need tablets or insulin. It most often '
        'resolves after birth, with a check later to confirm.',
    whenToContact: [
      'Sugar readings staying above your target despite diet.',
      'Very high or very low readings, or feeling shaky/sweaty (possible low sugar on medication).',
      'Reduced baby movements.',
    ],
    faqs: [
      Faq('Did I cause this?',
          'No. GDM is driven mainly by pregnancy hormones and your own body\'s response, not by anything you did wrong.'),
      Faq('Will it go away after birth?',
          'For most women, yes. A follow-up test after delivery confirms it, and it flags a higher future risk to watch.'),
      Faq('Will I definitely need insulin?',
          'Many women manage with diet and activity alone. Medication is added only if needed, and it is safe in pregnancy.'),
    ],
    aliases: ['gdm', 'gestational diabetes', 'sugar', 'high sugar', 'diabetes'],
  ),

  // -- Pre-eclampsia ---------------------------------------------------------
  FindingInfo(
    id: 'preeclampsia',
    name: 'Pre-eclampsia',
    altName: 'High Blood Pressure in Pregnancy',
    tag: TrimesterTag.t3,
    whatIsIt:
        'A pregnancy condition with raised blood pressure, usually after 20 '
        'weeks, often with protein in the urine or other signs that your body '
        'needs closer attention.',
    whyHappens:
        'It is thought to start with how the placenta\'s blood vessels formed '
        'early in pregnancy, which later affects your blood pressure and organs. '
        'It is more likely in a first pregnancy, with a family history, twins, or '
        'existing high blood pressure or diabetes.',
    symptoms: [
      'Often none early on - which is why blood pressure and urine are checked at every visit.',
      'A bad, persistent headache.',
      'Vision changes - blurring or flashing lights.',
      'Pain just below the ribs, on the right side.',
      'Sudden swelling of the face, hands or feet.',
    ],
    diagnosis:
        'Raised blood pressure readings plus protein in the urine and/or blood '
        'tests, at your routine antenatal checks. This is why those simple checks '
        'are done every time.',
    implications:
        'Closely monitored and managed, most women and babies do well. It is '
        'taken seriously because, untreated, it can affect your organs and your '
        'baby\'s growth - so the aim is early detection and the right timing of '
        'delivery, which is the definitive treatment.',
    management:
        'More frequent checks, blood-pressure medication if needed, blood tests, '
        'and monitoring your baby\'s growth. The timing and plan for a safe '
        'delivery are decided by your doctor; rest and follow-up are part of it.',
    whenToContact: [
      'A severe or persistent headache.',
      'Vision changes - blurring, spots or flashing lights.',
      'Upper-tummy pain below the ribs.',
      'Sudden swelling of face/hands, or reduced baby movements - contact your doctor urgently.',
    ],
    faqs: [
      Faq('Can I prevent it?',
          'Sometimes low-dose aspirin is advised from early pregnancy if you are higher risk. Keeping every antenatal appointment is the key to catching it early.'),
      Faq('Will I need an early delivery?',
          'Sometimes. Delivery is the definitive treatment, and your doctor balances the timing carefully for you and your baby.'),
      Faq('Does it go away after birth?',
          'It usually resolves after delivery, though blood pressure is watched for a while afterwards.'),
    ],
    aliases: ['preeclampsia', 'pre eclampsia', 'high bp', 'pih', 'protein in urine', 'blood pressure'],
  ),

  // -- IUGR ------------------------------------------------------------------
  FindingInfo(
    id: 'iugr',
    name: 'Growth Restriction',
    altName: 'IUGR / FGR',
    tag: TrimesterTag.t3,
    whatIsIt:
        'Your baby is growing more slowly than expected and measuring smaller '
        'than they should for the number of weeks - not simply a constitutionally '
        'small baby, but one whose growth has slowed.',
    whyHappens:
        'Most often the placenta is not delivering quite enough nourishment and '
        'oxygen. It can also relate to high blood pressure, certain infections, '
        'smoking, or (less often) a problem with the baby.',
    symptoms: [
      'Usually none you can feel.',
      'Your bump may measure small on examination.',
      'Sometimes reduced baby movements later on.',
    ],
    diagnosis:
        'Growth scans plotting your baby\'s size over time, with Doppler '
        'blood-flow studies and fluid measurement to judge how your baby is '
        'coping - the trend matters more than a single scan.',
    implications:
        'With close monitoring, many babies are delivered safely at the right '
        'time. It is watched carefully because a baby getting less nourishment '
        'needs the right timing of delivery - which is exactly what monitoring '
        'ensures.',
    management:
        'More frequent growth and Doppler scans, monitoring of movements and '
        'heartbeat (sometimes CTG), managing any blood pressure, and planning '
        'delivery at the safest time. You may be advised to rest and to track '
        'movements closely.',
    whenToContact: [
      'Reduced or changed baby movements - report promptly, do not wait.',
      'Any bleeding, strong contractions, or a headache/vision changes.',
      'If you cannot make a monitoring appointment, call to rearrange soon.',
    ],
    faqs: [
      Faq('Is my baby just naturally small?',
          'Some small babies are simply constitutionally small and well. Growth restriction is when the growth trend slows and Doppler/fluid suggest the placenta is the cause - your doctor distinguishes the two.'),
      Faq('What can I do to help?',
          'Attend all monitoring, track movements, avoid smoking and second-hand smoke, rest, and follow your doctor\'s plan. There is no food that "fixes" it, but good nutrition and rest help.'),
      Faq('Will I need an early delivery?',
          'Possibly. If monitoring shows your baby would be better out than in, your doctor will plan delivery at the safest time.'),
    ],
    aliases: ['iugr', 'fgr', 'growth restriction', 'small baby', 'sga', 'baby small'],
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
