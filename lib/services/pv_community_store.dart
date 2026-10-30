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
import '../screens/post_pregnancy/pp_child_profile.dart' show ChildProfileStore;
import 'life_stage_store.dart';
import 'pregnancy_controller.dart';
import 'pregnancy_ended_store.dart';
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

  /// Rooms, her stage's first, then joined, then the house order. (0137) Her
  /// birth club leads the rail: it is the one room made only for her month.
  List<PvCommunityRoom> get rooms {
    final stage = currentStageTag;
    final list = [..._rooms];
    int score(PvCommunityRoom r) => r.isClub
        ? -1
        : (r.stage == stage ? 0 : (r.stage == 'all' ? 1 : 2)) * 1000 + r.sort;
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

  /// [about] narrows a course room's feed to one lesson or session (0137);
  /// the part is only added when set, so phase 1's cached keys still parse.
  /// A #tag feed (scope 'tag') carries its tag in the [room] slot, so the key
  /// keeps its shape and `_reloadKey` needs no new case.
  static String feedKey({String scope = 'for_you', String sort = 'top', String? room, PvPostAbout? about}) =>
      '$scope|$sort|${room ?? ''}${about == null ? '' : '|${about.kind}:${about.id}'}';

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
      unawaited(syncBirthClub());
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
    PvPostAbout? about,
    bool more = false,
  }) async {
    final key = feedKey(scope: scope, sort: sort, room: room, about: about);
    if (_feedLoading[key] == true) return true;
    if (!signedIn) return false;
    _feedLoading[key] = true;
    notifyListeners();
    try {
      final have = more ? (_feeds[key]?.length ?? 0) : 0;
      final res = await _call('community_feed', {
        'p_scope': scope,
        'p_sort': sort,
        'p_room': scope == 'tag' ? null : room,
        'p_tag': scope == 'tag' ? room : null,
        'p_stage': currentStageTag,
        'p_ids': scope == 'ids' ? savedPostIds : null,
        'p_offset': have,
        'p_limit': 20,
        'p_about_kind': about?.kind,
        'p_about_id': about?.id,
      });
      final list = [
        for (final p in (res is List ? res : const []))
          ?PvCommunityPost.fromJson(p),
      ];
      for (final p in list) {
        _posts[p.id] = _withLocalMedia(p);
      }
      // Her own queued posts stay at the top of the feeds they belong to.
      final queued = more ? const <PvCommunityPost>[] : _queuedFor(scope, room, about);
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

  List<PvCommunityPost> _queuedFor(String scope, String? room, [PvPostAbout? about]) => [
        for (final e in _outbox)
          if (e['kind'] == 'post')
            if (PvCommunityPost.fromJson(e['local']) case final p?)
              if (about == null || p.about == about)
                if (scope == 'mine' ||
                    (scope == 'for_you' && p.roomKind != 'offering') ||
                    (scope == 'room' && p.roomId == room))
                  p,
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
      _fresh.remove(postId); // a pull shows everything; nothing is left waiting
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
  /// (0137) An expert's named face carries her badge, as the server will.
  PvCommunityAuthor myFace({required bool anon}) => anon
      ? PvCommunityAuthor(label: _me.pseudonym ?? 'You', anon: true, seed: _me.seed, isMine: true)
      : PvCommunityAuthor(
          label: _me.firstName ?? _me.expert?.name ?? 'You',
          anon: false,
          expert: _me.expert,
          moderator: _me.isMod,
          isMine: true,
        );

  Future<PvCommunityOutcome> createPost({
    required String roomId,
    required bool anon,
    required String title,
    String body = '',
    List<String>? pollOptions,
    int pollDays = 3,
    List<String> photoFiles = const [],
    PvPostAbout? about,
  }) async {
    final id = newId();
    final r = room(roomId);
    final offering = r?.isOffering == true;
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
      roomKind: r?.kind ?? 'room',
      about: offering ? about : null,
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
        'p_about_kind': local.about?.kind,
        'p_about_id': local.about?.id,
      },
      'local': local.toJson(),
    };
    _outbox.add(entry);
    _posts[id] = local;
    for (final k in [
      // A course post stays out of For you, as it does on the server.
      if (!offering) feedKey(),
      feedKey(scope: 'room', sort: 'top', room: roomId),
      feedKey(scope: 'room', sort: 'new', room: roomId),
      if (local.about != null) feedKey(scope: 'room', sort: 'new', room: roomId, about: local.about),
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
    final about = parts.length > 3 ? parts[3].split(':') : const <String>[];
    return loadFeed(
      scope: parts[0],
      sort: parts.length > 1 ? parts[1] : 'top',
      room: parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null,
      about: about.length == 2 ? PvPostAbout(kind: about[0], id: about[1]) : null,
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

  /// Whether she follows the face [face] last opened (0137). Kept beside the
  /// record rather than in it, so the one caller's shape did not change.
  bool lastFaceFollowing = false;

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
      lastFaceFollowing = res['following'] == true;
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

  // ---- course discussions (0137, LA-20) --------------------------------------
  //
  // One discussion per offering RUN. The phone never decides who may enter:
  // it asks `community_offering_room`, which checks her receipt, a booked
  // seat, a host or a moderator on the server, and also picks her run. The
  // phone's own record of a purchase is a claim, and a claim is never an
  // access check.

  final Map<String, PvOfferingRoom> _offering = {};

  /// The last answer for a programme (cached for the screen's first frame).
  PvOfferingRoom? offering(String programmeId) => _offering[programmeId];

  Future<PvOfferingRoom?> offeringRoom(String programmeId, {String? runId}) async {
    if (!signedIn) return _offering[programmeId];
    try {
      final res = await _call('community_offering_room', {'p_programme': programmeId, 'p_run': runId});
      final o = PvOfferingRoom.fromJson(res);
      if (o != null) {
        _offering[programmeId] = o;
        if (o.access) {
          _rooms = [for (final r in _rooms) if (r.id != o.room.id) r, o.room];
        }
        notifyListeners();
      }
      return o ?? _offering[programmeId];
    } catch (e) {
      debugPrint('[community] offering $programmeId: $e');
      return _offering[programmeId];
    }
  }

  /// The course room's state for an open room screen: host / moderator.
  PvOfferingRoom? offeringForRoom(String roomId) {
    for (final o in _offering.values) {
      if (o.room.id == roomId) return o;
    }
    return null;
  }

  /// When a booked session USED to start, from the pinned team notice the
  /// server wrote when it moved (LA-22). Null when nothing moved, or when this
  /// course's room has not been read on this phone yet. [slotId] is the
  /// booking's slot (`ps_` + the session id).
  DateTime? movedFrom(String slotId) {
    if (!slotId.startsWith('ps_')) return null;
    final session = slotId.substring(3);
    for (final p in _posts.values) {
      if (p.author.team && p.pinned && p.movedFrom != null && p.about?.kind == 'session' && p.about?.id == session) {
        return p.movedFrom;
      }
    }
    return null;
  }

  /// Reads a course's room so its notices are on the phone (My learning
  /// calls this for each upcoming class). Quiet: nothing to show on failure.
  Future<void> loadCourseNotices(String programmeId) async {
    final o = await offeringRoom(programmeId);
    if (o != null && o.access) await loadFeed(scope: 'room', sort: 'new', room: o.room.id);
  }

  /// She opened a room: its unread count clears here and on the server.
  Future<void> roomSeen(String roomId) async {
    final i = _rooms.indexWhere((r) => r.id == roomId);
    if (i >= 0 && _rooms[i].unread > 0) {
      _rooms = [..._rooms]..[i] = _rooms[i].copyWith(unread: 0);
      notifyListeners();
    }
    if (!signedIn) return;
    try {
      await _call('community_room_seen', {'p_room': roomId});
    } catch (_) {}
  }

  static const _kCourseHeadsUp = 'pv_community_course_heads_up';

  /// B4: the first time she writes in a course thread, she is told it uses
  /// her first name. Never silent; shown once per phone.
  Future<bool> courseHeadsUpDue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kCourseHeadsUp) != true;
    } catch (_) {
      return false;
    }
  }

  Future<void> markCourseHeadsUpShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kCourseHeadsUp, true);
    } catch (_) {}
  }

  // ---- the team voice and pinning (0137, L.6 / B3) ---------------------------

  /// "Post as ParentVeda team": moderators only. Online only, like a
  /// moderator action, so its outcome is known at once. Returns the outcome.
  Future<PvCommunityOutcome> createPrompt({
    required String roomId,
    required String title,
    String body = '',
    int pinDays = 0,
  }) async {
    if (!signedIn) return PvCommunityOutcome.signedOut;
    final id = newId();
    try {
      final res = await _call('community_create_prompt', {
        'p_id': id,
        'p_room': roomId,
        'p_title': title.trim(),
        'p_body': body.trim(),
        'p_pin_days': pinDays,
      });
      final o = pvOutcomeFrom(res);
      if (o == PvCommunityOutcome.live) {
        unawaited(loadFeed(scope: 'room', sort: 'new', room: roomId));
        unawaited(loadFeed(scope: 'room', sort: 'top', room: roomId));
      }
      return o;
    } catch (_) {
      return PvCommunityOutcome.queued;
    }
  }

  /// Pin for [days] (1..14), or unpin with 0. Moderators, or a course's
  /// hosts in its room. Returns null on success, or what to tell her.
  Future<String?> pin(String postId, int days) async {
    final p = _posts[postId];
    try {
      final res = await _call('community_pin', {'p_post': postId, 'p_days': days});
      if (res is Map && res['ok'] == true) {
        if (p != null) _posts[postId] = p.copyWith(pinned: days > 0);
        notifyListeners();
        if (p != null) unawaited(loadFeed(scope: 'room', sort: 'new', room: p.roomId));
        return null;
      }
      return switch (res is Map ? res['reason'] : null) {
        'not_mod' => 'Only moderators and this course\'s hosts can pin here.',
        'gone' => 'That post no longer exists.',
        _ => 'That did not go through. Try again.',
      };
    } catch (_) {
      return 'No connection. Nothing was pinned.';
    }
  }

  // ---- experts (0137) ---------------------------------------------------------

  /// "Ask an expert to look", by the post's author, once per post.
  /// Returns 'ok' | 'crisis' | 'offline' | 'error'.
  Future<String> askExpert(String postId) async {
    final p = _posts[postId];
    try {
      final res = await _call('community_ask_expert', {'p_post': postId});
      if (res is Map && res['ok'] == true) {
        if (p != null) _posts[postId] = p.copyWith(expertAsked: true);
        notifyListeners();
        return 'ok';
      }
      return res is Map && res['reason'] == 'crisis' ? 'crisis' : 'error';
    } catch (_) {
      return 'offline';
    }
  }

  List<PvExpertRequest> _queue = const [];
  List<PvExpertRequest> get expertQueueItems => _queue;

  /// The questions members asked an expert to look at, oldest first.
  /// Returns false when the server could not be reached.
  Future<bool> expertQueue() async {
    if (!signedIn) return false;
    try {
      final res = await _call('community_expert_queue');
      if (res is Map && res['ok'] == true) {
        _queue = [
          for (final i in (res['items'] as List?) ?? const [])
            ?PvExpertRequest.fromJson(i),
        ];
        for (final q in _queue) {
          _posts[q.post.id] = _withLocalMedia(q.post);
        }
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Claim a question so two experts do not answer the same one.
  /// Returns null on success, or what to tell her.
  Future<String?> expertClaim(String postId, {bool on = true}) async {
    try {
      final res = await _call('community_expert_claim', {'p_post': postId, 'p_on': on});
      if (res is Map && res['ok'] == true) {
        _queue = [for (final q in _queue) q.post.id == postId ? q.copyWith(claimedByMe: on) : q];
        notifyListeners();
        return null;
      }
      return switch (res is Map ? res['reason'] : null) {
        'taken' => 'Another expert is already on this one.',
        'gone' => 'This question has been answered.',
        _ => 'That did not go through. Try again.',
      };
    } catch (_) {
      return 'No connection. Nothing was claimed.';
    }
  }

  /// An expert marks a reply helpful. Optimistic; rolls back on a no.
  Future<bool> endorse(String postId, String commentId, {required bool on}) async {
    final list = _comments[postId];
    final c = list?.where((x) => x.id == commentId).firstOrNull;
    final me = _me.expert;
    if (list == null || c == null || me == null) return false;
    void put(PvCommunityComment v) {
      _comments[postId] = [for (final x in _comments[postId]!) x.id == commentId ? v : x];
      notifyListeners();
    }

    put(c.copyWith(
      endorsed: on,
      endorsements: on
          ? [...c.endorsements, me]
          : [for (final e in c.endorsements) if (e.name != me.name) e],
    ));
    try {
      final res = await _call('community_endorse', {'p_kind': 'comment', 'p_id': commentId, 'p_on': on});
      if (res is Map && res['ok'] == true) return true;
    } catch (_) {}
    put(c);
    return false;
  }

  // ---- the doctor's "Your offerings" (0137, LA-21) ---------------------------

  List<PvExpertOffering> _offerings = const [];
  List<PvExpertOffering> get myOfferingItems => _offerings;

  /// Every run she hosts, from the server. False when it could not be read.
  Future<bool> myOfferings() async {
    if (!signedIn) return false;
    try {
      final res = await _call('expert_my_offerings');
      if (res is Map && res['ok'] == true) {
        _offerings = [
          for (final i in (res['items'] as List?) ?? const [])
            ?PvExpertOffering.fromJson(i),
        ];
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---- birth clubs (0137, plan decisions 11-13) -------------------------------
  //
  // The phone, not the server, knows her month: the server's copy of a due
  // date can lag behind the phone and outlives a loss (the same reason the
  // phone already sends her stage). So the app DERIVES the month and sends
  // it; the server creates `club_YYYY_MM` on first need and moves only the
  // memberships it made itself ('auto'). One she chose ('self') stays hers.

  static const _kClubLossAnswered = 'pv_community_club_loss_answered';

  /// Test seam: the facts the month is derived from, in place of the stores.
  @visibleForTesting
  ({String? month, bool loss})? debugClubFacts;

  String? _clubAfterLoss;

  /// Her birth club's room id when her pregnancy ended in a loss and she has
  /// not yet said whether to stay. The home shows the Stay / Leave sheet once;
  /// nothing changes until she answers (decision 12).
  String? get clubAfterLoss => _clubAfterLoss;

  PvCommunityRoom? get myClub => _rooms.where((r) => r.isClub && r.joined).firstOrNull;

  static String _month(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

  ({String? month, bool loss}) _clubFacts() {
    final d = debugClubFacts;
    if (d != null) return d;
    final stage = LifeStageStore.instance.stage;
    if (stage == LifeStage.tryingToConceive) {
      // Trying sends nothing; a loss recorded before she went back to trying
      // still asks about the club she was in.
      return (month: null, loss: PregnancyEndedStore.instance.ended);
    }
    final c = PregnancyController.current;
    final due = c != null && c.isDueDateSet ? c.dueDate : null;
    if (stage != LifeStage.parenting) {
      final loss = PregnancyEndedStore.instance.ended;
      return (month: loss || due == null ? null : _month(due), loss: loss);
    }
    // Parenting. `children` never holds the seed child (dob = today), so an
    // empty list means no real child yet.
    final kids = ChildProfileStore.instance.children;
    if (kids.isEmpty) return (month: due == null ? null : _month(due), loss: false);
    final youngest = kids.map((k) => k.dob).reduce((a, b) => a.isAfter(b) ? a : b);
    // After birth she stays in her due month's club (it becomes her baby's
    // month group), so the due month wins when this pregnancy made this child.
    final same = due != null && due.difference(youngest).inDays.abs() <= 62;
    return (month: _month(same ? due : youngest), loss: false);
  }

  /// Puts her in her month's club, or raises the after-a-loss question.
  /// Called from [refreshMe]; a no-op when she is already in the right club.
  Future<void> syncBirthClub() async {
    if (!signedIn) return;
    final f = _clubFacts();
    if (f.loss) {
      final club = _rooms.where((r) => r.isClub && r.joined && r.via != 'self').firstOrNull;
      String? answered;
      try {
        answered = (await SharedPreferences.getInstance()).getString(_kClubLossAnswered);
      } catch (_) {}
      final next = club != null && answered != club.id ? club.id : null;
      if (next != _clubAfterLoss) {
        _clubAfterLoss = next;
        notifyListeners();
      }
      return;
    }
    _clubAfterLoss = null;
    final month = f.month;
    if (month == null) return;
    final want = 'club_${month.replaceAll('-', '_')}';
    if (_rooms.any((r) => r.id == want && r.joined)) return;
    try {
      final res = await _call('community_birth_club', {'p_month': month});
      if (res is! Map || res['ok'] != true) return;
      final rooms = await _call('community_rooms_list');
      if (rooms is List) {
        _rooms = [
          for (final r in rooms)
            ?PvCommunityRoom.fromJson(r),
        ];
        notifyListeners();
        unawaited(_persist());
      }
    } catch (e) {
      debugPrint('[community] club: $e');
    }
  }

  /// Her answer on the after-a-loss sheet. Stay re-joins as her own choice
  /// ('self'), so no later sync moves her; Leave takes her out. Either way the
  /// sheet never shows again for this club. Returns false if it did not go
  /// through (the sheet stays due).
  Future<bool> answerClubAfterLoss({required bool stay}) async {
    final id = _clubAfterLoss;
    if (id == null) return true;
    final ok = await setRoom(id, join: stay);
    if (!ok) return false;
    _clubAfterLoss = null;
    if (stay) {
      final i = _rooms.indexWhere((r) => r.id == id);
      if (i >= 0) _rooms = [..._rooms]..[i] = _rooms[i].copyWith(via: 'self');
    }
    notifyListeners();
    unawaited(_persist());
    try {
      await (await SharedPreferences.getInstance()).setString(_kClubLossAnswered, id);
    } catch (_) {}
    return true;
  }

  // ---- following (0137, decisions 14-15) --------------------------------------

  PvCommunityFollowing _following = const PvCommunityFollowing();

  /// Rooms she is in, #tags and faces she follows. No ids of people.
  PvCommunityFollowing get following => _following;

  static String _tagOf(String t) => t.trim().toLowerCase().replaceFirst(RegExp('^#'), '');

  bool followsTag(String tag) => _following.tags.contains(_tagOf(tag));

  Future<bool> loadFollowing() async {
    if (!signedIn) return false;
    try {
      _following = PvCommunityFollowing.fromJson(await _call('community_following_list'));
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Follow or unfollow. [kind] 'tag' (target = the tag), 'member' (target =
  /// a post or comment id of that face) or 'follow' (target = a row id from
  /// [following]; unfollow only). A tag or a row changes on screen at once and
  /// rolls back if the server says no. Returns false when it did not go through.
  Future<bool> follow({required String kind, required String target, required bool on}) async {
    final before = _following;
    if (kind == 'tag') {
      final t = _tagOf(target);
      _following = PvCommunityFollowing(
        rooms: before.rooms,
        tags: [if (on) t, ...before.tags.where((x) => x != t)],
        people: before.people,
      );
    } else if (kind == 'follow' && !on) {
      _following = PvCommunityFollowing(
        rooms: before.rooms,
        tags: before.tags,
        people: [...before.people.where((p) => p.id != target)],
      );
    }
    notifyListeners();
    try {
      final res = await _call('community_follow', {'p_kind': kind, 'p_target': target, 'p_on': on});
      if (res is Map && res['ok'] == true) {
        if (kind == 'member') {
          lastFaceFollowing = on;
          unawaited(loadFollowing());
        }
        return true;
      }
    } catch (_) {}
    _following = before;
    notifyListeners();
    return false;
  }

  // ---- search (0137, decision 16) ---------------------------------------------

  static const _kRecentSearches = 'pv_community_recent_searches';

  /// Posts, rooms and #tags for [q]. Null when the server could not be
  /// reached, so the screen can say so rather than show "no results".
  Future<PvCommunitySearch?> search(String q, {int offset = 0}) async {
    if (!signedIn) return null;
    try {
      final r = PvCommunitySearch.fromJson(await _call('community_search', {'p_q': q.trim(), 'p_offset': offset}));
      for (final p in r.posts) {
        _posts[p.id] = _withLocalMedia(p);
      }
      unawaited(_signFor(r.posts));
      return r;
    } catch (_) {
      return null;
    }
  }

  /// Her last searches, newest first. Kept on the phone only.
  Future<List<String>> recentSearches() async {
    try {
      return (await SharedPreferences.getInstance()).getStringList(_kRecentSearches) ?? const [];
    } catch (_) {
      return const [];
    }
  }

  Future<void> rememberSearch(String q) async {
    final t = q.trim();
    if (t.length < 2) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kRecentSearches) ?? const [];
      await prefs.setStringList(
          _kRecentSearches, [t, ...list.where((x) => x.toLowerCase() != t.toLowerCase())].take(6).toList());
    } catch (_) {}
  }

  Future<void> clearRecentSearches() async {
    try {
      await (await SharedPreferences.getInstance()).remove(_kRecentSearches);
    } catch (_) {}
  }

  // ---- edit within 15 minutes (0137, decisions 17-18) ------------------------

  static const editWindow = Duration(minutes: 15);

  /// Whether the Edit row shows: her own post, inside the window. A team
  /// post is edited by nobody (it is the house speaking).
  bool canEdit(PvCommunityPost p) =>
      p.author.isMine && !p.author.team && DateTime.now().difference(p.createdAt) < editWindow;

  /// Title and body only. Online only: an edit queued past the window would
  /// be refused later, which surprises her more than "no connection" now. A
  /// post still in the outbox is edited in place (it has not been sent).
  /// Returns 'ok' | 'held' | 'too_late' | 'too_short' | 'offline' | 'error'.
  Future<String> editPost(String id, {required String title, required String body}) async {
    final t = title.trim();
    final b = body.trim();
    final p = _posts[id];
    final i = _outbox.indexWhere((e) => e['id'] == id);
    if (i >= 0) {
      final e = Map<String, dynamic>.from(_outbox[i]);
      e['params'] = {...(e['params'] as Map), 'p_title': t, 'p_body': b};
      _outbox[i] = e;
      if (p != null) _posts[id] = p.copyWith(title: t, body: b);
      notifyListeners();
      unawaited(_persist());
      return 'ok';
    }
    if (p != null && !canEdit(p)) return 'too_late';
    try {
      final res = await _call('community_edit_post', {'p_id': id, 'p_title': t, 'p_body': b});
      if (res is Map && res['ok'] == true) {
        final st = '${res['status'] ?? 'live'}';
        if (p != null) _posts[id] = p.copyWith(title: t, body: b, editedAt: DateTime.now(), status: st);
        notifyListeners();
        unawaited(_persist());
        return st == 'held' ? 'held' : 'ok';
      }
      return switch (res is Map ? res['reason'] : null) {
        'too_late' => 'too_late',
        'too_short' => 'too_short',
        _ => 'error',
      };
    } catch (_) {
      return 'offline';
    }
  }

  // ---- the live thread (0145, phase 3 C3-1) -----------------------------------
  //
  // While a post is open, the server signals "a reply changed on post X" on a
  // private topic. The signal carries only the post id, so we re-read through
  // community_comments_list: blocks, holds and faces apply as they always do.
  //
  // ⚠️ THE RE-READ GOES INTO [_fresh], NOT [_comments]. The screen renders
  // _comments; writing there would move the list under her finger as she
  // reads. _fresh waits until she taps the pill ([showNewReplies]). A change
  // with nothing new in it (a reply removed, a like) is not worth a pill and
  // waits for her next pull or visit.

  final Map<String, PvLiveListen> _live = {};
  final Map<String, List<PvCommunityComment>> _fresh = {};
  final Map<String, Timer> _liveWait = {};

  @visibleForTesting
  PvLiveListen? Function(String topic, void Function() onSignal)? debugListen;

  /// Replies waiting behind the "N new replies" pill.
  int newReplies(String postId) {
    final f = _fresh[postId];
    return f == null ? 0 : communityNewReplyIds(_comments[postId] ?? const [], f).length;
  }

  /// The post screen opened. Safe to call twice; a no-op signed out.
  void watchPost(String postId) {
    if (!signedIn || _live.containsKey(postId)) return;
    final topic = 'post:$postId';
    void signal() => _onLiveSignal(postId);
    final sub = debugListen != null ? debugListen!(topic, signal) : SupabaseRepo.listenBroadcast(topic, 'reply', signal);
    if (sub != null) _live[postId] = sub;
  }

  /// The post screen closed: leave the topic and drop what was waiting.
  void unwatchPost(String postId) {
    _live.remove(postId)?.close();
    _liveWait.remove(postId)?.cancel();
    _fresh.remove(postId);
  }

  // Three replies in a second are one re-read, not three.
  void _onLiveSignal(String postId) {
    _liveWait[postId]?.cancel();
    _liveWait[postId] = Timer(const Duration(milliseconds: 700), () => _fetchFresh(postId));
  }

  Future<void> _fetchFresh(String postId) async {
    if (!_live.containsKey(postId)) return;
    try {
      final res = await _call('community_comments_list', {'p_post': postId, 'p_sort': 'top'});
      final server = [
        for (final c in (res is List ? res : const []))
          ?PvCommunityComment.fromJson(c),
      ];
      if (!_live.containsKey(postId)) return; // she left while it loaded
      if (communityNewReplyIds(_comments[postId] ?? const [], server).isEmpty) return;
      _fresh[postId] = server;
      notifyListeners();
    } catch (_) {
      // A missed re-read costs a pill. Pull to refresh still works.
    }
  }

  /// She tapped the pill: show what was waiting. Returns the new replies'
  /// ids, for the screen to scroll to and ring.
  List<String> showNewReplies(String postId) {
    final f = _fresh.remove(postId);
    if (f == null) return const [];
    final ids = communityNewReplyIds(_comments[postId] ?? const [], f);
    final queued = [
      for (final e in _outbox)
        if (e['kind'] == 'comment' && e['params']?['p_post'] == postId)
          ?PvCommunityComment.fromJson(e['local']),
    ];
    _comments[postId] = [...f, ...queued];
    notifyListeners();
    return ids;
  }

  @visibleForTesting
  Future<void> debugFetchFresh(String postId) => _fetchFresh(postId);

  // ---- tests -----------------------------------------------------------------

  @visibleForTesting
  void debugReset() {
    for (final l in _live.values) {
      l.close();
    }
    _live.clear();
    _fresh.clear();
    for (final t in _liveWait.values) {
      t.cancel();
    }
    _liveWait.clear();
    debugListen = null;
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
    _offering.clear();
    _queue = const [];
    _offerings = const [];
    _following = const PvCommunityFollowing();
    _clubAfterLoss = null;
    debugClubFacts = null;
    lastFaceFollowing = false;
    debugBackend = null;
    debugSignedIn = null;
  }
}

/// Replies in [fresh] that are not in [shown] and not hers, in [fresh]'s
/// order. Her own replies never count: she saw each one as she sent it, and
/// the app made its id, so her local copy and the server's share it.
List<String> communityNewReplyIds(List<PvCommunityComment> shown, List<PvCommunityComment> fresh) {
  final have = {for (final c in shown) c.id};
  return [
    for (final c in fresh)
      if (!have.contains(c.id) && !c.author.isMine) c.id,
  ];
}
