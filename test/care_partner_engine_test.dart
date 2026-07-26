// =============================================================================
//  Care Partner engine — tokens, links, and who gets credited
// -----------------------------------------------------------------------------
//  Attribution is money, so the tests concentrate on refusal: guessed tokens,
//  self-referral, inactive partners, expiry, and — the one most likely to cause
//  real damage — a partner link being resolved by the PARENT referral engine or
//  vice versa.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/care_partner/care_partner_engine.dart';
import 'package:parentveda/care_partner/care_partner_models.dart';
import 'package:parentveda/referral/referral_engine.dart';

CarePartner _partner({
  String id = 'cp_rao',
  PartnerStatus status = PartnerStatus.active,
  String? expertId,
}) =>
    CarePartner(
      id: id,
      name: 'Dr Meera Rao',
      type: CarePartnerType.doctor,
      status: status,
      speciality: 'Paediatrician',
      expertId: expertId,
    );

void main() {
  group('tokens', () {
    test('are stable for a partner, so a printed poster keeps working', () {
      expect(CarePartnerEngine.tokenFor('cp_rao'),
          CarePartnerEngine.tokenFor('cp_rao'));
      expect(CarePartnerEngine.tokenFor('cp_rao').length, 10);
    });

    test('differ per partner, per campaign and per rotation', () {
      final base = CarePartnerEngine.tokenFor('cp_rao');
      expect(CarePartnerEngine.tokenFor('cp_other'), isNot(base));
      expect(CarePartnerEngine.tokenFor('cp_rao', campaignId: 'poster'),
          isNot(base));
      expect(CarePartnerEngine.tokenFor('cp_rao', rotation: 1), isNot(base));
    });

    test('rotating produces a genuinely different token — the old poster dies',
        () {
      final seen = {
        for (var r = 0; r < 8; r++)
          CarePartnerEngine.tokenFor('cp_rao', rotation: r)
      };
      expect(seen.length, 8);
    });

    test('neighbouring partner ids do not produce neighbouring tokens', () {
      // Structure in a token is what makes the next one guessable.
      final a = CarePartnerEngine.tokenFor('cp_1');
      final b = CarePartnerEngine.tokenFor('cp_2');
      var same = 0;
      for (var i = 0; i < a.length; i++) {
        if (a[i] == b[i]) same++;
      }
      expect(same, lessThan(5), reason: '$a vs $b share too much shape');
    });

    test('use no glyph that is misread off a printed poster', () {
      for (var i = 0; i < 200; i++) {
        final t = CarePartnerEngine.tokenFor('cp_$i');
        for (final bad in ['I', 'L', 'O', '0', '1']) {
          expect(t.contains(bad), isFalse, reason: '$t contains $bad');
        }
      }
    });

    test('an empty partner has no token rather than a fake one', () {
      expect(CarePartnerEngine.tokenFor(''), '');
    });
  });

  group('links', () {
    test('carry the token, the channel and the campaign', () {
      final url = CarePartnerEngine.linkFor('ABCD234XYZ',
          channel: ReferralChannel.poster, campaignId: 'winter');
      expect(url, startsWith('https://parentveda.in/care/ABCD234XYZ'));
      final uri = Uri.parse(url);
      expect(CarePartnerEngine.tokenFromUri(uri), 'ABCD234XYZ');
      expect(CarePartnerEngine.channelFromUri(uri), ReferralChannel.poster);
      expect(CarePartnerEngine.campaignFromUri(uri), 'winter');
    });

    test('an unknown channel falls back rather than throwing', () {
      final uri = Uri.parse('https://parentveda.in/care/ABCD234XYZ?ch=carrier');
      expect(CarePartnerEngine.channelFromUri(uri), ReferralChannel.link);
    });

    test('somebody else\'s domain is ignored', () {
      expect(
          CarePartnerEngine.tokenFromUri(
              Uri.parse('https://evil.example.com/care/ABCD234XYZ')),
          isNull);
    });

    test('a malformed token in a valid link is refused', () {
      expect(
          CarePartnerEngine.tokenFromUri(
              Uri.parse('https://parentveda.in/care/OI01')),
          isNull);
    });
  });

  group('the two referral systems never resolve each other', () {
    // The most damaging possible confusion: a partner link consumed as a parent
    // invite would credit a mother instead of a doctor, and silently.
    test('a PARENT invite link yields no partner token', () {
      expect(
          CarePartnerEngine.tokenFromUri(
              Uri.parse('https://parentveda.in/invite/ABCD234')),
          isNull);
    });

    test('a PARTNER link yields no parent code', () {
      final url = CarePartnerEngine.linkFor('ABCD234XYZ');
      final asParentCode = ReferralEngine.normalise(url);
      expect(ReferralEngine.isWellFormed(asParentCode), isFalse,
          reason: 'a 10-char partner token must not pass as a 7-char code');
    });

    test('the two token shapes cannot be confused', () {
      expect(CarePartnerEngine.tokenLength, isNot(ReferralEngine.codeLength));
      expect(
          CarePartnerEngine.isWellFormed(ReferralEngine.codeForUser('u1')),
          isFalse);
    });
  });

  group('who gets credited', () {
    final tok = CarePartnerEngine.tokenFor('cp_rao');

    test('a valid first scan is accepted', () {
      expect(
        CarePartnerEngine.refusal(
            token: tok, partner: _partner(), alreadyAttributed: false),
        isNull,
      );
    });

    test('a guessed token is refused before a partner is even looked up', () {
      expect(
        CarePartnerEngine.refusal(
            token: 'nope', partner: null, alreadyAttributed: false),
        AttributionRefusal.malformedToken,
      );
    });

    test('an unknown partner is refused', () {
      expect(
        CarePartnerEngine.refusal(
            token: tok, partner: null, alreadyAttributed: false),
        AttributionRefusal.unknownPartner,
      );
    });

    test('an unverified partner cannot acquire families', () {
      for (final s in [
        PartnerStatus.pending,
        PartnerStatus.inactive,
        PartnerStatus.rejected
      ]) {
        expect(
          CarePartnerEngine.refusal(
              token: tok,
              partner: _partner(status: s),
              alreadyAttributed: false),
          AttributionRefusal.partnerNotActive,
          reason: 'status $s must not acquire',
        );
      }
    });

    test('an expired invitation is refused', () {
      expect(
        CarePartnerEngine.refusal(
          token: tok,
          partner: _partner(),
          alreadyAttributed: false,
          expiresAt: DateTime(2026, 1, 1),
          now: DateTime(2026, 7, 1),
        ),
        AttributionRefusal.expired,
      );
    });

    test('a doctor cannot scan their own QR into commission', () {
      expect(
        CarePartnerEngine.refusal(
          token: tok,
          partner: _partner(expertId: 'neha'),
          alreadyAttributed: false,
          viewerExpertId: 'neha',
        ),
        AttributionRefusal.selfReferral,
      );
    });

    test('FIRST TOUCH WINS — a later scan does not steal the family', () {
      expect(
        CarePartnerEngine.refusal(
            token: tok, partner: _partner(), alreadyAttributed: true),
        AttributionRefusal.alreadyAttributed,
      );
    });

    test('every refusal has a message that does not blame the parent', () {
      for (final r in AttributionRefusal.values) {
        expect(r.parentMessage, isNotEmpty);
        expect(r.parentMessage.toLowerCase(), isNot(contains('you failed')));
        expect(r.analyticsLabel, r.name);
      }
    });
  });

  group('partner state explains itself to the doctor', () {
    test('pending says the QR is not live yet', () {
      expect(
          CarePartnerEngine.partnerBlocked(
              _partner(status: PartnerStatus.pending)),
          contains('verified'));
    });

    test('inactive reassures that existing families are unaffected', () {
      expect(
          CarePartnerEngine.partnerBlocked(
              _partner(status: PartnerStatus.inactive)),
          contains('unaffected'));
    });

    test('an active partner is not blocked', () {
      expect(CarePartnerEngine.partnerBlocked(_partner()), isNull);
    });
  });

  group('partner types are data, not code', () {
    test('known types have proper labels', () {
      expect(CarePartnerType.label(CarePartnerType.ivfCentre), 'IVF Centre');
      expect(CarePartnerType.label(CarePartnerType.lactationConsultant),
          'Lactation Consultant');
    });

    test('a type invented in the admin panel still renders sensibly', () {
      expect(CarePartnerType.label('milk_bank'), 'Milk Bank');
      expect(CarePartnerType.label('corporate_wellness'), 'Corporate Wellness');
    });

    test('organisations are told apart from people', () {
      expect(CarePartnerType.isOrganisation(CarePartnerType.hospital), isTrue);
      expect(CarePartnerType.isOrganisation(CarePartnerType.doctor), isFalse);
    });
  });

  group('the app refuses to call a care partner an advertisement', () {
    test('banned words are swapped for the safe default', () {
      const bad = TrustMessage(primary: 'Sponsored by', secondary: 'Advertisement');
      expect(bad.safePrimary, 'Invited by');
      expect(bad.safeSecondary, 'Your care partner');
    });

    test('legitimate wording is left alone', () {
      const ok = TrustMessage(
          primary: 'Connected through', secondary: 'Your trusted partner');
      expect(ok.safePrimary, 'Connected through');
      expect(ok.safeSecondary, 'Your trusted partner');
    });

    test('the check is case-insensitive', () {
      expect(TrustMessage.isAllowed('SPONSORED BY'), isFalse);
      expect(TrustMessage.isAllowed('A Promotion'), isFalse);
      expect(TrustMessage.isAllowed('Recommended by'), isTrue);
    });
  });

  group('attribution record', () {
    test('round-trips, including the funnel timestamps', () {
      final a = Attribution(
        partnerId: 'cp_rao',
        token: 'ABCD234XYZ',
        channel: ReferralChannel.prescription,
        campaignId: 'winter',
        scannedAt: DateTime(2026, 8, 1, 10),
        signedUpAt: DateTime(2026, 8, 1, 11),
        linkedAt: DateTime(2026, 8, 1, 11),
      );
      final back = Attribution.fromMap(a.toMap());
      expect(back.partnerId, 'cp_rao');
      expect(back.channel, ReferralChannel.prescription);
      expect(back.campaignId, 'winter');
      expect(back.isLinked, isTrue);
      expect(back.installedAt, isNull);
    });

    test('reads snake_case rows straight from the server', () {
      final a = Attribution.fromMap({
        'partner_id': 'cp_x',
        'token': 'ABCD234XYZ',
        'channel': 'qr',
        'linked_at': '2026-08-01T10:00:00Z',
      });
      expect(a.partnerId, 'cp_x');
      expect(a.isLinked, isTrue);
    });
  });
}
