// The community's shapes, exactly as the server's functions return them
// (supabase/migrations/0121_community.sql). Plain classes, no codegen.
//
// ⚠️ THERE IS NO USER ID ANYWHERE IN HERE, BY DESIGN. The server never sends
// one (anonymity is a column problem — see the 0121 header), so nothing on
// the phone can leak it. An author is a label, a face (community name or
// first name), a seed for the drawn avatar, and `isMine`.

/// One face of a member, as the app may show it.
class PvCommunityAuthor {
  const PvCommunityAuthor({
    required this.label,
    required this.anon,
    this.seed = 0,
    this.team = false,
    this.isMine = false,
  });

  final String label;

  /// True on the community-name face; false on her first name.
  final bool anon;

  /// Picks the drawn face mark and its tint (0..63).
  final int seed;

  /// A ParentVeda moderator posting under their name.
  final bool team;
  final bool isMine;

  static PvCommunityAuthor fromJson(Object? raw) {
    final m = raw is Map ? raw : const {};
    return PvCommunityAuthor(
      label: (m['label'] as String?)?.trim().isNotEmpty == true ? m['label'] as String : 'A member',
      anon: m['anon'] != false,
      seed: (m['seed'] as num?)?.toInt() ?? 0,
      team: m['team'] == true,
      isMine: m['is_mine'] == true,
    );
  }

  Map<String, dynamic> toJson() =>
      {'label': label, 'anon': anon, 'seed': seed, 'team': team, 'is_mine': isMine};
}

class PvCommunityRoom {
  const PvCommunityRoom({
    required this.id,
    required this.title,
    this.blurb = '',
    this.stage = 'all',
    this.mark = '',
    this.hue = 210,
    this.sort = 100,
    this.members = 0,
    this.joined = false,
    this.muted = false,
  });

  final String id;
  final String title;
  final String blurb;

  /// 'trying' | 'pregnancy' | 'parenting' | 'all'.
  final String stage;

  /// `tab:<TtcTabMark>` or `tool:<TtcToolMark>`: the room's drawn mark.
  final String mark;
  final double hue;
  final int sort;
  final int members;
  final bool joined;
  final bool muted;

  PvCommunityRoom copyWith({bool? joined, bool? muted, int? members}) => PvCommunityRoom(
        id: id,
        title: title,
        blurb: blurb,
        stage: stage,
        mark: mark,
        hue: hue,
        sort: sort,
        members: members ?? this.members,
        joined: joined ?? this.joined,
        muted: muted ?? this.muted,
      );

