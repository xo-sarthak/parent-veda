// =============================================================================
//  ParentVeda Watch - content model, seed catalog + viewing store
// -----------------------------------------------------------------------------
//  Watch is a personalised video LEARNING experience (not YouTube, not Reels).
//  Every video is expert-led and carries learning metadata only - topic, child
//  age, expert, duration, category - never likes/views/followers/trending. The
//  same catalog + store powers both viewing modes:
//    • Quick Learn - 30–90s vertical expert clips for a fast daily lesson.
//    • Deep Learn  - 5–30 min sessions/workshops.
//  They share recommendations, continue-watching, collections and progress.
//  Static seed data for now (a CMS/recommendation engine slots in later). Kept in
//  the post_pregnancy module - nothing here depends on the pregnancy app.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_experts_data.dart';

/// One learning item. `quick` splits Deep vs Quick (Shorts) modes; `isPodcast`
/// marks a listen-first episode (longer, audio-led). Everything else is shared.
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
    this.isPodcast = false,
    this.videoUrl,
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
  final bool isPodcast; // a listen-first episode (channel Podcasts bucket)
  final String why; // "why this matters today" / the lesson in one line
  final int seed; // varies the placeholder thumbnail

  // The URL that actually plays (an MP4/HLS on our own backend). Null on the
  // seed catalog: in production it's filled from the authenticated backend
  // (a signed URL), never hardcoded here. See video/pv_video_config.dart for
  // how dev placeholders are resolved.
  final String? videoUrl;

  // Ecosystem links (shown as "Learn next" + "related", never comments).
  final String? relatedArticle;
  final String? relatedActivity;
  final String? relatedRecipe;
  final String? relatedProductId;
  final String? relatedCommunity;

  Expert get expert => expertById(expertId);
  String get durationLabel => quick ? '${seconds}s' : '${(seconds / 60).round()} min';

  /// Short human label for the kind of item ("Short" / "Podcast" / "Video").
  String get kindLabel => isPodcast ? 'Podcast' : (quick ? 'Short' : 'Video');
}

/// A curated learning collection (not a playlist - a path with a finish line).
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

/// A collection the parent builds themselves - a plain named bucket of videos.
/// In-memory only for now (no persistence); ids are minted from a counter in the
/// store, so they're stable within a session without leaning on time/random.
class UserWatchCollection {
  UserWatchCollection({required this.id, required this.name, List<String>? videoIds})
      : videoIds = videoIds ?? <String>[];
  final String id;
  String name;
  final List<String> videoIds;
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
        'The clinginess and broken naps aren’t a step back, they’re a leap forward. See what your baby is working out about cause and effect right now.',
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
        'Exactly what’s due at this visit, what’s normal afterwards, and how to keep Aarav comfortable, so vaccine day feels calm, not scary.',
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
        'A clear, calm guide to baby fever, what’s normal, what helps, and the red flags that mean call the doctor now.',
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
        'One mother’s honest account of the fourth month, the hard nights, the first belly laugh, and what she’d tell herself again.',
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
    why: 'A rolled towel under the chest makes tummy time comfier, and buys you a few more happy minutes.',
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
    why: 'Steady white noise recreates the constant whoosh of the womb, familiar, and genuinely soothing for sleep.',
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
    why: 'Ragi, well-cooked dal and soft greens, three easy, iron-rich firsts for when your baby is ready to eat.',
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
    why: '“Now we’re pouring the water…”, talking through the ordinary is how your baby learns the music of speech.',
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
    why: 'Young eyes see bold contrast best, a simple black-and-white card can hold real fascination.',
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
  WatchVideo(
    id: 'q_burp',
    title: 'The upright burping hold',
    topic: 'Fewer post-feed tears',
    category: 'Health',
    expertId: 'neha',
    ageTag: '0–6 mo',
    seconds: 40,
    quick: true,
    why: 'Hold your baby upright against your chest and pat low on the back, trapped wind comes up faster.',
    seed: 17,
  ),
  WatchVideo(
    id: 'q_massage',
    title: 'A 60-second leg massage',
    topic: 'Wind-down touch',
    category: 'Activities',
    expertId: 'meher',
    ageTag: '0–12 mo',
    seconds: 60,
    quick: true,
    why: 'Slow strokes down the legs before a nap signal "we are winding down", and it is lovely bonding.',
    seed: 18,
  ),
  WatchVideo(
    id: 'q_sing',
    title: 'Why singing beats talking',
    topic: 'Melody holds attention',
    category: 'Language',
    expertId: 'kabir',
    ageTag: '3–6 mo',
    seconds: 45,
    quick: true,
    why: 'The sing-song rise and fall of a nursery rhyme holds a baby\'s attention far longer than flat speech.',
    seed: 19,
  ),
  WatchVideo(
    id: 'q_sleepcue',
    title: 'Spotting the first tired cue',
    topic: 'Catch the window',
    category: 'Sleep',
    expertId: 'ananya',
    ageTag: '0–6 mo',
    seconds: 50,
    quick: true,
    why: 'A quick stare into the distance is the first tired cue, start the wind-down then, before the overtired cry.',
    seed: 20,
  ),
  WatchVideo(
    id: 'q_safe',
    title: 'One drawer, one weekend',
    topic: 'Start baby-proofing small',
    category: 'Health',
    expertId: 'meera',
    ageTag: '6–12 mo',
    seconds: 55,
    quick: true,
    why: 'Do not baby-proof the whole house at once. Secure one low drawer this weekend, then the next.',
    seed: 15,
  ),
];

