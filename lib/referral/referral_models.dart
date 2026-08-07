// =============================================================================
//  Referral — the domain
// -----------------------------------------------------------------------------
//  A referral system is a machine that gives things away, so every rule about
//  WHO gets WHAT and WHEN lives here, in one testable place, rather than being
//  spread across screens. Nothing in this file touches Flutter, storage or the
//  network - the same reason doctor_schedule.dart does not.
//
//  Two ideas shape the design:
//
//  1. THE CODE IS THE SOURCE OF TRUTH, the link is a convenience. Firebase
//     Dynamic Links - which the original spec assumed - was shut down on
//     25 August 2025 and its links now 404. Rather than take on a paid
//     attribution vendor pre-launch, a short human-readable code carries the
//     referral and the link merely saves typing. A code also survives being
//     screenshotted, read aloud, or pasted into WhatsApp, which links do not.
//
//  2. REWARDS ARE ENTITLEMENTS. ParentVeda already has a credit system (buy an
//     entitlement, spend credits on slots). A referral reward grants into that
//     same system instead of inventing a second currency nobody can spend.
//
//  Every knob here is CONFIG, not code, so the admin panel can own it later
//  without a release. See docs/BRAND-STUDIO.md for the same principle applied
//  to campaigns.
// =============================================================================

import 'package:flutter/foundation.dart';

/// Where an invited friend has got to. Strictly ordered: an invite only ever
/// moves forward, which is what makes "is this reward already paid?" answerable
/// by comparing two values rather than reading a history.
enum InviteStatus {
  /// The code was shared. We cannot know more than this on its own.
  sent,

  /// The link was opened (or the code entered) but no account exists yet.
  opened,

  /// The app is installed and running for this invite.
  installed,

  /// An account exists and the phone number is verified.
  registered,

  /// Every qualification rule is satisfied. The reward is now OWED.
  qualified,

  /// The reward has actually been granted. Terminal, and the only status
  /// that may not be re-processed.
  credited,

  /// Fraud rules refused it. Terminal, and deliberately visible rather than
  /// silently dropped, so a real parent can be told why.
  blocked,
}

extension InviteStatusX on InviteStatus {
  /// Human wording for the dashboard. Never blames the friend.
  String get label => switch (this) {
        InviteStatus.sent => 'Invite sent',
        InviteStatus.opened => 'Link opened',
        InviteStatus.installed => 'App installed',
        InviteStatus.registered => 'Signed up',
        InviteStatus.qualified => 'Reward unlocked',
        InviteStatus.credited => 'Reward received',
        InviteStatus.blocked => 'Not eligible',
      };

  bool get isTerminal =>
      this == InviteStatus.credited || this == InviteStatus.blocked;

  /// Counts toward "friends joined" on the dashboard.
  bool get hasJoined => index >= InviteStatus.registered.index &&
      this != InviteStatus.blocked;
}

/// What a reward actually IS. Kinds map onto things the app can already grant.
enum RewardKind {
  /// A bookable consultation credit — an EntitlementGrant.
  consultCredit,

  /// Days of premium access.
  premiumDays,

  /// A specific masterclass/webinar unlocked.
  sessionAccess,

  /// A downloadable guide.
  download,
}

@immutable
class RewardSpec {
  const RewardSpec({
    required this.kind,
    required this.value,
    required this.label,
    this.description = '',
    this.offeringId,
  });

  final RewardKind kind;

  /// Credits, days, or 1 for a single unlock.
  final int value;

  /// Shown to the parent, e.g. "1 free consultation".
  final String label;
  final String description;

  /// Which offering a consultCredit/sessionAccess applies to. Null = the
  /// parent chooses when they spend it.
  final String? offeringId;

  Map<String, Object?> toMap() => {
        'kind': kind.name,
        'value': value,
        'label': label,
        'description': description,
        'offeringId': offeringId,
      };

  static RewardSpec fromMap(Map d) => RewardSpec(
        kind: RewardKind.values.firstWhere((k) => k.name == d['kind'],
            orElse: () => RewardKind.consultCredit),
        value: (d['value'] as num?)?.toInt() ?? 1,
        label: (d['label'] ?? '').toString(),
        description: (d['description'] ?? '').toString(),
        offeringId: d['offeringId']?.toString(),
      );
}

