// The community's shapes, exactly as the server's functions return them
// (supabase/migrations/0121_community.sql, then 0137_community_phase2.sql).
// Plain classes, no codegen.
//
// ⚠️ THERE IS NO USER ID ANYWHERE IN HERE, BY DESIGN. The server never sends
// one (anonymity is a column problem — see the 0121 header), so nothing on
// the phone can leak it. An author is a label, a face (community name or
// first name), a seed for the drawn avatar, and `isMine`.

/// A verified expert, as the badge names them: the profile's name and
/// category, from the server's expert register (route A + published), never
/// from anything a member typed.
class PvCommunityExpert {
  const PvCommunityExpert({required this.name, this.category = ''});
  final String name;
  final String category;

  static PvCommunityExpert? fromJson(Object? raw) {
    if (raw is! Map || raw['name'] is! String) return null;
    return PvCommunityExpert(name: raw['name'] as String, category: (raw['category'] as String?) ?? '');
  }

  Map<String, dynamic> toJson() => {'name': name, 'category': category};
}

/// One face of a member, as the app may show it.
class PvCommunityAuthor {
  const PvCommunityAuthor({
    required this.label,
    required this.anon,
    this.seed = 0,
    this.team = false,
    this.moderator = false,
    this.expert,
    this.isMine = false,
  });

  final String label;

  /// True on the community-name face; false on her first name.
  final bool anon;

  /// Picks the drawn face mark and its tint (0..63).
  final int seed;

  /// "ParentVeda team": the house speaking (a prompt, a notice). Never a
  /// person's name. (Phase 1 used this flag for a moderator's named post;
  /// since 0137 that is [moderator].)
  final bool team;

  /// A moderator posting under her first name: a "Moderator" chip (D2).
  final bool moderator;

  /// Set on a verified expert's NAMED posts and replies only: the seal.
  final PvCommunityExpert? expert;
  final bool isMine;

