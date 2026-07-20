// =============================================================================
//  ParentVeda Development - content model, seed data + store
// -----------------------------------------------------------------------------
//  A Development COMPANION (not a tracker / assessment / checklist): helps
//  parents understand what's developing, what comes next, and how to support it
//  TODAY. Supportive language only (Emerging → Mastered), never "behind/delayed".
//  Feels playful and optimistic (vs. Health's calm structure). Seeded for Aarav
//  (~4 months); a real Development/Age/Brain engine slots in later. No gamification
//  - no points, streaks or badges. Nothing here depends on the pregnancy app.
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/cloud_synced_store.dart';

/// Supportive progress words - never percentages, never grades.
enum DevWord { emerging, practicing, growing, confident, mastered }

String devWordLabel(DevWord w) => switch (w) {
      DevWord.emerging => 'Emerging',
      DevWord.practicing => 'Practicing',
      DevWord.growing => 'Growing',
      DevWord.confident => 'Confident',
      DevWord.mastered => 'Mastered',
    };

/// A gentle 0..1 fill for the soft progress arc - visual encouragement, not a score.
double devWordFraction(DevWord w) => switch (w) {
      DevWord.emerging => 0.25,
      DevWord.practicing => 0.45,
      DevWord.growing => 0.65,
      DevWord.confident => 0.85,
      DevWord.mastered => 1.0,
    };

/// One step on a developmental journey (a story, not a checkbox).
class DevStage {
  const DevStage(this.name, this.status, this.meaning, this.why, {this.activities = const []});
  final String name;
  final String status; // 'mastered' | 'current' | 'next' | 'future'
  final String meaning;
  final String why;
  final List<String> activities; // DevActivity ids to encourage it
}

class DevArea {
  const DevArea({
    required this.id,
    required this.name,
    required this.icon,
    required this.accent,
    required this.word,
    required this.stage,
    required this.summary,
    required this.todayTip,
    required this.brainNote,
    required this.journey,
    required this.seed,
    this.about = const [],
    this.nextActivityId,
    this.relatedArticle,
    this.relatedVideoId,
  });
  final String id;
  final String name;
  final IconData icon;
  final Color accent;
  final DevWord word;
  final String stage; // current stage label
  final String summary; // one line
  final String todayTip; // one thing a parent can do today
  final String brainNote;
  final List<DevStage> journey;
  final int seed;
  final List<String> about; // 2–3 paragraph description for the area screen
  final String? nextActivityId;
  final String? relatedArticle;
  final String? relatedVideoId;

  /// The area's full description; falls back to summary + brain note if no
  /// dedicated `about` copy has been written yet.
  List<String> get description => about.isNotEmpty ? about : [summary, brainNote];
}

class DevActivity {
  const DevActivity({
    required this.id,
    required this.title,
    required this.areaId,
    required this.minutes,
    required this.difficulty,
    required this.ageTag,
    required this.materials,
    required this.skills,
    required this.safety,
    required this.benefit,
    required this.steps,
    required this.seed,
  });
  final String id;
  final String title;
  final String areaId;
  final int minutes;
  final String difficulty;
  final String ageTag;
  final List<String> materials;
  final List<String> skills;
  final List<String> safety;
  final String benefit;
  final List<String> steps;
  final int seed;
}

class BrainTopic {
  const BrainTopic(this.title, this.body, this.tip);
  final String title;
  final String body;
  final String tip;
}

