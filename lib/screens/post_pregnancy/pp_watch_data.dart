// =============================================================================
//  ParentVeda Watch — content model, seed catalog + viewing store
// -----------------------------------------------------------------------------
//  Watch is a personalised video LEARNING experience (not YouTube, not Reels).
//  Every video is expert-led and carries learning metadata only — topic, child
//  age, expert, duration, category — never likes/views/followers/trending. The
//  same catalog + store powers both viewing modes:
//    • Quick Learn — 30–90s vertical expert clips for a fast daily lesson.
//    • Deep Learn  — 5–30 min sessions/workshops.
//  They share recommendations, continue-watching, collections and progress.
//  Static seed data for now (a CMS/recommendation engine slots in later). Kept in
//  the post_pregnancy module — nothing here depends on the pregnancy app.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_experts_data.dart';

/// One learning video. `quick` splits the two modes; everything else is shared.
class WatchVideo {
  const WatchVideo({
    required this.id,
    required this.title,
    required this.topic,
    required this.category,
    required this.expertId,
    required this.ageTag,
    required this.seconds,
    required this.quick,
    required this.why,
    required this.seed,
    this.relatedArticle,
    this.relatedActivity,
    this.relatedRecipe,
    this.relatedProductId,
    this.relatedCommunity,
  });

  final String id;
  final String title;
  final String topic;
  final String category;
  final String expertId;
  final String ageTag; // "3–6 mo"
  final int seconds;
  final bool quick;
  final String why; // "why this matters today" / the lesson in one line
  final int seed; // varies the placeholder thumbnail

  // Ecosystem links (shown as "Learn next" + "related", never comments).
  final String? relatedArticle;
  final String? relatedActivity;
  final String? relatedRecipe;
  final String? relatedProductId;
  final String? relatedCommunity;

  Expert get expert => expertById(expertId);
  String get durationLabel => quick ? '${seconds}s' : '${(seconds / 60).round()} min';
}

/// A curated learning collection (not a playlist — a path with a finish line).
class WatchCollection {
  const WatchCollection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.videoIds,
    required this.seed,
  });
  final String id;
  final String title;
  final String subtitle;
  final List<String> videoIds;
  final int seed;
}

// ---- categories (each opens its own feed) -----------------------------------
const List<(String, IconData)> kWatchCategories = [
  ('Brain Development', Icons.psychology_outlined),
  ('Nutrition', Icons.restaurant_outlined),
  ('Sleep', Icons.bedtime_outlined),
  ('Activities', Icons.extension_outlined),
  ('Health', Icons.monitor_heart_outlined),
  ('Behaviour', Icons.child_care_outlined),
  ('Language', Icons.chat_bubble_outline_rounded),
  ('Play', Icons.toys_outlined),
  ('Recipes', Icons.restaurant_menu_outlined),
  ('Doctor Talks', Icons.medical_services_outlined),
  ('Exercises', Icons.fitness_center_outlined),
  ('Mental Wellness', Icons.spa_outlined),
  ('Parent Stories', Icons.favorite_border),
];

