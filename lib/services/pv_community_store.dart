// The community, on the phone. One singleton store over the server's
// functions (0121), in the house shape: local first, then the cloud.
//
// What lives where, and why:
//  · FEEDS are cached per feed key in shared_preferences, so the community
//    opens on the last thing she saw — instantly, offline, logged out — and
//    refreshes behind it. A cloud failure never empties a screen.
//  · WHAT SHE WRITES goes into an OUTBOX first, with an id the phone mints.
//    The server's create functions are idempotent on that id, so a post sent
//    twice (a retry after a dropped connection) is still one post. That is
//    the same trick as `PvReviewStore`: the app owns the identity, so sync is
//    a merge, never a duplicate.
//  · LIKES AND VOTES change on screen at once (optimistic) and roll back if
//    the server says no. A heart that waits for a round-trip feels broken.
//  · Every write returns a `PvCommunityOutcome`, so the screen can tell her
//    exactly what happened ("posted", "waiting for a quick review", "saved on
//    your phone, we will send it") — no save is silent.
//
// There is no realtime subscription in this version: a feed refreshes when it
// opens and on pull. Realtime arrives with push (docs/COMMUNITY.md, phase 3).
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pv_community.dart';
import 'life_stage_store.dart';
import 'remote/supabase_repo.dart';
import 'saved_store.dart';

/// The server call the store makes. A seam, so tests can answer for the
/// server without a mocking framework (`debugBackend`).
typedef CommunityBackend = Future<dynamic> Function(String fn, Map<String, dynamic> params);

const String kCommunityMediaBucket = 'community-media';

class PvCommunityStore extends ChangeNotifier {
  PvCommunityStore._();
  static final PvCommunityStore instance = PvCommunityStore._();

  static const _kMe = 'pv_community_me';
  static const _kRooms = 'pv_community_rooms';
  static const _kFeeds = 'pv_community_feeds';
  static const _kOutbox = 'pv_community_outbox';
  static const _kHidden = 'pv_community_hidden';

  // ---- seams (tests) ---------------------------------------------------------

  @visibleForTesting
  CommunityBackend? debugBackend;
  @visibleForTesting
  bool? debugSignedIn;

  bool get signedIn => debugSignedIn ?? SupabaseRepo.isLoggedIn;

  Future<dynamic> _call(String fn, [Map<String, dynamic> params = const {}]) {
    final b = debugBackend;
    if (b != null) return b(fn, params);
    return SupabaseRepo.rpcJson(fn, params);
  }

  // ---- state -----------------------------------------------------------------

  bool _loaded = false;
  bool get isLoaded => _loaded;

  PvCommunityMe _me = const PvCommunityMe();
  PvCommunityMe get me => _me;

  List<PvCommunityRoom> _rooms = const [];

  /// Rooms, her stage's first, then joined, then the house order.
  List<PvCommunityRoom> get rooms {
    final stage = currentStageTag;
    final list = [..._rooms];
    int score(PvCommunityRoom r) =>
        (r.stage == stage ? 0 : (r.stage == 'all' ? 1 : 2)) * 1000 + r.sort;
    list.sort((a, b) => score(a).compareTo(score(b)));
    return list;
  }

