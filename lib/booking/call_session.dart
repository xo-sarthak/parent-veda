// =============================================================================
//  CallSession — who is joining, as whom, and for how long
// -----------------------------------------------------------------------------
//  THE HOLE THIS FILLS. Until now the app worked out "am I the doctor or the
//  parent?" from which screen happened to push the call:
//
//      CallScreen(bookingId: b.id, title: b.title, waitingFor: who)   // parent
//      CallScreen(..., displayName: _myName(), waitingFor: patient.name) // doctor
//
//  That is not an identity, it is a coincidence of the call site. Nothing in
//  the session carried a role — the LiveKit token had a user id and a display
//  name and nothing else, so doctor and parent received byte-identical
//  credentials. The call screen therefore could not label a tile "Dr.", could
//  not tell you which side of the call you were on, and could not order or
//  restrict anything by role. Two devices side by side genuinely looked the
//  same, which is exactly what a user reported.
//
//  The role now comes from `join_context_for_booking` (0076), through the
//  livekit-token edge function, which stamps it into the token as `metadata`
//  AND echoes it in the response. Both matter and they are not redundant:
//
//    * the ECHO lets this app lay out its own screen before the room connects,
//    * the METADATA is how the OTHER participant learns our role, because
//      LiveKit hands each participant's metadata to everyone in the room.
//
//  Neither is client-asserted. A device cannot claim to be a doctor.
// -----------------------------------------------------------------------------
//  ON REFUSALS: they are not all the same, and the app must stop pretending
//  they are. "Your consultation opens at 4:50 PM", "this session is not
//  yours", and "you are offline" want three different sentences and three
//  different buttons. Collapsing them into one string is the failure written
//  up at length in 0075's header, and it had already cost an evening.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../services/remote/supabase_repo.dart';
import 'booking_models.dart';

/// Which side of the call this participant is on.
///
/// [unknown] is a real, expected state, not a bug: a group session carries no
/// role, and so does a 1:1 call joined through the pre-0076 fallback path. The
/// UI must degrade to "no role shown" rather than guess — a wrong badge on a
/// clinician is worse than no badge.
/// Four values, not two, and the fourth pair is what makes a class a class.
///
/// A consult is a CONVERSATION — two equal parties, both publishing. A class
/// is a BROADCAST — one voice and an audience. The role therefore carries both
/// facts at once, who you are and which product you are in, so a screen can
/// switch on it directly instead of pairing a role with a capacity check at
/// every call site.
///
///     capacity == 1   parent   | expert
///     capacity  > 1   attendee | host
enum CallRole { parent, expert, attendee, host, unknown }

extension CallRoleX on CallRole {
  bool get isExpert => this == CallRole.expert;
  bool get isParent => this == CallRole.parent;
  bool get isHost => this == CallRole.host;
  bool get isAttendee => this == CallRole.attendee;

  /// Whoever is running the room — the doctor in a consult, the teacher in a
  /// class. What the layout gives the big tile to.
  bool get leadsTheRoom => this == CallRole.expert || this == CallRole.host;

  /// The word shown beside a name on a tile. Empty for [unknown], which the
  /// chip then omits entirely.
  ///
  /// 'Attendee' is deliberately absent. In a class of forty, labelling every
  /// tile "Attendee" says nothing anyone needed to know and turns the one
  /// label that matters — Host — into noise.
  String get label => switch (this) {
        CallRole.expert => 'Doctor',
        CallRole.parent => 'Parent',
        CallRole.host => 'Host',
        CallRole.attendee => '',
        CallRole.unknown => '',
      };

  static CallRole parse(Object? raw) => switch (raw?.toString()) {
        'expert' => CallRole.expert,
        'parent' => CallRole.parent,
        'host' => CallRole.host,
        'attendee' => CallRole.attendee,
        _ => CallRole.unknown,
      };
}

/// Why a join was refused. Each one is a different sentence to the user, and
/// only [offline] and [serverError] are worth a Retry button.
enum CallRefusal {
  /// The request never reached the server.
  offline,

  /// Signed out, or the session expired underneath us.
  notSignedIn,

  /// The booking does not exist, or is not this caller's. Deliberately one
  /// case: the database answers null for both so ids cannot be probed.
  notYours,

  /// A consult, before its window opens. Carries [CallJoinFailure.opensUtc].
  tooEarly,

  /// A consult, after its window closed.
  ended,

  /// LiveKit keys missing, the function down, a migration unapplied.
  serverError,
}

@immutable
class CallJoinFailure {
  const CallJoinFailure(this.kind, {this.opensUtc, this.startsUtc, this.detail});

  final CallRefusal kind;
  final DateTime? opensUtc;
  final DateTime? startsUtc;
  final String? detail;