// ---- catalog ----------------------------------------------------------------
const List<WatchVideo> kWatchVideos = [
  // ---- Deep Learn (5–30 min) -------------------------------------------------
  WatchVideo(
    id: 'sleep4mo',
    title: 'Why your baby’s sleep changes at 4 months',
    topic: 'The 4-month sleep shift',
    category: 'Sleep',
    expertId: 'ananya',
    ageTag: '3–6 mo',
    seconds: 720,
    quick: false,
    why:
        'Aarav is right in the middle of the 4-month sleep shift. Dr Ananya explains what’s happening in his brain and the calm, no-cry changes that actually help.',
    seed: 1,
    relatedArticle: 'The 4-month regression, night by night',
    relatedActivity: 'A gentle wind-down routine',
    relatedProductId: 'dozy',
    relatedCommunity: 'Parents on the 4-month regression',
  ),
  WatchVideo(
    id: 'leap4brain',
    title: 'Inside Leap 4: the world of events',
    topic: 'What the fussiness means',
    category: 'Brain Development',
    expertId: 'ananya',
    ageTag: '3–6 mo',
    seconds: 600,
    quick: false,
    why:
        'The clinginess and broken naps aren’t a step back — they’re a leap forward. See what your baby is working out about cause and effect right now.',
    seed: 2,
    relatedArticle: 'Leap 4, decoded',
    relatedActivity: 'Reach-for-the-ring',
    relatedCommunity: 'Leap 4 support',
  ),
  WatchVideo(
    id: 'solids101',
    title: 'Starting solids, calmly',
    topic: 'Readiness, first foods, safety',
    category: 'Nutrition',
    expertId: 'neha',
    ageTag: '6–12 mo',
    seconds: 900,
    quick: false,
    why:
        'A little ahead for Aarav, but worth knowing: how to spot readiness, the safest first foods, and why milk still leads for the first year.',
    seed: 3,
    relatedArticle: 'Distracted feeds: is he getting enough?',
    relatedRecipe: 'Ragi & banana pancakes',
  ),
  WatchVideo(
    id: 'tummytime',
    title: 'Tummy time that doesn’t end in tears',
    topic: 'Building strength for rolling',
    category: 'Activities',
    expertId: 'meher',
    ageTag: '3–6 mo',
    seconds: 480,
    quick: false,
    why:
        'Short, happy sessions build the neck and core strength Aarav needs to roll. Dr Meher shows how to keep it a game, not a battle.',
    seed: 4,
    relatedActivity: 'Chest-to-chest tummy time',
    relatedArticle: 'Drowsy but awake: the hardest skill',
  ),
  WatchVideo(
    id: 'vaccines4mo',
    title: 'The 4-month vaccines, explained',
    topic: 'What’s due and how to soothe',
    category: 'Doctor Talks',
    expertId: 'neha',
    ageTag: '3–6 mo',
    seconds: 540,
    quick: false,
    why:
        'Exactly what’s due at this visit, what’s normal afterwards, and how to keep Aarav comfortable — so vaccine day feels calm, not scary.',
    seed: 5,
    relatedArticle: 'The 4-month vaccines, explained calmly',
    relatedCommunity: 'Vaccine-day tips',
  ),
  WatchVideo(
    id: 'babbling',
    title: 'From coos to first words',
    topic: 'How language begins',
    category: 'Language',
    expertId: 'kabir',
    ageTag: '3–6 mo',
    seconds: 420,
    quick: false,
    why:
        'Your baby is learning language long before he speaks. See how everyday narration and back-and-forth “conversations” build his ear for it.',
    seed: 6,
    relatedActivity: 'Narrate your day',
    relatedArticle: 'Leap 4, decoded',
  ),
  WatchVideo(
    id: 'fevercalm',
    title: 'Fever, without the panic',
    topic: 'What to watch, when to call',
    category: 'Health',
    expertId: 'neha',
    ageTag: '0–12 mo',
    seconds: 660,
    quick: false,
    why:
        'A clear, calm guide to baby fever — what’s normal, what helps, and the red flags that mean call the doctor now.',
    seed: 7,
    relatedRecipe: 'Moong dal water',
    relatedCommunity: 'When did you call the doctor?',
  ),
  WatchVideo(
    id: 'mumwellness',
    title: 'Five minutes for you, too',
    topic: 'Looking after the parent',
    category: 'Mental Wellness',
    expertId: 'meera',
    ageTag: 'All stages',
    seconds: 480,
    quick: false,
    why:
        'You can’t pour from an empty cup. A short, honest session on protecting your own calm in the fourth-month fog.',
    seed: 8,
    relatedActivity: 'A two-minute breathing reset',
    relatedCommunity: 'Fourth-trimester feelings',
  ),
  WatchVideo(
    id: 'parentstory',
    title: 'Priya’s fourth month',
    topic: 'A real parent’s story',
    category: 'Parent Stories',
    expertId: 'ritu',
    ageTag: '3–6 mo',
    seconds: 360,
    quick: false,
    why:
        'One mother’s honest account of the fourth month — the hard nights, the first belly laugh, and what she’d tell herself again.',
    seed: 9,
    relatedCommunity: 'Share your fourth-month story',
  ),

  // ---- Quick Learn (30–90s) --------------------------------------------------
  WatchVideo(
    id: 'q_tummy',
    title: 'A 30-second tummy-time trick',
    topic: 'Roll a towel',
    category: 'Activities',
    expertId: 'meher',
    ageTag: '3–6 mo',
    seconds: 45,
    quick: true,
    why: 'A rolled towel under the chest makes tummy time comfier — and buys you a few more happy minutes.',
    seed: 10,
    relatedActivity: 'Chest-to-chest tummy time',
  ),
  WatchVideo(
    id: 'q_noise',
    title: 'Why white noise works',
    topic: 'The womb was loud',
    category: 'Sleep',
    expertId: 'ananya',
    ageTag: '0–6 mo',
    seconds: 60,
    quick: true,
    why: 'Steady white noise recreates the constant whoosh of the womb — familiar, and genuinely soothing for sleep.',
    seed: 11,
    relatedProductId: 'dozy',
  ),
  WatchVideo(
    id: 'q_iron',
    title: 'Three iron-rich first foods',
    topic: 'When solids begin',
    category: 'Nutrition',
    expertId: 'neha',
    ageTag: '6–12 mo',
    seconds: 50,
    quick: true,
    why: 'Ragi, well-cooked dal and soft greens — three easy, iron-rich firsts for when your baby is ready to eat.',
    seed: 12,
    relatedRecipe: 'Ragi & banana smoothie',
  ),
  WatchVideo(
    id: 'q_soothe',
    title: 'The calm-down hold',
    topic: 'Side-lying soothe',
    category: 'Behaviour',
    expertId: 'meher',
    ageTag: '0–12 mo',
    seconds: 40,
    quick: true,
    why: 'A gentle side or tummy hold, close to you, can settle a crying baby faster than bouncing.',
    seed: 13,
  ),
  WatchVideo(
    id: 'q_talk',
    title: 'Narrate your day',
    topic: '30 seconds of language',
    category: 'Language',
    expertId: 'kabir',
    ageTag: '3–6 mo',
    seconds: 55,
    quick: true,
    why: '“Now we’re pouring the water…” — talking through the ordinary is how your baby learns the music of speech.',
    seed: 14,
    relatedActivity: 'Narrate your day',
  ),
  WatchVideo(
    id: 'q_play',
    title: 'High-contrast play',
    topic: 'Black, white & red',
    category: 'Play',
    expertId: 'kabir',
    ageTag: '0–6 mo',
    seconds: 45,
    quick: true,
    why: 'Young eyes see bold contrast best — a simple black-and-white card can hold real fascination.',
    seed: 15,
  ),
  WatchVideo(
    id: 'q_breathe',
    title: 'A breath for you',
    topic: 'Reset in 40 seconds',
    category: 'Mental Wellness',
    expertId: 'meera',
    ageTag: 'All stages',
    seconds: 50,
    quick: true,
    why: 'One slow breath in, a longer breath out. A tiny reset you can do while rocking the baby.',
    seed: 16,
  ),
];

