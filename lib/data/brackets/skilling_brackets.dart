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
    layers: _skillLayers(
      content: 'Speaking practice with prompts, stage exercises',
      activities: 'Practice + record & self-review',
      tools: 'Record & self-review tool + rubric tracker',
      products: 'Optional',
      course: 'Leveled program (paid)',
      consult: 'Speaking coach',
      extras: 'Challenges, certificates, progress report',
    ),
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
    layers: _skillLayers(
      content: 'Daily speaking prompts, storytelling, spoken expression',
      activities: 'Practice set',
      tools: 'Rubric tracker',
      products: 'Optional',
      course: 'Leveled program (paid)',
      consult: 'Rare',
      extras: 'Challenges, certificates, progress report',
    ),
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
    layers: _skillLayers(
      content: "Puzzles, reasoning & 'why' chains, light debate",
      activities: 'Practice set',
      tools: 'Rubric tracker',
      products: 'Optional',
      course: 'Leveled program (paid)',
      consult: 'Rare',
      extras: 'Challenges, certificates, progress report',
    ),
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
    layers: _skillLayers(
      content: 'Unplugged -> block-based -> projects, age-banded',
      activities: 'Project practice',
      tools: 'Project / rubric tracker (honest, no outcome promises)',
      products: 'Optional',
      course: 'Leveled program (paid) - WhiteHat Jr caution',
      consult: 'Rare',
      extras: 'Challenges, certificates, progress report',
    ),
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
    layers: _skillLayers(
      content: 'Art, music, and making prompts',
      activities: 'Making practice',
      tools: 'Portfolio tracker',
      products: 'Optional',
      course: 'Optional',
      consult: 'Rare',
      extras: 'Portfolio showcase',
    ),
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
    layers: _skillLayers(
      content: 'Scenario practice, journaling prompts',
      activities: 'Scenario / journal practice',
      tools: 'Rubric tracker',
      products: 'Optional',
      course: 'Optional',
      consult: 'Rare',
      extras: 'Progress report',
    ),
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
    layers: _skillLayers(
      content: 'Guided kid meditations & yoga',
      activities: 'Guided practice',
      tools: 'Streak tracker',
      products: 'Optional',
      course: 'Optional',
      consult: 'Rare',
      extras: 'Streaks, progress report',
    ),
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