/// What a friend must actually DO before anyone is paid.
///
/// The spec is explicit that a reward is never given on install alone, and it
/// is right: install-only referrals are the single easiest thing to farm.
@immutable
class QualificationRules {
  const QualificationRules({
    this.requireRegistration = true,
    this.requireOtpVerified = true,
    this.requireOnboardingComplete = true,
    this.requirePregnancyConfirmed = true,
    this.within = const Duration(days: 30),
  });

  final bool requireRegistration;
  final bool requireOtpVerified;
  final bool requireOnboardingComplete;
  final bool requirePregnancyConfirmed;

  /// How long after installing a friend has to finish. Null = forever.
  /// A window stops an invite sitting "pending" in someone's dashboard for a
  /// year, which reads as broken.
  final Duration? within;

  Map<String, Object?> toMap() => {
        'requireRegistration': requireRegistration,
        'requireOtpVerified': requireOtpVerified,
        'requireOnboardingComplete': requireOnboardingComplete,
        'requirePregnancyConfirmed': requirePregnancyConfirmed,
        'withinDays': within?.inDays,
      };

  static QualificationRules fromMap(Map d) => QualificationRules(
        requireRegistration: d['requireRegistration'] as bool? ?? true,
        requireOtpVerified: d['requireOtpVerified'] as bool? ?? true,
        requireOnboardingComplete:
            d['requireOnboardingComplete'] as bool? ?? true,
        requirePregnancyConfirmed:
            d['requirePregnancyConfirmed'] as bool? ?? true,
        within: d['withinDays'] == null
            ? null
            : Duration(days: (d['withinDays'] as num).toInt()),
      );
}

/// What a friend has actually completed, as far as we know.
@immutable
class QualificationState {
  const QualificationState({
    this.registered = false,
    this.otpVerified = false,
    this.onboardingComplete = false,
    this.pregnancyConfirmed = false,
    this.installedAt,
  });

  final bool registered;
  final bool otpVerified;
  final bool onboardingComplete;
  final bool pregnancyConfirmed;
  final DateTime? installedAt;
}

/// A whole referral campaign. Every number the business might want to change
/// lives here, so changing an offer is data, never a release.
@immutable
class ReferralConfig {
  const ReferralConfig({
    this.campaignId = 'default',
    this.startsAt,
    this.endsAt,
    this.inviterReward = const RewardSpec(
      kind: RewardKind.consultCredit,
      value: 1,
      // A literal, not S.now.uiFreeConsultation: this is a const DEFAULT
      // parameter value, and a getter can never be a constant expression.
      // Localising it means giving RewardSpec a LocalizedText label and
      // resolving at the render site - a real change, not a lift.
      label: 'Free consultation',
      description: 'Yours when a friend joins and finishes setting up.',
    ),
    this.inviteeReward = const RewardSpec(
      kind: RewardKind.consultCredit,
      value: 1,
      // A literal, not S.now.uiFreeConsultation: this is a const DEFAULT
      // parameter value, and a getter can never be a constant expression.
      // Localising it means giving RewardSpec a LocalizedText label and
      // resolving at the render site - a real change, not a lift.
      label: 'Free consultation',
      description: 'A welcome gift for joining through a friend.',
    ),
    this.rules = const QualificationRules(),
    this.maxRewardsPerUser = 10,
    this.maxInvitesPerDay = 20,
    this.maxInvitesPerMonth = 100,
    this.enabled = true,
  });

  final String campaignId;
  final DateTime? startsAt;
  final DateTime? endsAt;

  /// Both sides are rewarded — the spec asks for it, and one-sided referrals
  /// convert far worse because the friend is asked to do the work for nothing.
  final RewardSpec inviterReward;
  final RewardSpec inviteeReward;

  final QualificationRules rules;

  /// Lifetime cap on rewards one parent may earn. The main defence against a
  /// determined farmer once every other check is passed.
  final int maxRewardsPerUser;
  final int maxInvitesPerDay;
  final int maxInvitesPerMonth;

  /// The kill switch, so a campaign can be stopped without a release.
  final bool enabled;

  bool isLiveAt(DateTime now) {
    if (!enabled) return false;
    if (startsAt != null && now.isBefore(startsAt!)) return false;
    if (endsAt != null && now.isAfter(endsAt!)) return false;
    return true;
  }

  Map<String, Object?> toMap() => {
        'campaignId': campaignId,
        'startsAt': startsAt?.toIso8601String(),
        'endsAt': endsAt?.toIso8601String(),
        'inviterReward': inviterReward.toMap(),
        'inviteeReward': inviteeReward.toMap(),
        'rules': rules.toMap(),
        'maxRewardsPerUser': maxRewardsPerUser,
        'maxInvitesPerDay': maxInvitesPerDay,
        'maxInvitesPerMonth': maxInvitesPerMonth,
        'enabled': enabled,
      };