  /// True where trying the same thing again could plausibly work.
  bool get retryable =>
      kind == CallRefusal.offline || kind == CallRefusal.serverError;
}

/// Everything needed to open a room, and to render it correctly.
@immutable
class CallJoin {
  const CallJoin({
    required this.url,
    required this.token,
    required this.room,
    this.slotId = '',
    this.role = CallRole.unknown,
    this.canPublish = true,
    this.capacity = 0,
    this.startsUtc,
    this.endsUtc,
    this.counterpart = '',
  });

  final String url;
  final String token;
  final String room;

  /// The slot this room belongs to. What moderation is addressed to, because a
  /// host has no booking to name.
  final String slotId;

  /// This device's own role, decided by the server.
  final CallRole role;

  /// May this device turn its camera and microphone on at all?
  ///
  /// False for an attendee at a masterclass. Note this is a MIRROR of what the
  /// token already enforces, not the enforcement itself — the media server
  /// honours the token and a modified client cannot argue with it. It exists
  /// so the screen can lay itself out correctly before connecting, and so the
  /// controls that would not work are not offered.
  ///
  /// Defaults to true, which is the pre-0079 shape: an old server that does
  /// not send the field gets the behaviour it has always had.
  final bool canPublish;

  /// Seats on the slot. **This is the consult-vs-class switch**, and it is the
  /// same number the server uses for the same purpose (`book_slot`, 0029): a
  /// one-to-one consultation has exactly one seat.
  ///
  /// 0 means "the server did not say" — the pre-0076 fallback — and is treated
  /// as NOT a consult, so an unknown session keeps the old behaviour rather
  /// than acquiring new rules it was never tested under.
  final int capacity;

  final DateTime? startsUtc;
  final DateTime? endsUtc;

  /// The other side's name, when the server knew it. Usually empty: both apps
  /// already hold a better local answer.
  final String counterpart;

  /// The guard that keeps this whole pass away from group calls.
  ///
  /// Every new behaviour — the join window, the pre-join room, role chips, the
  /// both-present clock — is gated on this. A class takes the code path it
  /// took before any of this existed.
  bool get isConsult => capacity == 1;

  /// A masterclass or a cohort — one voice and an audience.
  bool get isGroup => capacity > 1;

  /// How long the session was sold for, when known.
  Duration? get scheduledLength => (startsUtc != null && endsUtc != null)
      ? endsUtc!.difference(startsUtc!)
      : null;
}

/// Ask the server for a token, and get back either a join or a reason.
class CallSession {
  CallSession._();

  static Future<(CallJoin?, CallJoinFailure?)> fetchJoin({
    required String bookingId,
    String? displayName,
  }) async {
    if (!SupabaseRepo.isLoggedIn) {
      return (null, const CallJoinFailure(CallRefusal.notSignedIn));
    }

    final res = await SupabaseRepo.invokeEdgeResult('livekit-token', {
      'bookingId': bookingId,
      if (displayName != null && displayName.trim().isNotEmpty)
        'name': displayName,
    });

    return _readJoin(res);
  }

  /// The HOST's way into their own class.
  ///
  /// A host holds no booking — they did not buy a seat at their own
  /// masterclass — so every booking-based route was closed to them. Before
  /// this, a masterclass could be bought and joined and simply **could not be
  /// taught**; the only way in would have been handing the teacher one of
  /// their attendees' booking ids.
  ///
  /// The slot descriptor travels with the request because the slot row may not
  /// exist yet: `booking_slots` self-seeds on first booking (0029), so a class
  /// nobody has booked has no row to point a room at. `open_session_room`
  /// (0079) creates it — after checking, against `my_expert_ids()`, that the
  /// caller may host it. A caller can only ever open a room for an expert they
  /// already are.
  static Future<(CallJoin?, CallJoinFailure?)> fetchHostJoin({
    required Slot slot,
    String? displayName,
  }) async {
    if (!SupabaseRepo.isLoggedIn) {
      return (null, const CallJoinFailure(CallRefusal.notSignedIn));
    }

    final res = await SupabaseRepo.invokeEdgeResult('livekit-token', {
      'slotId': slot.id,
      'offeringId': slot.offeringId,
      'expertId': slot.expertId,
      'startsUtc': slot.startsUtc.toUtc().toIso8601String(),
      'durationMin': slot.durationMin,
      'capacity': slot.capacity,
      if (displayName != null && displayName.trim().isNotEmpty)
        'name': displayName,
    });

    return _readJoin(res);
  }

