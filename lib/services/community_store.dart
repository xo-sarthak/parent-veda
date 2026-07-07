// =============================================================================
//  CommunityStore - local state for the Community prototype
// -----------------------------------------------------------------------------
//  Holds joins, mutes, likes, saves, poll votes, user-created posts and user
//  comments, persisted via shared_preferences. Also provides a lightweight feed
//  "ranking" (algorithmic, not chronological): user posts pinned, then joined
//  communities, then recommended - ordered by engagement.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/community_data.dart';
import '../models/community_models.dart';
import 'remote/cloud_synced_store.dart';

/// The identity used while testing "Doctor mode" (until real doctor logins
/// exist). When the test doctor verifies a post, it counts as one expert.
const String kTestDoctorName = 'Dr. (You)';
const String kTestDoctorCred = 'OB-GYN';

class CommunityStore extends ChangeNotifier with CloudSyncedStore {
  CommunityStore._();
  static final CommunityStore instance = CommunityStore._();

  static const _joinedKey = 'comm_joined';
  static const _mutedKey = 'comm_muted';
  static const _likedKey = 'comm_liked';
  static const _savedKey = 'comm_saved';
  static const _upvotedKey = 'comm_upvoted';
  static const _votesKey = 'comm_votes';
  static const _postsKey = 'comm_posts';
  static const _commentsKey = 'comm_comments';
  static const _seededKey = 'comm_seeded';
  static const _doctorModeKey = 'comm_doctor_mode';
  static const _docEndorsedKey = 'comm_doc_endorsed';
  static const _repostedKey = 'comm_reposted';

  SharedPreferences? _prefs;
  final Set<String> _joined = {};
  final Set<String> _muted = {};
  final Set<String> _liked = {};
  final Set<String> _saved = {};
  final Set<String> _upvoted = {};
  final Map<String, String> _votes = {};
  final List<CommunityPost> _created = [];
  final Map<String, List<String>> _userComments = {};
  bool _doctorMode = false;
  final Set<String> _doctorEndorsed = {};
  final Set<String> _reposted = {};
  final Set<String> _hidden = {}; // "Not interested" - session only, not saved

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    _joined
      ..clear()
      ..addAll(p.getStringList(_joinedKey) ?? const []);
    _muted
      ..clear()
      ..addAll(p.getStringList(_mutedKey) ?? const []);
    _liked
      ..clear()
      ..addAll(p.getStringList(_likedKey) ?? const []);
    _saved
      ..clear()
      ..addAll(p.getStringList(_savedKey) ?? const []);
    _upvoted
      ..clear()
      ..addAll(p.getStringList(_upvotedKey) ?? const []);

    // First run: auto-join the pregnancy-stage communities.
    if (!(p.getBool(_seededKey) ?? false)) {
      for (final c in kCommunities) {
        if (c.auto) _joined.add(c.id);
      }
      await p.setBool(_seededKey, true);
      await p.setStringList(_joinedKey, _joined.toList());
    }

