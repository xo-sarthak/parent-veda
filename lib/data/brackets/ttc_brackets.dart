// =============================================================================
//  TTC brackets — the L1 column for Trying to Conceive
// -----------------------------------------------------------------------------
//  Seven problem brackets, seven layers each, transcribed from
//  `parentveda-level-map-checklist.xlsx` (the PRECONCEPTION rows) and audited
//  against real files. Order is the workbook's.
//
//  ⚠️ THE FINDING THAT MATTERS MOST HERE, because it inverts what the other two
//  stages taught: **TTC's Course and Consult layers are the STRONGEST in the
//  product, not the weakest.**
//
//  In pregnancy and parenting those two columns are almost entirely `notReady` —
//  five specialists with mock slots against forty brackets. TTC has THIRTEEN
//  real offerings in `lib/ttc/ttc_prepare_data.dart`, priced, with named
//  experts, and they line up against the workbook's asks almost cell for cell:
//  "The PCOS programme" for the PCOS course, "The half nobody talks about" for
//  male fertility, "After a loss", "Preparing for IVF", "Fertility, honestly"
//  for the conception-basics masterclass the workbook wanted.
//
//  So the shape of this stage's grid is genuinely different, and that is data
//  rather than taste: TTC is the stage where the paid layer is real.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE ONE RULE THIS TABLE NEEDED THAT THE OTHER TWO DID NOT
//  ---------------------------------------------------------------------------
//
//  Four cells put the workbook's refusal against something we have DEMONSTRABLY
//  SHIPPED. "Not a fit (too clinical to package)" sits on Infertility → Course,
//  and `ttc_course_ivf` — "Preparing for IVF" — is live in Prepare today.
//
//  Neither half can simply win:
//
//    · Marking it `notApplicable` would say the thing must NEVER exist, while
//      it is on sale two taps away. The table would be lying about inventory.
//    · Marking it `live` would overrule a product decision that has a stated
//      reason — don't merchandise IVF inside the IVF explainer, where she is
//      frightened and reading rather than shopping.
//
//  So: **a refusal that collides with shipped inventory becomes `notCore`, not
//  `notApplicable`.** It exists, and it belongs on Prepare rather than here.
//  Both halves survive: the workbook keeps its intent (no shop inside the
//  explainer) and the table keeps telling the truth (the thing is real).
//
//  `notApplicable` is reserved for refusals with NOTHING behind them — where the
//  workbook said no and we also built nothing. That keeps the strongest state in
//  the enum meaning exactly one thing.
//
//  The four affected cells are marked ⚑ below. **They are the user's call to
//  re-rule, and until they do, the conservative reading applies.**
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/bracket.dart';
import '../../services/life_stage_store.dart';

const _t = LocalizedText.new;

// ⚠️ HINGLISH, NOT DEVANAGARI — and this is the one bracket table where that is
// correct. Per CLAUDE.md the Devanagari migration covers the PREGNANCY stage
// only; TTC's entire chrome is still Hinglish (`ttc_strings.dart`). Devanagari
// door labels inside a Hinglish shell would be worse than either choice made
// consistently. These move when the stage does, in one pass.

