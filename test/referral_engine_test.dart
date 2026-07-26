// =============================================================================
//  The referral engine — codes, qualification, fraud, growth maths
// -----------------------------------------------------------------------------
//  This is a machine that gives things away, so the tests lean hard on the
//  paths where it must REFUSE.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/referral/referral_engine.dart';
import 'package:parentveda/referral/referral_models.dart';

void main() {
  group('codes', () {
    test('are stable for a user — a code can be printed and remembered', () {
      final a = ReferralEngine.codeForUser('user-abc-123');
      final b = ReferralEngine.codeForUser('user-abc-123');
      expect(a, b);
      expect(a.length, ReferralEngine.codeLength);
    });

    test('differ between users', () {
      final seen = <String>{};
      for (var i = 0; i < 500; i++) {
        seen.add(ReferralEngine.codeForUser('user-$i'));
      }
      // Collisions are possible in principle; 500 users should not produce a
      // pile of them. The server's unique constraint is the real backstop.
      expect(seen.length, greaterThan(490));
    });

    test('never contain glyphs that are misread aloud or on paper', () {
      for (var i = 0; i < 200; i++) {
        final c = ReferralEngine.codeForUser('u$i');
        for (final bad in ['I', 'O', '0', '1', 'L']) {
          expect(c.contains(bad), isFalse, reason: '$c contains $bad');
        }
      }
    });

    test('an empty user has no code, rather than a fake one', () {
      expect(ReferralEngine.codeForUser(''), '');
    });
  });

  group('what people actually paste', () {
    test('a full invite link yields the code', () {
      expect(ReferralEngine.normalise('https://parentveda.in/invite/ABCD234'),
          'ABCD234');
    });

    test('the query-string form works too', () {
      expect(ReferralEngine.normalise('https://parentveda.in?r=ABCD234'),
          'ABCD234');
    });

    test('spaces, dashes and lower case are forgiven', () {
      expect(ReferralEngine.normalise('  abc d-234 '), 'ABCD234');
    });

    test('shape checking catches nonsense before the server is bothered', () {
      expect(ReferralEngine.isWellFormed('ABCD234'), isTrue);
      expect(ReferralEngine.isWellFormed('ABC'), isFalse);
      expect(ReferralEngine.isWellFormed('ABCD01I'), isFalse,
          reason: '0, 1 and I are not in the alphabet');
    });
  });

  group('qualification — a reward is never given on install alone', () {
    const rules = QualificationRules();
    final installed = DateTime(2026, 8, 1);

    test('installing is not enough', () {
      expect(
          ReferralEngine.qualifies(
              QualificationState(installedAt: installed), rules),
          isFalse);
    });

    test('every gate must be passed', () {
      expect(
        ReferralEngine.qualifies(
            QualificationState(
              registered: true,
              otpVerified: true,
              onboardingComplete: true,
              pregnancyConfirmed: true,
              installedAt: installed,
            ),
            rules,
            now: installed.add(const Duration(days: 2))),
        isTrue,
      );
    });

    test('an unverified number does not qualify', () {
      expect(
        ReferralEngine.qualifies(
            QualificationState(
              registered: true,
              onboardingComplete: true,
              pregnancyConfirmed: true,
              installedAt: installed,
            ),
            rules,
            now: installed),
        isFalse,
      );
    });

    test('qualifying too late does not count', () {
      final state = QualificationState(
        registered: true,
        otpVerified: true,
        onboardingComplete: true,
        pregnancyConfirmed: true,
        installedAt: installed,
      );
      expect(
          ReferralEngine.qualifies(state, rules,
              now: installed.add(const Duration(days: 31))),
          isFalse);
    });

    test('the reason given is specific enough to act on', () {
      expect(
          ReferralEngine.blockingReason(
              const QualificationState(), const QualificationRules()),
          'Waiting for them to sign up');
      expect(
          ReferralEngine.blockingReason(
              const QualificationState(registered: true),
              const QualificationRules()),
          contains('verify'));
    });

    test('relaxed rules can be configured without touching code', () {
      const relaxed = QualificationRules(
        requireOtpVerified: false,
        requireOnboardingComplete: false,
        requirePregnancyConfirmed: false,
        within: null,
      );
      expect(
          ReferralEngine.qualifies(
              const QualificationState(registered: true), relaxed),
          isTrue);
    });
  });

  group('fraud', () {
    const config = ReferralConfig();

    test('a parent cannot invite themselves', () {
      expect(
        ReferralEngine.redemptionProblem(
            code: 'ABCD234',
            ownCode: 'ABCD234',
            alreadyRedeemedOne: false,
            config: config),
        'You cannot invite yourself',
      );
    });

    test('a code can only be redeemed once per account', () {
      expect(
        ReferralEngine.redemptionProblem(
            code: 'ABCD234',
            ownCode: 'ZZZZ999',
            alreadyRedeemedOne: true,
            config: config),
        contains('already used'),
      );
    });

    test('a malformed code is refused before anything else', () {
      expect(
        ReferralEngine.redemptionProblem(
            code: 'nope',
            ownCode: '',
            alreadyRedeemedOne: false,
            config: config),
        'That code does not look right',
      );
    });

    test('a disabled campaign refuses everything', () {
      const off = ReferralConfig(enabled: false);
      expect(
          ReferralEngine.redemptionProblem(
              code: 'ABCD234',
              ownCode: '',
              alreadyRedeemedOne: false,
              config: off),
          contains('not running'));
    });

    test('a campaign outside its dates refuses everything', () {
      final past = ReferralConfig(endsAt: DateTime(2026, 1, 1));
      expect(
          ReferralEngine.redemptionProblem(
              code: 'ABCD234',
              ownCode: '',
              alreadyRedeemedOne: false,
              config: past,
              now: DateTime(2026, 7, 1)),
          contains('not running'));
    });

    test('a valid redemption returns no problem at all', () {
      expect(
        ReferralEngine.redemptionProblem(
            code: 'ABCD234',
            ownCode: 'ZZZZ999',
            alreadyRedeemedOne: false,
            config: config),
        isNull,
      );
    });

    test('daily, monthly and lifetime caps all bite', () {
      expect(
          ReferralEngine.invitingProblem(
              sentToday: 20,
              sentThisMonth: 30,
              rewardsEarned: 0,
              config: config),
          contains('today'));
      expect(
          ReferralEngine.invitingProblem(
              sentToday: 0,
              sentThisMonth: 100,
              rewardsEarned: 0,
              config: config),
          contains('month'));
      expect(
          ReferralEngine.invitingProblem(
              sentToday: 0,
              sentThisMonth: 0,
              rewardsEarned: 10,
              config: config),
          contains('maximum rewards'));
      expect(
          ReferralEngine.invitingProblem(
              sentToday: 1,
              sentThisMonth: 5,
              rewardsEarned: 2,
              config: config),
          isNull);
    });
  });

  group('growth maths', () {
    test('conversion rate handles the no-invites case', () {
      expect(ReferralEngine.conversionRate(0, 0), 0);
      expect(ReferralEngine.conversionRate(10, 3), closeTo(0.3, 0.0001));
    });

    test('K = average invites x conversion rate', () {
      // 100 users sent 200 invites, 50 qualified: avg 2 invites, 25% convert.
      final k = ReferralEngine.kFactor(
          totalUsers: 100, totalInvitesSent: 200, totalQualified: 50);
      expect(k, closeTo(0.5, 0.0001));
    });

    test('K is zero with no users, rather than dividing by zero', () {
      expect(
          ReferralEngine.kFactor(
              totalUsers: 0, totalInvitesSent: 5, totalQualified: 1),
          0);
    });
  });

  group('birth clubs', () {
    test('a due date maps to its month cohort', () {
      expect(ReferralEngine.birthClubFor(DateTime(2026, 10, 14)), '2026-10');
      expect(ReferralEngine.birthClubFor(DateTime(2027, 3, 2)), '2027-03');
    });

    test('the cohort reads as a name a mother would recognise', () {
      expect(ReferralEngine.birthClubLabel('2026-10'), 'October 2026 Birth Club');
    });

    test('a broken key degrades to something harmless', () {
      expect(ReferralEngine.birthClubLabel('nonsense'), 'Birth Club');
      expect(ReferralEngine.birthClubLabel('2026-99'), 'Birth Club');
    });
  });

  group('invite status', () {
    test('joined counts registered and beyond, but never blocked', () {
      expect(InviteStatus.sent.hasJoined, isFalse);
      expect(InviteStatus.installed.hasJoined, isFalse);
      expect(InviteStatus.registered.hasJoined, isTrue);
      expect(InviteStatus.credited.hasJoined, isTrue);
      expect(InviteStatus.blocked.hasJoined, isFalse);
    });

    test('credited and blocked are terminal', () {
      expect(InviteStatus.credited.isTerminal, isTrue);
      expect(InviteStatus.blocked.isTerminal, isTrue);
      expect(InviteStatus.qualified.isTerminal, isFalse);
    });
  });
}
