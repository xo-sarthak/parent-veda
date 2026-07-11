// =============================================================================
//  Garbh Sanskar Journey - curated seed content
// -----------------------------------------------------------------------------
//  A starter library across the four pillars. Warm, universal, non-religious;
//  enough to make the experience feel real. Scales to the launch quantities
//  (Shravan 40–50, Samvad 280, Vichara 100–150, Kriya 30–40) by adding entries.
// =============================================================================

import '../models/garbh_content.dart';

// ---------------------------------------------------------------------------
//  Shravan - Sacred Listening (placeholder audio uses the bundled drone)
// ---------------------------------------------------------------------------
const List<GarbhAudio> kShravan = [
  GarbhAudio(id: 'morning_raga', title: 'Morning Calm Raga', subtitle: 'Begin the day with calmness', emoji: '🌅', minutes: 7, kind: GarbhKind.raga),
  GarbhAudio(id: 'bonding_raga', title: 'Baby Bonding Raga', subtitle: 'A melody to share with your baby', emoji: '💗', minutes: 7, kind: GarbhKind.raga),
  GarbhAudio(id: 'evening_raga', title: 'Evening Raga', subtitle: 'Unwind as the day softens', emoji: '🌙', minutes: 8, kind: GarbhKind.raga),
  GarbhAudio(id: 'sleep_raga', title: 'Sleep Raga', subtitle: 'Drift gently into rest', emoji: '😴', minutes: 10, kind: GarbhKind.raga),
  GarbhAudio(id: 'relax_raga', title: 'Relaxation Raga', subtitle: 'Let the tension melt away', emoji: '🍃', minutes: 6, kind: GarbhKind.raga),
  GarbhAudio(id: 'rain', title: 'Gentle Rain', subtitle: 'Soft, steady rainfall', emoji: '🌧️', minutes: 15, kind: GarbhKind.nature),
  GarbhAudio(id: 'ocean', title: 'Ocean Waves', subtitle: 'Slow rolling waves', emoji: '🌊', minutes: 15, kind: GarbhKind.nature),
  GarbhAudio(id: 'forest', title: 'Forest Morning', subtitle: 'Birdsong and a gentle breeze', emoji: '🌲', minutes: 12, kind: GarbhKind.nature),
  GarbhAudio(id: 'bells', title: 'Temple Bells', subtitle: 'Soft, distant bells', emoji: '🔔', minutes: 8, kind: GarbhKind.nature),
  GarbhAudio(id: 'bodyscan', title: 'Body Awareness Journey', subtitle: 'A guided full-body relaxation', emoji: '🧘', minutes: 9, kind: GarbhKind.guided),
];

