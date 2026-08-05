// =============================================================================
//  ReferralNotifications — telling a parent her invite did something
// -----------------------------------------------------------------------------
//  Three moments the spec asks for, and the reason each earns an interruption:
//
//    FRIEND JOINED   - the single most motivating thing that can happen. She
//                      did a favour and it landed.
//    REWARD UNLOCKED - she is owed something; not saying so is close to
//                      keeping it.
//    CLUB UNLOCK     - a rung on the Birth Club ladder actually opened.
//
//  What is deliberately NOT here: "invite more friends" nagging. The spec lists
//  it as an example, but a pregnancy app that pesters a mother to recruit her
//  friends has stopped being a pregnancy app. If she wants to invite more, the
//  screen is one tap from her profile.
//
//  Ids are derived from the thing being announced, so a re-sync re-notifying
//  overwrites rather than stacking - the same rule as the consult reminders.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../services/notification_service.dart';
import '../localization/app_language.dart';

class ReferralNotifications {
  ReferralNotifications._();
  static final ReferralNotifications instance = ReferralNotifications._();

  /// Namespaced away from the consult reminders so the two can never collide.
  static int _id(String seed, int slot) =>
      0x5000000 + ((seed.hashCode & 0x0fffff) * 4 + slot);

  /// A friend finished signing up.
  Future<void> friendJoined({required String inviteId, String? name}) async {
    final who = (name ?? '').trim().isEmpty ? S.now.someFriend : name!.trim();
    await _now(
      id: _id(inviteId, 0),
      title: S.now.friendJoinedTitle(who),
      body: S.now.friendJoinedBody,
    );
  }

  /// Something is now hers to spend.
  Future<void> rewardUnlocked({
    required String rewardId,
    required String label,
  }) async {
    await _now(
      id: _id(rewardId, 1),
      title: S.now.rewardEarnedTitle(label),
      body: S.now.rewardReadyBody,
    );
  }

  /// A Birth Club rung opened.
  Future<void> clubUnlocked({
    required String club,
    required int rung,
    required String what,
  }) async {
    await _now(
      id: _id('$club-$rung', 2),
      title: S.now.unlockedTitle(what),
      body: S.now.birthClubBetter,
    );
  }

  /// Fire in a few seconds rather than instantly: these are triggered during a
  /// sync, and a notification arriving while she is already looking at the
  /// screen that caused it is noise.
  Future<void> _now({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await NotificationService.instance.scheduleOneOff(
        id: id,
        title: title,
        body: body,
        when: DateTime.now().add(const Duration(seconds: 4)),
      );
    } catch (_) {
      if (kDebugMode) debugPrint('[referral] notification failed: $title');
    }
  }
}
