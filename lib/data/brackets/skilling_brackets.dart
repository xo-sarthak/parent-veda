// =============================================================================
//  Skilling brackets — the L1 column for the fourth stage
// -----------------------------------------------------------------------------
//  Twelve problem brackets, seven layers each, transcribed from
//  `parentveda-level-map-checklist.xlsx` (the SKILLING rows). Order is the
//  workbook's.
//
//  ---------------------------------------------------------------------------
//  ⚠️ NOT ONE CELL IS LIVE, AND THAT IS THE POINT OF THE FILE
//  ---------------------------------------------------------------------------
//
//  ⚠️ NO LONGER TRUE OF ONE ROW — `skilling_coding` has five live cells since
//  2026-09-14, each pointing at a named file through `sk_surface_router.dart`
//  (see the row). Everything below still describes the other eleven, and the
//  gate it names — "nothing may be promoted without a named file" — is the
//  gate Coding passed. The two conflicts further down are RESOLVED by the
//  Coding v2 brief: the stage speaks to the child (behind a parent gate),
//  and nothing scores a child; the text is kept as the record of why they
//  were flagged.
//
//  Eighty-four cells, zero resolvers. The other three stages had years of
//  content sitting behind their doors before the doors existed — TTC's grid
//  mostly WIRED screens that already shipped. Skilling has nothing at all: no
//  content file, no tool, no course, no expert, no screen.
//
//  So this table is a PLAN expressed in the same type as the others, and the
//  `notReady` state is doing exactly the job it was added for: real, named,
//  not built. Nothing here may be promoted to `live` without a named file, the
//  same gate `docs/BRACKET-AUDIT.md` enforces for pregnancy.
//
//  The consequence for the UI, stated once so nobody re-derives it: **the doors
//  cannot open bracket screens yet.** A bracket screen with zero live layers
//  renders a header and nothing, and twelve doors onto twelve empty rooms is
//  worse than no doors — an empty room read as a promise is what makes an app
//  feel abandoned. The preview shows each bracket's PLAN instead.
//
//  ---------------------------------------------------------------------------
//  ⚠️ TWO CONFLICTS WITH THE PRODUCT'S OWN RULES. NEITHER IS RESOLVED HERE.
//  ---------------------------------------------------------------------------
//
//  1. **The workbook header says SKILLING "speaks to the child".** Every other
//     stage says "speaks to the parent", and the entire app's voice, safety
//     framing and disclaimer style is built for an adult reader. A stage that
//     addresses a child is a different product decision, not a copy tweak — it
//     changes consent, data handling and tone at once. The shell below is
//     written to the PARENT, because that is what the app is, and the question
//     is flagged rather than silently answered.
//
//  2. **The workbook asks for challenges, streaks, certificates and progress
//     reports** on nearly every bracket's Extras. The product bans scoring a
//     child — the parenting Development area refuses a progress bar for exactly
//     this reason, and `devWordLabel` exists so the word can be shown without
//     the percentage. Ten of the twelve Extras cells below are therefore
//     recorded in the workbook's own words and left `notReady`, so the decision
//     is visible rather than pre-empted in either direction.
//
//  Both are the user's to rule on. Until then nothing is built either way,
//  which is the cheapest place for an unresolved question to sit.
//
//  ---------------------------------------------------------------------------
//  ⚠️ HINDI IS DEVANAGARI HERE, unlike TTC.
//
//  TTC's table is Hinglish because that stage's entire chrome is Hinglish and
//  mixing scripts inside one shell is worse than either choice made
//  consistently. Skilling has NO legacy: nothing to be consistent with, so it
//  starts where the house style is going rather than where it has been.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/bracket.dart';
import '../../services/life_stage_store.dart';

const _t = LocalizedText.new;

