// =============================================================================
//  ReferralAnalytics — the growth funnel
// -----------------------------------------------------------------------------
//  Invite sent -> link opened -> code redeemed -> signed up -> qualified ->
//  reward granted. Written into the EXISTING profile_events table (0028),
//  tagged surface='referral', exactly as the Memories funnel is - one analytics
//  table, one identity story, no new vendor.
//
//  Anonymous by inheritance: install_id + session_id, no user_id. Which means
//  the referral CODE is never sent either - it identifies a person. The funnel
//  answers "how many got this far", which is the only question worth asking of
//  it; per-parent attribution lives server-side in referral_invites, where it
//  is protected by RLS.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../services/profile_analytics.dart';
import '../services/remote/supabase_repo.dart';

enum ReferralEvent {
  opened,
  shared,
  linkOpened,
  codeEntered,
  codeAccepted,
  codeRejected,
  qualified,
  rewardGranted,
  birthClubJoined,
}

abstract class ReferralAnalyticsSink {
  void record(ReferralEvent event, {String? detail});
}

class DebugReferralSink implements ReferralAnalyticsSink {
  const DebugReferralSink();
  @override
  void record(ReferralEvent event, {String? detail}) {
    if (kDebugMode) debugPrint('[referral] ${event.name} ${detail ?? ''}');
  }
}

/// Writes to profile_events (0028), surface='referral'.
class SupabaseReferralSink implements ReferralAnalyticsSink {
  const SupabaseReferralSink();

  @override
  void record(ReferralEvent event, {String? detail}) {
    final ids = ProfileAnalytics.instance;
    SupabaseRepo.fireEvent('profile_events', {
      'install_id': ids.installId,
      'session_id': ids.sessionId,
      'event': 'referral${event.name[0].toUpperCase()}${event.name.substring(1)}',
      // A bounded label only - never the code, which identifies a person.
      'value': detail,
      'surface': 'referral',
      'at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}

class ReferralAnalytics {
  ReferralAnalytics._();

  static ReferralAnalyticsSink _sink = const DebugReferralSink();
  static void setSink(ReferralAnalyticsSink sink) => _sink = sink;

  /// Fire-and-forget, and it can never throw: analytics must not be able to
  /// break a parent inviting a friend.
  static void _fire(ReferralEvent e, {String? detail}) {
    try {
      _sink.record(e, detail: detail);
    } catch (_) {/* swallowed on purpose */}
  }

  static void opened() => _fire(ReferralEvent.opened);
  static void shared(String channel) =>
      _fire(ReferralEvent.shared, detail: channel);
  static void linkOpened() => _fire(ReferralEvent.linkOpened);
  static void codeEntered() => _fire(ReferralEvent.codeEntered);
  static void codeAccepted() => _fire(ReferralEvent.codeAccepted);

  /// [reason] is one of our own fixed messages, never free text from a parent.
  static void codeRejected(String reason) =>
      _fire(ReferralEvent.codeRejected, detail: reason);
  static void qualified() => _fire(ReferralEvent.qualified);
  static void rewardGranted(String kind) =>
      _fire(ReferralEvent.rewardGranted, detail: kind);
  static void birthClubJoined() => _fire(ReferralEvent.birthClubJoined);
}