// ---------------------------------------------------------------------------
//  Vichara - Positive Contemplation (short reflective reads)
// ---------------------------------------------------------------------------
const List<GarbhStory> kVichara = [
  GarbhStory(
    id: 'curiosity',
    theme: 'Curiosity',
    title: 'The Child Who Asked Why',
    blurb: 'A short reflection on curiosity, wonder and lifelong learning.',
    body:
        'There was once a child who asked "why" about everything. Why is the sky blue? Why do birds sing in the morning? Why does the moon follow us home?\n\n'
        'At first the grown-ups answered quickly, and then they grew tired of answering at all. But the child kept asking - not to be difficult, but because the world felt endlessly interesting.\n\n'
        'Years later, that same curiosity became the child\'s greatest gift. It made them a careful listener, a patient learner, and someone who never stopped growing.\n\n'
        'Every child is born with this spark. It does not need to be taught - only protected, welcomed, and answered with a little patience.',
    reflection: 'What quality would you most like your child to keep as they grow?',
  ),
  GarbhStory(
    id: 'patience',
    theme: 'Patience',
    title: 'How Trees Grow Slowly Yet Strongly',
    blurb: 'A gentle reminder that the strongest things take time.',
    body:
        'A tree does not rush. In its first year it may look like nothing more than a thin stem, easily bent by the wind.\n\n'
        'But beneath the soil, quietly and unseen, it is doing the most important work - sending roots deep and wide. Only later does it rise tall, and by then it can hold the weight of storms.\n\n'
        'Pregnancy is a little like this. So much of what matters is happening quietly, unseen, day by day. You do not have to feel productive for important things to be growing.\n\n'
        'Slow is not the same as still. You and your baby are both becoming, a little more each day.',
    reflection: 'Where in your life could you offer yourself a little more patience?',
  ),
  GarbhStory(
    id: 'kindness',
    theme: 'Kindness',
    title: 'The Warmth of a Small Gesture',
    blurb: 'How the smallest kindnesses leave the deepest mark.',
    body:
        'We often think kindness has to be grand - a big gift, a great sacrifice. But ask anyone about a kindness they still remember, and it is almost always something small.\n\n'
        'A warm word on a hard day. Someone who waited. Someone who noticed. These tiny moments stay with us for years.\n\n'
        'Children learn kindness not from lectures but from feeling it, again and again, in ordinary moments. The way they are spoken to becomes the way they speak to the world.\n\n'
        'Your gentleness, even now, is already shaping a gentle heart.',
    reflection: 'What small kindness has stayed with you over the years?',
  ),
  GarbhStory(
    id: 'gratitude',
    theme: 'Gratitude',
    title: 'Counting Quiet Blessings',
    blurb: 'Finding the ordinary moments worth holding onto.',
    body:
        'Gratitude is not about pretending everything is perfect. It is about noticing what is good, even alongside what is hard.\n\n'
        'A warm cup in your hands. A moment of stillness. The flutter of a tiny movement reminding you that you are not alone in your own body.\n\n'
        'When we practise noticing these things, our minds slowly learn to look for them. The same day can feel heavier or lighter depending on where our attention rests.\n\n'
        'Tonight, you might name just one small thing that went gently. That is enough.',
    reflection: 'What is one small thing from today you feel grateful for?',
  ),
  GarbhStory(
    id: 'courage',
    theme: 'Courage',
    title: 'The Little Boat and the Big Sea',
    blurb: 'Courage is not the absence of fear, but moving with it.',
    body:
        'A small boat once worried it was too little for such a wide sea. The waves looked enormous, the horizon far away.\n\n'
        'But the boat discovered something: it did not need to conquer the whole ocean at once. It only needed to ride the next wave, and then the next.\n\n'
        'Courage is rarely a single brave leap. More often it is the quiet decision to keep going, one small step at a time, even when we feel unsure.\n\n'
        'You are doing something extraordinary, one ordinary day at a time. That is courage too.',
    reflection: 'What is one small, brave step you can take this week?',
  ),
  GarbhStory(
    id: 'wonder',
    theme: 'Wonder',
    title: 'The Night Full of Stars',
    blurb: 'Remembering how to look at the world with fresh eyes.',
    body:
        'Children look at the night sky and gasp. Adults, often, forget to look up at all.\n\n'
        'Wonder is the ability to be amazed by ordinary things - a leaf, a raindrop, a sky full of distant light. It is not childish; it is one of the great quiet joys of being alive.\n\n'
        'Your baby will arrive seeing everything for the very first time. In their company, you may rediscover wonder too - the world made new through their eyes.\n\n'
        'For a moment now, let yourself simply marvel that a whole new person is forming, quietly, within you.',
    reflection: 'When did you last feel genuine wonder?',
  ),
  GarbhStory(
    id: 'compassion',
    theme: 'Compassion',
    title: 'The Bird with the Tired Wing',
    blurb: 'On caring for others - and for yourself.',
    body:
        'A flock once paused its long journey because one bird could fly no further that day. Rather than leaving it behind, the others rested too, until it was ready.\n\n'
        'Compassion is simply this: noticing when someone needs gentleness, and offering it without keeping score.\n\n'
        'It applies to ourselves as well. On the days you feel tired, slow, or not enough, you deserve the same softness you would offer a dear friend.\n\n'
        'A mother who is kind to herself teaches her child that they, too, are worthy of kindness.',
    reflection: 'How could you be a little gentler with yourself today?',
  ),
  GarbhStory(
    id: 'resilience',
    theme: 'Resilience',
    title: 'The River That Found Its Way',
    blurb: 'How softness can be its own kind of strength.',
    body:
        'A river never argues with the rock in its path. It simply finds a way around, or over, or slowly, over time, straight through.\n\n'
        'Resilience is not about being hard. It is about being able to bend, adapt, and keep moving toward what matters.\n\n'
        'There will be easier days and harder ones ahead. You will not need to be unbreakable - only to keep flowing, gently, in your own direction.\n\n'
        'You have already come further than you sometimes give yourself credit for.',
    reflection: 'What is something difficult you have already moved through?',
  ),
];