/// Every skilling bracket carries the identical layer pattern, because the
/// workbook does: content, a practice set, a rubric tracker, an optional
/// product, a levelled paid programme, a rare consult, and challenges.
///
/// ⚠️ A HELPER HERE, AND DELIBERATELY NOT IN THE OTHER THREE TABLES. Pregnancy
/// and TTC are written out longhand because every cell there is a separate
/// judgement about a separate resolver, and a shorthand would hide the one word
/// that decides whether a section can appear. Skilling is the opposite: the
/// workbook gives twelve rows of the SAME shape, and writing it out twelve
/// times would bury the three cells that actually differ — the workbooks,
/// the speaking coach, and the forwardable cards.
Map<BracketLayer, BracketLayerSpec> _skillLayers({
  required String content,
  required String activities,
  required String tools,
  required String products,
  required String course,
  required String consult,
  required String extras,
}) =>
    {
      BracketLayer.content:
          BracketLayerSpec(state: LayerState.notReady, reason: content),
      BracketLayer.activities:
          BracketLayerSpec(state: LayerState.notReady, reason: activities),
      BracketLayer.tools:
          BracketLayerSpec(state: LayerState.notReady, reason: tools),
      BracketLayer.products:
          BracketLayerSpec(state: LayerState.notReady, reason: products),
      BracketLayer.course:
          BracketLayerSpec(state: LayerState.notReady, reason: course),
      BracketLayer.consult:
          BracketLayerSpec(state: LayerState.notReady, reason: consult),
      BracketLayer.extras:
          BracketLayerSpec(state: LayerState.notReady, reason: extras),
    };

