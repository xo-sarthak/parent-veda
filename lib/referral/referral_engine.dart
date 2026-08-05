// =============================================================================
//  ReferralEngine — codes, qualification, fraud, and the growth maths
// -----------------------------------------------------------------------------
//  Pure functions. Every decision that gives something away passes through here
//  so it can be tested exhaustively, and so there is exactly one place to look
//  when someone asks "why did this parent not get their reward?".
//
//  IMPORTANT: this is the CLIENT's copy of the rules. It exists to keep the UI
//  honest (never promise a reward the server will refuse) and to fail fast
//  offline. It is NOT the authority - the server RPC re-runs every check before
//  granting anything, because a client that decides who gets paid is a client
//  that can be edited.
// =============================================================================

import 'referral_models.dart';
import '../localization/app_language.dart';

class ReferralEngine {
  ReferralEngine._();

  /// Deliberately excludes I, l, 1, O and 0. A referral code gets read aloud
  /// down a phone, written on paper, and retyped by someone holding a baby -
  /// ambiguous glyphs are a support ticket waiting to happen.
  static const String alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const int codeLength = 7;

  /// A stable code for a user. Deterministic, so the same parent always shares
  /// the same code - it can be printed, remembered, and does not churn if the
  /// device is reinstalled. 31^7 is ~27 billion, and the server holds a unique
  /// constraint that catches the rare collision.
  static String codeForUser(String userId) {
    if (userId.isEmpty) return '';
    var h = 0x811c9dc5; // FNV-1a, chosen for a good avalanche on short strings
    for (final unit in userId.codeUnits) {
      h ^= unit;
      h = (h * 0x01000193) & 0xffffffff;
    }
    final out = StringBuffer();
    var v = h;
    for (var i = 0; i < codeLength; i++) {
      out.write(alphabet[v % alphabet.length]);
      v = (v ~/ alphabet.length) ^ (v << 3) & 0xffffffff;
      if (v == 0) v = h + i + 1;
    }
    return out.toString();
  }

  /// Cheap client-side shape check before we bother the server.
  static bool isWellFormed(String code) {
    final c = code.trim().toUpperCase();
    if (c.length != codeLength) return false;
    return c.split('').every(alphabet.contains);
  }

  /// Tolerates what people actually paste: spaces, dashes, lower case, and a
  /// full invite URL.
  static String normalise(String raw) {
    var s = raw.trim();
    // Pull the code out of a link, e.g. parentveda.in/invite/ABCD123?x=1
    final m = RegExp(r'(?:invite/|[?&]r=)([A-Za-z0-9]+)').firstMatch(s);
    if (m != null) s = m.group(1)!;
    return s.replaceAll(RegExp(r'[\s\-_]'), '').toUpperCase();
  }

  /// The share URL. Contract with parentveda.in: ALWAYS emit uppercase. The
  /// site accepts any case and normalises, but emitting mixed case would make
  /// links look inconsistent wherever they are pasted.
  static String linkFor(String code) =>
      'https://parentveda.in/invite/${code.toUpperCase()}';

  // ---- qualification --------------------------------------------------------

  /// Has this friend done enough to trigger the reward?
  static bool qualifies(
    QualificationState state,
    QualificationRules rules, {
    DateTime? now,
  }) {
    if (rules.requireRegistration && !state.registered) return false;
    if (rules.requireOtpVerified && !state.otpVerified) return false;
    if (rules.requireOnboardingComplete && !state.onboardingComplete) {
      return false;
    }
    if (rules.requirePregnancyConfirmed && !state.pregnancyConfirmed) {
      return false;
    }
    final window = rules.within;
    final installed = state.installedAt;
    if (window != null && installed != null) {
      final deadline = installed.add(window);
      if ((now ?? DateTime.now()).isAfter(deadline)) return false;
    }
    return true;
  }