// ---------------------------------------------------------------------------
//  Kriya - Breath & Grounding (each is one breath cycle, looped)
// ---------------------------------------------------------------------------
const List<GarbhPractice> kKriya = [
  GarbhPractice(
    id: 'bhramari',
    title: 'Bhramari Breath',
    blurb: 'A calming humming breath',
    emoji: '🐝',
    minutes: 3,
    phases: [
      BreathPhase('Breathe in', 4, 1.0),
      BreathPhase('Hum out softly', 6, 0.5),
    ],
  ),
  GarbhPractice(
    id: 'deep_belly',
    title: 'Deep Belly Breathing',
    blurb: 'Slow, grounding belly breaths',
    emoji: '🌬️',
    minutes: 5,
    phases: [
      BreathPhase('Breathe in', 4, 1.0),
      BreathPhase('Hold', 2, 1.0),
      BreathPhase('Breathe out', 6, 0.5),
    ],
  ),
  GarbhPractice(
    id: 'box',
    title: 'Box Breathing',
    blurb: 'Steady, balancing square breath',
    emoji: '⬜',
    minutes: 4,
    phases: [
      BreathPhase('Breathe in', 4, 1.0),
      BreathPhase('Hold', 4, 1.0),
      BreathPhase('Breathe out', 4, 0.5),
      BreathPhase('Rest', 4, 0.5),
    ],
  ),
  GarbhPractice(
    id: 'calm',
    title: 'Calm Breathing',
    blurb: 'A simple settling breath',
    emoji: '🍃',
    minutes: 3,
    phases: [
      BreathPhase('Breathe in', 4, 1.0),
      BreathPhase('Breathe out', 6, 0.5),
    ],
  ),
  GarbhPractice(
    id: 'relax',
    title: 'Guided Relaxation',
    blurb: 'Release tension, head to toe',
    emoji: '🧘',
    minutes: 8,
    phases: [
      BreathPhase('Breathe in', 4, 1.0),
      BreathPhase('Hold', 2, 1.0),
      BreathPhase('Breathe out', 6, 0.5),
    ],
  ),
];

// ---------------------------------------------------------------------------
//  Samvad - Womb Connection prompts (one shown as "today's connection")
// ---------------------------------------------------------------------------
// Three trimester-specific sets of SPEAKING cards (read aloud to the bump), per
// the Garbh spec (Pillar 3 - Womb Connection):
//  T1 = affirmations - welcome the baby + grow the mother's own confidence.
//  T2 = expressive, multi-genre read-aloud scripts for the "peak auditory window";
//       the punctuation is deliberately dramatic (- … ! CAPS) so her voice
//       naturally rises, falls and plays, helping baby map sound.
//  T3 = visualization prompts - welcome + the birth day as a cooperative team.
// (Old generic kSamvad prompts removed; replaced by these trimester sets.)

const List<GarbhPrompt> kSamvadT1 = [
  GarbhPrompt('aff1',
      'Little one, you are so wanted. I am becoming your mother, and my body already knows just what to do.'),
  GarbhPrompt('aff2',
      'My darling, every single day my heart makes a little more room for you. I am strong, and I am yours.'),
  GarbhPrompt('aff3',
      'Hello, tiny love. You are safe inside me. We are learning this journey together - you and I, side by side.'),
  GarbhPrompt('aff4',
      'Sweet baby, I welcome you with my whole heart. I trust my body, and I trust the gentle way you are growing.'),
  GarbhPrompt('aff5',
      'I am calm, and I am ready. Every change in me is making a soft, safe home for you, my little one.'),
  GarbhPrompt('aff6',
      'You are already loved beyond measure. Today I am kind to myself, so I can be kind to you.'),
];

