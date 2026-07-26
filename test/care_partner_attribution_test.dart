// =============================================================================
//  Care Partner attribution capture
// -----------------------------------------------------------------------------
//  The gap this module exists to survive: a mother scans a QR in a clinic
//  corridor, installs the app, and signs up ten minutes later. If the token is
//  lost anywhere in that gap, the doctor loses the family and nobody notices.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/care_partner/care_partner_engine.dart';
import 'package:parentveda/care_partner/care_partner_models.dart';
import 'package:parentveda/care_partner/care_partner_store.dart';
import 'package:parentveda/referral/referral_links.dart';
import 'package:parentveda/referral/referral_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final store = CarePartnerStore.instance;
  setUp(() {
    store.resetAll();
    ReferralLinks.clearPending();
    ReferralStore.instance.resetAll();
  });
  tearDown(store.resetAll);

  final token = CarePartnerEngine.tokenFor('cp_rao');

  group('a scanned token survives until there is an account', () {
    test('holding a token keeps it', () {
      expect(store.hasPending, isFalse);
      store.holdToken(token);
      expect(store.pendingToken, token);
    });

    test('a malformed token is not held at all', () {
      store.holdToken('nope');
      expect(store.hasPending, isFalse);
    });

    test('a lower-case or spaced token is normalised', () {
      store.holdToken(' ${token.toLowerCase()} ');
      expect(store.pendingToken, token);
    });

    test('FIRST TOUCH WINS — a second scan does not overwrite the first', () {
      store.debugSeed(
        attribution: Attribution(
            partnerId: 'cp_first',
            token: token,
            channel: ReferralChannel.qr,
            linkedAt: DateTime(2026, 8, 1)),
      );
      store.holdToken(CarePartnerEngine.tokenFor('cp_second'));
      expect(store.hasPending, isFalse,
          reason: 'an attributed parent must not be re-bound by a later scan');
    });
  });

  group('the two link systems stay apart', () {
    test('a /care/ link is held by the CARE store, not the parent referral', () {
      final url = CarePartnerEngine.linkFor(token,
          channel: ReferralChannel.poster, campaignId: 'winter');
      ReferralLinks.handleLink(Uri.parse(url));

      expect(store.pendingToken, token);
      expect(ReferralLinks.hasPending, isFalse,
          reason: 'a doctor referral must never be held as a mother invite');
    });

    test('an /invite/ link is held by the parent referral, not the CARE store',
        () {
      ReferralLinks.handleLink(Uri.parse('https://parentveda.in/invite/ABCD234'));

      expect(ReferralLinks.pending, 'ABCD234');
      expect(store.hasPending, isFalse,
          reason: 'a mother invite must never be held as a doctor referral');
    });

    test('the channel and campaign ride along with the link', () {
      final url = CarePartnerEngine.linkFor(token,
          channel: ReferralChannel.prescription, campaignId: 'nov');
      final uri = Uri.parse(url);
      expect(CarePartnerEngine.channelFromUri(uri), ReferralChannel.prescription);
      expect(CarePartnerEngine.campaignFromUri(uri), 'nov');
    });

    test('a foreign domain is held by neither', () {
      ReferralLinks.handleLink(Uri.parse('https://evil.example.com/care/$token'));
      expect(store.hasPending, isFalse);
      expect(ReferralLinks.hasPending, isFalse);
    });
  });

  group('applying without an account', () {
    test('keeps the token rather than losing it', () async {
      store.holdToken(token);
      // Signed out: applyPending is a no-op and must NOT clear the token,
      // otherwise the scan is lost in exactly the gap this module exists for.
      final problem = await store.applyPending();
      expect(problem, isNull);
      expect(store.pendingToken, token,
          reason: 'the token must survive until there is an account');
    });
  });

  group('what the parent ends up seeing', () {
    test('an attributed parent knows who introduced her', () {
      store.debugSeed(
        attribution: Attribution(
            partnerId: 'cp_rao',
            token: token,
            channel: ReferralChannel.qr,
            linkedAt: DateTime(2026, 8, 1)),
        partner: const CarePartner(
          id: 'cp_rao',
          name: 'Dr Meera Rao',
          type: CarePartnerType.doctor,
          status: PartnerStatus.active,
          speciality: 'Paediatrician',
          organisation: 'Fortis',
        ),
      );
      expect(store.hasPartner, isTrue);
      expect(store.partner!.name, 'Dr Meera Rao');
      expect(store.partner!.subtitle, 'Paediatrician · Fortis');
    });

    test('an organic parent has no partner and no empty-state lie', () {
      expect(store.hasPartner, isFalse);
      expect(store.partner, isNull);
    });
  });
}
