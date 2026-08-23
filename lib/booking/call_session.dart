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

/// Which side of the call this participant is on.
///
/// [unknown] is a real, expected state, not a bug: a group session carries no
/// role, and so does a 1:1 call joined through the pre-0076 fallback path. The
/// UI must degrade to "no role shown" rather than guess — a wrong badge on a
/// clinician is worse than no badge.
enum CallRole { parent, expert, unknown }

extension CallRoleX on CallRole {
  bool get isExpert => this == CallRole.expert;
  bool get isParent => this == CallRole.parent;

  /// The word shown beside a name on a tile. Empty for [unknown], which the
  /// chip then omits entirely.
  String get label => switch (this) {
        CallRole.expert => 'Doctor',
        CallRole.parent => 'Parent',
        CallRole.unknown => '',
      };

  static CallRole parse(Object? raw) => switch (raw?.toString()) {
        'expert' => CallRole.expert,
        'parent' => CallRole.parent,
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
    this.role = CallRole.unknown,
    this.capacity = 0,
    this.startsUtc,
    this.endsUtc,
    this.counterpart = '',
  });

  final String url;
  final String token;
  final String room;

  /// This device's own role, decided by the server.
  final CallRole role;

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
        role: CallRoleX.parse(d?['role']),
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