const List<GarbhPrompt> kSamvadT2 = [
  GarbhPrompt('scr1',
      "Once upon a time, there was a tiny seed… who dreamed of touching the SKY. 'I'm far too small!' it sighed. But the soft rain whispered, 'Just grow - one little leaf at a time.' And do you know what happened, my love? That tiny seed became a GREAT, tall tree!"),
  GarbhPrompt('scr2',
      "Knock, knock! Who's there? It's the morning sun, peeking through the window - 'Good morning, little one!' it calls. And the birds all answer, 'Tweet! Tweet! Wake UP - it's a beautiful day!'"),
  GarbhPrompt('scr3',
      "Listen… can you hear me? My voice goes soft and low… and then - bright and HIGH! This is how we'll talk, you and I. One day you'll giggle right back - and oh, how I cannot WAIT to hear it!"),
  GarbhPrompt('scr4',
      "Let me tell you about a clever little crow. He was SO thirsty! He found a pot - but the water sat low, low, low. 'What shall I do?' he wondered… Then - plop! plop! PLOP! - in went the pebbles, and the water rose UP. Clever crow! We never give up, do we, my love?"),
  GarbhPrompt('scr5',
      "Round and round the garden hums a gentle bee. Buzz, buzz, BUZZ! 'Hello, flowers!' she sings. And every flower nods - 'Hello, busy bee!' What a happy, humming, wonderful day."),
];

const List<GarbhPrompt> kSamvadT3 = [
  GarbhPrompt('vis1',
      'Close your eyes with me, little one. Picture the day we meet - soft light, gentle hands, and the voice you already know so well. We will do this together, as a team.'),
  GarbhPrompt('vis2',
      'Soon, my love, you will make your way toward my arms. I am strong, you are strong, and we move as one. I am right here, and I will welcome you.'),
  GarbhPrompt('vis3',
      'Imagine it, sweet baby: the very first time I hold you on my chest. Your tiny breath and my steady heartbeat - the two sounds you have always known, finally together.'),
  GarbhPrompt('vis4',
      'On your birth day, we are a team. When you are ready, you will show me the way, and I will breathe you gently into the world. I trust you, and I trust us.'),
  GarbhPrompt('vis5',
      'Picture us, little one - you nestled close, me holding you near. Whatever the day brings, we meet it together. You are not arriving alone; I am right here with you.'),
];

/// The speaking-cards for trimester [t]: affirmations (1) → read-aloud scripts
/// (2) → visualizations (3).
List<GarbhPrompt> samvadForTrimester(int t) =>
    t <= 1 ? kSamvadT1 : (t == 2 ? kSamvadT2 : kSamvadT3);

// ---------------------------------------------------------------------------
//  Lookups
// ---------------------------------------------------------------------------
GarbhAudio? shravanById(String id) {
  for (final a in kShravan) {
    if (a.id == id) return a;
  }
  return null;
}

GarbhStory? vicharaById(String id) {
  for (final s in kVichara) {
    if (s.id == id) return s;
  }
  return null;
}

GarbhPractice? kriyaById(String id) {
  for (final p in kKriya) {
    if (p.id == id) return p;
  }
  return null;
}

/// Today's connection card, rotating gently by day - from the set that matches
/// the mother's [trimester] (affirmation / read-aloud script / visualization).
GarbhPrompt promptForDay(int day, int trimester) {
  final list = samvadForTrimester(trimester);
  return list[(day.clamp(1, 280) - 1) % list.length];
}

// ===========================================================================
//  v2.0 - trimester engine + per-pillar "today" pickers
// ===========================================================================
int garbhTrimester(int week) => week <= 13 ? 1 : (week <= 27 ? 2 : 3);

// --- Shravan (today's listening session) ---
GarbhAudio shravanForTrimester(int t) {
  switch (t) {
    case 1:
      return shravanById('morning_raga') ?? kShravan.first;
    case 2:
      return shravanById('bonding_raga') ?? kShravan.first;
    default:
      return shravanById('relax_raga') ?? kShravan.first;
  }
}

