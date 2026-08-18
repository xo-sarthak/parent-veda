// =============================================================================
//  Pregnancy brackets — the L1 column, typed
// -----------------------------------------------------------------------------
//  Ten problem brackets, seven layers each, transcribed from
//  `parentveda-level-map-checklist.xlsx` and audited against real files in
//  `docs/BRACKET-AUDIT.md`. Read that document before changing any state here —
//  it names the resolver behind every `live` cell, and the gate it enforces is
//  that no layer may claim to ship without one.
//
//  ORDER IS THE WORKBOOK'S, AND IT IS ALREADY DEMAND-RANKED. Scans & tests
//  carries anomaly scan ~135,000 and ectopic ~74,000 — the highest-volume entry
//  point in the product. It is door one because of the data, not because of
//  taste. Do not reorder for visual balance.
//
//  ⚠️ EVERY LAYER IS DECLARED ON EVERY BRACKET, including the ones that render
//  nothing. Seventy cells, no defaulting. An omitted layer would inherit
//  someone's assumption, and the assumption people make is that it ships.
//
//  ONE FILE PER STAGE, on purpose — see the plan. The resolver for parenting
//  will import `post_pregnancy/pp_*` data that pregnancy must never depend on,
//  and the stages ship months apart.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/bracket.dart';
import '../../services/life_stage_store.dart';

const _t = LocalizedText.new;

// NOTE ON STYLE: the layer specs below are written out in full rather than
// through one-letter helpers. Shorthands were tried and removed — this table is
// read far more often than it is written, and `_no('Not a fit')` hides the one
// word that decides whether a section can ever appear. The verbosity is the
// point.
//
// The workbook leaves some Extras cells blank. Blank is not the same as "Not a
// fit" — it is "nothing proposed" — and although both render nothing, the
// reason string keeps them distinguishable for whoever reads this next.

