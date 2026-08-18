// =============================================================================
//  Parenting brackets — the L1 column for the after-birth stage
// -----------------------------------------------------------------------------
//  Eleven brackets, seven layers each, transcribed from the workbook and audited
//  against real files. Same rules as pregnancy (see pregnancy_brackets.dart):
//  every cell declared, no defaulting, every `live` naming a resolver, and every
//  non-live cell carrying the workbook's reason verbatim.
//
//  ⚠️ PARENTING IS THE OPPOSITE SHAPE TO PREGNANCY, and it changes what the
//  grid will feel like. Pregnancy's gaps were commerce — Products, Courses and
//  Consults were thin while content was deep. Parenting's content is deep AND
//  its commerce exists (23 SKUs, 15 programs, 6 experts), so most brackets fill
//  out. The gaps are instead **three brackets that barely exist at all**:
//
//    · Potty training      — two sentences inside a phase description
//    · Early learning      — one line, and the "learning" screens are the
//                            PARENT course catalogue, not child learning
//    · First 40 days       — a masterclass by that name, and nothing else.
//                            No day-1..40 structure, no "jaapa" anywhere
//
//  Those three are the honest reason this stage will look uneven, and the
//  unevenness is correct: rendering seven confident sections over two sentences
//  is exactly the filler the workbook exists to prevent.
//
//  SURFACE IDS ARE `pp_`-PREFIXED and resolve through `parenting_surfaces.dart`,
//  not `app_structure.dart` — see that file for why the two stages cannot share
//  one surface list.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/bracket.dart';
import '../../services/life_stage_store.dart';

const _t = LocalizedText.new;