  static ReferralConfig fromMap(Map d) => ReferralConfig(
        campaignId: (d['campaignId'] ?? 'default').toString(),
        startsAt: d['startsAt'] == null
            ? null
            : DateTime.tryParse(d['startsAt'].toString()),
        endsAt: d['endsAt'] == null
            ? null
            : DateTime.tryParse(d['endsAt'].toString()),
        inviterReward: d['inviterReward'] is Map
            ? RewardSpec.fromMap(d['inviterReward'] as Map)
            : const ReferralConfig().inviterReward,
        inviteeReward: d['inviteeReward'] is Map
            ? RewardSpec.fromMap(d['inviteeReward'] as Map)
            : const ReferralConfig().inviteeReward,
        rules: d['rules'] is Map
            ? QualificationRules.fromMap(d['rules'] as Map)
            : const QualificationRules(),
        maxRewardsPerUser: (d['maxRewardsPerUser'] as num?)?.toInt() ?? 10,
        maxInvitesPerDay: (d['maxInvitesPerDay'] as num?)?.toInt() ?? 20,
        maxInvitesPerMonth: (d['maxInvitesPerMonth'] as num?)?.toInt() ?? 100,
        enabled: d['enabled'] as bool? ?? true,
      );
}

/// One invited friend, tracked from share to reward.
@immutable
class Invite {
  const Invite({
    required this.id,
    required this.code,
    required this.status,
    required this.sentAt,
    this.friendName = '',
    this.installedAt,
    this.qualifiedAt,
    this.creditedAt,
    this.blockedReason,
    this.dueMonth,
  });

  final String id;

  /// The inviter's code that carried this invite.
  final String code;
  final InviteStatus status;
  final DateTime sentAt;

  /// Known only once they sign up. Blank before that, and the UI says
  /// "A friend" rather than inventing one.
  final String friendName;

  final DateTime? installedAt;
  final DateTime? qualifiedAt;
  final DateTime? creditedAt;

  /// Why a fraud rule refused it, in words a support person can act on.
  final String? blockedReason;

  /// For Birth Club matching, e.g. '2026-10'.
  final String? dueMonth;

  Invite copyWith({
    InviteStatus? status,
    String? friendName,
    DateTime? installedAt,
    DateTime? qualifiedAt,
    DateTime? creditedAt,
    String? blockedReason,
    String? dueMonth,
  }) =>
      Invite(
        id: id,
        code: code,
        status: status ?? this.status,
        sentAt: sentAt,
        friendName: friendName ?? this.friendName,
        installedAt: installedAt ?? this.installedAt,
        qualifiedAt: qualifiedAt ?? this.qualifiedAt,
        creditedAt: creditedAt ?? this.creditedAt,
        blockedReason: blockedReason ?? this.blockedReason,
        dueMonth: dueMonth ?? this.dueMonth,
      );

  String get displayName => friendName.trim().isEmpty ? 'A friend' : friendName.trim();

  Map<String, Object?> toMap() => {
        'id': id,
        'code': code,
        'status': status.name,
        'sentAt': sentAt.toIso8601String(),
        'friendName': friendName,
        'installedAt': installedAt?.toIso8601String(),
        'qualifiedAt': qualifiedAt?.toIso8601String(),
        'creditedAt': creditedAt?.toIso8601String(),
        'blockedReason': blockedReason,
        'dueMonth': dueMonth,
      };

  static Invite fromMap(Map d) => Invite(
        id: (d['id'] ?? '').toString(),
        code: (d['code'] ?? '').toString(),
        status: InviteStatus.values.firstWhere((s) => s.name == d['status'],
            orElse: () => InviteStatus.sent),
        sentAt: DateTime.tryParse('${d['sentAt']}') ?? DateTime(2026),
        friendName: (d['friendName'] ?? '').toString(),
        installedAt: d['installedAt'] == null
            ? null
            : DateTime.tryParse(d['installedAt'].toString()),
        qualifiedAt: d['qualifiedAt'] == null
            ? null
            : DateTime.tryParse(d['qualifiedAt'].toString()),
        creditedAt: d['creditedAt'] == null
            ? null
            : DateTime.tryParse(d['creditedAt'].toString()),
        blockedReason: d['blockedReason']?.toString(),
        dueMonth: d['dueMonth']?.toString(),
      );
}