  PvCommunityRoom? room(String id) {
    for (final r in _rooms) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Feed key → posts, as last read (or as written on this phone).
  final Map<String, List<PvCommunityPost>> _feeds = {};
  final Map<String, bool> _feedLoading = {};
  final Map<String, bool> _feedEnded = {};
  final Map<String, PvCommunityPost> _posts = {};
  final Map<String, List<PvCommunityComment>> _comments = {};
  final Set<String> _hidden = {};
  List<PvCommunityActivity> _activity = const [];
  List<PvCommunityActivity> get activity => _activity;

  /// Outbox entries: {kind: 'post'|'comment', id, params, local: {...}}.
  final List<Map<String, dynamic>> _outbox = [];
  bool _flushing = false;

  /// path → (url, expires)
  final Map<String, (String, DateTime)> _signed = {};

  /// 'trying' | 'pregnancy' | 'parenting' — the server's stage words.
  String get currentStageTag => switch (LifeStageStore.instance.stage) {
        LifeStage.tryingToConceive => 'trying',
        LifeStage.parenting => 'parenting',
        _ => 'pregnancy',
      };

  static String feedKey({String scope = 'for_you', String sort = 'top', String? room}) =>
      '$scope|$sort|${room ?? ''}';

  List<PvCommunityPost> feed(String key) => [
        for (final p in _feeds[key] ?? const <PvCommunityPost>[])
          if (!_hidden.contains(p.id)) _posts[p.id] ?? p,
      ];
  bool isLoading(String key) => _feedLoading[key] == true;
  bool hasMore(String key) => _feedEnded[key] != true;

  PvCommunityPost? post(String id) => _posts[id];
  List<PvCommunityComment>? comments(String postId) => _comments[postId];

  /// Things she wrote that the server has not accepted yet.
  int get unsentCount => _outbox.length;

  // ---- load ------------------------------------------------------------------

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final me = prefs.getString(_kMe);
      if (me != null) _me = PvCommunityMe.fromJson(jsonDecode(me));
      final rooms = prefs.getString(_kRooms);
      if (rooms != null) {
        _rooms = [
          for (final r in jsonDecode(rooms) as List)
            ?PvCommunityRoom.fromJson(r),
        ];
      }
      final feeds = prefs.getString(_kFeeds);
      if (feeds != null) {
        (jsonDecode(feeds) as Map).forEach((k, v) {
          final list = [
            for (final p in v as List)
              ?PvCommunityPost.fromJson(p),
          ];
          _feeds[k as String] = list.map((p) => p.id).isEmpty ? [] : list;
          for (final p in list) {
            _posts[p.id] = p;
          }
        });
      }
      final out = prefs.getString(_kOutbox);
      if (out != null) {
        _outbox.addAll([
          for (final e in jsonDecode(out) as List) Map<String, dynamic>.from(e as Map),
        ]);
      }
      _hidden.addAll(prefs.getStringList(_kHidden) ?? const []);
    } catch (_) {
      /* start empty: a bad cache never blocks the community */
    }
    _loaded = true;
    notifyListeners();
    unawaited(refreshMe());
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kMe, jsonEncode(_me.toJson()));
      await prefs.setString(_kRooms, jsonEncode([for (final r in _rooms) r.toJson()]));
      // Only the first page of each feed is worth keeping for next launch.
      await prefs.setString(_kFeeds, jsonEncode({
        for (final e in _feeds.entries)
          e.key: [for (final p in e.value.take(20)) (_posts[p.id] ?? p).toJson()],
      }));
      await prefs.setString(_kOutbox, jsonEncode(_outbox));
      await prefs.setStringList(_kHidden, _hidden.toList());
    } catch (_) {
      /* best-effort */
    }
  }

  /// Her standing, rooms and unread count. Also sends anything still queued.
  Future<void> refreshMe() async {
    if (!signedIn) return;
    try {
      final me = await _call('community_me');
      if (me is Map) _me = PvCommunityMe.fromJson(me);
      final rooms = await _call('community_rooms_list');
      if (rooms is List) {
        _rooms = [
          for (final r in rooms)
            ?PvCommunityRoom.fromJson(r),
        ];
      }
      notifyListeners();
      unawaited(_persist());
      unawaited(flushOutbox());
    } catch (e) {
      debugPrint('[community] me: $e');
    }
  }

  /// Loads (or reloads, when [more] is false) one feed. Returns false when the
  /// server could not be reached, so the screen can say "showing saved posts".
  Future<bool> loadFeed({
    String scope = 'for_you',
    String sort = 'top',
    String? room,
    bool more = false,
  }) async {
    final key = feedKey(scope: scope, sort: sort, room: room);
    if (_feedLoading[key] == true) return true;
    if (!signedIn) return false;
    _feedLoading[key] = true;
    notifyListeners();
    try {
      final have = more ? (_feeds[key]?.length ?? 0) : 0;
      final res = await _call('community_feed', {
        'p_scope': scope,
        'p_sort': sort,
        'p_room': room,
        'p_stage': currentStageTag,
        'p_ids': scope == 'ids' ? savedPostIds : null,
        'p_offset': have,
        'p_limit': 20,
      });
      final list = [
        for (final p in (res is List ? res : const []))
          ?PvCommunityPost.fromJson(p),
      ];
      for (final p in list) {
        _posts[p.id] = _withLocalMedia(p);
      }
      // Her own queued posts stay at the top of the feeds they belong to.
      final queued = more ? const <PvCommunityPost>[] : _queuedFor(scope, room);
      _feeds[key] = more ? [...?_feeds[key], ...list] : [...queued, ...list];
      _feedEnded[key] = list.length < 20;
      _feedLoading[key] = false;
      notifyListeners();
      unawaited(_signFor(list));
      unawaited(_persist());
      return true;
    } catch (e) {
      debugPrint('[community] feed $key: $e');
      _feedLoading[key] = false;
      notifyListeners();
      return false;
    }
  }

  List<PvCommunityPost> _queuedFor(String scope, String? room) => [
        for (final e in _outbox)
          if (e['kind'] == 'post')
            if (PvCommunityPost.fromJson(e['local']) case final p?)
              if (scope == 'mine' || scope == 'for_you' || (scope == 'room' && p.roomId == room)) p,
      ];

  PvCommunityPost _withLocalMedia(PvCommunityPost p) {
    final prev = _posts[p.id];
    if (prev == null || !p.author.isMine) return p;
    // The server sends her pending photos by path; the phone still has the
    // files, so she sees her own pictures at once.
    final local = {for (final m in prev.media) if (m.localPath != null) m.path: m.localPath};
    if (local.isEmpty) return p;
    return p.copyWith(media: [
      for (final m in p.media)
        PvCommunityMedia(path: m.path, status: m.status, localPath: local[m.path]),
    ]);
  }

  /// One post, fresh from the server (the detail screen opens on the cached
  /// copy and calls this).
  Future<PvCommunityPost?> loadPost(String id) async {
    if (!signedIn) return _posts[id];
    try {
      final res = await _call('community_post', {'p_id': id});
      final p = PvCommunityPost.fromJson(res);
      if (p != null) {
        _posts[id] = _withLocalMedia(p);
        notifyListeners();
        unawaited(_signFor([p]));
      }
      return _posts[id];
    } catch (_) {
      return _posts[id];
    }
  }

  Future<bool> loadComments(String postId, {String sort = 'top'}) async {
    if (!signedIn) return false;
    try {
      final res = await _call('community_comments_list', {'p_post': postId, 'p_sort': sort});
      final server = [
        for (final c in (res is List ? res : const []))
          ?PvCommunityComment.fromJson(c),
      ];
      final queued = [
        for (final e in _outbox)
          if (e['kind'] == 'comment' && e['params']?['p_post'] == postId)
            ?PvCommunityComment.fromJson(e['local']),
      ];
      _comments[postId] = [...server, ...queued];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---- membership ------------------------------------------------------------

  /// First time: accept the rules and take a community name. Also a rename.
  /// Returns null on success, or what to tell her.
  Future<String?> join(String pseudonym, int seed) async {
    if (!signedIn) return 'Sign in to join the community.';
    try {
      final res = await _call('community_join', {'p_pseudonym': pseudonym, 'p_seed': seed});
      if (res is Map && res['ok'] == true) {
        _me = PvCommunityMe(
          signedIn: true,
          joined: true,
          pseudonym: res['pseudonym'] as String? ?? pseudonym,
          seed: seed,
          firstName: _me.firstName,
          canRenameAt: DateTime.now().add(const Duration(days: 30)),
          isMod: _me.isMod,
          unread: _me.unread,
        );
        notifyListeners();
        unawaited(_persist());
        unawaited(refreshMe());
        return null;
      }
      return switch (res is Map ? res['reason'] : null) {
        'taken' => 'Someone already has that name. Try another.',
        'too_soon' => 'You can change your community name once every 30 days.',
        'invalid' => 'Use letters only, 3 to 40 of them.',
        _ => 'That did not go through. Try again.',
      };
    } catch (_) {
      return 'No connection. Your name was not saved. Try again when you are online.';
    }
  }

  /// Join, leave or mute a room. Optimistic; rolls back on failure.
  Future<bool> setRoom(String roomId, {required bool join, bool mute = false}) async {
    final i = _rooms.indexWhere((r) => r.id == roomId);
    final before = i >= 0 ? _rooms[i] : null;
    if (before != null) {
      _rooms = [..._rooms]
        ..[i] = before.copyWith(
          joined: join,
          muted: join && mute,
          members: before.members + (join == before.joined ? 0 : (join ? 1 : -1)),
        );
      notifyListeners();
    }
    try {
      final res = await _call('community_set_room', {'p_room': roomId, 'p_join': join, 'p_mute': mute});
      if (res is Map && res['ok'] == true) {
        unawaited(_persist());
        return true;
      }
    } catch (_) {}
    if (before != null) {
      _rooms = [..._rooms]..[i] = before;
      notifyListeners();
    }
    return false;
  }

  // ---- writing ---------------------------------------------------------------

  static final _rand = Random.secure();
  static String newId() {
    final t = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final n = List.generate(10, (_) => _rand.nextInt(36).toRadixString(36)).join();
    return '$t$n';
  }

  /// Her community-name face, or her first-name face, as she will appear.
  PvCommunityAuthor myFace({required bool anon}) => anon
      ? PvCommunityAuthor(label: _me.pseudonym ?? 'You', anon: true, seed: _me.seed, isMine: true)
      : PvCommunityAuthor(label: _me.firstName ?? 'You', anon: false, isMine: true);

  Future<PvCommunityOutcome> createPost({
    required String roomId,
    required bool anon,
    required String title,
    String body = '',
    List<String>? pollOptions,
    int pollDays = 3,
    List<String> photoFiles = const [],
  }) async {
    final id = newId();
    final r = room(roomId);
    final media = [
      for (var k = 0; k < photoFiles.length && k < 4; k++)
        PvCommunityMedia(
          path: '$id/${newId()}.jpg',
          status: 'pending',
          localPath: photoFiles[k],
        ),
    ];
    final local = PvCommunityPost(
      id: id,
      roomId: roomId,
      roomTitle: r?.title ?? '',
      roomMark: r?.mark ?? '',
      roomHue: r?.hue ?? 210,
      author: myFace(anon: anon),
      title: title.trim(),
      body: body.trim(),
      poll: (pollOptions == null || pollOptions.length < 2)
          ? null
          : PvPoll(
              options: pollOptions,
              counts: List.filled(pollOptions.length, 0),
              closesAt: DateTime.now().add(Duration(days: pollDays)),
            ),
      media: media,
      createdAt: DateTime.now(),
      sending: true,
    );
    final entry = <String, dynamic>{
      'kind': 'post',
      'id': id,
      'params': {
        'p_id': id,
        'p_room': roomId,
        'p_identity': anon ? 'anon' : 'named',
        'p_title': title.trim(),
        'p_body': body.trim(),
        'p_poll_options': local.poll?.options,
        'p_poll_days': pollDays,
      },
      'local': local.toJson(),
    };
    _outbox.add(entry);
    _posts[id] = local;
    for (final k in [
      feedKey(),
      feedKey(scope: 'room', sort: 'top', room: roomId),
      feedKey(scope: 'room', sort: 'new', room: roomId),
      feedKey(scope: 'mine', sort: 'new'),
    ]) {
      _feeds[k] = [local, ...?_feeds[k]];
    }
    notifyListeners();
    await _persist();
    return _send(entry);
  }

  Future<PvCommunityOutcome> comment({
    required String postId,
    String? parentId,
    required bool anon,
    required String body,
  }) async {
    final id = newId();
    final local = PvCommunityComment(
      id: id,
      postId: postId,
      parentId: parentId,
      author: myFace(anon: anon),
      body: body.trim(),
      createdAt: DateTime.now(),
      sending: true,
    );
    final entry = <String, dynamic>{
      'kind': 'comment',
      'id': id,
      'params': {
        'p_id': id,
        'p_post': postId,
        'p_parent': parentId,
        'p_identity': anon ? 'anon' : 'named',
        'p_body': body.trim(),
      },
      'local': local.toJson(),
    };
    _outbox.add(entry);
    _comments[postId] = [...?_comments[postId], local];
    final p = _posts[postId];
    if (p != null) _posts[postId] = p.copyWith(commentCount: p.commentCount + 1);
    notifyListeners();
    await _persist();
    return _send(entry);
  }

  /// Sends one outbox entry. Network failure keeps it queued (and says so);
  /// a server "no" removes it and rolls the screen back.
  Future<PvCommunityOutcome> _send(Map<String, dynamic> e) async {
    if (!signedIn) return PvCommunityOutcome.queued;
    final isPost = e['kind'] == 'post';
    final id = e['id'] as String;
    dynamic res;
    try {
      res = await _call(isPost ? 'community_create_post' : 'community_comment',
          Map<String, dynamic>.from(e['params'] as Map));
    } catch (err) {
      debugPrint('[community] send $id queued: $err');
      return PvCommunityOutcome.queued;
    }
    final outcome = pvOutcomeFrom(res);
    _outbox.removeWhere((x) => x['id'] == id);
    if (outcome == PvCommunityOutcome.live || outcome == PvCommunityOutcome.held) {
      final status = outcome == PvCommunityOutcome.held ? 'held' : 'live';
      if (isPost) {
        final p = _posts[id];
        if (p != null) _posts[id] = p.copyWith(sending: false, status: status);
        unawaited(_uploadPhotos(id));
      } else {
        final postId = (e['params'] as Map)['p_post'] as String;
        _comments[postId] = [
          for (final c in _comments[postId] ?? const <PvCommunityComment>[])
            c.id == id ? c.copyWith(sending: false, status: status) : c,
        ];
      }
    } else {
      // The server refused it for good (muted, room gone…): take it back off
      // the screen. The screen tells her why from the outcome.
      if (isPost) {
        _posts.remove(id);
        for (final k in _feeds.keys.toList()) {
          _feeds[k] = [for (final p in _feeds[k]!) if (p.id != id) p];
        }
      } else {
        final postId = (e['params'] as Map)['p_post'] as String;
        _comments[postId] = [for (final c in _comments[postId] ?? const <PvCommunityComment>[]) if (c.id != id) c];
        final p = _posts[postId];
        if (p != null) _posts[postId] = p.copyWith(commentCount: max(0, p.commentCount - 1));
      }
      if (outcome == PvCommunityOutcome.muted || outcome == PvCommunityOutcome.banned) {
        unawaited(refreshMe());
      }
    }
    notifyListeners();
    unawaited(_persist());
    return outcome;
  }

  Future<void> _uploadPhotos(String postId) async {
    final p = _posts[postId];
    if (p == null) return;
    var position = 0;
    for (final m in p.media) {
      final path = m.localPath;
      if (path == null) continue;
      try {
        final bytes = await File(path).readAsBytes();
        final ok = await SupabaseRepo.uploadPrivateFile(kCommunityMediaBucket, m.path, bytes);
        if (ok) {
          await _call('community_add_media', {'p_post': postId, 'p_path': m.path, 'p_position': position});
        }
      } catch (e) {
        debugPrint('[community] photo ${m.path}: $e');
      }
      position++;
    }
  }

  /// Sends everything still queued, oldest first. Called on launch, on a
  /// refresh, and when a screen opens.
  Future<void> flushOutbox() async {
    if (_flushing || _outbox.isEmpty || !signedIn) return;
    _flushing = true;
    try {
      for (final e in [..._outbox]) {
        final o = await _send(e);
        if (o == PvCommunityOutcome.queued) break; // still offline
      }
    } finally {
      _flushing = false;
    }
  }

  // ---- reactions -------------------------------------------------------------

  Future<bool> toggleLike(String postId) async {
    final p = _posts[postId];
    if (p == null || p.sending) return false;
    final on = !p.liked;
    _posts[postId] = p.copyWith(liked: on, likeCount: max(0, p.likeCount + (on ? 1 : -1)));
    notifyListeners();
    try {
      final res = await _call('community_react', {'p_kind': 'post', 'p_id': postId, 'p_on': on});
      if (res is Map && res['ok'] == true) {
        final now = _posts[postId];
        if (now != null) {
          _posts[postId] = now.copyWith(likeCount: (res['count'] as num?)?.toInt() ?? now.likeCount);
        }
        notifyListeners();
        return true;
      }
    } catch (_) {}
    _posts[postId] = p;
    notifyListeners();
    return false;
  }

  Future<bool> toggleCommentLike(String postId, String commentId) async {
    final list = _comments[postId];
    final c = list?.where((x) => x.id == commentId).firstOrNull;
    if (list == null || c == null || c.sending) return false;
    final on = !c.liked;
    void put(PvCommunityComment v) {
      _comments[postId] = [for (final x in _comments[postId]!) x.id == commentId ? v : x];
      notifyListeners();
    }

    put(c.copyWith(liked: on, likeCount: max(0, c.likeCount + (on ? 1 : -1))));
    try {
      final res = await _call('community_react', {'p_kind': 'comment', 'p_id': commentId, 'p_on': on});
      if (res is Map && res['ok'] == true) return true;
    } catch (_) {}
    put(c);
    return false;
  }

  /// Votes once. Returns the outcome so the screen can say "Poll closed".
  Future<PvCommunityOutcome> vote(String postId, int option) async {
    final p = _posts[postId];
    final poll = p?.poll;
    if (p == null || poll == null || poll.mine != null) return PvCommunityOutcome.invalid;
    _posts[postId] = p.copyWith(poll: poll.voted(option));
    notifyListeners();
    try {
      final res = await _call('community_vote', {'p_post': postId, 'p_option': option});
      if (res is Map && res['ok'] == true) {
        final fresh = PvCommunityPost.fromJson(res['post']);
        if (fresh?.poll != null) _posts[postId] = _posts[postId]!.copyWith(poll: fresh!.poll);
        notifyListeners();
        return PvCommunityOutcome.live;
      }
      _posts[postId] = p;
      notifyListeners();
      return res is Map && res['reason'] == 'closed' ? PvCommunityOutcome.gone : pvOutcomeFrom(res);
    } catch (_) {
      _posts[postId] = p;
      notifyListeners();
      return PvCommunityOutcome.queued;
    }
  }

  // ---- saving (the app's one Saved list) -------------------------------------

  bool isSaved(String postId) => SavedStore.instance.isSaved(SavedKind.post, postId);
  List<String> get savedPostIds => SavedStore.instance.idsOf(SavedKind.post);

  Future<void> toggleSave(PvCommunityPost p) async {
    if (isSaved(p.id)) {
      await SavedStore.instance.unsave(SavedKind.post, p.id);
    } else {
      await SavedStore.instance.save(SavedKind.post, p.id, title: p.title, subtitle: p.roomTitle);
    }
    notifyListeners();
  }

  // ---- safety ----------------------------------------------------------------

  /// Hides a post for her at once, then tells the server.
  Future<void> hide(String postId) async {
    _hidden.add(postId);
    notifyListeners();
    unawaited(_persist());
    try {
      await _call('community_hide', {'p_post': postId});
    } catch (_) {}
  }

  Future<bool> report({
    required String kind,
    required String id,
    required String reason,
    String note = '',
    String? postId,
  }) async {
    if (kind == 'post') {
      _hidden.add(id);
    } else if (postId != null) {
      _comments[postId] = [for (final c in _comments[postId] ?? const <PvCommunityComment>[]) if (c.id != id) c];
    }
    notifyListeners();
    unawaited(_persist());
    try {
      final res = await _call('community_report', {'p_kind': kind, 'p_id': id, 'p_reason': reason, 'p_note': note});
      return res is Map && res['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Blocks the author of a post or comment, then drops their posts from
  /// every feed on this phone. The server does the same on every read.
  Future<bool> block({required String kind, required String id}) async {
    try {
      final res = await _call('community_block', {'p_kind': kind, 'p_id': id});
      if (res is! Map || res['ok'] != true) return false;
    } catch (_) {
      return false;
    }
    for (final k in _feeds.keys.toList()) {
      unawaited(_reloadKey(k));
    }
    return true;
  }

  Future<void> _reloadKey(String key) {
    final parts = key.split('|');
    return loadFeed(
      scope: parts[0],
      sort: parts.length > 1 ? parts[1] : 'top',
      room: parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null,
    );
  }

  Future<List<Map<String, dynamic>>> blockedList() async {
    try {
      final res = await _call('community_blocked_list');
      return [for (final b in (res is List ? res : const [])) Map<String, dynamic>.from(b as Map)];
    } catch (_) {
      return const [];
    }
  }

  Future<bool> unblock(String blockId) async {
    try {
      final res = await _call('community_unblock', {'p_block': blockId});
      return res is Map && res['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteMine({required String kind, required String id, String? postId}) async {
    // A queued post that never reached the server is just taken off the phone.
    final queued = _outbox.any((e) => e['id'] == id);
    if (queued) _outbox.removeWhere((e) => e['id'] == id);
    if (kind == 'post') {
      _posts.remove(id);
      for (final k in _feeds.keys.toList()) {
        _feeds[k] = [for (final p in _feeds[k]!) if (p.id != id) p];
      }
    } else if (postId != null) {
      _comments[postId] = [for (final c in _comments[postId] ?? const <PvCommunityComment>[]) if (c.id != id) c];
      final p = _posts[postId];
      if (p != null) _posts[postId] = p.copyWith(commentCount: max(0, p.commentCount - 1));
    }
    notifyListeners();
    unawaited(_persist());
    if (queued) return true;
    try {
      final res = await _call('community_delete', {'p_kind': kind, 'p_id': id});
      return res is Map && res['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  // ---- replies to her --------------------------------------------------------

  Future<void> loadActivity() async {
    if (!signedIn) return;
    try {
      final res = await _call('community_activity', {'p_limit': 40});
      _activity = [
        for (final a in (res is List ? res : const []))
          ?PvCommunityActivity.fromJson(a),
      ];
      notifyListeners();
    } catch (_) {}
  }

  /// She has seen her replies: the home card's count and the bell dot clear.
  Future<void> markSeen() async {
    if (_me.unread == 0 && _activity.every((a) => !a.unread)) return;
    _me = PvCommunityMe.fromJson({..._me.toJson(), 'unread': 0});
    notifyListeners();
    unawaited(_persist());
    try {
      await _call('community_mark_seen');
    } catch (_) {}
  }

  /// One face of a member: from a post or comment id she tapped, or her own.
  Future<(PvCommunityAuthor, List<PvCommunityPost>)?> face({String? fromId, bool anon = true}) async {
    if (!signedIn) return null;
    try {
      final res = await _call('community_face', {'p_from': fromId, 'p_face': anon ? 'anon' : 'named'});
      if (res is! Map) return null;
      final posts = [
        for (final p in (res['posts'] as List?) ?? const [])
          ?PvCommunityPost.fromJson(p),
      ];
      for (final p in posts) {
        _posts[p.id] = _withLocalMedia(p);
      }
      unawaited(_signFor(posts));
      return (PvCommunityAuthor.fromJson(res['author']), posts);
    } catch (_) {
      return null;
    }
  }

  // ---- photos ----------------------------------------------------------------

  /// A signed URL for an approved photo, if one is ready.
  String? urlFor(String path) {
    final s = _signed[path];
    if (s == null || s.$2.isBefore(DateTime.now())) return null;
    return s.$1;
  }

  Future<void> _signFor(List<PvCommunityPost> posts) async {
    final need = [
      for (final p in posts)
        for (final m in p.media)
          if (m.localPath == null && urlFor(m.path) == null) m.path,
    ];
    if (need.isEmpty || debugBackend != null) return;
    final urls = await SupabaseRepo.signedUrls(kCommunityMediaBucket, need);
    final until = DateTime.now().add(const Duration(minutes: 50));
    urls.forEach((k, v) => _signed[k] = (v, until));
    if (urls.isNotEmpty) notifyListeners();
  }

  /// For the moderator screen: sign whatever paths it shows.
  Future<void> signPaths(List<String> paths) async {
    if (debugBackend != null) return;
    final urls = await SupabaseRepo.signedUrls(kCommunityMediaBucket, paths);
    final until = DateTime.now().add(const Duration(minutes: 50));
    urls.forEach((k, v) => _signed[k] = (v, until));
    if (urls.isNotEmpty) notifyListeners();
  }

  // ---- moderation ------------------------------------------------------------

  Future<Map<String, dynamic>?> modQueue(String queue) async {
    try {
      final res = await _call('community_mod_queue', {'p_queue': queue});
      return res is Map ? Map<String, dynamic>.from(res) : null;
    } catch (_) {
      return null;
    }
  }

  /// Returns null on success, or what went wrong.
  Future<String?> modAct({
    required String kind,
    required String id,
    required String action,
    required String reason,
    int muteHours = 24,
  }) async {
    try {
      final res = await _call('community_mod_act', {
        'p_kind': kind,
        'p_id': id,
        'p_action': action,
        'p_reason': reason,
        'p_mute_hours': muteHours,
      });
      if (res is Map && res['ok'] == true) return null;
      return switch (res is Map ? res['reason'] : null) {
        'not_mod' => 'This account is not on the moderators list.',
        'reason_required' => 'Add a short reason. It goes in the audit trail.',
        'gone' => 'That post or reply no longer exists.',
        _ => 'That did not go through. Try again.',
      };
    } catch (_) {
      return 'No connection. Nothing was changed.';
    }
  }

  // ---- tests -----------------------------------------------------------------

  @visibleForTesting
  void debugReset() {
    _loaded = false;
    _me = const PvCommunityMe();
    _rooms = const [];
    _feeds.clear();
    _feedLoading.clear();
    _feedEnded.clear();
    _posts.clear();
    _comments.clear();
    _hidden.clear();
    _outbox.clear();
    _signed.clear();
    _activity = const [];
    debugBackend = null;
    debugSignedIn = null;
  }
}