final List<Bracket> kParentingBrackets = [
  // ---------------------------------------------------------------------------
  //  1. Sleep — the strongest bracket in the stage
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'parenting_sleep',
    stage: LifeStage.parenting,
    theme: 'sleep',
    hue: 232,
    label: _t(en: 'Sleep', hi: 'नींद'),
    title: _t(en: 'Sleep', hi: 'नींद'),
    blurb: _t(
        en: 'Safe sleep, day and night, schedules — and the regressions that '
            'undo all of it for a fortnight.',
        hi: 'सुरक्षित नींद, दिन-रात का फ़र्क़, और वे दौर जब सब गड़बड़ा जाता है।'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['pp_read', 'pp_watch']),
      // Wind-down routine and drowsy-but-awake practice are named in the
      // workbook and do not exist as activities — the Grow engine's 39
      // activities are developmental, not sleep-specific.
      BracketLayer.activities: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Wind-down routine, drowsy-but-awake practice'),
      BracketLayer.tools:
          BracketLayerSpec.live(['pp_sleep', 'pp_what_changed']),
      BracketLayer.products: BracketLayerSpec.live(['pp_products']),
      BracketLayer.course: BracketLayerSpec.live(['pp_courses']),
      BracketLayer.consult: BracketLayerSpec.live(['pp_experts']),
      BracketLayer.extras: BracketLayerSpec.live(['pp_nuskhe'],
          heading: _t(
              en: 'What the grandmothers say', hi: 'दादी-नानी क्या कहती हैं')),
    },
  ),

  // ---------------------------------------------------------------------------
  //  2. Feeding
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'parenting_feeding',
    stage: LifeStage.parenting,
    theme: 'feeding',
    hue: 104,
    label: _t(en: 'Feeding', hi: 'खिलाना'),
    title: _t(en: 'Feeding', hi: 'दूध और खाना'),
    blurb: _t(
        en: 'Latch and supply, bottles, and the long slow start of solids.',
        hi: 'स्तनपान, बोतल, और ठोस आहार की धीमी शुरुआत।'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['pp_food', 'pp_read']),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.tools:
          BracketLayerSpec.live(['pp_feeding', 'pp_growth', 'pp_what_changed']),
      BracketLayer.products: BracketLayerSpec.live(['pp_products']),
      BracketLayer.course: BracketLayerSpec.live(['pp_courses']),
      // ⚠️ The workbook calls lactation "the most certain sale" in the stage.
      // `kFindHelpNeeds` lists "Lactation expert" as a need; none of the six
      // experts in `kExperts` is one. The demand is declared and the supply is
      // not there.
      BracketLayer.consult: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Lactation (paid, most certain sale) + pediatric nutrition'),
      BracketLayer.extras: BracketLayerSpec.live(['pp_food'],
          heading: _t(en: 'What to cook', hi: 'क्या पकाएँ')),
    },
  ),

  // ---------------------------------------------------------------------------
  //  3. Health & illness
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'parenting_health',
    stage: LifeStage.parenting,
    theme: 'health',
    hue: 186,
    label: _t(en: 'Health', hi: 'सेहत'),
    title: _t(en: 'Health & illness', hi: 'सेहत और बीमारी'),
    blurb: _t(
        en: 'Fever, rashes, colic, teething — what it is, and when it stops '
            'being ordinary.',
        hi: 'बुख़ार, रैश, पेट दर्द, दाँत आना — और कब यह सामान्य नहीं रह जाता।'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['pp_read', 'pp_watch']),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.tools: BracketLayerSpec.live(
          ['pp_vaccines', 'pp_health', 'pp_what_changed', 'pp_growth']),
      BracketLayer.products: BracketLayerSpec.live(['pp_products']),
      BracketLayer.course: BracketLayerSpec(
          state: LayerState.notApplicable,
          reason: 'Not a fit (reactive; content + consult)'),
      BracketLayer.consult: BracketLayerSpec.live(['pp_experts']),
      BracketLayer.extras: BracketLayerSpec.live(['pp_health'],
          heading: _t(
              en: 'Before the doctor visit', hi: 'डॉक्टर के पास जाने से पहले')),
    },
  ),

  // ---------------------------------------------------------------------------
  //  4. Milestones & development — rides the stage's own spine
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'parenting_development',
    stage: LifeStage.parenting,
    theme: 'development',
    hue: 268,
    label: _t(en: 'Development', hi: 'विकास'),
    title: _t(
        en: 'Milestones & development', hi: 'पड़ाव और विकास'),
    blurb: _t(
        en: 'What is coming, what is late, and what is simply a different '
            'child.',
        hi: 'आगे क्या आना है, कब देर मानी जाए, और कब बच्चा बस अलग है।'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['pp_development']),
      BracketLayer.activities: BracketLayerSpec.live(['pp_activities']),
      BracketLayer.tools:
          BracketLayerSpec.live(['pp_milestones', 'pp_development']),
      BracketLayer.products:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.course: BracketLayerSpec.live(['pp_courses']),
      BracketLayer.consult: BracketLayerSpec.live(['pp_experts']),
      BracketLayer.extras:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'None proposed'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  5. Behaviour & psychology
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'parenting_behaviour',
    stage: LifeStage.parenting,
    theme: 'behaviour',
    hue: 344,
    label: _t(en: 'Behaviour', hi: 'व्यवहार'),
    title: _t(en: 'Behaviour & psychology', hi: 'व्यवहार और मन'),
    blurb: _t(
        en: 'Tantrums, biting, screens, sharing — and what is actually going on '
            'underneath.',
        hi: 'ग़ुस्सा, काटना, स्क्रीन, बाँटना — और अंदर असल में क्या चल रहा है।'),
    layers: {
      // ⚠️ One article. No dedicated data file. The eight behaviour concerns in
      // What Changed are the only real depth here, and they are a tool, not
      // content.
      BracketLayer.content: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Tantrums, discipline, screen time, biting / hitting, sharing'),
      BracketLayer.activities: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Connection / regulation techniques'),
      BracketLayer.tools: BracketLayerSpec.live(['pp_what_changed']),
      BracketLayer.products: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Emotion cards, books (minor affiliate)'),
      BracketLayer.course: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Positive discipline / toddler behaviour masterclass (paid)'),
      BracketLayer.consult: BracketLayerSpec.live(['pp_experts']),
      BracketLayer.extras: BracketLayerSpec(
          state: LayerState.notReady,
          reason: "'What to say when...' script library"),
    },
  ),

  // ---------------------------------------------------------------------------
  //  6. Potty training — two sentences exist. Nothing else does.
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'parenting_potty',
    stage: LifeStage.parenting,
    theme: 'potty',
    hue: 160,
    label: _t(en: 'Potty training', hi: 'टॉयलेट ट्रेनिंग'),
    title: _t(en: 'Potty training', hi: 'टॉयलेट ट्रेनिंग'),
    blurb: _t(
        en: 'Readiness, methods, nights, and the setbacks nobody warns about.',
        hi: 'तैयारी, तरीक़े, रातें, और वे झटके जिनके बारे में कोई नहीं बताता।'),
    layers: {
      BracketLayer.content: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Readiness signs, methods, night training, regressions'),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notReady, reason: 'Potty routine'),
      BracketLayer.tools:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'None proposed'),
      BracketLayer.products: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Potty seat, training pants (affiliate)'),
      BracketLayer.course: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Short potty-training masterclass (paid, low ticket)'),
      BracketLayer.consult:
          BracketLayerSpec(state: LayerState.notReady, reason: 'Light'),
      BracketLayer.extras:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'None proposed'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  7. Early learning — the biggest demand in the stage, and near-zero built
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'parenting_early_learning',
    stage: LifeStage.parenting,
    theme: 'early_learning',
    hue: 42,
    label: _t(en: 'Early learning', hi: 'शुरुआती सीख'),
    title: _t(
        en: 'Early learning & school readiness', hi: 'शुरुआती सीख और स्कूल की तैयारी'),
    blurb: _t(
        en: 'Montessori at home, habits, stories — and what school actually '
            'expects.',
        hi: 'घर पर Montessori, आदतें, कहानियाँ — और स्कूल असल में क्या चाहता है।'),
    layers: {
      // ⚠️ THE LARGEST GAP IN THE STAGE, by demand: montessori ~18,100 ·
      // kids activities ~27,100 · good habits ~14,800 · moral stories ~27,100.
      // The `learning_*` screens are the PARENT course catalogue and must not
      // be mapped here — that would be the wrong audience behind a right label.
      BracketLayer.content: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Montessori-at-home, activities, good habits, moral stories'),
      BracketLayer.activities: BracketLayerSpec.live(['pp_activities']),
      BracketLayer.tools:
          BracketLayerSpec(state: LayerState.notReady, reason: 'Not strong'),
      BracketLayer.products: BracketLayerSpec.live(['pp_recos']),
      BracketLayer.course: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Early-learning / school-readiness masterclass + activity box'),
      BracketLayer.consult:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.extras: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Bridges into skilling (Stage 4)'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  8. First 40 days — a masterclass by that name, and nothing else
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'parenting_first_40',
    stage: LifeStage.parenting,
    theme: 'first_40',
    hue: 26,
    label: _t(en: 'First 40 days', hi: 'पहले 40 दिन'),
    title: _t(en: 'The first 40 days', hi: 'पहले चालीस दिन'),
    blurb: _t(
        en: 'Newborn care, and looking after the person who just gave birth.',
        hi: 'नवजात की देखभाल, और उस माँ की भी जिसने अभी जन्म दिया है।'),
    layers: {
      BracketLayer.content: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Newborn care A-Z, feeding / sleep basics, mother recovery'),
      BracketLayer.activities: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Newborn soothing, malish, baby-wearing'),
      BracketLayer.tools: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Newborn feed / sleep / diaper tracker'),
      BracketLayer.products: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Postpartum care kit, malish oil, newborn essentials'),
      // The one thing that does exist: a recorded masterclass of that name.
      BracketLayer.course: BracketLayerSpec.live(['pp_courses']),
      BracketLayer.consult: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Newborn-care + lactation consult'),
      BracketLayer.extras:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'None proposed'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  9. Maternal & postpartum recovery — the mother, in a stage about the child
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'parenting_maternal',
    stage: LifeStage.parenting,
    theme: 'mental_health', // shares a theme with pregnancy_mental_health
    hue: 288,
    label: _t(en: 'You', hi: 'आप'),
    title: _t(en: 'Your own recovery', hi: 'आपकी अपनी रिकवरी'),
    blurb: _t(
        en: 'Healing, mood, pelvic floor, going back to work — the half of this '
            'stage nobody asks about.',
        hi: 'शरीर, मन, pelvic floor, काम पर लौटना — इस दौर का वह हिस्सा जिसके '
            'बारे में कोई नहीं पूछता।'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['pp_read', 'pp_watch']),
      BracketLayer.activities: BracketLayerSpec.live(['pp_yoga']),
      BracketLayer.tools: BracketLayerSpec(
          state: LayerState.notReady, reason: 'No maternal tracker exists'),
      // ⚠️ Every one of the 23 SKUs is for the baby. Nothing in the shop is for
      // the mother, in the stage where she is recovering from surgery or birth.
      BracketLayer.products: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Postpartum belt, nursing essentials'),
      BracketLayer.course: BracketLayerSpec.live(['pp_courses']),
      BracketLayer.consult: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Maternal mental-health counselling; pelvic-floor physio'),
      BracketLayer.extras: BracketLayerSpec(
          state: LayerState.notReady,
          reason: '4th-trimester peer circle (community)'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  10. Buying guides — the commerce bracket, and the app's strongest
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'parenting_buying',
    stage: LifeStage.parenting,
    theme: 'commerce',
    hue: 12,
    label: _t(en: 'What to buy', hi: 'क्या ख़रीदें'),
    title: _t(en: 'Buying guides', hi: 'ख़रीदने की गाइड'),
    blurb: _t(
        en: 'What you actually need, what you do not, and how to tell the '
            'difference.',
        hi: 'क्या वाक़ई चाहिए, क्या नहीं, और फ़र्क़ कैसे पहचानें।'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['pp_product_guide']),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.tools:
          BracketLayerSpec.live(['pp_product_guide', 'pp_recos']),
      BracketLayer.products: BracketLayerSpec.live(['pp_products']),
      BracketLayer.course:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.consult:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.extras:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'None proposed'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  11. Traditional & cultural
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'parenting_traditional',
    stage: LifeStage.parenting,
    theme: 'tradition',
    hue: 206,
    label: _t(en: 'Traditions', hi: 'रीति-रिवाज'),
    title: _t(en: 'Traditional & cultural', hi: 'रीति-रिवाज और परंपरा'),
    blurb: _t(
        en: 'Annaprashan, mundan, naming, malish — held up honestly against '
            'what the evidence says.',
        hi: 'अन्नप्राशन, मुंडन, नामकरण, मालिश — और विज्ञान इन पर क्या कहता है।'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['pp_nuskhe']),
      BracketLayer.activities: BracketLayerSpec(
          state: LayerState.notReady, reason: 'Ritual or event how-tos'),
      BracketLayer.tools: BracketLayerSpec.live(['pp_nuskhe', 'pp_names']),
      BracketLayer.products: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Ceremony essentials (minor affiliate)'),
      BracketLayer.course:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.consult:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.extras:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'None proposed'),
    },
  ),
];