final List<Bracket> kSkillingBrackets = [
  Bracket(
    id: 'skilling_focus',
    stage: LifeStage.skilling,
    theme: 'attention',
    hue: 206,
    label: _t(en: 'Focus', hi: 'ध्यान'),
    title: _t(en: 'Focus & attention', hi: 'ध्यान और एकाग्रता'),
    blurb: _t(
        en: 'Holding attention on one thing for longer, and coming back to it '
            'when it wanders.',
        hi: 'एक चीज़ पर देर तक ध्यान टिकाना, और भटक जाए तो वापस लौटना।'),
    layers: _skillLayers(
      content: 'Attention games, sustained-focus drills',
      activities: 'Practice set (per skilling pattern)',
      tools: 'Rubric progress tracker',
      products: 'Optional workbook',
      course: 'Leveled program (paid)',
      consult: 'Rare',
      extras: 'Challenges, certificates, progress report',
    ),
  ),

  // ⚠️ THE STAGE'S ONE NAMED DEMAND SIGNAL — "High WTP" in the workbook, the
  // only skilling row carrying one. It is door two for that reason, and the
  // only bracket whose Consult cell names a real role rather than "Rare".
  Bracket(
    id: 'skilling_confidence',
    stage: LifeStage.skilling,
    theme: 'speaking',
    hue: 344,
    label: _t(en: 'Confidence', hi: 'आत्मविश्वास'),
    title: _t(
        en: 'Confidence & public speaking', hi: 'आत्मविश्वास और मंच पर बोलना'),
    blurb: _t(
        en: 'Standing up and speaking — with prompts to practise on and a way '
            'to hear yourself back.',
        hi: 'सामने खड़े होकर बोलना — अभ्यास के लिए विषय, और ख़ुद को सुनकर '
            'सुधारने का तरीक़ा।'),
    // ⚠️ LIVE SINCE 2026-09-16, to `ParentVeda_Confidence_structure.pdf`.
    // Six cells live — the first door with a live CONSULT: the brief
    // un-holds the speaking coach ("the only door naming a real role with
    // real supply"), built as a placeholder row on the grown-up screen
    // until a coach is onboarded. The rubric tracker is refused ("it scores
    // a child") into "Hear yourself back". Extras stay `notReady`.
    layers: {
      BracketLayer.content: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Speaking practice with prompts, stage exercises',
        surfaceIds: ['sk_lessons/skilling_confidence'],
      ),
      BracketLayer.activities: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Practice + record & self-review',
        surfaceIds: ['sk_activities/skilling_confidence'],
      ),
      BracketLayer.tools: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Record & self-review tool + rubric tracker',
        surfaceIds: ['sk_record/skilling_confidence', 'sk_voice/skilling_confidence'],
      ),
      BracketLayer.products: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Optional',
        surfaceIds: ['sk_products/skilling_confidence'],
      ),
      BracketLayer.course: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Leveled program (paid)',
        surfaceIds: ['sk_courses/skilling_confidence'],
      ),
      BracketLayer.consult: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Speaking coach',
        surfaceIds: ['sk_courses/skilling_confidence'],
      ),
      BracketLayer.extras: const BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Challenges, certificates, progress report'),
    },
    /* kept for revert — the row as declared before the door
    layers: _skillLayers(
      content: 'Speaking practice with prompts, stage exercises',
      activities: 'Practice + record & self-review',
      tools: 'Record & self-review tool + rubric tracker',
      products: 'Optional',
      course: 'Leveled program (paid)',
      consult: 'Speaking coach',
      extras: 'Challenges, certificates, progress report',
    ),
    */
  ),

  Bracket(
    id: 'skilling_communication',
    stage: LifeStage.skilling,
    theme: 'speaking',
    hue: 26,
    label: _t(en: 'Expression', hi: 'अभिव्यक्ति'),
    title: _t(
        en: 'Communication & articulation', hi: 'बातचीत और बात रखने का ढंग'),
    blurb: _t(
        en: 'Saying what you mean — daily prompts, storytelling, and spoken '
            'expression.',
        hi: 'जो कहना है वही कहना — रोज़ के विषय, कहानी कहना, और बोलकर '
            'ख़ुद को व्यक्त करना।'),
    // ⚠️ LIVE SINCE 2026-09-15, to `ParentVeda_Communication_structure.pdf`.
    // Same shape as Coding's row below: five layers to named surfaces,
    // workbook text kept, extras (reshape) and consult (hold) `notReady`.
    // The "rubric tracker" the workbook asked for is refused by the brief
    // ("a rubric scores a child") and becomes "Your voice, saved".
    layers: {
      BracketLayer.content: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Daily speaking prompts, storytelling, spoken expression',
        surfaceIds: ['sk_lessons/skilling_communication'],
      ),
      BracketLayer.activities: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Practice set',
        surfaceIds: ['sk_activities/skilling_communication'],
      ),
      BracketLayer.tools: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Rubric tracker',
        surfaceIds: ['sk_voice/skilling_communication'],
      ),
      BracketLayer.products: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Optional',
        surfaceIds: ['sk_products/skilling_communication'],
      ),
      BracketLayer.course: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Leveled program (paid)',
        surfaceIds: ['sk_courses/skilling_communication'],
      ),
      BracketLayer.consult: const BracketLayerSpec(
          state: LayerState.notReady, reason: 'Rare'),
      BracketLayer.extras: const BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Challenges, certificates, progress report'),
    },
    /* kept for revert — the row as declared before the door
    layers: _skillLayers(
      content: 'Daily speaking prompts, storytelling, spoken expression',
      activities: 'Practice set',
      tools: 'Rubric tracker',
      products: 'Optional',
      course: 'Leveled program (paid)',
      consult: 'Rare',
      extras: 'Challenges, certificates, progress report',
    ),
    */
  ),

  Bracket(
    id: 'skilling_critical_thinking',
    stage: LifeStage.skilling,
    theme: 'reasoning',
    hue: 268,
    label: _t(en: 'Thinking', hi: 'सोच'),
    title: _t(
        en: 'Critical thinking & first principles',
        hi: 'तर्क और मूल सिद्धांतों से सोचना'),
    blurb: _t(
        en: 'Puzzles, reasoning, chains of "why", and enough light debate to '
            'enjoy being wrong.',
        hi: 'पहेलियाँ, तर्क, "क्यों" की कड़ियाँ, और इतनी हल्की बहस कि ग़लत '
            'होना भी अच्छा लगे।'),
    // ⚠️ LIVE SINCE 2026-09-17, to `ParentVeda_Thinking_structure.pdf`.
    // Six cells live. The rubric tracker is refused ("it scores a child,
    // and scoring a child's thinking is the surest way to stop her enjoying
    // being wrong") into the shared no-score keepsake; extras are reshaped
    // — challenges become optional fun (a lesson set), the certificate
    // becomes the "you kept thinking" keepsake, the progress report is
    // dropped. Consult stays held: "a reasoning or debate coach, rarely".
    layers: {
      BracketLayer.content: const BracketLayerSpec(
        state: LayerState.live,
        reason: "Puzzles, reasoning & 'why' chains, light debate",
        surfaceIds: ['sk_lessons/skilling_critical_thinking'],
      ),
      BracketLayer.activities: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Practice set',
        surfaceIds: ['sk_activities/skilling_critical_thinking'],
      ),
      BracketLayer.tools: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Rubric tracker',
        surfaceIds: ['sk_keepsake/skilling_critical_thinking'],
      ),
      BracketLayer.products: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Optional',
        surfaceIds: ['sk_products/skilling_critical_thinking'],
      ),
      BracketLayer.course: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Leveled program (paid)',
        surfaceIds: ['sk_courses/skilling_critical_thinking'],
      ),
      BracketLayer.consult:
          const BracketLayerSpec(state: LayerState.notReady, reason: 'Rare'),
      BracketLayer.extras: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Challenges, certificates, progress report',
        surfaceIds: [
          'sk_lessons/skilling_critical_thinking',
          'sk_keepsake/skilling_critical_thinking',
        ],
      ),
    },
    /* kept for revert — the row as declared before the door
    layers: _skillLayers(
      content: "Puzzles, reasoning & 'why' chains, light debate",
      activities: 'Practice set',
      tools: 'Rubric tracker',
      products: 'Optional',
      course: 'Leveled program (paid)',
      consult: 'Rare',
      extras: 'Challenges, certificates, progress report',
    ),
    */
  ),

  // The stage's highest-volume bracket by a distance — good habits ~14,800 and
  // moral stories ~27,100. The workbook's own word for the register is
  // "rooted, secular", which is the same line garbh sanskar walks in pregnancy.
  Bracket(
    id: 'skilling_values',
    stage: LifeStage.skilling,
    theme: 'character',
    hue: 42,
    label: _t(en: 'Values', hi: 'संस्कार'),
    title: _t(en: 'Values & character', hi: 'संस्कार और चरित्र'),
    blurb: _t(
        en: 'Moral stories and good habits — rooted in what we come from, and '
            'never preachy.',
        hi: 'नीति-कथाएँ और अच्छी आदतें — अपनी जड़ों से जुड़ी, उपदेश दिए बिना।'),
    layers: _skillLayers(
      content: 'Moral stories & good habits, habit-building (rooted, secular)',
      activities: 'Habit / story practice',
      tools: 'Habit / rubric tracker',
      products: 'Story books / values workbook',
      course: 'Leveled program (paid) - the rooted layer for kids',
      consult: 'Rare',
      extras: "'Dadi says / Science says' forwardable cards",
    ),
  ),

  Bracket(
    id: 'skilling_maths',
    stage: LifeStage.skilling,
    theme: 'maths',
    hue: 104,
    label: _t(en: 'Maths', hi: 'गणित'),
    title: _t(en: 'Maths ability', hi: 'गणित की पकड़'),
    blurb: _t(
        en: 'Vedic maths, abacus and mental-arithmetic drills, levelled by '
            'where the child actually is.',
        hi: 'वैदिक गणित, abacus और मन-ही-मन जोड़-घटाव का अभ्यास — बच्चा जहाँ '
            'है वहाँ से।'),
    layers: _skillLayers(
      content: 'Vedic maths, abacus, mental-math drills (leveled)',
      activities: 'Drill practice',
      tools: 'Rubric tracker',
      products: 'Workbook',
      course: 'Leveled program (paid)',
      consult: 'Rare',
      extras: 'Challenges, certificates, progress report',
    ),
  ),

  // ⚠️ THE WORKBOOK WRITES ITS OWN WARNING INTO THIS CELL — "WhiteHat Jr
  // caution". Kept verbatim, because it is the most important sentence in the
  // stage: the category's cautionary tale is a coding programme sold to parents
  // on outcome promises, and the tools cell answers it in the same breath
  // ("honest, no outcome promises").
  Bracket(
    id: 'skilling_coding',
    stage: LifeStage.skilling,
    theme: 'coding',
    hue: 186,
    label: _t(en: 'Coding', hi: 'कोडिंग'),
    title: _t(en: 'Coding & AI literacy', hi: 'कोडिंग और AI की समझ'),
    blurb: _t(
        en: 'Unplugged first, then blocks, then real projects — age-banded, and '
            'promising nothing about anyone\'s future.',
        hi: 'पहले बिना कंप्यूटर, फिर blocks, फिर असली projects — उम्र के हिसाब '
            'से, और किसी के भविष्य का कोई वादा किए बिना।'),
    // ⚠️ THE FIRST LIVE CELLS IN THE STAGE — 2026-09-14, to
    // `ParentVeda_Coding_structure_v2.pdf`. Five layers promoted to their
    // named files; `extras` and `consult` stay `notReady` as the brief
    // says ("Leave extras and consult as notReady"). The workbook text is
    // KEPT on the live cells (a longhand spec rather than `.live()`), so
    // the plan sheet the other eleven tiles show would still render this
    // row if it ever needed to, and so the reason a cell is live is read
    // beside the surface it opens. Every surface resolves through
    // `sk_surface_router.dart`; `test/sk_doors_sanity_test.dart` holds it.
    layers: {
      BracketLayer.content: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Unplugged -> block-based -> projects, age-banded',
        surfaceIds: ['sk_lessons/skilling_coding', 'sk_cross/skilling_coding'],
      ),
      BracketLayer.activities: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Project practice',
        surfaceIds: ['sk_today/skilling_coding', 'sk_activities/skilling_coding'],
      ),
      BracketLayer.tools: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Project / rubric tracker (honest, no outcome promises)',
        surfaceIds: ['sk_keepsake/skilling_coding'],
      ),
      BracketLayer.products: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Optional',
        surfaceIds: ['sk_products/skilling_coding'],
      ),
      BracketLayer.course: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Leveled program (paid) - WhiteHat Jr caution',
        surfaceIds: ['sk_courses/skilling_coding'],
      ),
      BracketLayer.consult: const BracketLayerSpec(
          state: LayerState.notReady, reason: 'Rare'),
      BracketLayer.extras: const BracketLayerSpec(
          state: LayerState.notReady,
          reason: 'Challenges, certificates, progress report'),
    },
    /* kept for revert — the row as declared before the door
    layers: _skillLayers(
      content: 'Unplugged -> block-based -> projects, age-banded',
      activities: 'Project practice',
      tools: 'Project / rubric tracker (honest, no outcome promises)',
      products: 'Optional',
      course: 'Leveled program (paid) - WhiteHat Jr caution',
      consult: 'Rare',
      extras: 'Challenges, certificates, progress report',
    ),
    */
  ),

  Bracket(
    id: 'skilling_reading',
    stage: LifeStage.skilling,
    theme: 'reading',
    hue: 160,
    label: _t(en: 'Reading', hi: 'पढ़ना'),
    title: _t(en: 'Reading habit', hi: 'पढ़ने की आदत'),
    blurb: _t(
        en: 'Book lists by age and reading challenges that build the habit '
            'rather than the count.',
        hi: 'उम्र के हिसाब से किताबों की सूची, और ऐसी चुनौतियाँ जो गिनती नहीं, '
            'आदत बनाएँ।'),
    layers: _skillLayers(
      content: 'Leveled reading challenges, book lists by age',
      activities: 'Reading practice',
      tools: 'Reading tracker',
      products: 'Book lists (affiliate)',
      course: 'Optional',
      consult: 'Rare',
      extras: 'Challenges, streaks, progress report',
    ),
  ),

  Bracket(
    id: 'skilling_creativity',
    stage: LifeStage.skilling,
    theme: 'creativity',
    hue: 12,
    label: _t(en: 'Making', hi: 'रचना'),
    title: _t(en: 'Creativity & expression', hi: 'रचनात्मकता और अभिव्यक्ति'),
    blurb: _t(
        en: 'Art, music and making — prompts to start with, and somewhere to '
            'keep what comes out.',
        hi: 'कला, संगीत और बनाना — शुरू करने के लिए विषय, और जो बने उसे '
            'सँभालने की जगह।'),
    // ⚠️ LIVE SINCE 2026-09-18, to `ParentVeda_Creativity_structure.pdf` —
    // "the one door whose plan already refuses scoring". Six cells live.
    // The portfolio tracker survives as a PORTFOLIO, not a tracker: a
    // gallery that keeps what she made and cannot return a score. The
    // showcase is kept and held PRIVATE — a show mode on this phone, no
    // cross-user gallery, no likes, no featured wall (the user's call, 1a).
    // Consult held: "an art or music teacher, rarely".
    layers: {
      BracketLayer.content: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Art, music, and making prompts',
        surfaceIds: ['sk_lessons/skilling_creativity'],
      ),
      BracketLayer.activities: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Making practice',
        surfaceIds: ['sk_activities/skilling_creativity'],
      ),
      BracketLayer.tools: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Portfolio tracker',
        surfaceIds: ['sk_portfolio/skilling_creativity'],
      ),
      BracketLayer.products: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Optional',
        surfaceIds: ['sk_products/skilling_creativity'],
      ),
      BracketLayer.course: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Optional',
        surfaceIds: ['sk_courses/skilling_creativity'],
      ),
      BracketLayer.consult:
          const BracketLayerSpec(state: LayerState.notReady, reason: 'Rare'),
      BracketLayer.extras: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Portfolio showcase',
        surfaceIds: ['sk_portfolio/skilling_creativity'],
      ),
    },
    /* kept for revert — the row as declared before the door
    layers: _skillLayers(
      content: 'Art, music, and making prompts',
      activities: 'Making practice',
      tools: 'Portfolio tracker',
      products: 'Optional',
      course: 'Optional',
      consult: 'Rare',
      extras: 'Portfolio showcase',
    ),
    */
  ),

  Bracket(
    id: 'skilling_emotional',
    stage: LifeStage.skilling,
    theme: 'mental_health',
    hue: 288,
    label: _t(en: 'Feelings', hi: 'भावनाएँ'),
    title: _t(
        en: 'Emotional intelligence & resilience', hi: 'भावनाओं की समझ और सँभलना'),
    blurb: _t(
        en: 'Real situations to think through, and prompts for writing the '
            'harder ones down.',
        hi: 'असली हालात जिन पर सोचा जाए, और मुश्किल वाली बातें लिखने के लिए '
            'सवाल।'),
    // ⚠️ LIVE SINCE 2026-09-18, to `ParentVeda_Feelings_structure.pdf` —
    // the mental-health door. Five cells live, and the content marked
    // "care": nothing authored until a child psychologist has reviewed it.
    // The rubric tracker is REFUSED "and here it matters most: you cannot
    // rate a child's emotional intelligence" — into the plain keepsake, no
    // mood score, no chart, never any AI reading of a child's feelings.
    // Extras (the progress report) are DROPPED OUTRIGHT — "an emotional
    // progress report on a child is unthinkable, and it is a score" — the
    // sharpest notApplicable in the stage. Consult held: the free off-ramp
    // comes first; help is not an upsell.
    layers: {
      BracketLayer.content: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Scenario practice, journaling prompts',
        surfaceIds: ['sk_lessons/skilling_emotional'],
      ),
      BracketLayer.activities: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Scenario / journal practice',
        surfaceIds: ['sk_activities/skilling_emotional', 'sk_journal/skilling_emotional'],
      ),
      BracketLayer.tools: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Rubric tracker',
        surfaceIds: ['sk_keepsake/skilling_emotional'],
      ),
      BracketLayer.products: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Optional',
        surfaceIds: ['sk_products/skilling_emotional'],
      ),
      BracketLayer.course: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Optional',
        surfaceIds: ['sk_courses/skilling_emotional'],
      ),
      BracketLayer.consult:
          const BracketLayerSpec(state: LayerState.notReady, reason: 'Rare'),
      BracketLayer.extras: const BracketLayerSpec(
          state: LayerState.notApplicable,
          reason: 'Progress report — dropped outright; it is a score'),
    },
    /* kept for revert — the row as declared before the door
    layers: _skillLayers(
      content: 'Scenario practice, journaling prompts',
      activities: 'Scenario / journal practice',
      tools: 'Rubric tracker',
      products: 'Optional',
      course: 'Optional',
      consult: 'Rare',
      extras: 'Progress report',
    ),
    */
  ),

  Bracket(
    id: 'skilling_stillness',
    stage: LifeStage.skilling,
    theme: 'garbh',
    hue: 232,
    label: _t(en: 'Stillness', hi: 'शांति'),
    title: _t(
        en: 'Meditation, yoga & mindfulness', hi: 'ध्यान, योग और सजगता'),
    blurb: _t(
        en: 'Guided sitting and simple yoga, made for a child\'s attention '
            'span rather than an adult\'s.',
        hi: 'साथ-साथ बैठना और आसान योग — बड़ों नहीं, बच्चों के ध्यान के '
            'हिसाब से।'),
    // ⚠️ LIVE SINCE 2026-09-17, to `ParentVeda_Stillness_structure.pdf`.
    // Six cells live. The streak tracker is REFUSED, and on the record with
    // its reason (the user's call, 1a): "a streak is the opposite of the
    // practice … becomes a gentle 'want to sit again?' invitation and a
    // shelf of quiet moments taken. Never a chain to keep or break." Extras
    // (streaks, progress report) are dropped outright — "the sharpest
    // refusal in the stage" — and what is left, the unmeasured record, is
    // the keepsake. Consult held: "real distress is not a meditation gap".
    layers: {
      BracketLayer.content: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Guided kid meditations & yoga',
        surfaceIds: ['sk_lessons/skilling_stillness'],
      ),
      BracketLayer.activities: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Guided practice',
        surfaceIds: ['sk_activities/skilling_stillness'],
      ),
      BracketLayer.tools: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Streak tracker',
        surfaceIds: ['sk_keepsake/skilling_stillness'],
      ),
      BracketLayer.products: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Optional',
        surfaceIds: ['sk_products/skilling_stillness'],
      ),
      BracketLayer.course: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Optional',
        surfaceIds: ['sk_courses/skilling_stillness'],
      ),
      BracketLayer.consult:
          const BracketLayerSpec(state: LayerState.notReady, reason: 'Rare'),
      BracketLayer.extras: const BracketLayerSpec(
        state: LayerState.live,
        reason: 'Streaks, progress report',
        surfaceIds: ['sk_keepsake/skilling_stillness'],
      ),
    },
    /* kept for revert — the row as declared before the door
    layers: _skillLayers(
      content: 'Guided kid meditations & yoga',
      activities: 'Guided practice',
      tools: 'Streak tracker',
      products: 'Optional',
      course: 'Optional',
      consult: 'Rare',
      extras: 'Streaks, progress report',
    ),
    */
  ),

  Bracket(
    id: 'skilling_memory',
    stage: LifeStage.skilling,
    theme: 'learning',
    hue: 320,
    label: _t(en: 'Memory', hi: 'याददाश्त'),
    title: _t(
        en: 'Memory & learning how to learn', hi: 'याददाश्त और सीखना कैसे है'),
    blurb: _t(
        en: 'Memory techniques and study skills — the part school assumes you '
            'already have.',
        hi: 'याद रखने के तरीक़े और पढ़ने का हुनर — वो हिस्सा जो स्कूल मान लेता '
            'है कि आता ही होगा।'),
    layers: _skillLayers(
      content: 'Memory techniques, study skills',
      activities: 'Technique practice',
      tools: 'Rubric tracker',
      products: 'Optional',
      course: 'Optional',
      consult: 'Rare',
      extras: 'Progress report',
    ),
  ),
];