// ---- collections ------------------------------------------------------------
const List<WatchCollection> kWatchCollections = [
  WatchCollection(
    id: 'firstyear',
    title: 'First Year Essentials',
    subtitle: 'The handful of things every new parent wants to understand.',
    videoIds: ['sleep4mo', 'vaccines4mo', 'tummytime', 'fevercalm', 'babbling'],
    seed: 21,
  ),
  WatchCollection(
    id: 'understandingsleep',
    title: 'Understanding Sleep',
    subtitle: 'Why it changes, and how to work with it — gently.',
    videoIds: ['sleep4mo', 'q_noise', 'tummytime'],
    seed: 22,
  ),
  WatchCollection(
    id: 'startingsolids',
    title: 'Starting Solids',
    subtitle: 'Everything to know before the first spoon.',
    videoIds: ['solids101', 'q_iron'],
    seed: 23,
  ),
  WatchCollection(
    id: 'braindev',
    title: 'Brain Development',
    subtitle: 'What’s growing behind those big new expressions.',
    videoIds: ['leap4brain', 'q_play', 'babbling'],
    seed: 24,
  ),
  WatchCollection(
    id: 'speech',
    title: 'Speech & Language',
    subtitle: 'The long, lovely road to the first word.',
    videoIds: ['babbling', 'q_talk'],
    seed: 25,
  ),
];