  static PvCommunityAuthor fromJson(Object? raw) {
    final m = raw is Map ? raw : const {};
    return PvCommunityAuthor(
      label: (m['label'] as String?)?.trim().isNotEmpty == true ? m['label'] as String : 'A member',
      anon: m['anon'] != false,
      seed: (m['seed'] as num?)?.toInt() ?? 0,
      team: m['team'] == true,
      moderator: m['moderator'] == true,
      expert: PvCommunityExpert.fromJson(m['expert']),
      isMine: m['is_mine'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'anon': anon,
        'seed': seed,
        'team': team,
        'moderator': moderator,
        'expert': expert?.toJson(),
        'is_mine': isMine,
      };
}

/// What a post in a course room is about: a lesson (an app id) or a
/// session (a server id). The app turns the id into "Lesson 2".
class PvPostAbout {
  const PvPostAbout({required this.kind, required this.id});
  final String kind; // 'lesson' | 'session'
  final String id;

  bool get isLesson => kind == 'lesson';

  static PvPostAbout? fromJson(Object? raw) {
    if (raw is! Map || raw['kind'] is! String || raw['id'] is! String) return null;
    return PvPostAbout(kind: raw['kind'] as String, id: raw['id'] as String);
  }

  Map<String, dynamic> toJson() => {'kind': kind, 'id': id};

  @override
  bool operator ==(Object other) => other is PvPostAbout && other.kind == kind && other.id == id;
  @override
  int get hashCode => Object.hash(kind, id);
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
    this.kind = 'room',
    this.programmeId,
    this.runId,
    this.access = true,
    this.unread = 0,
    this.via,
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

  /// 'room' | 'birth_club' | 'offering'.
  final String kind;

  /// A course room's programme and run (the discussion is per RUN, L.3).
  final String? programmeId;
  final String? runId;

  /// May she enter? Always true for an open room.
  final bool access;

  /// Posts since she last opened it (a high-water mark on the server).
  final int unread;

  /// 'auto' = the app put her there; 'self' = her own choice.
  final String? via;

  bool get isOffering => kind == 'offering';
  bool get isClub => kind == 'birth_club';

  PvCommunityRoom copyWith({bool? joined, bool? muted, int? members, int? unread}) => PvCommunityRoom(
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
        kind: kind,
        programmeId: programmeId,
        runId: runId,
        access: access,
        unread: unread ?? this.unread,
        via: via,
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
      kind: (raw['kind'] as String?) ?? 'room',
      programmeId: raw['programme_id'] as String?,
      runId: raw['run_id'] as String?,
      access: raw['access'] != false,
      unread: (raw['unread'] as num?)?.toInt() ?? 0,
      via: raw['via'] as String?,
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
        'kind': kind,
        'programme_id': programmeId,
        'run_id': runId,
        'access': access,
        'unread': unread,
        'via': via,
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
    this.roomKind = 'room',
    this.hostRole,
    this.hashtags = const [],
    this.editedAt,
    this.pinned = false,
    this.about,
    this.movedFrom,
    this.expertAsked = false,
    this.expertAnswered = false,
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

  /// The room's kind ('offering' for a course discussion).
  final String roomKind;

  /// In a course room, the author's role there ('host' | 'co_host' |
  /// 'moderator'), on named posts by a verified host only.
  final String? hostRole;
  final List<String> hashtags;
  final DateTime? editedAt;

  /// Pinned to the top of its room right now.
  final bool pinned;
  final PvPostAbout? about;

  /// On a timetable notice the server wrote: when the session USED to be.
  final DateTime? movedFrom;

  /// She asked an expert to look; an expert has answered.
  final bool expertAsked;
  final bool expertAnswered;

  bool get waitingForReview => status == 'held' || status == 'hidden';

  PvCommunityPost copyWith({
    bool? liked,
    int? likeCount,
    int? commentCount,
    PvPoll? poll,
    String? status,
    bool? sending,
    List<PvCommunityMedia>? media,
    bool? pinned,
    bool? expertAsked,
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
        roomKind: roomKind,
        hostRole: hostRole,
        hashtags: hashtags,
        editedAt: editedAt,
        pinned: pinned ?? this.pinned,
        about: about,
        movedFrom: movedFrom,
        expertAsked: expertAsked ?? this.expertAsked,
        expertAnswered: expertAnswered,
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
      roomKind: (raw['room_kind'] as String?) ?? 'room',
      hostRole: raw['host_role'] as String?,
      hashtags: [for (final t in (raw['hashtags'] as List?) ?? const []) '$t'],
      editedAt: DateTime.tryParse('${raw['edited_at'] ?? ''}')?.toLocal(),
      pinned: raw['pinned'] == true,
      about: PvPostAbout.fromJson(raw['about']),
      movedFrom: DateTime.tryParse('${raw['moved_from'] ?? ''}')?.toLocal(),
      expertAsked: raw['expert_asked'] == true,
      expertAnswered: raw['expert_answered'] == true,
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
        'room_kind': roomKind,
        'host_role': hostRole,
        'hashtags': hashtags,
        'edited_at': editedAt?.toUtc().toIso8601String(),
        'pinned': pinned,
        'about': about?.toJson(),
        'moved_from': movedFrom?.toUtc().toIso8601String(),
        'expert_asked': expertAsked,
        'expert_answered': expertAnswered,
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
    this.hostRole,
    this.endorsements = const [],
    this.endorsed = false,
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
  final String? hostRole;

  /// "Found helpful by Dr X, Paediatrician".
  final List<PvCommunityExpert> endorsements;

  /// She (an expert) has endorsed this reply.
  final bool endorsed;

  PvCommunityComment copyWith({
    bool? liked,
    int? likeCount,
    String? status,
    bool? sending,
    List<PvCommunityExpert>? endorsements,
    bool? endorsed,
  }) =>
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
        hostRole: hostRole,
        endorsements: endorsements ?? this.endorsements,
        endorsed: endorsed ?? this.endorsed,
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
      hostRole: raw['host_role'] as String?,
      endorsements: [
        for (final e in (raw['endorsements'] as List?) ?? const [])
          ?PvCommunityExpert.fromJson(e),
      ],
      endorsed: raw['endorsed'] == true,
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
        'host_role': hostRole,
        'endorsements': [for (final e in endorsements) e.toJson()],
        'endorsed': endorsed,
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
    this.expert,
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

  /// Set when this account is a verified expert (route A + published).
  final PvCommunityExpert? expert;
  bool get isExpert => expert != null;

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
      expert: PvCommunityExpert.fromJson(raw['expert']),
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
        'expert': expert?.toJson(),
      };
}

/// The answer to "may she enter this course's discussion?"
/// (`community_offering_room`). The server picks her run.
class PvOfferingRoom {
  const PvOfferingRoom({
    required this.room,
    required this.access,
    this.reason,
    this.isHost = false,
    this.isMod = false,
    this.posts = 0,
  });

  final PvCommunityRoom room;
  final bool access;

  /// Why not: 'book' (no seat yet) or 'refunded'.
  final String? reason;
  final bool isHost;
  final bool isMod;

  /// Live posts in the room.
  final int posts;

  /// Hosts and moderators may pin; only moderators post as the team.
  bool get canPin => isHost || isMod;

  static PvOfferingRoom? fromJson(Object? raw) {
    if (raw is! Map || raw['ok'] != true) return null;
    final room = PvCommunityRoom.fromJson(raw['room']);
    if (room == null) return null;
    return PvOfferingRoom(
      room: room,
      access: raw['access'] == true,
      reason: raw['reason'] as String?,
      isHost: raw['is_host'] == true,
      isMod: raw['is_mod'] == true,
      posts: (raw['posts'] as num?)?.toInt() ?? 0,
    );
  }
}

/// One question a member asked an expert to look at (the doctor's queue).
class PvExpertRequest {
  const PvExpertRequest({required this.post, required this.askedAt, this.claimedByMe = false, this.claimedBy});
  final PvCommunityPost post;
  final DateTime askedAt;
  final bool claimedByMe;

  /// Another expert who is on it (their profile name), or null.
  final String? claimedBy;

  PvExpertRequest copyWith({bool? claimedByMe}) =>
      PvExpertRequest(post: post, askedAt: askedAt, claimedByMe: claimedByMe ?? this.claimedByMe, claimedBy: claimedBy);

  static PvExpertRequest? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final p = PvCommunityPost.fromJson(raw['post']);
    if (p == null) return null;
    return PvExpertRequest(
      post: p,
      askedAt: DateTime.tryParse('${raw['asked_at'] ?? ''}')?.toLocal() ?? p.createdAt,
      claimedByMe: raw['claimed_by_me'] == true,
      claimedBy: raw['claimed_by'] as String?,
    );
  }
}

/// One run the doctor hosts, from `expert_my_offerings` (LA-21).
class PvExpertOffering {
  const PvExpertOffering({
    required this.programmeId,
    required this.runId,
    required this.title,
    this.runLabel = '',
    this.kind = '',
    this.role = 'host',
    this.seatsBooked = 0,
    this.capacity,
    this.nextSession,
    this.roomId,
    this.unread = 0,
  });

  final String programmeId;
  final String runId;
  final String title;
  final String runLabel;
  final String kind;
  final String role;
  final int seatsBooked;
  final int? capacity;
  final DateTime? nextSession;
  final String? roomId;
  final int unread;

  static PvExpertOffering? fromJson(Object? raw) {
    if (raw is! Map || raw['programme_id'] is! String || raw['run_id'] is! String) return null;
    return PvExpertOffering(
      programmeId: raw['programme_id'] as String,
      runId: raw['run_id'] as String,
      title: (raw['title'] as String?) ?? '',
      runLabel: (raw['run_label'] as String?) ?? '',
      kind: (raw['kind'] as String?) ?? '',
      role: (raw['role'] as String?) ?? 'host',
      seatsBooked: (raw['seats_booked'] as num?)?.toInt() ?? 0,
      capacity: (raw['capacity'] as num?)?.toInt(),
      nextSession: DateTime.tryParse('${raw['next_session'] ?? ''}')?.toLocal(),
      roomId: raw['room_id'] as String?,
      unread: (raw['unread'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A host's role in words, for the chip beside their name.
String pvHostRoleLabel(String? role) => switch (role) {
      'host' => 'Lead host',
      'co_host' => 'Co-host',
      'moderator' => 'Course moderator',
      null || '' => '',
      _ => 'Guest expert',
    };

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
  noAccess, // (0137) a course room she holds no seat in
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
    'no_access' => PvCommunityOutcome.noAccess,
    _ => PvCommunityOutcome.invalid,
  };
}
