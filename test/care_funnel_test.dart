// The acquisition funnel: a poster scan surviving the Play install, the two
// timestamps that make a funnel measurable, and the visibility rules that were
// previously declared but never enforced.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/care_partner/care_partner_engine.dart';
import 'package:parentveda/care_partner/care_partner_models.dart';
import 'package:parentveda/care_partner/care_partner_store.dart';
import 'package:parentveda/care_partner/care_presence_store.dart';
import 'package:parentveda/care_partner/care_visibility.dart';
import 'package:parentveda/care_partner/partner_dashboard_store.dart';
import 'package:parentveda/referral/install_referrer.dart';
import 'package:parentveda/screens/care_partner/care_partner_card.dart';
import 'package:parentveda/screens/care_partner/care_partner_slot.dart';

const _partner = CarePartner(
  id: 'cp_meera',
  name: 'Dr Meera Rao',
  type: CarePartnerType.lactationConsultant,
  status: PartnerStatus.active,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------
  // A poster is scanned by a phone that does not have the app. Everything
  // downstream depends on the token surviving the Play Store.
  // ---------------------------------------------------------------------
  group('install referrer carries a partner token', () {
    final token = CarePartnerEngine.tokenFor('cp_meera');

    test('a care referrer yields the token', () {
      final r = 'utm_source=care&utm_medium=partner&utm_content=$token';
      expect(InstallReferrerService.partnerTokenFromReferrer(r), token);
    });

    test('and is NOT redeemed as a parent invite code', () {
      final r = 'utm_source=care&utm_medium=partner&utm_content=$token';
      expect(InstallReferrerService.codeFromReferrer(r), isNull,
          reason: 'a doctor token must never credit a friend');
    });

    test('a parent invite still works, and is not read as a partner token', () {
      const r = 'utm_source=invite&utm_medium=referral&utm_content=ABCD234';
      expect(InstallReferrerService.codeFromReferrer(r), 'ABCD234');
      expect(InstallReferrerService.partnerTokenFromReferrer(r), isNull);
    });

    test('an unsourced referrer is treated as the parent system — old links '
        'from the website are still in circulation', () {
      const r = 'utm_content=ABCD234';
      expect(InstallReferrerService.codeFromReferrer(r), 'ABCD234');
      expect(InstallReferrerService.partnerTokenFromReferrer(r), isNull);
    });

    test('a care source carrying a malformed token yields nothing, not a '
        'guess', () {
      const r = 'utm_source=care&utm_content=nope';
      expect(InstallReferrerService.partnerTokenFromReferrer(r), isNull);
      expect(InstallReferrerService.codeFromReferrer(r), isNull);
    });

    test('channel and campaign ride along', () {
      final r = 'utm_source=care&utm_content=$token'
          '&utm_term=whatsapp&utm_campaign=diwali';
      expect(InstallReferrerService.partnerChannelFromReferrer(r),
          ReferralChannel.whatsapp);
      expect(InstallReferrerService.partnerCampaignFromReferrer(r), 'diwali');
    });

    test('a referrer with no channel defaults to QR — what survives an '
        'install is almost always something printed', () {
      final r = 'utm_source=care&utm_content=$token';
      expect(InstallReferrerService.partnerChannelFromReferrer(r),
          ReferralChannel.qr);
    });

    test('garbage never throws', () {
      for (final r in ['', '   ', 'not a query string at all', '%%%']) {
        expect(() => InstallReferrerService.partnerTokenFromReferrer(r),
            returnsNormally);
      }
    });
  });

  // ---------------------------------------------------------------------
  // Frequency and dismissal — both were configurable and neither did
  // anything before this.
  // ---------------------------------------------------------------------
  group('frequency is enforced, not just stored', () {
    const ctx = CareContext(
        surface: CareSurface.topic, topic: CareTopic.breastfeeding);
    final base = CareVisibilityRule.defaultsFor(_partner.type);

    CareVisibilityRule at(CareFrequency f) => CareVisibilityRule(
        topics: base.topics, surfaces: base.surfaces, frequency: f);

    test('once means once, ever', () {
      expect(
        CareVisibility.shouldShow(
          partner: _partner,
          rule: at(CareFrequency.once),
          context: ctx,
          lastShown: DateTime(2020),
          now: DateTime(2026, 7, 26),
        ),
        isFalse,
      );
    });

    test('daily hides it again the same day', () {
      final now = DateTime(2026, 7, 26, 18);
      expect(
        CareVisibility.shouldShow(
          partner: _partner,
          rule: at(CareFrequency.daily),
          context: ctx,
          lastShown: DateTime(2026, 7, 26, 9),
          now: now,
        ),
        isFalse,
      );
    });

    test('and shows it again the next day', () {
      expect(
        CareVisibility.shouldShow(
          partner: _partner,
          rule: at(CareFrequency.daily),
          context: ctx,
          lastShown: DateTime(2026, 7, 25, 23, 59),
          now: DateTime(2026, 7, 26, 0, 1),
        ),
        isTrue,
      );
    });

    test('always ignores the history', () {
      expect(
        CareVisibility.shouldShow(
          partner: _partner,
          rule: at(CareFrequency.always),
          context: ctx,
          lastShown: DateTime(2026, 7, 26, 9),
          now: DateTime(2026, 7, 26, 9, 1),
        ),
        isTrue,
      );
    });

    test('the Care Circle is still exempt', () {
      expect(
        CareVisibility.shouldShow(
          partner: _partner,
          rule: at(CareFrequency.once),
          context: const CareContext(surface: CareSurface.careCircle),
          lastShown: DateTime(2020),
        ),
        isTrue,
      );
    });
  });

  group('CarePresenceStore', () {
    tearDown(CarePresenceStore.instance.resetAll);

    test('dismissal is per surface AND topic — "not here" is not "never"', () {
      final s = CarePresenceStore.instance;
      s.dismiss('cp1', CareSurface.topic, CareTopic.vaccination);
      expect(s.isDismissed('cp1', CareSurface.topic, CareTopic.vaccination),
          isTrue);
      expect(s.isDismissed('cp1', CareSurface.topic, CareTopic.breastfeeding),
          isFalse);
      expect(s.isDismissed('cp1', CareSurface.profile, null), isFalse);
    });

    test('a different partner is unaffected', () {
      final s = CarePresenceStore.instance;
      s.dismiss('cp1', CareSurface.profile, null);
      expect(s.isDismissed('cp2', CareSurface.profile, null), isFalse);
    });
  });

  group('CarePartnerSlot honours both', () {
    setUp(() {
      CarePresenceStore.instance.resetAll();
      CarePartnerStore.instance.debugSeed(partner: _partner);
    });
    tearDown(() {
      CarePartnerStore.instance.resetAll();
      CarePresenceStore.instance.resetAll();
    });

    testWidgets('a dismissed slot stays gone on the next mount',
        (tester) async {
      Widget host() => const MaterialApp(
            home: Scaffold(
              body: CarePartnerSlot(
                surface: CareSurface.topic,
                topic: CareTopic.breastfeeding,
              ),
            ),
          );

      await tester.pumpWidget(host());
      await tester.pump();
      expect(find.byType(CarePartnerCard), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(find.byType(CarePartnerCard), findsNothing);

      // Remount: the decision must survive, or dismissing achieves nothing.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(host());
      await tester.pump();
      expect(find.byType(CarePartnerCard), findsNothing);
    });

    testWidgets('showing it records that it was shown', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CarePartnerSlot(
            surface: CareSurface.profile,
            shape: CarePartnerCardShape.full,
          ),
        ),
      ));
      await tester.pump();
      expect(
          CarePresenceStore.instance
              .lastShown(_partner.id, CareSurface.profile, null),
          isNotNull);
    });

    testWidgets('the card does not vanish on a rebuild after being marked '
        'shown', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CarePartnerSlot(
            surface: CareSurface.profile,
            shape: CarePartnerCardShape.full,
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(CarePartnerCard), findsOneWidget);
      // Force rebuilds — the daily-frequency rule would now say "already shown
      // today", and the card must not disappear mid-screen because of it.
      for (var i = 0; i < 3; i++) {
        CarePartnerStore.instance.debugSeed(partner: _partner);
        await tester.pump();
      }
      expect(find.byType(CarePartnerCard), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------
  // 0039
  // ---------------------------------------------------------------------
  group('migration 0039', () {
    final sql =
        File('supabase/migrations/0039_care_funnel.sql').readAsStringSync();

    test('the client timestamps are clamped, not trusted', () {
      expect(sql.contains('least(greatest(p_scanned_at'), isTrue,
          reason: 'a device clock could otherwise fabricate a funnel');
      expect(sql.contains('v_ref.created_at'), isTrue,
          reason: 'a scan cannot predate the token');
    });

    test('the funnel is still counts-only and still scoped to the caller', () {
      final start = sql.indexOf('function public.partner_funnel(');
      expect(start, greaterThan(-1));
      final body = sql.substring(start, sql.indexOf(r'$$;', start));
      expect(body.contains("security definer set search_path = ''"), isTrue);
      expect(body.contains('ea.user_id = auth.uid()'), isTrue);
      final sig = sql.substring(start, sql.indexOf('language sql', start));
      expect(sig.contains('user_id'), isFalse,
          reason: 'partner_funnel must not return a family identifier');
    });

    test('the acquisition events are written to the timeline', () {
      for (final e in ['referral_scanned', 'app_installed', 'signup_completed']) {
        expect(sql.contains("'$e'"), isTrue, reason: '$e is never recorded');
      }
    });
  });

  group('PartnerFunnel', () {
    test('reads what partner_funnel returns', () {
      final f = PartnerFunnel.fromMap({
        'scanned': 60,
        'installed': 55,
        'signed_up': 41,
        'activated': 33,
      });
      expect(f.scanned, 60);
      expect(f.activationPct, 80);
    });

    test('no signups is zero percent, not a division by zero', () {
      expect(const PartnerFunnel().activationPct, 0);
    });
  });
}
