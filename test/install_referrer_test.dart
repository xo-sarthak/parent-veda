// =============================================================================
//  Play Install Referrer — the contract with parentveda.in
// -----------------------------------------------------------------------------
//  The website redirects Android visitors to Play with
//      &referrer=utm_source=invite&utm_medium=referral&utm_content=<CODE>
//  and hands that string back after install. If this parsing drifts, shared
//  links silently stop crediting anyone — nothing errors, the reward just never
//  arrives. So the contract itself is what gets pinned here.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/referral/install_referrer.dart';
import 'package:parentveda/referral/referral_engine.dart';

void main() {
  group('the referrer string the website sends', () {
    test('the exact documented shape yields the code', () {
      expect(
        InstallReferrerService.codeFromReferrer(
            'utm_source=invite&utm_medium=referral&utm_content=ABCD234'),
        'ABCD234',
      );
    });

    test('key ORDER does not matter — it is parsed, not matched', () {
      expect(
        InstallReferrerService.codeFromReferrer(
            'utm_content=ABCD234&utm_source=invite&utm_medium=referral'),
        'ABCD234',
      );
    });

    test('EXTRA keys added later do not break it', () {
      // The whole reason the contract says "parse, do not substring-match".
      expect(
        InstallReferrerService.codeFromReferrer(
            'utm_source=invite&utm_campaign=diwali&utm_content=ABCD234'
            '&gclid=xyz&utm_medium=referral'),
        'ABCD234',
      );
    });

    test('a lower-case code is normalised up', () {
      expect(
        InstallReferrerService.codeFromReferrer('utm_content=abcd234'),
        'ABCD234',
      );
    });

    test('an organic install carries no code', () {
      expect(InstallReferrerService.codeFromReferrer(null), isNull);
      expect(InstallReferrerService.codeFromReferrer(''), isNull);
      expect(
          InstallReferrerService.codeFromReferrer(
              'utm_source=google-play&utm_medium=organic'),
          isNull);
    });

    test('a malformed code in the referrer is refused, not half-applied', () {
      expect(InstallReferrerService.codeFromReferrer('utm_content=OI01'), isNull);
      expect(InstallReferrerService.codeFromReferrer('utm_content=AB'), isNull);
    });

    test('junk never throws', () {
      for (final junk in ['%%%', '=', '&&&', 'utm_content=', '   ']) {
        expect(() => InstallReferrerService.codeFromReferrer(junk),
            returnsNormally);
      }
    });
  });

  group('the share URL the website expects back', () {
    test('is exactly parentveda.in/invite/<CODE>, uppercase', () {
      expect(ReferralEngine.linkFor('abcd234'),
          'https://parentveda.in/invite/ABCD234');
    });

    test('round-trips: a link we emit parses back to the same code', () {
      const code = 'ABCD234';
      expect(ReferralEngine.normalise(ReferralEngine.linkFor(code)), code);
    });
  });

  group('the code format reported to the website', () {
    test('is 7 characters', () {
      expect(ReferralEngine.codeLength, 7);
      expect(ReferralEngine.codeForUser('any-user-id').length, 7);
    });

    test('sits inside the website\'s 4-12 A-Z0-9 window', () {
      final c = ReferralEngine.codeForUser('another-user');
      expect(c.length, inInclusiveRange(4, 12));
      expect(RegExp(r'^[A-Z0-9]+$').hasMatch(c), isTrue);
    });

    test('excludes the glyphs that get misread — the website regex may be '
        'tightened to match', () {
      expect(ReferralEngine.alphabet.contains('I'), isFalse);
      expect(ReferralEngine.alphabet.contains('L'), isFalse);
      expect(ReferralEngine.alphabet.contains('O'), isFalse);
      expect(ReferralEngine.alphabet.contains('0'), isFalse);
      expect(ReferralEngine.alphabet.contains('1'), isFalse);
      expect(ReferralEngine.alphabet.length, 31);
    });
  });
}