  /// Why it did not qualify, for the dashboard and for support. Null when it
  /// does qualify.
  static String? blockingReason(
    QualificationState state,
    QualificationRules rules, {
    DateTime? now,
  }) {
    if (rules.requireRegistration && !state.registered) {
      return 'Waiting for them to sign up';
    }
    if (rules.requireOtpVerified && !state.otpVerified) {
      return 'Waiting for them to verify their number';
    }
    if (rules.requireOnboardingComplete && !state.onboardingComplete) {
      return 'Waiting for them to finish setting up';
    }
    if (rules.requirePregnancyConfirmed && !state.pregnancyConfirmed) {
      return 'Waiting for their due date';
    }
    final window = rules.within;
    final installed = state.installedAt;
    if (window != null &&
        installed != null &&
        (now ?? DateTime.now()).isAfter(installed.add(window))) {
      return 'This invite expired after ${window.inDays} days';
    }
    return null;
  }

  // ---- fraud ---------------------------------------------------------------

  /// Whether [code] may be redeemed by this device/user at all.
  ///
  /// Returns null when it is fine, or the reason to show. The reasons are
  /// deliberately readable: a real parent who hits one of these deserves to be
  /// told what happened rather than watching a button do nothing.
  static String? redemptionProblem({
    required String code,
    required String ownCode,
    required bool alreadyRedeemedOne,
    required ReferralConfig config,
    DateTime? now,
  }) {
    final c = normalise(code);
    if (!isWellFormed(c)) return 'That code does not look right';
    if (!config.isLiveAt(now ?? DateTime.now())) {
      return S.now.referralNotRunning;
    }
    // Self-referral: the single most common attempt, and the easiest to catch.
    if (ownCode.isNotEmpty && c == ownCode.toUpperCase()) {
      return 'You cannot invite yourself';
    }
    // One redemption per account, ever. A referral is a joining bonus.
    if (alreadyRedeemedOne) return 'You have already used an invite code';
    return null;
  }

  /// Whether the INVITER may send more invites, and earn more.
  static String? invitingProblem({
    required int sentToday,
    required int sentThisMonth,
    required int rewardsEarned,
    required ReferralConfig config,
    DateTime? now,
  }) {
    if (!config.isLiveAt(now ?? DateTime.now())) {
      return S.now.referralNotRunning;
    }
    if (sentToday >= config.maxInvitesPerDay) {
      return S.now.inviteLimitToday;
    }
    if (sentThisMonth >= config.maxInvitesPerMonth) {
      return S.now.inviteLimitMonth;
    }
    if (rewardsEarned >= config.maxRewardsPerUser) {
      return S.now.maxRewardsEarned;
    }
    return null;
  }

  // ---- growth maths ---------------------------------------------------------

  /// Share of invites that became qualified users.
  static double conversionRate(int invitesSent, int qualified) =>
      invitesSent <= 0 ? 0 : qualified / invitesSent;

  /// K = average invites per user x conversion rate. Above 1.0 means each
  /// cohort more than replaces itself: viral growth. Below 1.0 - which almost
  /// everything is - means referral is a discount on acquisition, not a
  /// growth engine, and should be judged on cost per joined parent instead.
  static double kFactor({
    required int totalUsers,
    required int totalInvitesSent,
    required int totalQualified,
  }) {
    if (totalUsers <= 0) return 0;
    final avgInvites = totalInvitesSent / totalUsers;
    return avgInvites * conversionRate(totalInvitesSent, totalQualified);
  }

  /// The due-date cohort a mother belongs to, e.g. '2026-10'.
  static String birthClubFor(DateTime dueDate) =>
      '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}';

  /// "October 2026 Birth Club"
  static String birthClubLabel(String key) {
    final parts = key.split('-');
    if (parts.length != 2) return 'Birth Club';
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (y == null || m == null || m < 1 || m > 12) return 'Birth Club';
    
    return '${S.now.monthLong(m)} $y Birth Club';
  }
}