  /// Turn an edge-function answer into a join, or into the REASON it is not
  /// one. Shared by the booking route and the host route: they differ entirely
  /// in how authorisation is decided and not at all in how the answer reads.
  static (CallJoin?, CallJoinFailure?) _readJoin(EdgeResult res) {
    if (res.offline) {
      return (null, const CallJoinFailure(CallRefusal.offline));
    }

    if (!res.ok) {
      final reason = res.data?['reason']?.toString();
      final kind = switch ((res.status, reason)) {
        (_, 'too_early') => CallRefusal.tooEarly,
        (_, 'ended') => CallRefusal.ended,
        (401, _) => CallRefusal.notSignedIn,
        (403, _) => CallRefusal.notYours,
        _ => CallRefusal.serverError,
      };
      return (
        null,
        CallJoinFailure(
          kind,
          opensUtc: _utc(res.data?['opensUtc']),
          startsUtc: _utc(res.data?['startsUtc']),
          detail: res.data?['error']?.toString(),
        )
      );
    }

    final d = res.data;
    final url = d?['url']?.toString();
    final token = d?['token']?.toString();
    if (url == null || url.isEmpty || token == null || token.isEmpty) {
      // A 200 that cannot be joined. Treat it as a server fault rather than a
      // refusal — there is nothing the user did wrong and nothing to explain.
      return (null, const CallJoinFailure(CallRefusal.serverError));
    }

    return (
      CallJoin(
        url: url,
        token: token,
        room: d?['room']?.toString() ?? '',
        slotId: d?['slotId']?.toString() ?? '',
        role: CallRoleX.parse(d?['role']),
        canPublish: d?['canPublish'] != false,
        capacity: (d?['capacity'] as num?)?.toInt() ?? 0,
        startsUtc: _utc(d?['startsUtc']),
        endsUtc: _utc(d?['endsUtc']),
        counterpart: d?['counterpart']?.toString() ?? '',
      ),
      null
    );
  }

  /// Read a participant's role out of the LiveKit metadata the server stamped.
  ///
  /// Defensive on purpose: this parses a string that arrived over the network,
  /// and a malformed one must cost a badge, never the call.
  static CallRole roleFromMetadata(String? metadata) {
    if (metadata == null || metadata.isEmpty) return CallRole.unknown;
    try {
      final m = jsonDecode(metadata);
      if (m is Map) return CallRoleX.parse(m['role']);
    } catch (_) {
      // Not our metadata, or not JSON. No role, no harm.
    }
    return CallRole.unknown;
  }

  static DateTime? _utc(Object? raw) {
    final s = raw?.toString();
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s)?.toUtc();
  }
}

/// The host controls, which only exist because they run on the SERVER.
///
/// A LiveKit client governs its own tracks and nobody else's, so a "mute
/// everyone" button on the host's phone could at best ASK forty clients to
/// mute themselves — ignored by a modified one, unheard by an offline one, and
/// the host would be looking at a muted-looking list while somebody's kitchen
/// carried on being broadcast. That is worse than no button: it is a promise
/// the product cannot keep, in the one moment a teacher needs certainty.
///
/// So every method here is a round trip to `livekit-moderate`, which holds the
/// API secret, asks Postgres one question (`can_moderate_slot`) and then talks
/// to LiveKit's RoomService. Slower than a local toggle, and true.
class CallModeration {
  CallModeration._();

  /// Silence every microphone in the room except the caller's own.
  /// Returns how many tracks were actually muted, or null if it failed.
  static Future<int?> muteAll(String slotId) async {
    final res = await _call(slotId, 'muteAll');
    if (res == null) return null;
    return (res['muted'] as num?)?.toInt() ?? 0;
  }

  /// Let one attendee speak — or take it back.
  ///
  /// Live, with no reconnect. The alternative would be minting a new token and
  /// rejoining, which means dropping someone out of a class in order to let
  /// them speak in it.
  static Future<bool> setCanSpeak(
    String slotId,
    String identity, {
    required bool allow,
  }) async {
    final res = await _call(
      slotId,
      allow ? 'allowSpeak' : 'denySpeak',
      identity: identity,
    );
    return res != null;
  }

  static Future<bool> remove(String slotId, String identity) async =>
      await _call(slotId, 'remove', identity: identity) != null;

  /// End the class for everyone, rather than leaving an audience in a room
  /// with nobody teaching.
  static Future<bool> endRoom(String slotId) async =>
      await _call(slotId, 'endRoom') != null;

  static Future<Map<String, dynamic>?> _call(
    String slotId,
    String action, {
    String? identity,
  }) async {
    final res = await SupabaseRepo.invokeEdgeResult('livekit-moderate', {
      'slotId': slotId,
      'action': action,
      'identity': ?identity,
    });
    if (!res.ok) {
      debugPrint('[moderate] $action -> ${res.status} ${res.reason}');
      return null;
    }
    return res.data ?? const {};
  }
}