// ---- podcasts (channel "Podcasts" bucket) -----------------------------------
//  Longer, listen-first episodes led by the same experts. Reuses WatchVideo
//  (isPodcast:true) so cards, saving, progress and the mock player all just work.
const List<WatchVideo> kWatchPodcasts = [
  WatchVideo(
    id: 'pod_sleep',
    title: 'The truth about baby sleep',
    topic: 'A calm hour on the 4-month shift',
    category: 'Sleep',
    expertId: 'ananya',
    ageTag: '0–12 mo',
    seconds: 1560,
    quick: false,
    isPodcast: true,
    why: 'Dr Ananya sits down for a longer, honest conversation about why sleep breaks at four months, and what genuinely helps.',
    seed: 31,
  ),
  WatchVideo(
    id: 'pod_leaps',
    title: 'Inside the fussy leaps',
    topic: 'The science of Wonder Weeks',
    category: 'Brain Development',
    expertId: 'kabir',
    ageTag: '3–12 mo',
    seconds: 1980,
    quick: false,
    isPodcast: true,
    why: 'A relaxed deep-dive into what is happening in your baby\'s brain during each leap, and why the clinginess is progress.',
    seed: 32,
  ),
  WatchVideo(
    id: 'pod_solids',
    title: 'Feeding without the fear',
    topic: 'Solids, allergies and appetite',
    category: 'Nutrition',
    expertId: 'neha',
    ageTag: '6–12 mo',
    seconds: 1680,
    quick: false,
    isPodcast: true,
    why: 'Dr Neha answers the questions parents actually ask about starting solids, gagging, allergies, and "is he eating enough?".',
    seed: 33,
  ),
  WatchVideo(
    id: 'pod_calm',
    title: 'The crying conversation',
    topic: 'Soothing without losing yourself',
    category: 'Behaviour',
    expertId: 'meher',
    ageTag: '0–12 mo',
    seconds: 1440,
    quick: false,
    isPodcast: true,
    why: 'A warm, practical episode on reading a baby\'s cries and staying regulated yourself when it is 3am and nothing works.',
    seed: 34,
  ),
  WatchVideo(
    id: 'pod_mind',
    title: 'The fourth trimester, for you',
    topic: 'A parent\'s mental health',
    category: 'Mental Wellness',
    expertId: 'meera',
    ageTag: 'All stages',
    seconds: 1320,
    quick: false,
    isPodcast: true,
    why: 'An unhurried, honest talk about the parent behind the baby, the identity shift, the guilt, and small ways back to yourself.',
    seed: 35,
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
    subtitle: 'Why it changes, and how to work with it, gently.',
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
/// Every playable item across the catalog (videos, shorts and podcasts). Handy
/// for id lookups so saving/progress works for podcasts too.
List<WatchVideo> get kWatchAll => [...kWatchVideos, ...kWatchPodcasts];

WatchVideo watchVideoById(String id) =>
    kWatchAll.firstWhere((v) => v.id == id, orElse: () => kWatchVideos.first);
WatchCollection watchCollectionById(String id) =>
    kWatchCollections.firstWhere((c) => c.id == id, orElse: () => kWatchCollections.first);
List<WatchVideo> watchByCategory(String category) =>
    kWatchVideos.where((v) => v.category == category).toList();
List<WatchVideo> get quickVideos => kWatchVideos.where((v) => v.quick).toList();
List<WatchVideo> get deepVideos => kWatchVideos.where((v) => !v.quick).toList();

/// Today's one carefully-chosen video (the daily habit). For a given mode, pick
/// the stage-relevant hero (real engine would personalise; seeded for Aarav).
WatchVideo todaysVideo({bool quick = false}) => quick ? watchVideoById('q_noise') : watchVideoById('sleep4mo');

/// "Learn next" - the next VIDEOS to keep the learning thread going (videos only,
/// never mixed content). Prefers the same category (and mode), then the same
/// expert, then collection siblings, padding with the wider catalog if needed.
List<WatchVideo> learnNextVideos(WatchVideo video, {int limit = 4}) {
  final seen = <String>{video.id};
  final out = <WatchVideo>[];
  void add(Iterable<WatchVideo> vids) {
    for (final v in vids) {
      if (out.length >= limit) return;
      if (seen.add(v.id)) out.add(v);
    }
  }

  add(kWatchVideos.where((v) => v.category == video.category && v.quick == video.quick));
  add(kWatchVideos.where((v) => v.category == video.category));
  add(kWatchVideos.where((v) => v.expertId == video.expertId));
  for (final c in kWatchCollections) {
    if (c.videoIds.contains(video.id)) add(c.videoIds.map(watchVideoById));
  }
  add(kWatchVideos);
  return out.take(limit).toList();
}

/// Expert collections, generated automatically from the catalog: every expert
/// with 2+ videos becomes a finishable learning path - no per-collection authoring.
List<WatchCollection> expertCollections() {
  final byExpert = <String, List<WatchVideo>>{};
  for (final v in kWatchVideos) {
    (byExpert[v.expertId] ??= <WatchVideo>[]).add(v);
  }
  final out = <WatchCollection>[];
  byExpert.forEach((expertId, vids) {
    if (vids.length < 2) return;
    final e = expertById(expertId);
    out.add(WatchCollection(
      id: 'expert_$expertId',
      title: e.name,
      subtitle: '${e.credential} · ${vids.length} lessons',
      videoIds: vids.map((v) => v.id).toList(),
      seed: vids.first.seed,
    ));
  });
  out.sort((a, b) => b.videoIds.length.compareTo(a.videoIds.length));
  return out;
}

// =============================================================================
//  WatchStore - saved, following + continue-watching progress (in-memory seed).
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

  // ---- channel subscriptions ----------------------------------------------
  // Subscribe (channels, YouTube-style) is the same relationship as Follow (the
  // player) - one source of truth - so subscribing on a channel and following an
  // expert stay in sync, and the existing Follow button keeps working unchanged.
  bool isSubscribed(String expertId) => isFollowing(expertId);
  void toggleSubscribe(String expertId) => toggleFollow(expertId);
  int get subscribedCount => _following.length;
  List<String> get subscribedExpertIds => _following.toList();

  double progressOf(String id) => _progress[id] ?? 0;
  void setProgress(String id, double p) {
    _progress[id] = p.clamp(0, 1);
    if (!_recent.contains(id)) _recent.insert(0, id);
    notifyListeners();
  }

  // ---- resume position + completion (real player) -------------------------
  // The player reports exact seconds so playback resumes where the parent left
  // off (the fraction above still powers continue-watching + progress bars).
  // In-memory for now; the repository layer (video/pv_video_repository.dart)
  // is where this syncs to the backend / Supabase later.
  final Map<String, int> _lastSeconds = {};
  final Set<String> _completed = {};

  /// The second to resume from (0 if unseen or already finished).
  int lastPositionOf(String id) => _lastSeconds[id] ?? 0;

  /// Record the exact playback position. [total] keeps the 0..1 fraction (and
  /// therefore continue-watching) in step without a second source of truth.
  void setLastPosition(String id, int seconds, int total) {
    _lastSeconds[id] = seconds < 0 ? 0 : seconds;
    if (total > 0) setProgress(id, seconds / total); // notifies
  }

  bool isCompleted(String id) => _completed.contains(id) || progressOf(id) >= 0.98;

  /// Mark a lesson finished: full progress, clear the resume point, remember it.
  void markCompleted(String id) {
    _completed.add(id);
    _lastSeconds[id] = 0; // next open starts fresh, not at the very end
    setProgress(id, 1); // notifies
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

  // ---- user-built collections (in-memory) ---------------------------------
  // Named buckets the parent creates and drops videos into. Ids are minted from
  // a simple incrementing counter - no DateTime.now()/random, so they stay
  // predictable within a session. One example is seeded so the library isn't bare.
  int _seq = 2; // next id to mint; 'uc_1' is the seeded example below.
  final List<UserWatchCollection> _userCollections = [
    UserWatchCollection(id: 'uc_1', name: 'My favourites', videoIds: ['tummytime', 'q_play']),
  ];

  List<UserWatchCollection> get userCollections => List.unmodifiable(_userCollections);

  UserWatchCollection? _userCollectionById(String id) {
    for (final c in _userCollections) {
      if (c.id == id) return c;
    }
    return null;
  }

  UserWatchCollection createCollection(String name) {
    final c = UserWatchCollection(id: 'uc_${_seq++}', name: name.trim());
    _userCollections.add(c);
    notifyListeners();
    return c;
  }

  void addToCollection(String collectionId, String videoId) {
    final c = _userCollectionById(collectionId);
    if (c == null || c.videoIds.contains(videoId)) return;
    c.videoIds.add(videoId);
    notifyListeners();
  }

  void removeFromCollection(String collectionId, String videoId) {
    final c = _userCollectionById(collectionId);
    if (c == null) return;
    if (c.videoIds.remove(videoId)) notifyListeners();
  }

  void deleteCollection(String collectionId) {
    final before = _userCollections.length;
    _userCollections.removeWhere((c) => c.id == collectionId);
    if (_userCollections.length != before) notifyListeners();
  }

  bool collectionContains(String collectionId, String videoId) {
    final c = _userCollectionById(collectionId);
    return c != null && c.videoIds.contains(videoId);
  }
}
