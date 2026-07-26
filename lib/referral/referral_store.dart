// =============================================================================
//  ReferralStore — the parent's own referral state
// -----------------------------------------------------------------------------
//  Local-first like every other store: the Invite Friends screen must open and
//  show a shareable code instantly, offline, on a phone in a lift. The server
//  is caught up separately and is the authority on anything that costs money.
//
//  The split that matters:
//    * CODE + invite list + counts -> local, for the UI.
//    * GRANTING A REWARD           -> server only (0035). This store can ask;
//                                     it can never pay.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../booking/booking_store.dart';
import '../services/remote/supabase_repo.dart';
import 'referral_analytics.dart';
import 'referral_engine.dart';
import 'referral_models.dart';
import 'referral_notifications.dart';

class ReferralStore extends ChangeNotifier {
  ReferralStore._();
  static final ReferralStore instance = ReferralStore._();

  static const _key = 'referral_v1';

  final List<Invite> _invites = [];

  /// Rewards that landed on THIS device for the first time and have not been
  /// celebrated yet. Drained by the UI, so the moment is shown once.
  final List<String> _freshRewards = [];
  String _code = '';
  String _redeemedCode = '';
  int _rewardsEarned = 0;
  bool _loaded = false;

  ReferralConfig config = const ReferralConfig();

  bool get isLoaded => _loaded;

  /// This parent's own shareable code. Derived from their user id so it is
  /// stable, and falls back to a device-local id when signed out so the screen
  /// is never empty during testing.
  String get code => _code;
  String get link => ReferralEngine.linkFor(_code);

  /// The code this parent joined with, if any. Empty means they came organically.
  String get redeemedCode => _redeemedCode;
  bool get hasRedeemed => _redeemedCode.isNotEmpty;

  List<Invite> get invites => List.unmodifiable(_invites);

  int get totalInvites => _invites.length;
  int get friendsJoined => _invites.where((i) => i.status.hasJoined).length;
  int get pendingRewards =>
      _invites.where((i) => i.status == InviteStatus.qualified).length;
  int get rewardsEarned => _rewardsEarned;

  int get sentToday {
    final now = DateTime.now();
    return _invites
        .where((i) =>
            i.sentAt.year == now.year &&
            i.sentAt.month == now.month &&
            i.sentAt.day == now.day)
        .length;
  }

  int get sentThisMonth {
    final now = DateTime.now();
    return _invites
        .where((i) => i.sentAt.year == now.year && i.sentAt.month == now.month)
        .length;
  }

  /// Take the labels of rewards that have not yet been celebrated, clearing
  /// them. Draining rather than reading is what makes it show exactly once.
  List<String> takeFreshRewards() {
    final out = List<String>.from(_freshRewards);
    _freshRewards.clear();
    return out;
  }

  /// Why the parent cannot invite right now, or null.
  String? get invitingProblem => ReferralEngine.invitingProblem(
        sentToday: sentToday,
        sentThisMonth: sentThisMonth,
        rewardsEarned: _rewardsEarned,
        config: config,
      );