String shravanWhy(int t) {
  switch (t) {
    case 1:
      return 'Calming sound can ease early-pregnancy stress and help you settle into the day.';
    case 2:
      return 'Your baby is beginning to hear - gentle melodies are soothing for you both.';
    default:
      return 'Calming music may help create a relaxing environment as birth approaches.';
  }
}

// --- Vichara: Sacred Insights ---
const List<GarbhInsight> _insights = [
  GarbhInsight(
    sloka: 'Begin gently; the smallest steady step still moves you forward.',
    meaning: 'You do not have to do everything at once - showing up softly is enough.',
    lesson: 'Consistency, not intensity, builds calm.',
    reflection: 'What is one small, kind thing you can do for yourself today?',
  ),
  GarbhInsight(
    sloka: 'A calm mind is a quiet gift you pass to your child.',
    meaning: 'Your peace becomes your baby\'s first felt experience of the world.',
    lesson: 'Tending to your own calm is also caring for your baby.',
    reflection: 'What helped you feel most at ease this week?',
  ),
  GarbhInsight(
    sloka: 'Trust the body that has carried you this far.',
    meaning: 'As birth nears, confidence and rest matter as much as preparation.',
    lesson: 'Strength can be soft - trusting is its own kind of courage.',
    reflection: 'What are you most looking forward to about meeting your baby?',
  ),
];
GarbhInsight insightForTrimester(int t) => _insights[(t - 1).clamp(0, 2)];

/// All Sacred-Insight verses (used by the Tools library - the full repository).
List<GarbhInsight> garbhAllInsights() => _insights;

// --- Vichara: Brain Fitness (gentle puzzles for focused calm) ---
const List<GarbhPuzzle> kPuzzles = [
  GarbhPuzzle('Word Search', '🔤', 'Find the hidden words - a quiet few minutes.'),
  GarbhPuzzle('Sudoku', '🔢', 'A gentle number puzzle to settle a busy mind.'),
  GarbhPuzzle('Logic Puzzle', '🧩', 'A light brain-teaser for focused calm.'),
  GarbhPuzzle('Memory Match', '🃏', 'A simple memory game to relax into.'),
];

// --- Samvad: "why this matters" line per trimester (cards rotate by day) ---
String samvadThemeForTrimester(int t) {
  switch (t) {
    case 1:
      return 'Say these affirmations aloud - welcome your baby, and let your own confidence grow with every word.';
    case 2:
      return "Your baby's hearing is awake now. Read aloud with feeling - let your voice rise, fall and play, so they learn its music.";
    default:
      return 'Picture the day you meet, and speak it softly - you and your baby, a team getting ready together.';
  }
}

// --- Kriya: today's practice + a safety note ---
GarbhPractice kriyaForTrimester(int t) {
  switch (t) {
    case 1:
      return kriyaById('calm') ?? kKriya.first;
    case 2:
      return kriyaById('deep_belly') ?? kKriya.first;
    default:
      return kriyaById('bhramari') ?? kKriya.first;
  }
}

String kriyaSafety(int t) {
  switch (t) {
    case 1:
      return 'Move gently and stop if you feel dizzy or unwell.';
    case 2:
      return 'Avoid lying flat on your back for long; keep movements slow.';
    default:
      return 'Support your bump, go slow, and rest whenever you need to.';
  }
}

// --- Ahara: Nourishment per trimester ---
const List<GarbhNutrition> _nutrition = [
  GarbhNutrition(
    tip: 'Sip water through the day and eat small, frequent meals.',
    why: 'Steady hydration and small meals ease nausea and keep energy stable in the first trimester.',
    recipe: 'Lemon-ginger water with a few soaked almonds.',
    swap: 'Swap one heavy meal for lighter, frequent snacks.',
    habit: 'Keep a glass of water by your bed for the morning.',
  ),
  GarbhNutrition(
    tip: 'Add a good source of protein and iron to today\'s meals.',
    why: 'The second trimester is a growth phase - protein, iron and healthy fats support it.',
    recipe: 'Moong dal khichdi with a side of curd.',
    swap: 'Swap white rice for a dal-and-vegetable bowl.',
    habit: 'Pair iron-rich food with vitamin C (lemon, amla) for absorption.',
  ),
  GarbhNutrition(
    tip: 'Focus on fibre and a light, early dinner.',
    why: 'Fibre eases the constipation common late in pregnancy, and a light dinner supports sleep.',
    recipe: 'Vegetable soup with a fruit for dessert.',
    swap: 'Swap a late, heavy dinner for a lighter early one.',
    habit: 'Dim the lights and screens an hour before bed.',
  ),
];
GarbhNutrition nutritionForTrimester(int t) => _nutrition[(t - 1).clamp(0, 2)];