class LookAhead {
  const LookAhead(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

class CheckInQ {
  const CheckInQ(this.areaId, this.text);
  final String areaId;
  final String text;
}

// ---- development areas ------------------------------------------------------
const Color _amber = Color(0xFFC98A2B);
const Color _blue = Color(0xFF3E6DA6);
const Color _rose = Color(0xFFD6478A);
const Color _violet = Color(0xFF7C5CC4);

const List<DevArea> kDevAreas = [
  DevArea(
    id: 'cognitive',
    name: 'Thinking & Problem Solving',
    icon: Icons.psychology_outlined,
    accent: Color(0xFF6A30B6),
    word: DevWord.growing,
    stage: 'Cause & effect',
    summary: 'Working out that one thing makes another happen.',
    todayTip: 'Show him a simple cause and effect, shake a rattle, then pause, and let him take it in.',
    brainNote: 'His brain is wiring the idea that his actions change the world, the seed of all problem-solving.',
    seed: 1,
    about: [
      'Thinking begins with a simple, astonishing discovery: that one thing makes another happen. Right now your baby is working out that his own hand reaching is what makes the toy move — cause, meet effect. It is the foundation every future bit of problem-solving is built on.',
      'You will see it in the way he studies things: following your hand all the way to the toy, watching what happens when he bats at a rattle, beginning to expect the peekaboo before it comes. He is running tiny experiments all day long.',
      'None of this needs flashcards or “brain-training”. It needs everyday moments where his actions clearly change something, and a calm narrator — you — putting words to what he is figuring out.',
    ],
    nextActivityId: 'peekaboo',
    relatedVideoId: 'leap4brain',
    journey: [
      DevStage('Notices contrast', 'mastered', 'Fixes on bold patterns and faces.', 'The very first attention-building.'),
      DevStage('Follows a moving toy', 'mastered', 'Tracks something across his view.', 'Visual attention and prediction.'),
      DevStage('Cause & effect', 'current', 'Grasps that his hand makes the toy move.', 'Where thinking begins.', activities: ['peekaboo', 'highcontrast']),
      DevStage('Object permanence', 'next', 'Begins to sense things exist when hidden.', 'Why peekaboo becomes magic.', activities: ['peekaboo']),
      DevStage('Simple problem solving', 'future', 'Reaches around a barrier for a toy.', 'Early planning and persistence.'),
    ],
  ),
  DevArea(
    id: 'language',
    name: 'Language & Communication',
    icon: Icons.chat_bubble_outline_rounded,
    accent: Color(0xFFFF5A79),
    word: DevWord.emerging,
    stage: 'Musical babble',
    summary: 'Coos stretching into “aah-goo”, squeals and raspberries.',
    todayTip: 'Have a “conversation”: say something, then pause and wait for his coo, and answer it back.',
    brainNote: 'Long before words, his brain is mapping the rhythm and melody of your voice.',
    seed: 2,
    about: [
      'The conversation starts long before the first word. Your baby is soaking up the melody, rhythm and turn-taking of language now, in every coo and every reply you give back. This is the groundwork the first words will stand on.',
      'He is learning that sounds mean something, that his voice earns a response, and that talking happens back-and-forth. Squeals, raspberries and sing-song “aah-goo” are all rehearsal — the more you answer them, the more he practises.',
      'The simplest things matter most: narrate your day, sing, and pause to leave room for his reply. You do not need to teach words; you just need to have the conversation.',
    ],
    nextActivityId: 'narrate',
    relatedArticle: 'Talking to your baby before they can talk',
    relatedVideoId: 'babbling',
    journey: [
      DevStage('Cooing', 'mastered', 'Soft vowel sounds, aah, ooh.', 'The first voice play.'),
      DevStage('Musical babble', 'current', 'Squeals, raspberries, sing-song sounds.', 'Rehearsing conversation’s music.', activities: ['narrate', 'song']),
      DevStage('Turn-taking', 'next', 'Waits, then “answers” you.', 'The back-and-forth of real talk.', activities: ['narrate']),
      DevStage('Babble with consonants', 'future', '“Ba-ba”, “da-da” appear.', 'Building blocks of first words.'),
      DevStage('First words', 'future', 'A meaningful “mama”, “dada”.', 'Language, arrived.'),
    ],
  ),
  DevArea(
    id: 'gross_motor',
    name: 'Gross Motor',
    icon: Icons.directions_run_rounded,
    accent: _amber,
    word: DevWord.practicing,
    stage: 'Rolling',
    summary: 'Pushing up strong on the floor, rocking, a first roll is near.',
    todayTip: 'A little tummy time with a toy just out of reach, it builds the strength to roll.',
    brainNote: 'Each push-up wires the neck, core and coordination he’ll build every future move on.',
    seed: 3,
    about: [
      'Every big movement builds on the last. Head control came first; now your baby is pushing up strong on the floor and rocking — the first roll is close. Each of these is a rung on the ladder that leads to sitting, crawling and, eventually, those first steps.',
      'This is physical strength and brain wiring at the same time: every push-up and wobble is teaching his neck, core and coordination to work together. Being on the floor, free to move, is the single best thing for it.',
      'You cannot rush the timeline — every baby arrives at each move in his own week. What helps is plenty of safe, happy floor time and a little something just out of reach to tempt him toward it.',
    ],
    nextActivityId: 'tummy_play',
    relatedVideoId: 'tummytime',
    journey: [
      DevStage('Head control', 'mastered', 'Holds his head steady and lifts it.', 'The foundation for everything.'),
      DevStage('Pushes up on forearms', 'mastered', 'Lifts chest during tummy time.', 'Building upper-body strength.'),
      DevStage('Rolling', 'current', 'Rocks and rolls tummy-to-back any day now.', 'His first way to move himself.', activities: ['tummy_play', 'roll_help']),
      DevStage('Sitting with support', 'next', 'Props upright, wobbling but proud.', 'A whole new view of the world.'),
      DevStage('Crawling', 'future', 'The floor becomes his to explore.', 'Independence takes off.'),
      DevStage('Standing & walking', 'future', 'Pulls up, cruises, then those first steps.', 'The big one.'),
    ],
  ),
  DevArea(
    id: 'fine_motor',
    name: 'Fine Motor',
    icon: Icons.back_hand_outlined,
    accent: _blue,
    word: DevWord.emerging,
    stage: 'Reaching & grasping',
    summary: 'Hands find each other; he swipes and grabs at dangling toys.',
    todayTip: 'Offer a light, easy-to-hold toy at his midline and let him reach and grasp.',
    brainNote: 'Hand-eye coordination is being wired, every grab is his brain aiming and adjusting.',
    seed: 4,
    nextActivityId: 'reach_ring',
    relatedVideoId: 'leap4brain',
    journey: [
      DevStage('Hands to midline', 'mastered', 'Brings hands together at his chest.', 'Discovering his own hands.'),
      DevStage('Reaching & grasping', 'current', 'Swipes at, then grabs, a toy.', 'Aiming with intent.', activities: ['reach_ring', 'texture']),
      DevStage('Transfers hand to hand', 'next', 'Passes a toy between hands.', 'Coordination across the body.'),
      DevStage('Pincer grasp', 'future', 'Picks up tiny things with finger and thumb.', 'The key to self-feeding.'),
    ],
  ),
  DevArea(
    id: 'emotional',
    name: 'Emotional',
    icon: Icons.favorite_border,
    accent: _rose,
    word: DevWord.growing,
    stage: 'Borrowing your calm',
    summary: 'Beams with joy, and settles fastest in your steady arms.',
    todayTip: 'When he fusses, slow your own breathing and voice, he tunes to your calm.',
    brainNote: 'He can’t regulate emotions alone yet, he literally borrows yours. That’s co-regulation.',
    seed: 5,
    about: [
      'Your baby feels big feelings, but he has none of the tools to manage them yet — so he borrows yours. When he settles fastest in your steady arms, that is not a habit to break; it is exactly how emotional development is meant to work at this age.',
      'This is called co-regulation: your calm voice and slow breathing literally settle his nervous system. Every time you soothe him, you are laying down the wiring he will one day use to soothe himself.',
      'The social side is blossoming too — he beams across a room, and a laugh now earns a laugh back. Warm, responsive back-and-forth is what teaches him that he is safe, loved and understood.',
    ],
    relatedVideoId: 'mumwellness',
    journey: [
      DevStage('Social smile', 'mastered', 'Smiles on purpose at the people he loves.', 'The first true connection.'),
      DevStage('Borrowing your calm', 'current', 'Settles with your steady presence.', 'Learning that big feelings pass.', activities: ['song']),
      DevStage('Expressing delight', 'next', 'Belly laughs and squeals of joy.', 'A widening emotional range.'),
      DevStage('Self-soothing begins', 'future', 'Finds a thumb or a lovey to settle.', 'Early independence in feelings.'),
    ],
  ),
  DevArea(
    id: 'social',
    name: 'Social',
    icon: Icons.groups_outlined,
    accent: _violet,
    word: DevWord.growing,
    stage: 'You are his world',
    summary: 'Your face is the best thing in the room; a laugh earns a laugh.',
    todayTip: 'Play face-to-face: exaggerate your expressions and watch him copy and respond.',
    brainNote: 'He’s learning that people are special and responsive, the root of all relationships.',
    seed: 6,
    nextActivityId: 'peekaboo',
    journey: [
      DevStage('Prefers faces', 'mastered', 'Drawn to faces above all else.', 'People matter most.'),
      DevStage('Social back-and-forth', 'current', 'Smiles and “talks” to get a response.', 'The dance of connection.', activities: ['peekaboo', 'narrate']),
      DevStage('Enjoys games', 'next', 'Peekaboo and “gonna get you” delight him.', 'Shared joy and anticipation.'),
      DevStage('Stranger awareness', 'future', 'Prefers familiar people, wary of new ones.', 'A sign of secure attachment.'),
    ],
  ),
  DevArea(
    id: 'creativity',
    name: 'Creativity & Imagination',
    icon: Icons.palette_outlined,
    accent: Color(0xFFFF5A79),
    word: DevWord.emerging,
    stage: 'Exploring the senses',
    summary: 'Fascinated by texture, contrast and sound, his first “art”.',
    todayTip: 'Offer safe things with different textures to touch, soft, crinkly, smooth.',
    brainNote: 'Rich sensory input now builds the pathways later imagination and creativity will use.',
    seed: 7,
    nextActivityId: 'texture',
    journey: [
      DevStage('Sensory delight', 'current', 'Loves contrast, texture and new sounds.', 'The raw material of imagination.', activities: ['texture', 'highcontrast']),
      DevStage('Exploring with mouth & hands', 'next', 'Everything is investigated.', 'Learning by doing.'),
      DevStage('Cause-and-effect play', 'future', 'Bangs, drops, and shakes to see what happens.', 'Experimenting like a little scientist.'),
    ],
  ),
  DevArea(
    id: 'selfcare',
    name: 'Self-care & Independence',
    icon: Icons.emoji_food_beverage_outlined,
    accent: _amber,
    word: DevWord.emerging,
    stage: 'First self-soothing',
    summary: 'Brings hands to his mouth and finds small ways to settle himself.',
    todayTip: 'Let him have safe moments to settle himself before you step in, a beat of patience helps.',
    brainNote: 'The first flickers of independence, small self-soothing that grows into big self-reliance.',
    seed: 8,
    journey: [
      DevStage('Hands to mouth', 'current', 'Finds and mouths his own hands.', 'The very first self-soothing.'),
      DevStage('Holds during feeds', 'next', 'Rests a hand on the bottle or breast.', 'Participating in his own care.'),
      DevStage('Finger foods', 'future', 'Feeds himself soft bits (from ~6 months).', 'A big leap in independence.'),
    ],
  ),
];

// ---- activities -------------------------------------------------------------
const List<DevActivity> kDevActivities = [
  DevActivity(
    id: 'peekaboo',
    title: 'Peekaboo, slow and silly',
    areaId: 'cognitive',
    minutes: 5,
    difficulty: 'Easy',
    ageTag: '3–6 mo',
    materials: ['Just your hands (or a light cloth)'],
    skills: ['Object permanence', 'Social connection', 'Cause & effect'],
    safety: ['Keep any cloth light and away from his face', 'Stop if he seems overwhelmed'],
    benefit: 'Plants the first seed of object permanence, the idea that things (and you) still exist when out of sight.',
    steps: ['Hide your face behind your hands.', 'Pause a beat, let the anticipation build.', 'Reveal with a warm “peekaboo!”.', 'Watch his reaction, and follow his lead on the pace.'],
    seed: 11,
  ),
  DevActivity(
    id: 'narrate',
    title: 'Narrate & pause',
    areaId: 'language',
    minutes: 3,
    difficulty: 'Easy',
    ageTag: '3–12 mo',
    materials: ['Nothing at all'],
    skills: ['Language', 'Turn-taking', 'Attention'],
    safety: ['None, just your voice'],
    benefit: 'Builds his ear for language and the back-and-forth rhythm of conversation, long before words.',
    steps: ['Describe what you’re doing, “now we’re pouring the water”.', 'Pause, as if leaving room for his reply.', 'When he coos, answer as if it meant something.', 'Keep the loop going, it’s a real conversation.'],
    seed: 12,
  ),
  DevActivity(
    id: 'tummy_play',
    title: 'Tummy-time mirror play',
    areaId: 'gross_motor',
    minutes: 5,
    difficulty: 'Easy',
    ageTag: '2–6 mo',
    materials: ['A baby-safe mirror or a favourite toy'],
    skills: ['Neck & core strength', 'Visual tracking'],
    safety: ['Always supervise tummy time', 'Stop before happy turns to upset'],
    benefit: 'Builds the neck, shoulder and core strength he needs to roll, then sit.',
    steps: ['Lay him on his tummy on a firm, safe surface.', 'Place a mirror or toy just in front at his eye level.', 'Get down low and talk to him.', 'Short and frequent beats one long session.'],
    seed: 13,
  ),
  DevActivity(
    id: 'roll_help',
    title: 'Encourage the roll',
    areaId: 'gross_motor',
    minutes: 4,
    difficulty: 'Easy',
    ageTag: '3–6 mo',
    materials: ['A rattly toy'],
    skills: ['Rolling', 'Coordination'],
    safety: ['Soft, clear surface', 'Never force the movement'],
    benefit: 'Invites the first roll by tempting him to turn toward something interesting.',
    steps: ['Lay him on his back.', 'Hold a toy to one side, just past his shoulder.', 'Let him reach and twist toward it.', 'Cheer the effort, not just the roll.'],
    seed: 14,
  ),
  DevActivity(
    id: 'reach_ring',
    title: 'Reach for the ring',
    areaId: 'fine_motor',
    minutes: 4,
    difficulty: 'Easy',
    ageTag: '3–6 mo',
    materials: ['A light ring or graspable toy'],
    skills: ['Reaching', 'Grasp', 'Hand-eye coordination'],
    safety: ['Toy larger than his mouth', 'Nothing with small parts'],
    benefit: 'Sharpens hand-eye coordination as he aims, reaches and grasps with intent.',
    steps: ['Hold the ring at his midline, an arm’s reach away.', 'Let him track it and reach.', 'Bring it close enough to grab if he tires.', 'Celebrate the grasp.'],
    seed: 15,
  ),
  DevActivity(
    id: 'texture',
    title: 'A little texture basket',
    areaId: 'creativity',
    minutes: 6,
    difficulty: 'Easy',
    ageTag: '3–8 mo',
    materials: ['A few safe items, silk, a wooden spoon, a crinkly cloth'],
    skills: ['Sensory exploration', 'Fine motor', 'Curiosity'],
    safety: ['Everything larger than his mouth', 'Supervise closely'],
    benefit: 'Feeds his senses and builds the neural pathways that curiosity and creativity grow from.',
    steps: ['Gather 3–4 safe items with different textures.', 'Offer one at a time to touch and hold.', 'Name each feeling, “soft”, “crinkly”.', 'Follow his interest; there’s no wrong way.'],
    seed: 16,
  ),
  DevActivity(
    id: 'highcontrast',
    title: 'Black, white & red',
    areaId: 'cognitive',
    minutes: 4,
    difficulty: 'Easy',
    ageTag: '0–6 mo',
    materials: ['A high-contrast card or book'],
    skills: ['Visual attention', 'Focus'],
    safety: ['None'],
    benefit: 'Bold contrast is easiest for young eyes, holding his gaze builds visual attention.',
    steps: ['Hold a high-contrast image about 30 cm away.', 'Let his eyes settle and study it.', 'Slowly move it side to side so he tracks.', 'Stop when his attention drifts.'],
    seed: 17,
  ),
  DevActivity(
    id: 'song',
    title: 'Sing, pause, and play',
    areaId: 'language',
    minutes: 4,
    difficulty: 'Easy',
    ageTag: '0–12 mo',
    materials: ['A song you love'],
    skills: ['Language', 'Emotional connection', 'Anticipation'],
    safety: ['None'],
    benefit: 'Melody and repetition are gifts to a developing brain, and the pauses invite him to join in.',
    steps: ['Sing a simple, repetitive song.', 'Pause before the last word or a tickle.', 'Watch him anticipate what’s coming.', 'Repeat, babies adore the familiar.'],
    seed: 18,
  ),
];

// ---- brain development ------------------------------------------------------
const String kBrainThisWeek =
    'This month, {child}’s brain is becoming far better at connecting cause and effect, and at recognising the faces he loves. Every bit of eye contact, narrated play and “conversation” you share is physically strengthening these fast-growing connections.';

const List<BrainTopic> kBrainTopics = [
  BrainTopic('Recognising familiar faces', 'He now knows your face from a stranger’s, and lights up for it. This is memory and social wiring, together.', 'Lots of face-to-face time and warm eye contact strengthens it.'),
  BrainTopic('Cause and effect', 'He’s grasping that his own actions make things happen, the foundation of thinking and problem-solving.', 'Give him simple “I did that!” moments, like a rattle that sounds when he moves it.'),
  BrainTopic('The music of language', 'His brain is mapping the rhythm and melody of speech long before he understands words.', 'Talk, sing and pause for his reply, narration is brain food.'),
  BrainTopic('Borrowing calm', 'The part that manages big feelings is years from ready, for now, he regulates by tuning into you.', 'Your steady voice and slow breathing literally settle his nervous system.'),
];

// ---- looking ahead ----------------------------------------------------------
const List<LookAhead> kLookAhead = [
  LookAhead(Icons.directions_run_rounded, 'A first roll, and then both ways', 'Over the coming weeks, many babies begin rolling tummy-to-back, then back-to-tummy. Plenty of floor time is the best invitation.'),
  LookAhead(Icons.pan_tool_alt_outlined, 'Reaching becomes grabbing', 'Swiping at toys turns into confident grabbing, and soon passing a toy from hand to hand.'),
  LookAhead(Icons.restaurant_outlined, 'The world of first foods', 'Around six months, many babies show they’re ready to explore solids, a whole new kind of learning.'),
  LookAhead(Icons.record_voice_over_outlined, 'Consonants join the babble', 'Over time, “aah-goo” grows into “ba-ba” and “da-da”, the building blocks of first words.'),
];

const List<(String, String)> kLookAheadPicks = [
  ('Toy', 'A soft, graspable rattle or textured ring'),
  ('Book', 'A high-contrast board book'),
  ('Read', 'The quiet case for tummy time'),
];

// ---- gentle check-ins -------------------------------------------------------
const List<CheckInQ> kCheckIns = [
  CheckInQ('gross_motor', 'Does he push up on his forearms during tummy time?'),
  CheckInQ('social', 'Does he smile back when you smile at him?'),
  CheckInQ('language', 'Does he turn toward your voice or new sounds?'),
  CheckInQ('fine_motor', 'Does he bring his hands together at his chest?'),
  CheckInQ('cognitive', 'Does he follow a toy as you move it across his view?'),
  CheckInQ('emotional', 'Does he settle more easily in your arms?'),
];

// ---- lookups ----------------------------------------------------------------
DevArea devAreaById(String id) => kDevAreas.firstWhere((a) => a.id == id, orElse: () => kDevAreas.first);
DevActivity devActivityById(String id) => kDevActivities.firstWhere((a) => a.id == id, orElse: () => kDevActivities.first);
List<DevActivity> activitiesForArea(String areaId) => kDevActivities.where((a) => a.areaId == areaId).toList();

/// Today's one highlighted area (a real engine would rotate/personalise).
DevArea todaysFocus() => devAreaById('language');

// ---- domain → cross-content mapping -----------------------------------------
//  Maps a development area to the Watch category, Read collection and Product
//  category used by its three "Go deeper" rails and their "view more" screens.
String watchCategoryForArea(String areaId) => switch (areaId) {
      'cognitive' => 'Brain Development',
      'language' => 'Language',
      'gross_motor' => 'Activities',
      'fine_motor' => 'Activities',
      'emotional' => 'Behaviour',
      'social' => 'Behaviour',
      'creativity' => 'Play',
      'selfcare' => 'Health',
      _ => 'Brain Development',
    };

String readCollectionForArea(String areaId) => switch (areaId) {
      'cognitive' => 'brain',
      'language' => 'play',
      'gross_motor' => 'play',
      'fine_motor' => 'play',
      'emotional' => 'behaviour',
      'social' => 'behaviour',
      'creativity' => 'play',
      'selfcare' => 'feeding',
      _ => 'brain',
    };

String productCategoryForArea(String areaId) => switch (areaId) {
      'emotional' => 'Sleep',
      'selfcare' => 'Feeding',
      _ => 'Play & Development',
    };

/// The current + emerging skills of an area (its 'current' and 'next' stages) -
/// what the My Child "Milestones" section and the area screen surface.
List<DevStage> activeStages(DevArea area) =>
    area.journey.where((s) => s.status == 'current' || s.status == 'next').toList();

// =============================================================================
//  DevStore - saved & completed activities + gentle check-in answers.
// =============================================================================
class DevStore extends ChangeNotifier with CloudSyncedStore {
  DevStore._();
  static final DevStore instance = DevStore._();

  final Set<String> _saved = {'peekaboo'};
  final Set<String> _completed = {'tummy_play'};
  final Map<String, bool> _checkIns = {}; // question text -> yes/no

  // ---- persistence (user_state KV; own-only, a personal preference) --------
  static const _prefsKey = 'pp_development';

  @override
  String get cloudKey => _prefsKey;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) applyCloudData(jsonDecode(raw));
    } catch (_) {/* keep the starter state */}
    notifyListeners();
    try {
      await syncStateFromCloud();
    } catch (_) {/* stay local */}
  }

  @override
  Object cloudData() => {
        'saved': _saved.toList(),
        'completed': _completed.toList(),
        'checkIns': _checkIns,
      };

  @override
  void applyCloudData(Object data) {
    if (data is! Map) return;
    final s = data['saved'];
    if (s is List) _saved..clear()..addAll(s.map((e) => e.toString()));
    final c = data['completed'];
    if (c is List) _completed..clear()..addAll(c.map((e) => e.toString()));
    final k = data['checkIns'];
    if (k is Map) {
      _checkIns
        ..clear()
        ..addAll(k.map((key, v) => MapEntry(key.toString(), v == true)));
    }
  }

  @override
  Future<void> persistLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(cloudData()));
    } catch (_) {}
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    persistLocalCache();
  }

  bool isSaved(String id) => _saved.contains(id);
  void toggleSave(String id) {
    _saved.contains(id) ? _saved.remove(id) : _saved.add(id);
    notifyListeners();
  }

  bool isCompleted(String id) => _completed.contains(id);
  void toggleComplete(String id) {
    _completed.contains(id) ? _completed.remove(id) : _completed.add(id);
    notifyListeners();
  }

  List<DevActivity> get savedActivities => _saved.map(devActivityById).toList();

  bool? checkInAnswer(String text) => _checkIns[text];
  void setCheckIn(String text, bool yes) {
    _checkIns[text] = yes;
    notifyListeners();
  }

  int get checkInsAnswered => _checkIns.length;
}