final List<Bracket> kPregnancyBrackets = [
  // ---------------------------------------------------------------------------
  //  1. Scans & tests — the highest-volume bracket in the product
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'pregnancy_scans_tests',
    stage: LifeStage.pregnancy,
    theme: 'scans',
    hue: 206, // the only cool blue on the grid — clinical, and findable without reading
    label: _t(en: 'Scans & tests', hi: 'स्कैन और जाँच'),
    title: _t(en: 'Scans & tests', hi: 'स्कैन और जाँचें'),
    blurb: _t(
        en: 'Every scan explained — what it is, why it is done, and what the '
            'result means.',
        hi: 'हर स्कैन आसान भाषा में — कौन-सा, कब, और रिपोर्ट का मतलब क्या है।'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['tests_scans']),
      BracketLayer.activities: BracketLayerSpec(
          state: LayerState.notCore, reason: 'Not core (rides week spine)'),
      // ⚠️ `tests_scans` is deliberately NOT repeated here. It is the library,
      // and the library is Content. Listing it under both layers put the same
      // row on screen twice under two headings — caught on the phone, not in a
      // test, because nothing about it is wrong except how it reads.
      BracketLayer.tools:
          BracketLayerSpec.live(['appointments', 'due_date']),
      BracketLayer.products:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.course: BracketLayerSpec(
          state: LayerState.notCore,
          reason: 'Not standalone (module of childbirth prep)'),
      BracketLayer.consult: BracketLayerSpec.live(['consults']),
      // "Report / result explainer (upload & understand)" — the most
      // distinctive thing in this bracket, and it already exists.
      BracketLayer.extras: BracketLayerSpec.live(['reports'],
          heading: _t(
              en: 'When the report comes back',
              hi: 'जब रिपोर्ट हाथ में आए')),
    },
  ),

  // ---------------------------------------------------------------------------
  //  2. Complications & conditions
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'pregnancy_complications',
    stage: LifeStage.pregnancy,
    theme: 'complications',
    hue: 186,
    label: _t(en: 'Complications', hi: 'जटिलताएँ'),
    title: _t(en: 'Complications & conditions', hi: 'जटिलताएँ और स्थितियाँ'),
    blurb: _t(
        en: 'Gestational diabetes, placenta previa, thyroid, high BP, anaemia — '
            'explained, and managed.',
        hi: 'gestational diabetes, placenta previa, thyroid, high BP, ख़ून की कमी '
            '— समझिए और सँभालिए।'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['tests_scans']),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      // ⚠️ CHANGED FROM THE AUDIT'S FIRST PASS. It read notReady because the
      // workbook asks for "kick counter, sugar & BP log" and we have no sugar
      // or BP log. But the kick counter DOES exist and reduced movement is this
      // bracket's own red flag, so the layer resolves. The missing logs are a
      // listed gap, not an absent layer.
      BracketLayer.tools: BracketLayerSpec.live(['movement']),
      BracketLayer.products: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Glucometer, BP monitor (affiliate)'),
      BracketLayer.course: BracketLayerSpec(
          state: LayerState.notCore, reason: 'Modules, not standalone'),
      BracketLayer.consult: BracketLayerSpec.live(['consults']),
      // The red-flag "when to call / rush" card. The five urgent symptoms
      // already exist in symptom_data.dart and surface in the Companion.
      BracketLayer.extras: BracketLayerSpec.live(['symptoms'],
          heading: _t(
              en: 'When to call someone', hi: 'कब किसी को बुलाना है')),
    },
  ),

  // ---------------------------------------------------------------------------
  //  3. Is it safe in pregnancy?
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'pregnancy_is_it_safe',
    stage: LifeStage.pregnancy,
    theme: 'safety',
    hue: 232,
    label: _t(en: 'Is it safe?', hi: 'सुरक्षित है?'),
    title: _t(
        en: 'Is it safe in pregnancy?', hi: 'क्या यह गर्भावस्था में सुरक्षित है?'),
    blurb: _t(
        en: 'Food, medicines, travel, beauty — what is fine and what is not.',
        hi: 'खाना, दवाइयाँ, सफ़र, ब्यूटी — क्या ठीक है और क्या नहीं।'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['can_i']),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.tools: BracketLayerSpec.live(['can_i']),
      // ⚠️ Both of these carry "Not a fit" in the workbook with NO red fill.
      // Read by colour alone they would have shipped a shopping prompt beside a
      // safety answer. Text wins — see BRACKET-AUDIT.md.
      BracketLayer.products:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.course:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.consult: BracketLayerSpec(
          state: LayerState.notReady, reason: 'Light quick-query consult'),
      BracketLayer.extras: BracketLayerSpec.live(['can_i'],
          heading: _t(
              en: 'Look something up', hi: 'कुछ ढूँढकर देखिए')),
    },
  ),

  // ---------------------------------------------------------------------------
  //  4. Nutrition & diet
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'pregnancy_nutrition',
    stage: LifeStage.pregnancy,
    theme: 'nutrition',
    hue: 104,
    label: _t(en: 'Nutrition', hi: 'पोषण'),
    title: _t(en: 'Nutrition & diet', hi: 'पोषण और आहार'),
    blurb: _t(
        en: 'Trimester diets built around an Indian kitchen, healthy weight '
            'gain, cravings and deficiencies.',
        hi: 'तिमाही के हिसाब से आहार, भारतीय थाली, सेहतमंद वज़न और cravings।'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['nutrition']),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.tools: BracketLayerSpec.live(['nutrition', 'weight']),
      // ⚠️ The clearest commerce gap in the stage: zero supplement or protein
      // category exists, in the bracket with the highest buying intent.
      BracketLayer.products: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Prenatal supplements, protein (affiliate)'),
      BracketLayer.course: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Trimester nutrition masterclass (paid)'),
      BracketLayer.consult: BracketLayerSpec.live(['consults']),
      BracketLayer.extras: BracketLayerSpec(
          state: LayerState.notReady, reason: 'Pregnancy-safe recipe playlist'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  5. Symptoms & discomforts
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'pregnancy_symptoms',
    stage: LifeStage.pregnancy,
    theme: 'symptoms',
    hue: 26,
    label: _t(en: 'Symptoms', hi: 'लक्षण'),
    title: _t(en: 'Symptoms & discomforts', hi: 'लक्षण और तकलीफ़ें'),
    blurb: _t(
        en: 'Nausea, back pain, sleep, swelling, heartburn, cramps — and relief '
            'for each one.',
        hi: 'मतली, कमर दर्द, नींद, सूजन, जलन — हर एक के लिए राहत।'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['symptoms']),
      BracketLayer.activities: BracketLayerSpec.live(['yoga']),
      BracketLayer.tools: BracketLayerSpec.live(['symptoms']),
      BracketLayer.products: BracketLayerSpec.live(['shop']),
      BracketLayer.course:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.consult:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.extras:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'None proposed'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  6. Labour & childbirth prep — the only bracket with every layer live
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'pregnancy_labour',
    stage: LifeStage.pregnancy,
    theme: 'labour',
    hue: 344,
    label: _t(en: 'Labour prep', hi: 'प्रसव तैयारी'),
    title: _t(en: 'Labour & childbirth prep', hi: 'प्रसव और जन्म की तैयारी'),
    blurb: _t(
        en: 'Normal or C-section, the stages of labour, pain relief, a birth '
            'plan, and the bag.',
        hi: 'normal या C-section, प्रसव के चरण, दर्द से राहत, और अस्पताल का बैग।'),
    layers: {
      BracketLayer.content:
          BracketLayerSpec.live(['hospital_bag', 'daily_reads']),
      BracketLayer.activities: BracketLayerSpec.live(['yoga']),
      BracketLayer.tools:
          BracketLayerSpec.live(['contractions', 'hospital_bag', 'kegel']),
      BracketLayer.products: BracketLayerSpec.live(['shop', 'product_guide']),
      BracketLayer.course: BracketLayerSpec.live(
          ['masterclasses', 'cohorts', 'birthing_classes']),
      BracketLayer.consult: BracketLayerSpec.live(['consults']),
      BracketLayer.extras: BracketLayerSpec(
          state: LayerState.notReady, reason: 'Birth-plan builder'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  7. Garbh sanskar & bonding
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'pregnancy_garbh',
    stage: LifeStage.pregnancy,
    theme: 'garbh',
    hue: 42, // saffron — the same warm family the section already uses
    label: _t(en: 'Garbh Sanskar', hi: 'गर्भ संस्कार'),
    title: _t(en: 'Garbh Sanskar & bonding', hi: 'गर्भ संस्कार और जुड़ाव'),
    blurb: _t(
        en: 'Trimester-wise practice — sound, thought, conversation and breath.',
        hi: 'तिमाही के अनुसार अभ्यास — ध्वनि, विचार, संवाद और साँस।'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['garbh_daily']),
      BracketLayer.activities: BracketLayerSpec.live(['garbh_daily']),
      BracketLayer.tools: BracketLayerSpec.live(['garbh_daily']),
      BracketLayer.products: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Garbh sanskar music / books (affiliate)'),
      // ⚠️ The workbook names this the FREE DIFFERENTIATED HERO course, and we
      // own the deepest content asset in the app to build it on. It does not
      // exist. Needs recorded media — see the checklist's owner split.
      BracketLayer.course: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Recorded trimester-wise garbh sanskar (free hero course)'),
      BracketLayer.consult:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.extras:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'None proposed'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  8. Fitness & yoga
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'pregnancy_fitness',
    stage: LifeStage.pregnancy,
    theme: 'fitness',
    hue: 160,
    label: _t(en: 'Yoga & fitness', hi: 'योग और फ़िटनेस'),
    title: _t(en: 'Fitness & yoga', hi: 'फ़िटनेस और योग'),
    blurb: _t(
        en: 'Trimester-safe movement, and what to leave alone.',
        hi: 'तिमाही के लिए सुरक्षित व्यायाम, और किनसे बचना है।'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['yoga']),
      BracketLayer.activities: BracketLayerSpec.live(['yoga']),
      BracketLayer.tools:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.products: BracketLayerSpec(
          state: LayerState.notReady, reason: 'Mat, ball (minor affiliate)'),
      BracketLayer.course: BracketLayerSpec.live(['cohorts', 'masterclasses']),
      BracketLayer.consult: BracketLayerSpec.live(['consults']),
      BracketLayer.extras:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'None proposed'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  9. Pregnancy mental health — thinnest bracket with real demand
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'pregnancy_mental_health',
    stage: LifeStage.pregnancy,
    theme: 'mental_health', // shared with the parenting bracket; the id is not
    hue: 288,
    label: _t(en: 'Mind & mood', hi: 'मन और मूड'),
    title: _t(en: 'Pregnancy mental health', hi: 'गर्भावस्था में मन का स्वास्थ्य'),
    blurb: _t(
        en: 'Anxiety, low mood, and the fears almost everyone has and few say '
            'out loud.',
        hi: 'घबराहट, उदासी, और वे डर जो लगभग सब महसूस करती हैं पर कहती कम हैं।'),
    layers: {
      // ⚠️ Scattered across weekly JSON with no owned data file. Needs writing.
      BracketLayer.content: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Anxiety, prenatal depression, mood, common fears'),
      BracketLayer.activities: BracketLayerSpec.live(['yoga']),
      // ⚠️ A check-in, never a score. No EPDS, no diagnosis — CLAUDE.md.
      BracketLayer.tools:
          BracketLayerSpec(state: LayerState.notReady, reason: 'Mood check'),
      BracketLayer.products:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.course:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.consult: BracketLayerSpec.live(['consults']),
      BracketLayer.extras:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'None proposed'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  10. Belly & skin care — products without the content that earns them
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'pregnancy_belly_skin',
    stage: LifeStage.pregnancy,
    theme: 'skin',
    hue: 12,
    label: _t(en: 'Belly & skin', hi: 'पेट और त्वचा'),
    title: _t(en: 'Belly & skin care', hi: 'पेट और त्वचा की देखभाल'),
    blurb: _t(
        en: 'Stretch marks, pigmentation and itching — what helps, and what is '
            'just marketing.',
        hi: 'stretch marks, रंगत में बदलाव और खुजली — क्या काम आता है, और क्या '
            'सिर्फ़ विज्ञापन है।'),
    layers: {
      // ⚠️ Essentially nothing owned — grep for "melasma" returns nothing.
      BracketLayer.content: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Stretch marks (prevent & treat), pigmentation, itching'),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      // ⚠️ bump_journey is belly MEMORY, not belly CARE. Do not map it here.
      BracketLayer.tools:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.products: BracketLayerSpec.live(['shop']),
      BracketLayer.course:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.consult:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.extras:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'None proposed'),
    },
  ),
];