  static PvCommunityRoom? fromJson(Object? raw) {
    if (raw is! Map || raw['id'] is! String) return null;
    return PvCommunityRoom(
      id: raw['id'] as String,
      title: (raw['title'] as String?) ?? '',
      blurb: (raw['blurb'] as String?) ?? '',
      stage: (raw['stage'] as String?) ?? 'all',
      mark: (raw['mark'] as String?) ?? '',
      hue: (raw['hue'] as num?)?.toDouble() ?? 210,
      sort: (raw['sort'] as num?)?.toInt() ?? 100,
      members: (raw['members'] as num?)?.toInt() ?? 0,
      joined: raw['joined'] == true,
      muted: raw['muted'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'blurb': blurb,
        'stage': stage,
        'mark': mark,
        'hue': hue,
        'sort': sort,
        'members': members,
        'joined': joined,
        'muted': muted,
      };
}

class PvPoll {
  const PvPoll({required this.options, required this.counts, this.mine, this.closesAt});

  final List<String> options;
  final List<int> counts;

  /// Her vote, an index into [options]; null when she has not voted.
  final int? mine;
  final DateTime? closesAt;

  int get total => counts.fold(0, (a, b) => a + b);
  bool get closed => closesAt != null && closesAt!.isBefore(DateTime.now());
  bool get showResults => mine != null || closed;

  PvPoll voted(int i) => PvPoll(
        options: options,
        counts: [for (var k = 0; k < counts.length; k++) counts[k] + (k == i ? 1 : 0)],
        mine: i,
        closesAt: closesAt,
      );

  static PvPoll? fromJson(Object? raw) {
    if (raw is! Map || raw['options'] is! List) return null;
    final opts = [for (final o in raw['options'] as List) o.toString()];
    final counts = [for (final c in (raw['counts'] as List?) ?? const []) (c as num).toInt()];
    while (counts.length < opts.length) {
      counts.add(0);
    }
    return PvPoll(
      options: opts,
      counts: counts,
      mine: (raw['mine'] as num?)?.toInt(),
      closesAt: DateTime.tryParse('${raw['closes_at'] ?? ''}'),
    );
  }

  Map<String, dynamic> toJson() => {
        'options': options,
        'counts': counts,
        'mine': mine,
        'closes_at': closesAt?.toIso8601String(),
      };
}

/// A photo on a post: its storage path, and whether a moderator has seen it.
/// [localPath] is set only on her own just-posted photos, so she sees them
/// at once from the phone while the server still says "pending".
class PvCommunityMedia {
  const PvCommunityMedia({required this.path, this.status = 'approved', this.localPath});
  final String path;
  final String status;
  final String? localPath;
  bool get pending => status == 'pending';

  static PvCommunityMedia? fromJson(Object? raw) {
    if (raw is! Map || raw['path'] is! String) return null;
    return PvCommunityMedia(
      path: raw['path'] as String,
      status: (raw['status'] as String?) ?? 'approved',
      localPath: raw['local'] as String?,
    );
  }

  Map<String, dynamic> toJson() =>
      {'path': path, 'status': status, if (localPath != null) 'local': localPath};
}

class PvCommunityPost {
  const PvCommunityPost({
    required this.id,
    required this.roomId,
    required this.roomTitle,
    required this.author,
    required this.title,
    required this.createdAt,
    this.roomMark = '',
    this.roomHue = 210,
    this.body = '',
    this.poll,
    this.media = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.liked = false,
    this.status = 'live',
    this.sending = false,
  });

  final String id;
  final String roomId;
  final String roomTitle;
  final String roomMark;
  final double roomHue;
  final PvCommunityAuthor author;
  final String title;
  final String body;
  final PvPoll? poll;
  final List<PvCommunityMedia> media;
  final int likeCount;
  final int commentCount;
  final bool liked;

  /// 'live' for everyone; her own post may also be 'held' or 'hidden'.
  final String status;

  /// Written on the phone, not yet accepted by the server (offline queue).
  final bool sending;
  final DateTime createdAt;

  bool get waitingForReview => status == 'held' || status == 'hidden';

  PvCommunityPost copyWith({
    bool? liked,
    int? likeCount,
    int? commentCount,
    PvPoll? poll,
    String? status,
    bool? sending,
    List<PvCommunityMedia>? media,
  }) =>
      PvCommunityPost(
        id: id,
        roomId: roomId,
        roomTitle: roomTitle,
        roomMark: roomMark,
        roomHue: roomHue,
        author: author,
        title: title,
        body: body,
        poll: poll ?? this.poll,
        media: media ?? this.media,
        likeCount: likeCount ?? this.likeCount,
        commentCount: commentCount ?? this.commentCount,
        liked: liked ?? this.liked,
        status: status ?? this.status,
        sending: sending ?? this.sending,
        createdAt: createdAt,
      );

  static PvCommunityPost? fromJson(Object? raw) {
    if (raw is! Map || raw['id'] is! String) return null;
    return PvCommunityPost(
      id: raw['id'] as String,
      roomId: (raw['room_id'] as String?) ?? '',
      roomTitle: (raw['room_title'] as String?) ?? '',
      roomMark: (raw['room_mark'] as String?) ?? '',
      roomHue: (raw['room_hue'] as num?)?.toDouble() ?? 210,
      author: PvCommunityAuthor.fromJson(raw['author']),
      title: (raw['title'] as String?) ?? '',
      body: (raw['body'] as String?) ?? '',
      poll: PvPoll.fromJson(raw['poll']),
      media: [
        for (final m in (raw['media'] as List?) ?? const [])
          ?PvCommunityMedia.fromJson(m),
      ],
      likeCount: (raw['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (raw['comment_count'] as num?)?.toInt() ?? 0,
      liked: raw['liked'] == true,
      status: (raw['status'] as String?) ?? 'live',
      sending: raw['sending'] == true,
      createdAt: DateTime.tryParse('${raw['created_at'] ?? ''}')?.toLocal() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'room_id': roomId,
        'room_title': roomTitle,
        'room_mark': roomMark,
        'room_hue': roomHue,
        'author': author.toJson(),
        'title': title,
        'body': body,
        'poll': poll?.toJson(),
        'media': [for (final m in media) m.toJson()],
        'like_count': likeCount,
        'comment_count': commentCount,
        'liked': liked,
        'status': status,
        'sending': sending,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}

class PvCommunityComment {
  const PvCommunityComment({
    required this.id,
    required this.postId,
    required this.author,
    required this.body,
    required this.createdAt,
    this.parentId,
    this.likeCount = 0,
    this.liked = false,
    this.status = 'live',
    this.isOp = false,
    this.sending = false,
  });

  final String id;
  final String postId;
  final String? parentId;
  final PvCommunityAuthor author;
  final String body;
  final int likeCount;
  final bool liked;
  final String status;

  /// Written by the post's author, under the same face.
  final bool isOp;
  final bool sending;
  final DateTime createdAt;

  PvCommunityComment copyWith({bool? liked, int? likeCount, String? status, bool? sending}) =>
      PvCommunityComment(
        id: id,
        postId: postId,
        parentId: parentId,
        author: author,
        body: body,
        likeCount: likeCount ?? this.likeCount,
        liked: liked ?? this.liked,
        status: status ?? this.status,
        isOp: isOp,
        sending: sending ?? this.sending,
        createdAt: createdAt,
      );

  static PvCommunityComment? fromJson(Object? raw) {
    if (raw is! Map || raw['id'] is! String) return null;
    return PvCommunityComment(
      id: raw['id'] as String,
      postId: (raw['post_id'] as String?) ?? '',
      parentId: raw['parent_id'] as String?,
      author: PvCommunityAuthor.fromJson(raw['author']),
      body: (raw['body'] as String?) ?? '',
      likeCount: (raw['like_count'] as num?)?.toInt() ?? 0,
      liked: raw['liked'] == true,
      status: (raw['status'] as String?) ?? 'live',
      isOp: raw['is_op'] == true,
      sending: raw['sending'] == true,
      createdAt: DateTime.tryParse('${raw['created_at'] ?? ''}')?.toLocal() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': postId,
        'parent_id': parentId,
        'author': author.toJson(),
        'body': body,
        'like_count': likeCount,
        'liked': liked,
        'status': status,
        'is_op': isOp,
        'sending': sending,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}

/// One line in "Replies to you".
class PvCommunityActivity {
  const PvCommunityActivity({
    required this.commentId,
    required this.postId,
    required this.postTitle,
    required this.author,
    required this.body,
    required this.createdAt,
    this.toComment = false,
    this.unread = false,
  });

  final String commentId;
  final String postId;
  final String postTitle;
  final PvCommunityAuthor author;
  final String body;
  final bool toComment;
  final bool unread;
  final DateTime createdAt;

  static PvCommunityActivity? fromJson(Object? raw) {
    if (raw is! Map || raw['comment_id'] is! String) return null;
    return PvCommunityActivity(
      commentId: raw['comment_id'] as String,
      postId: (raw['post_id'] as String?) ?? '',
      postTitle: (raw['post_title'] as String?) ?? '',
      author: PvCommunityAuthor.fromJson(raw['author']),
      body: (raw['body'] as String?) ?? '',
      toComment: raw['to'] == 'comment',
      unread: raw['unread'] == true,
      createdAt: DateTime.tryParse('${raw['created_at'] ?? ''}')?.toLocal() ?? DateTime.now(),
    );
  }
}

/// Her standing in the community, from `community_me()`.
class PvCommunityMe {
  const PvCommunityMe({
    this.signedIn = false,
    this.joined = false,
    this.pseudonym,
    this.seed = 0,
    this.firstName,
    this.canRenameAt,
    this.mutedUntil,
    this.banned = false,
    this.isMod = false,
    this.unread = 0,
  });

  final bool signedIn;

  /// Accepted the house rules and has a community name.
  final bool joined;
  final String? pseudonym;
  final int seed;
  final String? firstName;
  final DateTime? canRenameAt;
  final DateTime? mutedUntil;
  final bool banned;
  final bool isMod;
  final int unread;

  static PvCommunityMe fromJson(Object? raw) {
    if (raw is! Map) return const PvCommunityMe();
    return PvCommunityMe(
      signedIn: raw['signed_in'] == true,
      joined: raw['joined'] == true,
      pseudonym: raw['pseudonym'] as String?,
      seed: (raw['seed'] as num?)?.toInt() ?? 0,
      firstName: raw['first_name'] as String?,
      canRenameAt: DateTime.tryParse('${raw['can_rename_at'] ?? ''}')?.toLocal(),
      mutedUntil: DateTime.tryParse('${raw['muted_until'] ?? ''}')?.toLocal(),
      banned: raw['banned'] == true,
      isMod: raw['is_mod'] == true,
      unread: (raw['unread'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'signed_in': signedIn,
        'joined': joined,
        'pseudonym': pseudonym,
        'seed': seed,
        'first_name': firstName,
        'can_rename_at': canRenameAt?.toUtc().toIso8601String(),
        'muted_until': mutedUntil?.toUtc().toIso8601String(),
        'banned': banned,
        'is_mod': isMod,
        'unread': unread,
      };
}

/// What happened to something she wrote. The server's answer, in the app's
/// terms, so every screen phrases the same outcome the same way.
enum PvCommunityOutcome {
  live,
  held,
  queued, // could not reach the server; kept on the phone and retried
  signedOut,
  notJoined,
  muted,
  banned,
  rate,
  noName,
  gone,
  invalid,
}

PvCommunityOutcome pvOutcomeFrom(Object? res) {
  if (res is! Map) return PvCommunityOutcome.invalid;
  if (res['ok'] == true) {
    return res['status'] == 'held' ? PvCommunityOutcome.held : PvCommunityOutcome.live;
  }
  return switch (res['reason']) {
    'signed_out' => PvCommunityOutcome.signedOut,
    'not_joined' => PvCommunityOutcome.notJoined,
    'muted' => PvCommunityOutcome.muted,
    'banned' => PvCommunityOutcome.banned,
    'rate' => PvCommunityOutcome.rate,
    'no_name' => PvCommunityOutcome.noName,
    'gone' || 'no_room' => PvCommunityOutcome.gone,
    _ => PvCommunityOutcome.invalid,
  };
}
