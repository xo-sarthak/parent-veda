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
        en: 'How conception works: timing, cycle basics, and the myths you '
            'can let go of.',
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
        en: 'PCOS and fertility: symptoms, insulin and diet, and getting your '
            'cycle back to something you can follow.',
        hi: 'PCOS aur fertility — symptoms, insulin aur diet, aur cycle ko wapas '
            'padhne layak banana.'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['ttc_chapter']),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      // Was half of what the workbook asked for — "PCOS symptom checker, cycle
      // tracker", with only the tracker shipping. Both halves now exist, and
      // the checker reads the tracker's data rather than duplicating it.
      BracketLayer.tools: BracketLayerSpec.live(
          ['ttc_pcos_check', 'ttc_cycle', 'ttc_calendar']),
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
        en: 'When to get help, which tests matter, and what IUI and IVF '
            'involve, including what they cost.',
        hi: 'Madad kab lein, kaunse tests maayne rakhte hain, aur IUI-IVF mein '
            'hota kya hai — kharch samet.'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live(['ttc_treatment']),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      // Was the last notReady cell in the stage: "'See a specialist?'
      // readiness checklist". It ships, and it reads her trying time, her
      // cycles and her PCOS result before asking anything.
      BracketLayer.tools: BracketLayerSpec.live(
          ['ttc_fertility_help', 'ttc_tests', 'ttc_records']),
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
      // Was notReady: "Light habit-building". Not built as a new surface — the
      // checklist's Lifestyle section holds the decisions and the Tools hub
      // holds the trackers, so this was a routing gap rather than a missing
      // feature. See the note at the journey's habits step.
      BracketLayer.activities:
          BracketLayerSpec.live(['ttc_precheck/lifestyle', 'ttc_tools']),
      // Was notReady: "Pre-pregnancy checklist, BMI". The checklist ships and
      // carries the weight item — with no BMI figure, no target and no
      // calculator, for the reason written at the journey's BMI slot.
      BracketLayer.tools: BracketLayerSpec.live(
          ['ttc_precheck', 'ttc_bmi', 'ttc_vaccinations', 'ttc_tests']),
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
        en: 'Sperm health, the lifestyle changes that really make a '
            'difference, and when a test is worth doing.',
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
      // Was notReady. `ttc_supplements` now carries two entries framed for him
      // — zinc and CoQ10 — each stating plainly that the evidence for
      // antioxidant supplements here is weak, which is the workbook's
      // "(careful)" honoured rather than ignored.
      BracketLayer.products: BracketLayerSpec.live(['ttc_supplements']),
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
        en: "Physical recovery, when it's safe to try again, and support for "
            "the feelings that don't follow a timeline.",
        hi: 'Sharir ka theek hona, phir se koshish kab safe hai, aur us hisse ke '
            'liye sahara jiska koi timeline nahi hota.'),
    layers: {
      // Was notReady, and was the last `notReady` content layer in the stage.
      // Two reads now carry the workbook's three topics: `ttc_read_loss_recovery`
      // (physical recovery) and `ttc_read_trying_again` (when it is safe, plus
      // the emotional half — one decision rather than two, because they are
      // asked in the same breath and answered by different people).
      BracketLayer.content: BracketLayerSpec.live(
          ['ttc_read/ttc_read_loss_recovery', 'ttc_read/ttc_read_trying_again']),
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
      // Community held back for launch (2026-09-26, TTC gap plan §7.1) — kept for revert.
      // BracketLayer.extras: BracketLayerSpec.live(['ttc_community'],
      //     heading: _t(
      //         en: 'Others who have been here',
      //         hi: 'Aur log jo yahan se guzre hain')),
      BracketLayer.extras: BracketLayerSpec(
          state: LayerState.notApplicable,
          reason: 'Community held back for launch (TTC gap plan §7.1)'),
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
            'sanskar. Calm as a way to get ready, not one more pressure.',
        hi: 'Stress aur fertility, roz ka abhyas, aur conceive se pehle ka garbh '
            'sanskar — shanti taiyaari hai, dabaav nahi.'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live([
        'ttc_chapter',
        'ttc_read/ttc_read_stress_fertility',
        'ttc_read/ttc_read_garbh_sanskar',
      ]),
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
      // Was notReady, and the note under it was right to refuse the yoga pack
      // as a substitute: the workbook asks for a FREE hook and a paid
      // eight-class pack is neither free nor garbh sanskar. `ttc_course_garbh`
      // is now the actual thing — eight sessions, both partners, priceMinor 0.
      BracketLayer.course: BracketLayerSpec.live(['ttc_prepare']),
      BracketLayer.consult:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.extras: BracketLayerSpec(
          state: LayerState.notApplicable, reason: 'Nothing proposed'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  8. Body and cycle — added 2026-09-26 from the TTC gap analysis
  // ---------------------------------------------------------------------------
  //  ⚠️ NOT IN THE WORKBOOK, AND THE TEST THAT SAID "SEVEN" WAS TOLD SO. The
  //  Level Map had seven PRECONCEPTION rows. The gap analysis (the user's
  //  source of truth since 2026-09-26, docs/TTC-GAP-PLAN.md §8) found about
  //  120 competitor pieces on the cycle, bleeding, intimate health and the
  //  conditions that slow conception, with no home here. So this is a decided
  //  eighth door, not an invented one.
  //
  //  ⚠️ ENGLISH ON BOTH SIDES. New work is English (CLAUDE.md, 2026-08-27):
  //  the Hindi build shows English here, which is now the expected state.
  //  `bracket_model_test` names both new brackets as English by policy.
  Bracket(
    id: 'ttc_body_cycle',
    stage: LifeStage.tryingToConceive,
    theme: 'body',
    hue: 172,
    label: _t(en: 'Body and cycle', hi: 'Body and cycle'),
    title: _t(en: 'Your body and your cycle', hi: 'Your body and your cycle'),
    blurb: _t(
        en: 'Late periods, bleeding and spotting, intimate health, and the '
            'conditions that can slow things down.',
        hi: 'Late periods, bleeding and spotting, intimate health, and the '
            'conditions that can slow things down.'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live([
        'ttc_read/ttc_read_bleeding_kinds',
        'ttc_read/ttc_read_slow_conception',
      ]),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.tools:
          BracketLayerSpec.live(['ttc_cycle', 'ttc_calendar']),
      BracketLayer.products:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.course:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.consult: BracketLayerSpec.live(['ttc_prepare']),
      BracketLayer.extras: BracketLayerSpec(
          state: LayerState.notApplicable, reason: 'Nothing proposed'),
    },
  ),

  // ---------------------------------------------------------------------------
  //  9. Trying, but not pregnant yet? — added 2026-09-26 (gap plan, P2)
  // ---------------------------------------------------------------------------
  //  ⚠️ A DOOR THAT GATHERS, IT WRITES NOTHING NEW. Every piece behind it
  //  already lives in another door; this puts the ones she needs after some
  //  months of trying in one place. Its home position (first after six
  //  months) is the home's job, not this table's.
  //
  //  ⚠️ THE LABEL IS SHORT ON PURPOSE: "Taking a while". A tile on the four
  //  column grid is about 73dp and the full question would be cut off. The
  //  door's own headline asks it in full.
  //
  //  ⚠️ PRODUCTS ARE REFUSED HERE, the same call as IVF's: a shop on the page
  //  she opens because it is taking longer is the wrong placement.
  Bracket(
    id: 'ttc_not_yet',
    stage: LifeStage.tryingToConceive,
    theme: 'treatment',
    hue: 250,
    label: _t(en: 'Taking a while', hi: 'Taking a while'),
    title: _t(
        en: 'Trying, but not pregnant yet?',
        hi: 'Trying, but not pregnant yet?'),
    blurb: _t(
        en: 'How long it usually takes, when to see a doctor, what a first '
            'check involves, and getting through the months.',
        hi: 'How long it usually takes, when to see a doctor, what a first '
            'check involves, and getting through the months.'),
    layers: {
      BracketLayer.content: BracketLayerSpec.live([
        'ttc_read/ttc_read_how_long_it_takes',
        'ttc_read/ttc_read_when_to_seek_help',
      ]),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.tools:
          BracketLayerSpec.live(['ttc_fertility_help', 'ttc_tests']),
      BracketLayer.products: BracketLayerSpec(
          state: LayerState.notApplicable, reason: 'Not a fit (clinical)'),
      BracketLayer.course:
          BracketLayerSpec(state: LayerState.notCore, reason: 'Not core'),
      BracketLayer.consult: BracketLayerSpec.live(['ttc_prepare']),
      BracketLayer.extras: BracketLayerSpec(
          state: LayerState.notApplicable, reason: 'Nothing proposed'),
    },
  ),
];