// =============================================================================
//  "Ways to help it along" — actionable pointers
// -----------------------------------------------------------------------------
//  A one-line "notice it and follow his lead" is true but useless at 9pm when a
//  parent wants to know what to actually DO. These are the concrete moves, per
//  developmental area, written so each one is a thing you could do in the next
//  ten minutes without buying anything.
//
//  Kept per-AREA rather than per-stage on purpose: the honest advice for
//  encouraging any gross-motor skill is broadly the same, and inventing a
//  different list for ninety-odd stages would produce filler, not guidance.
// =============================================================================
List<String> helpBulletsFor(DevArea area, DevStage stage) {
  switch (area.id) {
    case 'gross_motor':
      return const [
        'Floor time beats any equipment. A firm blanket and space to push against does more than a seat or a bouncer.',
        'Put one favourite toy just past his reach — close enough to be worth it, far enough to need the stretch.',
        'Let him work at it before you rescue him. The wobble IS the exercise; steadying him too soon removes the very thing building the strength.',
        'Short and often beats long and once. A few minutes several times a day, always stopping while he is still happy.',
      ];
    case 'cognitive':
      return const [
        'Pause after you respond. He needs a beat of quiet to notice that HIS action caused YOUR reaction — that gap is where the learning happens.',
        'Repeat the same game far past your own boredom. Repetition is how a hunch becomes a rule for him.',
        'Narrate the cause out loud: "you shook it, and it rattled". Words attach to the pattern he is already sensing.',
        'Give him things that respond honestly — a rattle, a crinkly page, a lid. Toys that do everything by themselves teach him nothing about his own effect.',
      ];
    case 'language':
      return const [
        'Leave a gap after you speak, as though waiting for an answer. Turn-taking is learned long before words arrive.',
        'Answer his sounds as if they were sentences. Copying his coo back is a conversation to him.',
        'Narrate what you are doing while you do it — changing, cooking, walking. Ordinary commentary is the richest input there is.',
        'Face him when you talk. He is reading your mouth as much as hearing you.',
      ];
    case 'emotional':
      return const [
        'Respond to the small bids, not only the crying. A look held and returned is the whole skill in miniature.',
        'Let him set the pace with new people. Being passed around teaches him his signals do not count.',
        'Name what he seems to feel — "that was a surprise, wasn\'t it". Long before he understands the words he learns the feeling has a shape.',
        'Repair after the hard moments. Babies do not need parents who never get it wrong, only ones who come back.',
      ];
    default:
      return [
        'Follow his lead — interest is the engine, and ${stage.name.toLowerCase()} arrives faster when he is enjoying it.',
        'Keep it short and stop while he is still content. Ending on a good moment makes the next one easier.',
        'Repeat it often. What looks like the same game to you is a fresh rehearsal to him.',
      ];
  }
}