final List<Bracket> kTtcBrackets = [
  // ---------------------------------------------------------------------------
  //  1. Conceiving & fertile window — the stage spine's own bracket
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'ttc_conceiving',
    stage: LifeStage.tryingToConceive,
    theme: 'cycle',
    hue: 344, // the stage's own rose — door one, and the only one at this hue
    label: _t(en: 'Fertile window', hi: 'Fertile window'),
    title: _t(en: 'Conceiving & the fertile window', hi: 'Conceive karna aur fertile window'),
    blurb: _t(
        en: 'How conception actually works — timing, cycle basics, and the '
            'myths worth putting down.',
        hi: 'Conception hota kaise hai — timing, cycle ki basics, aur wo myths '
            'jinhe chhod dena behtar hai.'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['ttc_chapter', 'ttc_can_i']),
      BracketLayer.activities: BracketLayerSpec(
          state: LayerState.notCore, reason: 'Not core (prep sits in mind-body)'),
      BracketLayer.tools: BracketLayerSpec.live(
          ['ttc_cycle', 'ttc_ovulation', 'ttc_window', 'ttc_calendar']),
      BracketLayer.products: BracketLayerSpec.live(['ttc_products']),
      // "Short 'conception basics' masterclass (low ticket)" — shipped, as
      // `ttc_course_basics`, "Fertility, honestly", 90 minutes, ₹299.
      BracketLayer.course: BracketLayerSpec.live(['ttc_prepare']),
      BracketLayer.consult: BracketLayerSpec.live(['ttc_prepare']),
      BracketLayer.extras: BracketLayerSpec(
          state: LayerState.notApplicable, reason: 'Nothing proposed'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  2. PCOS & hormonal blocks — the highest-demand bracket in the stage
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'ttc_pcos',
    stage: LifeStage.tryingToConceive,
    theme: 'hormonal',
    hue: 288,
    label: _t(en: 'PCOS', hi: 'PCOS'),
    title: _t(en: 'PCOS & hormonal blocks', hi: 'PCOS aur hormonal rukawatein'),
    blurb: _t(
        en: 'PCOS and fertility — symptoms, insulin and diet, and getting a '
            'cycle back to something readable.',
        hi: 'PCOS aur fertility — symptoms, insulin aur diet, aur cycle ko wapas '
            'padhne layak banana.'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['ttc_chapter']),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      // ⚠️ HALF OF WHAT THE WORKBOOK ASKED FOR. It wants "PCOS symptom checker,
      // cycle tracker"; the cycle tracker ships and the symptom checker does
      // not. The layer is live because it RESOLVES — she gets a real tool — and
      // the missing half is a listed gap rather than an absent layer. Same call
      // as pregnancy's Complications → Tools.
      BracketLayer.tools: BracketLayerSpec.live(['ttc_cycle', 'ttc_calendar']),
      BracketLayer.products: BracketLayerSpec.live(['ttc_supplements']),
      // "PCOS & Conception (paid flagship of stage)" — shipped as
      // `ttc_cohort_pcos`, "The PCOS programme".
      BracketLayer.course: BracketLayerSpec.live(['ttc_prepare']),
      BracketLayer.consult: BracketLayerSpec.live(['ttc_prepare']),
      BracketLayer.extras: BracketLayerSpec(
          state: LayerState.notApplicable, reason: 'Nothing proposed'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  3. Infertility & IVF
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'ttc_infertility',
    stage: LifeStage.tryingToConceive,
    theme: 'treatment',
    hue: 206,
    label: _t(en: 'IVF & IUI', hi: 'IVF aur IUI'),
    title: _t(en: 'Infertility & IVF', hi: 'Infertility aur IVF'),
    blurb: _t(
        en: 'When to seek help, which tests matter, and what IUI and IVF '
            'actually involve — including what they cost.',
        hi: 'Madad kab lein, kaunse tests maayne rakhte hain, aur IUI-IVF mein '
            'hota kya hai — kharch samet.'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['ttc_treatment']),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.tools: BracketLayerSpec(
          state: LayerState.notReady,
          reason: "'See a specialist?' readiness checklist"),
      // The workbook's refusal, and nothing shipped behind it — so this one is a
      // true `notApplicable`. Selling anything on this screen would be the
      // single worst placement in the product.
      BracketLayer.products: BracketLayerSpec(
          state: LayerState.notApplicable, reason: 'Not a fit (clinical)'),
      // ⚑ CONFLICT. Workbook: "Not a fit (too clinical to package)". Reality:
      // `ttc_cohort_ivf`, "Preparing for IVF", ships in Prepare. Resolved as
      // notCore per the rule at the head of this file — it exists, it is not
      // shown HERE.
      BracketLayer.course: BracketLayerSpec(
          state: LayerState.notCore,
          reason: 'Workbook: "Not a fit (too clinical to package)". '
              '"Preparing for IVF" ships in Prepare — not merchandised here'),
      BracketLayer.consult: BracketLayerSpec.live(['ttc_prepare']),
      // "Report / test explainer" — the most distinctive thing in this bracket,
      // and both halves already exist.
      BracketLayer.extras: BracketLayerSpec.live(
          ['ttc_records', 'ttc_tests'],
          heading: _t(
              en: 'When the report comes back',
              hi: 'Jab report haath mein aaye')),
    },
  ),

  // ---------------------------------------------------------------------------
  //  4. Preconception health & nutrition
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'ttc_preconception_health',
    stage: LifeStage.tryingToConceive,
    theme: 'nutrition',
    hue: 104,
    label: _t(en: 'Getting ready', hi: 'Taiyaari'),
    title: _t(en: 'Preconception health & nutrition', hi: 'Conceive se pehle sehat aur khana'),
    blurb: _t(
        en: 'Diet before pregnancy, folic acid, weight, and the tests and '
            'vaccinations worth doing before you start trying.',
        hi: 'Pregnancy se pehle ka khana, folic acid, weight, aur wo tests-'
            'vaccinations jo koshish shuru karne se pehle karwa lene chahiye.'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['ttc_nutrition', 'ttc_tests']),
      BracketLayer.activities: BracketLayerSpec(
          state: LayerState.notReady, reason: 'Light habit-building'),
      BracketLayer.tools: BracketLayerSpec(
          state: LayerState.notReady, reason: 'Pre-pregnancy checklist, BMI'),
      BracketLayer.products:
          BracketLayerSpec.live(['ttc_supplements', 'ttc_products']),
      BracketLayer.course: BracketLayerSpec(
          state: LayerState.notCore,
          reason: 'Folds into the conception masterclass'),
      // "Preconception nutrition consult" — `ttc_consult_nutrition` ships.
      BracketLayer.consult: BracketLayerSpec.live(['ttc_prepare']),
      BracketLayer.extras: BracketLayerSpec(
          state: LayerState.notApplicable, reason: 'Nothing proposed'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  5. Male fertility
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'ttc_male_fertility',
    stage: LifeStage.tryingToConceive,
    theme: 'partner',
    hue: 186,
    label: _t(en: 'His side', hi: 'Unki taraf'),
    title: _t(en: 'Male fertility', hi: 'Male fertility'),
    blurb: _t(
        en: 'Sperm health, the lifestyle factors that genuinely move it, and '
            'when a test is worth doing.',
        hi: 'Sperm health, wo lifestyle cheezein jo sach mein farq daalti hain, '
            'aur test kab karwana theek hai.'),
    layers: {
      // ⚠️ HER view of the partner material. See the note in the router about
      // why a bracket must never route at his account.
      BracketLayer.content: BracketLayerSpec.live(['ttc_partner']),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.tools:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.products: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Male fertility supplements (careful)'),
      // ⚑ The workbook wanted a module inside the conception course; a
      // STANDALONE shipped instead — `ttc_course_male`, "The half nobody talks
      // about". Live, because the thing she is promised exists and opens.
      BracketLayer.course: BracketLayerSpec.live(['ttc_prepare']),
      BracketLayer.consult: BracketLayerSpec.live(['ttc_prepare']),
      BracketLayer.extras: BracketLayerSpec(
          state: LayerState.notApplicable, reason: 'Nothing proposed'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  6. Trying again after loss — lowest volume, highest willingness to pay
  // ---------------------------------------------------------------------------
  //  ⚠️ THE MOST REFUSED BRACKET IN THE WORKBOOK, and every refusal is right.
  //  Five of seven layers are "Not a fit". A woman who has just lost a pregnancy
  //  is not shown a shop, a checklist, a course or a habit tracker. She is shown
  //  a person and, if she wants it, other people.
  Bracket(
    id: 'ttc_after_loss',
    stage: LifeStage.tryingToConceive,
    theme: 'loss',
    hue: 26,
    label: _t(en: 'After a loss', hi: 'Nuksaan ke baad'),
    title: _t(en: 'Trying again after loss', hi: 'Nuksaan ke baad phir se koshish'),
    blurb: _t(
        en: 'Physical recovery, when it is safe to try again, and support for '
            'the part that has no timeline.',
        hi: 'Sharir ka theek hona, phir se koshish kab safe hai, aur us hisse ke '
            'liye sahara jiska koi timeline nahi hota.'),
    layers: {
      BracketLayer.content: BracketLayerSpec(
          state: LayerState.notReady,
          reason:
              'Physical recovery, when it is safe to try again, emotional support'),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.tools:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      BracketLayer.products:
          BracketLayerSpec(state: LayerState.notApplicable, reason: 'Not a fit'),
      // ⚑ Workbook: "Not a fit". Reality: `ttc_cohort_loss`, "After a loss",
      // ships as a cohort. notCore per the rule — it exists, it is reached
      // through Prepare and through the consult row below, not merchandised on
      // this screen.
      BracketLayer.course: BracketLayerSpec(
          state: LayerState.notCore,
          reason: 'Workbook: "Not a fit". "After a loss" ships in Prepare — '
              'reached through a person, not a product row'),
      // The one layer the workbook actively wanted here, and it is real:
      // `ttc_consult_psych`, "Talking to a psychologist", plus the gynae.
      BracketLayer.consult: BracketLayerSpec.live(['ttc_prepare']),
      BracketLayer.extras: BracketLayerSpec.live(['ttc_community'],
          heading: _t(
              en: 'Others who have been here',
              hi: 'Aur log jo yahan se guzre hain')),
    },
  ),

  // ---------------------------------------------------------------------------
  //  7. Mind-body prep (preconception garbh sanskar)
  // ---------------------------------------------------------------------------
  Bracket(
    id: 'ttc_mind_body',
    stage: LifeStage.tryingToConceive,
    theme: 'garbh',
    hue: 42,
    label: _t(en: 'Mind & body', hi: 'Mann aur sharir'),
    title: _t(en: 'Mind-body preparation', hi: 'Mann-sharir ki taiyaari'),
    blurb: _t(
        en: 'Stress and fertility, daily practice, and preconception garbh '
            'sanskar — calm as preparation, not as pressure.',
        hi: 'Stress aur fertility, roz ka abhyas, aur conceive se pehle ka garbh '
            'sanskar — shanti taiyaari hai, dabaav nahi.'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['ttc_chapter']),
      // The one bracket in the stage whose Activities layer the workbook
      // actively wants — "rides light preconception spine" — and `ttc_ritual`
      // is exactly that spine.
      BracketLayer.activities: BracketLayerSpec.live(['ttc_ritual', 'ttc_journal']),
      BracketLayer.tools:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.products:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      // ⚠️ notReady, NOT live, and the distinction is worth defending. Prepare
      // ships "Fertility yoga - eight classes", which is close and is not the
      // same thing: the workbook asks for a FREE preconception garbh sanskar as
      // an acquisition hook, and a paid eight-class yoga pack is neither free
      // nor garbh sanskar. Marking it live would let the door promise a free
      // hook and open a ₹ price.
      BracketLayer.course: BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Preconception garbh sanskar (FREE acquisition hook)'),
      BracketLayer.consult:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.extras: BracketLayerSpec(
          state: LayerState.notApplicable, reason: 'Nothing proposed'),
    },
  ),
];