  Future<void> init({String? userId}) async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final d = jsonDecode(raw) as Map;
        _code = (d['code'] ?? '').toString();
        _redeemedCode = (d['redeemedCode'] ?? '').toString();
        _rewardsEarned = (d['rewardsEarned'] as num?)?.toInt() ?? 0;
        _invites
          ..clear()
          ..addAll(((d['invites'] as List?) ?? const [])
              .map((e) => Invite.fromMap(e as Map)));
      }
    } catch (_) {/* start empty */}

    // Derive the code if we do not have one yet.
    final uid = userId ?? SupabaseRepo.userId;
    if (_code.isEmpty) {
      _code = ReferralEngine.codeForUser(
          uid ?? 'device-${DateTime.now().microsecondsSinceEpoch}');
      _persist();
    }
    _loaded = true;
    notifyListeners();
  }

  /// Record that the parent shared their code. Deliberately optimistic and
  /// local: we cannot know whether a WhatsApp message was actually sent, and
  /// pretending otherwise would make the funnel lie.
  void recordShare({String channel = 'share_sheet'}) {
    _invites.insert(
      0,
      Invite(
        id: 'inv_${DateTime.now().microsecondsSinceEpoch}',
        code: _code,
        status: InviteStatus.sent,
        sentAt: DateTime.now(),
      ),
    );
    _persist();
    notifyListeners();
  }

  /// Load the live campaign from the server (0036). Falls back to the compiled
  /// default, so a fresh install with no network still shows real terms rather
  /// than an empty screen.
  ///
  /// Read-only by design: the table has no write policy, so the app can never
  /// rewrite the terms of its own reward. Caps here are what the BUSINESS wants;
  /// qualify_referral re-clamps them, because config is not a security boundary.
  Future<void> loadConfig() async {
    try {
      final rows = await SupabaseRepo.selectAll('referral_config');
      final active = rows
          .whereType<Map>()
          .where((r) => r['active'] == true)
          .toList();
      if (active.isEmpty) return;
      final raw = active.first['config'];
      if (raw is! Map) return;
      config = ReferralConfig.fromMap(raw);
      notifyListeners();
    } catch (_) {/* keep the compiled default */}
  }

  /// Claim the code on the server and register this parent's own code so
  /// others can redeem it. Both are no-ops when signed out.
  Future<void> syncToServer() async {
    if (!SupabaseRepo.isLoggedIn || _code.isEmpty) return;
    try {
      await SupabaseRepo.upsertRow(
        'referral_codes',
        {'user_id': SupabaseRepo.userId, 'code': _code},
        onConflict: 'user_id',
      );
    } catch (_) {/* a collision or offline - the code still works locally */}
    await refreshFromServer();
  }

  /// Pull the real invite list and reward count.
  Future<void> refreshFromServer() async {
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      final rows = await SupabaseRepo.selectAll('referral_invites');
      final mine = rows
          .whereType<Map>()
          .where((r) => '${r['inviter_id']}' == SupabaseRepo.userId)
          .toList();
      if (mine.isNotEmpty) {
        // Which friends had NOT joined last time we looked? Compared before the
        // list is replaced, because afterwards there is nothing to compare to -
        // and this is the most motivating notification in the whole feature:
        // she did someone a favour and it landed.
        final joinedBefore = {
          for (final i in _invites)
            if (i.status.hasJoined) i.id
        };
        final fresh = mine.map(_inviteFromRow).toList();
        _invites
          ..clear()
          ..addAll(fresh);
        for (final i in fresh) {
          if (i.status.hasJoined && !joinedBefore.contains(i.id)) {
            ReferralNotifications.instance
                .friendJoined(inviteId: i.id, name: i.friendName);
          }
        }
      }
      final rewards = await SupabaseRepo.selectAll('referral_rewards');
      final mineRewards = rewards
          .whereType<Map>()
          .where((r) => '${r['user_id']}' == SupabaseRepo.userId)
          .toList();
      _rewardsEarned = mineRewards.length;
      _materialise(mineRewards);
      _persist();
      notifyListeners();
    } catch (_) {/* keep the local view */}
  }

  /// Turn server reward ROWS into something the parent can actually spend.
  ///
  /// The server records that a reward is owed; this is what makes it real in
  /// the app. Idempotent by construction: the entitlement id is derived from
  /// the reward row id, so syncing ten times grants once. That is the whole
  /// safety property here - a referral system that mints a credit per sync
  /// gives away unlimited consultations to anyone who pulls to refresh.
  void _materialise(List<Map> rewards) {
    for (final r in rewards) {
      final id = '${r['id']}';
      if (id.isEmpty) continue;
      final kind = (r['kind'] ?? '').toString();
      // Only consultation credits map onto the booking engine today. Premium
      // days and downloads have nowhere to land yet, so they are recorded and
      // deliberately not faked.
      if (kind != RewardKind.consultCredit.name) continue;
      final label = (r['label'] ?? 'Referral reward').toString();
      final before = BookingStore.instance
          .entitlements()
          .where((e) => e.id == 'ent_gift_$id')
          .isNotEmpty;
      BookingStore.instance.grantFloatingCredit(
        sourceId: id,
        title: label,
        credits: (r['value'] as num?)?.toInt() ?? 1,
      );
      if (!before) {
        // FIRST time this reward has landed on this device. Tell her once -
        // celebrating the same credit on every sync would be nagging dressed
        // as delight.
        _freshRewards.add(label);
        ReferralNotifications.instance
            .rewardUnlocked(rewardId: id, label: label);
        ReferralAnalytics.rewardGranted(kind);
      }
    }
  }

  static Invite _inviteFromRow(Map r) => Invite(
        id: '${r['id']}',
        code: (r['code'] ?? '').toString(),
        status: InviteStatus.values.firstWhere(
            (s) => s.name == r['status'],
            orElse: () => InviteStatus.registered),
        sentAt: DateTime.tryParse('${r['created_at']}') ?? DateTime.now(),
        qualifiedAt: r['qualified_at'] == null
            ? null
            : DateTime.tryParse('${r['qualified_at']}'),
        creditedAt: r['credited_at'] == null
            ? null
            : DateTime.tryParse('${r['credited_at']}'),
        blockedReason: r['blocked_reason']?.toString(),
        dueMonth: r['due_month']?.toString(),
      );

  /// The invitee entering a code. Client-side checks first so the message is
  /// good and instant; the server then re-runs all of them.
  ///
  /// Returns null on success, or a sentence to show.
  Future<String?> redeem(String rawCode, {String? dueMonth}) async {
    final code = ReferralEngine.normalise(rawCode);
    final problem = ReferralEngine.redemptionProblem(
      code: code,
      ownCode: _code,
      alreadyRedeemedOne: hasRedeemed,
      config: config,
    );
    if (problem != null) return problem;

    if (!SupabaseRepo.isLoggedIn) {
      // Remember it so onboarding can claim it the moment they sign in -
      // otherwise a parent who enters a code before signing up loses it.
      _redeemedCode = code;
      _persist();
      notifyListeners();
      return null;
    }

    try {
      final result = await SupabaseRepo.callFunction(
        'redeem_referral',
        {'p_code': code, 'p_due_month': dueMonth},
      );
      final status = result.isEmpty ? 'ok' : '${result.first}';
      switch (status) {
        case 'ok':
          _redeemedCode = code;
          _persist();
          notifyListeners();
          return null;
        case 'unknown_code':
          return 'We could not find that code';
        case 'self_referral':
          return 'You cannot invite yourself';
        case 'already_redeemed':
          return 'You have already used an invite code';
        case 'not_signed_in':
          return 'Sign in first, then enter your code';
        default:
          return 'That did not work. Try again in a moment.';
      }
    } catch (_) {
      return 'We could not reach the server. Try again in a moment.';
    }
  }

  /// Called when the invitee finishes onboarding. The SERVER decides whether
  /// anything is granted; this only asks.
  Future<bool> claimQualification() async {
    if (!SupabaseRepo.isLoggedIn || !hasRedeemed) return false;
    try {
      final r = await SupabaseRepo.callFunction('qualify_referral', {
        'p_kind': config.inviteeReward.kind.name,
        'p_value': config.inviteeReward.value,
        'p_label': config.inviteeReward.label,
        'p_max_rewards': config.maxRewardsPerUser,
      });
      final ok = r.isEmpty || '${r.first}' == 'ok';
      if (ok) await refreshFromServer();
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode({
          'code': _code,
          'redeemedCode': _redeemedCode,
          'rewardsEarned': _rewardsEarned,
          'invites': _invites.map((i) => i.toMap()).toList(),
        }),
      );
    } catch (_) {/* in-memory stands */}
  }

  @visibleForTesting
  void resetAll() {
    _invites.clear();
    _code = '';
    _redeemedCode = '';
    _rewardsEarned = 0;
    _loaded = false;
    config = const ReferralConfig();
    notifyListeners();
  }

  @visibleForTesting
  void debugSeed(List<Invite> invites, {int rewards = 0}) {
    _invites
      ..clear()
      ..addAll(invites);
    _rewardsEarned = rewards;
    _loaded = true;
    if (_code.isEmpty) _code = 'ABCD234';
    notifyListeners();
  }
}