// ---- lookups ----------------------------------------------------------------
WatchVideo watchVideoById(String id) =>
    kWatchVideos.firstWhere((v) => v.id == id, orElse: () => kWatchVideos.first);
WatchCollection watchCollectionById(String id) =>
    kWatchCollections.firstWhere((c) => c.id == id, orElse: () => kWatchCollections.first);
List<WatchVideo> watchByCategory(String category) =>
    kWatchVideos.where((v) => v.category == category).toList();
List<WatchVideo> get quickVideos => kWatchVideos.where((v) => v.quick).toList();
List<WatchVideo> get deepVideos => kWatchVideos.where((v) => !v.quick).toList();

/// Today's one carefully-chosen video (the daily habit). For a given mode, pick
/// the stage-relevant hero (real engine would personalise; seeded for Aarav).
WatchVideo todaysVideo({bool quick = false}) => quick ? watchVideoById('q_noise') : watchVideoById('sleep4mo');

// =============================================================================
//  WatchStore — saved, following + continue-watching progress (in-memory seed).
//  A ChangeNotifier singleton, matching the app's other stores.
// =============================================================================
class WatchStore extends ChangeNotifier {
  WatchStore._();
  static final WatchStore instance = WatchStore._();

  final Set<String> _saved = {'tummytime', 'q_iron'};
  final Set<String> _following = {'ananya'};
  // 0..1 progress; a value in (0,1) = "continue watching".
  final Map<String, double> _progress = {
    'sleep4mo': 0.45,
    'leap4brain': 0.7,
    'solids101': 0.2,
  };
  final List<String> _recent = ['leap4brain', 'sleep4mo', 'q_play'];

  bool isSaved(String id) => _saved.contains(id);
  void toggleSave(String id) {
    _saved.contains(id) ? _saved.remove(id) : _saved.add(id);
    notifyListeners();
  }

  List<WatchVideo> get saved => _saved.map(watchVideoById).toList();

  bool isFollowing(String expertId) => _following.contains(expertId);
  void toggleFollow(String expertId) {
    _following.contains(expertId) ? _following.remove(expertId) : _following.add(expertId);
    notifyListeners();
  }

  double progressOf(String id) => _progress[id] ?? 0;
  void setProgress(String id, double p) {
    _progress[id] = p.clamp(0, 1);
    if (!_recent.contains(id)) _recent.insert(0, id);
    notifyListeners();
  }

  /// Unfinished videos (Netflix-style continue watching), most-progressed first.
  List<WatchVideo> get continueWatching {
    final ids = _progress.entries.where((e) => e.value > 0.02 && e.value < 0.98).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ids.map((e) => watchVideoById(e.key)).toList();
  }

  List<WatchVideo> get recentlyWatched => _recent.map(watchVideoById).toList();

  /// Collection progress = share of its videos finished (>90%).
  double collectionProgress(WatchCollection c) {
    if (c.videoIds.isEmpty) return 0;
    final done = c.videoIds.where((id) => progressOf(id) >= 0.9).length;
    return done / c.videoIds.length;
  }
}
