// =============================================================================
//  CommunityStore — local state for the Community prototype
// -----------------------------------------------------------------------------
//  Holds joins, mutes, likes, saves, poll votes, user-created posts and user
//  comments, persisted via shared_preferences. Also provides a lightweight feed
//  "ranking" (algorithmic, not chronological): user posts pinned, then joined
//  communities, then recommended — ordered by engagement.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/community_data.dart';
import '../models/community_models.dart';

class CommunityStore extends ChangeNotifier {
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

  SharedPreferences? _prefs;
  final Set<String> _joined = {};
  final Set<String> _muted = {};
  final Set<String> _liked = {};
  final Set<String> _saved = {};
  final Set<String> _upvoted = {};
  final Map<String, String> _votes = {};
  final List<CommunityPost> _created = [];
  final Map<String, List<String>> _userComments = {};

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
    notifyListeners();
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

  /// The personalized feed — algorithmic, not chronological.
  List<CommunityPost> feed() {
    final posts = _allPosts.where((p) => !_muted.contains(p.communityId)).toList();
    int score(CommunityPost p) {
      var s = likeCount(p) + commentCount(p) * 2 + saveCount(p) * 3;
      if (p.isUser) s += 1000000; // pin the user's own posts to the top
      if (_joined.contains(p.communityId)) s += 5000; // ~80% joined-first
      return s;
    }

    posts.sort((a, b) => score(b).compareTo(score(a)));
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

  void vote(String pollId, String option) {
    _votes[pollId] = option;
    _prefs?.setString(_votesKey, jsonEncode(_votes));
    notifyListeners();
  }

  void addPost(CommunityPost post) {
    _created.insert(0, post);
    _prefs?.setString(_postsKey, jsonEncode(_created.map((p) => p.toJson()).toList()));
    notifyListeners();
  }

  void addComment(String postId, String text) {
    (_userComments[postId] ??= []).add(text);
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
