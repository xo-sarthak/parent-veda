// =============================================================================
//  Garbh Sanskar Journey — curated seed content
// -----------------------------------------------------------------------------
//  A starter library across the four pillars. Warm, universal, non-religious;
//  enough to make the experience feel real. Scales to the launch quantities
//  (Shravan 40–50, Samvad 280, Vichara 100–150, Kriya 30–40) by adding entries.
// =============================================================================

import '../models/garbh_content.dart';

// ---------------------------------------------------------------------------
//  Shravan — Sacred Listening (placeholder audio uses the bundled drone)
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
//  Vichara — Positive Contemplation (short reflective reads)
// ---------------------------------------------------------------------------
const List<GarbhStory> kVichara = [
  GarbhStory(
    id: 'curiosity',
    theme: 'Curiosity',
    title: 'The Child Who Asked Why',
    blurb: 'A short reflection on curiosity, wonder and lifelong learning.',
    body:
        'There was once a child who asked "why" about everything. Why is the sky blue? Why do birds sing in the morning? Why does the moon follow us home?\n\n'
        'At first the grown-ups answered quickly, and then they grew tired of answering at all. But the child kept asking — not to be difficult, but because the world felt endlessly interesting.\n\n'
        'Years later, that same curiosity became the child\'s greatest gift. It made them a careful listener, a patient learner, and someone who never stopped growing.\n\n'
        'Every child is born with this spark. It does not need to be taught — only protected, welcomed, and answered with a little patience.',
    reflection: 'What quality would you most like your child to keep as they grow?',
  ),
  GarbhStory(
    id: 'patience',
    theme: 'Patience',
    title: 'How Trees Grow Slowly Yet Strongly',
    blurb: 'A gentle reminder that the strongest things take time.',
    body:
        'A tree does not rush. In its first year it may look like nothing more than a thin stem, easily bent by the wind.\n\n'
        'But beneath the soil, quietly and unseen, it is doing the most important work — sending roots deep and wide. Only later does it rise tall, and by then it can hold the weight of storms.\n\n'
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
        'We often think kindness has to be grand — a big gift, a great sacrifice. But ask anyone about a kindness they still remember, and it is almost always something small.\n\n'
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
        'Wonder is the ability to be amazed by ordinary things — a leaf, a raindrop, a sky full of distant light. It is not childish; it is one of the great quiet joys of being alive.\n\n'
        'Your baby will arrive seeing everything for the very first time. In their company, you may rediscover wonder too — the world made new through their eyes.\n\n'
        'For a moment now, let yourself simply marvel that a whole new person is forming, quietly, within you.',
    reflection: 'When did you last feel genuine wonder?',
  ),
  GarbhStory(
    id: 'compassion',
    theme: 'Compassion',
    title: 'The Bird with the Tired Wing',
    blurb: 'On caring for others — and for yourself.',
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
        'There will be easier days and harder ones ahead. You will not need to be unbreakable — only to keep flowing, gently, in your own direction.\n\n'
        'You have already come further than you sometimes give yourself credit for.',
    reflection: 'What is something difficult you have already moved through?',
  ),
];

// ---------------------------------------------------------------------------
//  Kriya — Breath & Grounding (each is one breath cycle, looped)
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
//  Samvad — Womb Connection prompts (one shown as "today's connection")
// ---------------------------------------------------------------------------
const List<GarbhPrompt> kSamvad = [
  GarbhPrompt('s1', 'Tell your baby about your favourite childhood memory.'),
  GarbhPrompt('s2', 'Tell your baby about the day you found out they were coming.'),
  GarbhPrompt('s3', 'Describe the people who are so excited to meet them.'),
  GarbhPrompt('s4', 'Tell your baby what you hope they will love about the world.'),
  GarbhPrompt('s5', 'Share a song that has always meant a lot to you.'),
  GarbhPrompt('s6', 'Tell your baby about their grandparents.'),
  GarbhPrompt('s7', 'Describe your favourite place, and why it is special.'),
  GarbhPrompt('s8', 'Tell your baby one value you hope to pass on.'),
  GarbhPrompt('s9', 'Tell your baby why you are excited to meet them.'),
  GarbhPrompt('s10', 'Share a small dream you have for them.'),
  GarbhPrompt('s11', 'Tell your baby about a time you felt truly brave.'),
  GarbhPrompt('s12', 'Describe what home feels like to you.'),
  GarbhPrompt('s13', 'Tell your baby about a food you cannot wait to share.'),
  GarbhPrompt('s14', 'Share what made you smile today.'),
];

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

/// Today's connection prompt, rotating gently by day of pregnancy.
GarbhPrompt promptForDay(int day) =>
    kSamvad[(day.clamp(1, 280) - 1) % kSamvad.length];

// ===========================================================================
//  v2.0 — trimester engine + per-pillar "today" pickers
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
      return 'Your baby is beginning to hear — gentle melodies are soothing for you both.';
    default:
      return 'Calming music may help create a relaxing environment as birth approaches.';
  }
}

// --- Vichara: Sacred Insights ---
const List<GarbhInsight> _insights = [
  GarbhInsight(
    sloka: 'Begin gently; the smallest steady step still moves you forward.',
    meaning: 'You do not have to do everything at once — showing up softly is enough.',
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
    lesson: 'Strength can be soft — trusting is its own kind of courage.',
    reflection: 'What are you most looking forward to about meeting your baby?',
  ),
];
GarbhInsight insightForTrimester(int t) => _insights[(t - 1).clamp(0, 2)];

// --- Vichara: Brain Fitness (gentle puzzles for focused calm) ---
const List<GarbhPuzzle> kPuzzles = [
  GarbhPuzzle('Word Search', '🔤', 'Find the hidden words — a quiet few minutes.'),
  GarbhPuzzle('Sudoku', '🔢', 'A gentle number puzzle to settle a busy mind.'),
  GarbhPuzzle('Logic Puzzle', '🧩', 'A light brain-teaser for focused calm.'),
  GarbhPuzzle('Memory Match', '🃏', 'A simple memory game to relax into.'),
];

// --- Samvad: theme line per trimester (the prompt rotates by day) ---
String samvadThemeForTrimester(int t) {
  switch (t) {
    case 1:
      return 'Welcome your baby and be kind to yourself as your body changes.';
    case 2:
      return 'Your baby can hear you now — talk, tell stories, share your day.';
    default:
      return 'Speak words of welcome and calm as you prepare to meet your baby.';
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
    why: 'The second trimester is a growth phase — protein, iron and healthy fats support it.',
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