    _votes
      ..clear()
      ..addAll(_decodeMap(p.getString(_votesKey)));
    _userComments
      ..clear()
      ..addAll(_decodeComments(p.getString(_commentsKey)));
    _created
      ..clear()
      ..addAll(_decodePosts(p.getString(_postsKey)));
    _doctorMode = p.getBool(_doctorModeKey) ?? false;
    _doctorEndorsed
      ..clear()
      ..addAll(p.getStringList(_docEndorsedKey) ?? const []);
    _reposted
      ..clear()
      ..addAll(p.getStringList(_repostedKey) ?? const []);
    notifyListeners();
    await syncStateFromCloud();
  }

  // --- cloud sync (all persistent state; "not interested" stays session-only) -
  @override
  String get cloudKey => 'community';
  @override
  Object cloudData() => {
        'joined': _joined.toList(),
        'muted': _muted.toList(),
        'liked': _liked.toList(),
        'saved': _saved.toList(),
        'upvoted': _upvoted.toList(),
        'votes': _votes,
        'posts': _created.map((p) => p.toJson()).toList(),
        'comments': _userComments,
        'doctorMode': _doctorMode,
        'docEndorsed': _doctorEndorsed.toList(),
        'reposted': _reposted.toList(),
      };
  @override
  void applyCloudData(Object data) {
    final m = data as Map;
    void fillSet(Set<String> s, Object? v) => s
      ..clear()
      ..addAll(((v as List?) ?? const []).map((e) => e.toString()));
    fillSet(_joined, m['joined']);
    fillSet(_muted, m['muted']);
    fillSet(_liked, m['liked']);
    fillSet(_saved, m['saved']);
    fillSet(_upvoted, m['upvoted']);
    _votes
      ..clear()
      ..addAll(((m['votes'] as Map?) ?? const {})
          .map((k, v) => MapEntry(k.toString(), v.toString())));
    _created
      ..clear()
      ..addAll(((m['posts'] as List?) ?? const [])
          .map((e) => CommunityPost.fromJson(Map<String, dynamic>.from(e))));
    _userComments
      ..clear()
      ..addAll(((m['comments'] as Map?) ?? const {}).map((k, v) => MapEntry(
          k.toString(),
          ((v as List?) ?? const []).map((e) => e.toString()).toList())));
    _doctorMode = m['doctorMode'] == true;
    fillSet(_doctorEndorsed, m['docEndorsed']);
    fillSet(_reposted, m['reposted']);
  }

  @override
  Future<void> persistLocalCache() async {
    final p = _prefs;
    if (p == null) return;
    await p.setStringList(_joinedKey, _joined.toList());
    await p.setStringList(_mutedKey, _muted.toList());
    await p.setStringList(_likedKey, _liked.toList());
    await p.setStringList(_savedKey, _saved.toList());
    await p.setStringList(_upvotedKey, _upvoted.toList());
    await p.setString(_votesKey, jsonEncode(_votes));
    await p.setString(
        _postsKey, jsonEncode(_created.map((e) => e.toJson()).toList()));
    await p.setString(_commentsKey, jsonEncode(_userComments));
    await p.setBool(_doctorModeKey, _doctorMode);
    await p.setStringList(_docEndorsedKey, _doctorEndorsed.toList());
    await p.setStringList(_repostedKey, _reposted.toList());
  }

  // --- queries ---
  List<String> get joinedIds => _joined.toList();
  bool isJoined(String id) => _joined.contains(id);
  bool isMuted(String id) => _muted.contains(id);
  bool isLiked(String id) => _liked.contains(id);
  bool isSaved(String id) => _saved.contains(id);
  bool isUpvoted(String id) => _upvoted.contains(id);
  String? votedOption(String id) => _votes[id];
  List<CommunityPost> get createdPosts => List.unmodifiable(_created);

  // --- "My Activity" / "My Bookmarks" views ---
  List<CommunityPost> get savedPosts =>
      _allPosts.where((p) => _saved.contains(p.id)).toList();
  List<CommunityPost> get likedPosts =>
      _allPosts.where((p) => _liked.contains(p.id)).toList();
  List<CommunityPost> get upvotedPosts =>
      _allPosts.where((p) => _upvoted.contains(p.id)).toList();
  List<CommunityPost> get commentedPosts =>
      _allPosts.where((p) => _userComments[p.id]?.isNotEmpty ?? false).toList();

  List<Community> get joinedCommunities =>
      kCommunities.where((c) => _joined.contains(c.id) && !_muted.contains(c.id)).toList();
  List<Community> get recommendedCommunities =>
      kCommunities.where((c) => !_joined.contains(c.id)).toList();

  int likeCount(CommunityPost p) => p.likes + (_liked.contains(p.id) ? 1 : 0);
  int saveCount(CommunityPost p) => p.saves + (_saved.contains(p.id) ? 1 : 0);
  int upvoteCount(CommunityPost p) => p.upvotes + (_upvoted.contains(p.id) ? 1 : 0);
  int commentCount(CommunityPost p) =>
      p.comments + (_userComments[p.id]?.length ?? 0);
  List<String> userComments(String postId) =>
      _userComments[postId] ?? const [];

  CommunityPost? postById(String id) {
    for (final p in _created) {
      if (p.id == id) return p;
    }
    for (final p in kSeedPosts) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// All posts (user-created first, then seed).
  List<CommunityPost> get _allPosts => [..._created, ...kSeedPosts];

  /// The personalized feed - algorithmic, not chronological.
  List<CommunityPost> feed() {
    final posts = _allPosts.where((p) => !_muted.contains(p.communityId)).toList();
    int score(CommunityPost p) {
      // Rank on the post's BASE engagement only - NOT the viewer's own live
      // like/save/repost toggles. Otherwise bookmarking or liking a post bumps
      // its score and re-ranks the feed, making rows jump up and down under your
      // finger. Stable score = the row stays put when you tap save.
      var s = p.likes + p.comments * 2 + p.saves * 3;
      if (p.isUser) s += 1000000; // pin the user's own posts to the top
      if (_joined.contains(p.communityId)) s += 5000; // ~80% joined-first
      return s;
    }

    posts.sort((a, b) {
      final byScore = score(b).compareTo(score(a));
      if (byScore != 0) return byScore;
      // Tie-break newest-first so a freshly created post sits on top (Dart's
      // sort isn't stable, so we order ties explicitly by creation time).
      return b.createdAt.compareTo(a.createdAt);
    });
    return posts;
  }

  List<CommunityPost> postsForCommunity(String communityId) =>
      _allPosts.where((p) => p.communityId == communityId).toList();

  // --- mutations ---
  void toggleJoin(String id) {
    if (!_joined.remove(id)) _joined.add(id);
    _prefs?.setStringList(_joinedKey, _joined.toList());
    notifyListeners();
  }

  void toggleMute(String id) {
    if (!_muted.remove(id)) _muted.add(id);
    _prefs?.setStringList(_mutedKey, _muted.toList());
    notifyListeners();
  }

  void toggleLike(String id) {
    if (!_liked.remove(id)) _liked.add(id);
    _prefs?.setStringList(_likedKey, _liked.toList());
    notifyListeners();
  }

  void toggleSave(String id) {
    if (!_saved.remove(id)) _saved.add(id);
    _prefs?.setStringList(_savedKey, _saved.toList());
    notifyListeners();
  }

  void toggleUpvote(String id) {
    if (!_upvoted.remove(id)) _upvoted.add(id);
    _prefs?.setStringList(_upvotedKey, _upvoted.toList());
    notifyListeners();
  }

  // --- Twitter-style: reposts + "not interested" --------------------------
  bool isReposted(String id) => _reposted.contains(id);

  /// A base repost count derived from likes so the number reads realistically,
  /// plus the user's own repost.
  int repostCount(CommunityPost p) =>
      (p.likes / 6).round() + (_reposted.contains(p.id) ? 1 : 0);

  void toggleRepost(String id) {
    if (!_reposted.remove(id)) _reposted.add(id);
    _prefs?.setStringList(_repostedKey, _reposted.toList());
    notifyListeners();
  }

  /// "Not interested" hides a post for the rest of the session (not persisted).
  bool isHidden(String id) => _hidden.contains(id);
  void hidePost(String id) {
    _hidden.add(id);
    notifyListeners();
  }

  void vote(String pollId, String option) {
    _votes[pollId] = option;
    _prefs?.setString(_votesKey, jsonEncode(_votes));
    notifyListeners();
  }

  // --- doctor (test) mode + expert endorsements ----------------------------
  bool get doctorMode => _doctorMode;
  bool isDoctorEndorsed(String id) => _doctorEndorsed.contains(id);

  /// A post shows the verified-expert banner if a seed expert OR the (test)
  /// doctor has backed it.
  bool isEndorsed(CommunityPost p) =>
      p.endorsedBy.isNotEmpty || _doctorEndorsed.contains(p.id);

  /// Total verified experts behind a post (seed count + the test doctor).
  int endorseCount(CommunityPost p) =>
      p.expertEndorseCount + (_doctorEndorsed.contains(p.id) ? 1 : 0);

  void setDoctorMode(bool v) {
    if (_doctorMode == v) return;
    _doctorMode = v;
    _prefs?.setBool(_doctorModeKey, v);
    notifyListeners();
  }

  void toggleDoctorEndorse(String id) {
    if (!_doctorEndorsed.remove(id)) _doctorEndorsed.add(id);
    _prefs?.setStringList(_docEndorsedKey, _doctorEndorsed.toList());
    notifyListeners();
  }

  void addPost(CommunityPost post) {
    _created.insert(0, post);
    _prefs?.setString(_postsKey, jsonEncode(_created.map((p) => p.toJson()).toList()));
    notifyListeners();
  }

  void addComment(String postId, String text) {
    (_userComments[postId] ??= []).add(text);
    // A doctor commenting on a post that ASKED for verification verifies it -
    // this replaces the old explicit "Verify this" button.
    if (_doctorMode) {
      final p = postById(postId);
      if (p != null && p.wantsVerification && !isEndorsed(p)) {
        _doctorEndorsed.add(postId);
        _prefs?.setStringList(_docEndorsedKey, _doctorEndorsed.toList());
      }
    }
    _prefs?.setString(_commentsKey, jsonEncode(_userComments));
    notifyListeners();
  }

  // --- decode helpers ---
  Map<String, String> _decodeMap(String? raw) {
    if (raw == null) return {};
    try {
      final m = jsonDecode(raw) as Map;
      return m.map((k, v) => MapEntry(k.toString(), v.toString()));
    } catch (_) {
      return {};
    }
  }

  Map<String, List<String>> _decodeComments(String? raw) {
    if (raw == null) return {};
    try {
      final m = jsonDecode(raw) as Map;
      return m.map((k, v) =>
          MapEntry(k.toString(), (v as List).map((e) => e.toString()).toList()));
    } catch (_) {
      return {};
    }
  }

  List<CommunityPost> _decodePosts(String? raw) {
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => CommunityPost.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
