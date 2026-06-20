// =============================================================================
//  Understanding Your Report™  — curated seed
// -----------------------------------------------------------------------------
//  Calm, reassurance-first explainers for the most common scan/test findings
//  (all six "popular topics" + several more). GENERAL educational guidance — not
//  a diagnosis, not a prediction — written to leave a worried mother CALMER, per
//  the spec's writing rules (never "dangerous/serious/fatal"; "what does this
//  mean?" before "what are the risks?"). Needs medical review before the long
//  tail is expanded to the full ~27-condition launch list.
//
//  English-first: `_t` / `_l` mirror en into hi so Hindi can be authored later.
// =============================================================================

import '../localization/app_language.dart';
import '../models/report_finding.dart';

LocalizedText _t(String s) => LocalizedText(en: s, hi: s);
List<LocalizedText> _l(List<String> xs) => xs.map(_t).toList();

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
    name: _t('Low-Lying Placenta'),
    altName: _t('Placenta Previa'),
    weekFrom: 18,
    weekTo: 22,
    whatItMeans: _t(
        'This means the placenta is sitting lower in the uterus than usual, near or over the cervix. In most cases it gradually moves upward and out of the way as the uterus grows.'),
    howCommon: _t(
        'It is a common finding on the mid-pregnancy scan. In the large majority of cases the placenta moves higher on its own later in pregnancy.'),
    whatNext: _t(
        'Your doctor will usually arrange a follow-up scan later in pregnancy to check the placenta\'s position. That scan helps guide any plans for your delivery.'),
    questions: _l([
      'Has the placenta moved since my last scan?',
      'Will I need another scan to check the position?',
      'Does this change anything about my delivery plan?',
    ]),
    remember: _l([
      'Most low-lying placentas move up on their own.',
      'Follow-up scans for this are very common.',
      'Your provider will keep an eye on it over time.',
    ]),
    aliases: ['placenta', 'previa', 'placenta previa', 'low placenta'],
  ),
  ReportFinding(
    id: 'breech',
    name: _t('Breech Position'),
    altName: _t('Breech Baby'),
    weekFrom: 32,
    weekTo: 36,
    whatItMeans: _t(
        'This means your baby is currently positioned bottom- or feet-down rather than head-down. Many babies are breech earlier in pregnancy and turn head-down on their own before birth.'),
    howCommon: _t(
        'Being breech is common through much of pregnancy. The number of babies who stay breech keeps falling as the due date comes closer.'),
    whatNext: _t(
        'Your doctor will keep checking your baby\'s position. If your baby is still breech later on, they may discuss gentle options to encourage turning, or the safest way to plan your birth.'),
    questions: _l([
      'Is there still time for the baby to turn?',
      'What are my options if the baby stays breech?',
      'Would you recommend anything to help the baby turn?',
    ]),
    remember: _l([
      'Many babies turn head-down on their own before birth.',
      'Position is checked again as you get closer to term.',
      'There are safe options if your baby stays breech.',
    ]),
    aliases: ['breech', 'breech baby', 'baby position', 'footling'],
  ),
  ReportFinding(
    id: 'nuchal_cord',
    name: _t('Cord Around Neck'),
    altName: _t('Nuchal Cord'),
    weekFrom: 36,
    whatItMeans: _t(
        'This means the umbilical cord is looped around the baby\'s neck. Scans often pick this up, and in most pregnancies it does not cause problems — the cord is built to keep delivering oxygen.'),
    howCommon: _t(
        'A nuchal cord is a frequent scan finding, especially closer to term. Many babies are born safely with a cord around the neck.'),
    whatNext: _t(
        'Your doctor will note it and continue routine monitoring of your baby. It usually does not change how your birth is planned.'),
    questions: _l([
      'Does this change anything about my delivery?',
      'Will you keep monitoring the baby during labour?',
      'Is there anything I should watch for?',
    ]),
    remember: _l([
      'A nuchal cord is common and often unwinds on its own.',
      'The cord keeps supplying oxygen throughout.',
      'Your team monitors the baby closely during labour.',
    ]),
    aliases: ['cord', 'nuchal cord', 'cord around neck', 'cord around baby'],
  ),
  ReportFinding(
    id: 'gestational_diabetes',
    name: _t('Gestational Diabetes'),
    altName: _t('GDM'),
    weekFrom: 24,
    weekTo: 28,
    whatItMeans: _t(
        'This means your body is having some trouble managing blood sugar during pregnancy. With the right steps it is usually well controlled, and it most often goes away after the baby is born.'),
    howCommon: _t(
        'Gestational diabetes is one of the more common findings, picked up by a routine sugar test in mid-pregnancy.'),
    whatNext: _t(
        'Your doctor will guide you on diet, gentle activity and checking your sugar levels. Some mothers also need medication. Regular check-ins help keep everything on track.'),
    questions: _l([
      'What diet changes would help most?',
      'How often should I check my sugar levels?',
      'Will this affect my delivery?',
    ]),
    remember: _l([
      'It is usually well managed with simple changes.',
      'It most often resolves after birth.',
      'Your care team will support you through it.',
    ]),
    aliases: ['gestational diabetes', 'gdm', 'diabetes', 'sugar', 'high sugar', 'gtt'],
  ),
  ReportFinding(
    id: 'low_fluid',
    name: _t('Low Amniotic Fluid'),
    altName: _t('Oligohydramnios'),
    weekFrom: 30,
    weekTo: 40,
    whatItMeans: _t(
        'This means the amount of fluid around your baby is on the lower side. The level can change, and your doctor will look at it alongside how your baby is growing and moving.'),
    howCommon: _t(
        'Lower fluid levels are sometimes seen on later scans, and the reading can vary from one scan to the next.'),
    whatNext: _t(
        'Your doctor may suggest extra fluids, more frequent scans, or closer monitoring of your baby. The plan depends on how far along you are and how your baby is doing.'),
    questions: _l([
      'Would drinking more water help?',
      'How often will the fluid be re-checked?',
      'How is my baby\'s growth and movement?',
    ]),
    remember: _l([
      'Fluid levels can change between scans.',
      'Extra monitoring is a common, careful step.',
      'Staying well hydrated is often advised.',
    ]),
    aliases: ['low fluid', 'amniotic fluid', 'oligohydramnios', 'low water', 'afi', 'liquor'],
  ),
  ReportFinding(
    id: 'preeclampsia',
    name: _t('Preeclampsia'),
    weekFrom: 20,
    whatItMeans: _t(
        'This means your blood pressure is raised during pregnancy, sometimes with other signs that your body needs closer attention. It is something doctors watch carefully and manage step by step.'),
    howCommon: _t(
        'It is a recognised pregnancy finding that care teams screen for at routine visits — which is why your blood pressure and urine are checked each time.'),
    whatNext: _t(
        'Your doctor will monitor your blood pressure more closely, may run some tests, and will guide the timing and plan for a safe delivery. Rest and follow-up visits are usually part of this.'),
    questions: _l([
      'How often should my blood pressure be checked?',
      'Are there any signs I should call you about?',
      'How might this affect the timing of delivery?',
    ]),
    remember: _l([
      'It is usually found through the routine checks at your visits.',
      'Closer monitoring helps your team manage it well.',
      'Your provider will guide every next step.',
    ]),
    aliases: ['preeclampsia', 'pre eclampsia', 'high bp', 'blood pressure', 'pih', 'protein in urine'],
  ),
  ReportFinding(
    id: 'high_fluid',
    name: _t('High Amniotic Fluid'),
    altName: _t('Polyhydramnios'),
    weekFrom: 28,
    weekTo: 40,
    whatItMeans: _t(
        'This means there is a little more fluid around your baby than average. In many cases no specific cause is found and the pregnancy continues well.'),
    howCommon: _t(
        'Higher fluid levels are sometimes noted on later scans, and are often mild.'),
    whatNext: _t(
        'Your doctor may recommend follow-up scans and a few checks to understand the cause, while keeping an eye on your comfort and your baby\'s growth.'),
    questions: _l([
      'Is there a cause we should look into?',
      'Will I need more scans?',
      'Is there anything I should watch for?',
    ]),
    remember: _l([
      'Mild increases are often harmless.',
      'A clear cause is not always found, and that is okay.',
      'Follow-up keeps everything monitored.',
    ]),
    aliases: ['high fluid', 'polyhydramnios', 'excess fluid', 'too much water', 'afi high'],
  ),
  ReportFinding(
    id: 'short_cervix',
    name: _t('Short Cervix'),
    weekFrom: 18,
    weekTo: 24,
    whatItMeans: _t(
        'This means the cervix is measuring shorter than average on a scan. Your doctor pays attention to this because it helps them support a full-term pregnancy.'),
    howCommon: _t(
        'It is a finding that mid-pregnancy scans can pick up, and there are well-established ways to support it.'),
    whatNext: _t(
        'Depending on the measurement, your doctor may suggest follow-up scans, more rest, or a simple supportive treatment. They will tailor the plan to you.'),
    questions: _l([
      'Will the cervix length be measured again?',
      'Is there a treatment that would help?',
      'Is there anything I should do differently?',
    ]),
    remember: _l([
      'There are established ways to support a short cervix.',
      'Follow-up measurements are common.',
      'Your provider will personalise the plan.',
    ]),
    aliases: ['short cervix', 'cervix', 'cervical length', 'cervical'],
  ),
  ReportFinding(
    id: 'placental_calcification',
    name: _t('Placental Calcification'),
    weekFrom: 28,
    weekTo: 40,
    whatItMeans: _t(
        'This means small calcium deposits are showing in the placenta. This is a normal part of the placenta maturing as pregnancy goes on, especially later.'),
    howCommon: _t(
        'Calcification is a common observation on later scans, and is often simply a sign of a maturing placenta.'),
    whatNext: _t(
        'Usually no special action is needed. Your doctor will continue routine monitoring of your baby\'s growth and wellbeing.'),
    questions: _l([
      'Does this affect my baby\'s growth?',
      'Is any extra monitoring needed?',
      'Is this expected for my stage of pregnancy?',
    ]),
    remember: _l([
      'It is often a normal sign of a maturing placenta.',
      'It is commonly seen on later scans.',
      'Routine monitoring usually continues as normal.',
    ]),
    aliases: ['placental calcification', 'calcification', 'placenta grade', 'grade 3 placenta', 'placenta'],
  ),
  ReportFinding(
    id: 'twin_pregnancy',
    name: _t('Twin Pregnancy'),
    weekFrom: 6,
    weekTo: 12,
    whatItMeans: _t(
        'This means you are expecting more than one baby. Twin pregnancies are followed a little more closely, with some extra scans and visits to support you and your babies.'),
    howCommon: _t(
        'Twins are usually identified on an early scan. They are well understood and routinely cared for.'),
    whatNext: _t(
        'Your doctor will arrange a schedule of extra scans and check-ups to monitor growth and wellbeing, and will talk you through what to expect.'),
    questions: _l([
      'How often will I have scans and visits?',
      'What extra care does a twin pregnancy need?',
      'What should I expect around delivery?',
    ]),
    remember: _l([
      'Twin pregnancies are routinely and safely cared for.',
      'Extra scans are a normal, supportive step.',
      'Your team will guide you the whole way.',
    ]),
    aliases: ['twin', 'twins', 'twin pregnancy', 'multiple', 'two babies'],
  ),
  ReportFinding(
    id: 'anemia',
    name: _t('Anemia During Pregnancy'),
    whatItMeans: _t(
        'This means your blood has fewer healthy red cells or less iron than ideal — common in pregnancy as your body makes more blood for your baby. It is usually straightforward to improve.'),
    howCommon: _t(
        'Mild anemia is very common in pregnancy and is picked up by routine blood tests.'),
    whatNext: _t(
        'Your doctor will usually recommend iron-rich foods and often an iron supplement, then re-check your levels. Most mothers improve with these simple steps.'),
    questions: _l([
      'Which iron supplement and dose do you recommend?',
      'Which foods would help most?',
      'When should we re-check my levels?',
    ]),
    remember: _l([
      'Mild anemia in pregnancy is very common.',
      'It usually improves with iron and diet.',
      'Levels are simply re-checked after treatment.',
    ]),
    aliases: ['anemia', 'anaemia', 'low hemoglobin', 'low hb', 'iron', 'haemoglobin'],
  ),
  ReportFinding(
    id: 'reduced_movements',
    name: _t('Reduced Fetal Movements'),
    weekFrom: 28,
    whatItMeans: _t(
        'This means your baby\'s movements have felt less frequent or different than usual. Movement patterns naturally change, and getting it checked is always the right thing to do.'),
    howCommon: _t(
        'Many mothers notice changes in movement at some point. It is one of the most common reasons for a quick reassurance check.'),
    whatNext: _t(
        'If you ever feel reduced movements, contact your doctor or hospital — they will check your baby, often with a simple heartbeat or monitoring test. It is always okay to get checked.'),
    questions: _l([
      'What is the best way to monitor movements?',
      'When exactly should I call you?',
      'Can I come in for a reassurance check?',
    ]),
    remember: _l([
      'Always get reduced movements checked — never wait it out.',
      'A reassurance check is quick and very common.',
      'You know your baby\'s usual pattern best.',
    ]),
    aliases: ['reduced movements', 'baby not moving', 'less movement', 'fetal movements', 'kicks'],
  ),
  ReportFinding(
    id: 'braxton_hicks',
    name: _t('Braxton Hicks Contractions'),
    weekFrom: 20,
    whatItMeans: _t(
        'This means you are feeling practice contractions — your uterus tightening and relaxing as it prepares for labour. They are usually irregular and ease off with rest or a change of position.'),
    howCommon: _t(
        'Braxton Hicks are a very common, normal part of the second half of pregnancy.'),
    whatNext: _t(
        'Usually nothing is needed beyond rest, water and changing position. Your doctor will explain how to tell these apart from real labour, and when to call.'),
    questions: _l([
      'How do I tell these apart from real labour?',
      'When should I call you about contractions?',
      'Is there anything that helps ease them?',
    ]),
    remember: _l([
      'They are practice contractions, usually harmless.',
      'They tend to be irregular and ease with rest.',
      'Your provider will explain the signs of real labour.',
    ]),
    aliases: ['braxton hicks', 'practice contractions', 'false labour', 'tightening', 'contractions'],
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