// ===========================================================================
//  Daily rotation pickers - used ONLY by the Home daily Garbh section, where
//  each pillar shows a different item each day (no recommendation lists). The
//  full Tools Garbh keeps the trimester pickers above.
// ===========================================================================
int _dayIdx(int day, int n) => (day.clamp(1, 280) - 1) % n;

List<GarbhAudio> get _dailyRagas =>
    kShravan.where((a) => a.kind == GarbhKind.raga).toList();

/// A different raga each day (cycles through the raga set).
GarbhAudio shravanForDay(int day) {
  final r = _dailyRagas;
  return r[_dayIdx(day, r.length)];
}

/// A different sacred insight each day.
GarbhInsight insightForDay(int day) => _insights[_dayIdx(day, _insights.length)];

/// One uplifting read per day (rotates through the library).
GarbhStory vicharaStoryForDay(int day) => kVichara[_dayIdx(day, kVichara.length)];

/// A different breath practice each day.
GarbhPractice kriyaForDay(int day) => kKriya[_dayIdx(day, kKriya.length)];

/// A different nourishment focus each day.
GarbhNutrition nutritionForDay(int day) =>
    _nutrition[_dayIdx(day, _nutrition.length)];

// ===========================================================================
//  v2.1 - Shravan month view + raga time-of-day badges (ADDITIVE)
// -----------------------------------------------------------------------------
//  The Shravan library is now browsed month-by-month (Month 1-9) instead of all
//  at once. kShravan items are NOT month-tagged, so we distribute the library
//  across the 9 pregnancy months here. Backward-compatible: kShravan, the daily
//  pickers and lookups above are untouched.
// ===========================================================================

/// Which pregnancy month (1-9) a given [week] falls in. 40 weeks over 9 months
/// (~4.4 weeks each), clamped to 1..9.
int garbhMonth(int week) =>
    ((week - 1) / 4.4).floor().clamp(0, 8) + 1;

/// TODO: approximation - real per-month audio curation not yet available, so the
/// existing 10 kShravan items are hand-distributed across the 9 months (some
/// months share popular ragas). Replace with month-specific recordings later.
const Map<int, List<String>> kShravanMonthIds = {
  1: ['morning_raga', 'relax_raga'],
  2: ['bonding_raga', 'forest'],
  3: ['evening_raga', 'bells'],
  4: ['relax_raga', 'rain'],
  5: ['bonding_raga', 'ocean'],
  6: ['morning_raga', 'forest', 'bells'],
  7: ['sleep_raga', 'rain'],
  8: ['evening_raga', 'bodyscan'],
  9: ['sleep_raga', 'ocean', 'bodyscan'],
};

/// The listening sessions curated for pregnancy [month] (1-9).
List<GarbhAudio> shravanForMonth(int month) {
  final ids = kShravanMonthIds[month.clamp(1, 9)] ?? const <String>[];
  return [for (final id in ids) shravanById(id)]
      .whereType<GarbhAudio>()
      .toList();
}

/// A gentle time-of-day badge for a listening item, derived from its existing
/// title/subtitle/id hints. Falls back to 'Morning'. Returns 'Morning' or
/// 'Evening' (English; the UI supplies its own bilingual label if needed).
String ragaTimeBadge(GarbhAudio a) {
  final hint = '${a.id} ${a.title} ${a.subtitle}'.toLowerCase();
  const eveningHints = [
    'evening', 'sleep', 'night', 'moon', 'unwind', 'rest', 'ocean', 'rain'
  ];
  for (final h in eveningHints) {
    if (hint.contains(h)) return 'Evening';
  }
  return 'Morning';
}
