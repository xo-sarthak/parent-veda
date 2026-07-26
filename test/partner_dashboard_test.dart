// The Partner Journey Dashboard — the doctor-facing side.
//
// The invariant being defended is not a layout: it is that a doctor can learn
// HOW MANY families they helped and never WHICH. That boundary is enforced in
// SQL (0037), so the tests come in two halves — the Dart that renders totals,
// and a read of the migration itself to prove nothing grants row access.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:parentveda/care_partner/care_partner_engine.dart';
import 'package:parentveda/care_partner/care_partner_models.dart';
import 'package:parentveda/care_partner/partner_dashboard_store.dart';
import 'package:parentveda/screens/doctor/doctor_impact_screen.dart';
import 'package:parentveda/screens/doctor/doctor_impact_tab.dart';
import 'package:parentveda/screens/doctor/doctor_referral_kit_screen.dart';

const _partner = CarePartner(
  id: 'cp_meera',
  name: 'Dr Meera Rao',
  type: CarePartnerType.doctor,
  status: PartnerStatus.active,
  expertId: 'exp_meera',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => PartnerDashboardStore.instance.reset());

  group('PartnerImpact', () {
    test('reads the shape partner_impact() actually returns', () {
      final i = PartnerImpact.fromMap({
        'families_referred': 41,
        'active_this_month': 28,
        'pregnancies_supported': 12,
        'children_added': 29,
        'consultations_done': 63,
        'vaccinations_completed': 104,
        'content_consumed': 890,
      });
      expect(i.familiesReferred, 41);
      expect(i.pregnanciesSupported, 12);
      expect(i.childrenAdded, 29);
      expect(i.vaccinationsCompleted, 104);
      expect(i.isEmpty, isFalse);
    });

    test('a missing column reads as zero, not as a crash', () {
      final i = PartnerImpact.fromMap({'families_referred': 3});
      expect(i.familiesReferred, 3);
      expect(i.contentConsumed, 0);
      expect(PartnerImpact.fromMap(const {}).isEmpty, isTrue);
    });
  });

  group('PartnerEarningRow', () {
    test('paise become whole rupees', () {
      const r = PartnerEarningRow(
          source: 'consultation',
          status: 'paid',
          entries: 4,
          partnerMinor: 128000);
      expect(r.amountLabel, '₹1280');
      expect(r.sourceLabel, 'Consultations');
      expect(r.statusLabel, 'paid out');
    });

    test('a source this build has never seen is shown, not swallowed', () {
      const r = PartnerEarningRow(
          source: 'workshop', status: 'pending', entries: 1, partnerMinor: 0);
      expect(r.sourceLabel, 'Workshop');
      expect(r.statusLabel, 'pending');
    });

    test('totals add up across sources', () {
      PartnerDashboardStore.instance.debugSeed(partner: _partner, earnings: const [
        PartnerEarningRow(
            source: 'consultation',
            status: 'paid',
            entries: 2,
            partnerMinor: 50000),
        PartnerEarningRow(
            source: 'referral',
            status: 'pending',
            entries: 9,
            partnerMinor: 22500),
      ]);
      expect(PartnerDashboardStore.instance.totalEarnedMinor, 72500);
    });
  });

  group('DoctorImpactScreen', () {
    testWidgets('a doctor with no families yet is told so kindly, not shown '
        'a wall of zeroes with no explanation', (tester) async {
      PartnerDashboardStore.instance
          .debugSeed(partner: _partner, impact: const PartnerImpact());
      await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: DoctorImpactScreen())));
      await tester.pump();
      expect(find.textContaining('yet to arrive'), findsOneWidget);
    });

    testWidgets('one family reads as one, not "1 families"', (tester) async {
      PartnerDashboardStore.instance.debugSeed(
          partner: _partner,
          impact: const PartnerImpact(familiesReferred: 1));
      await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: DoctorImpactScreen())));
      await tester.pump();
      expect(find.textContaining('One family'), findsOneWidget);
    });

    testWidgets('the real numbers render', (tester) async {
      PartnerDashboardStore.instance.debugSeed(
        partner: _partner,
        impact: const PartnerImpact(
          familiesReferred: 41,
          activeThisMonth: 28,
          pregnanciesSupported: 12,
          childrenAdded: 29,
          consultationsDone: 63,
          vaccinationsCompleted: 104,
          contentConsumed: 890,
        ),
      );
      await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: DoctorImpactScreen())));
      await tester.pump();
      expect(find.textContaining('41 families'), findsOneWidget);
      expect(find.text('Babies welcomed'), findsOneWidget);
      expect(find.text('104'), findsOneWidget);
      expect(find.text('890'), findsOneWidget);
    });

    testWidgets('the privacy boundary is stated to the doctor on the screen',
        (tester) async {
      // Taller than a phone: the note sits below the seven tiles, which is
      // where it belongs, so the default 600px test viewport never reaches it.
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      PartnerDashboardStore.instance.debugSeed(
          partner: _partner,
          impact: const PartnerImpact(familiesReferred: 5));
      await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: DoctorImpactScreen())));
      await tester.pump();
      expect(find.textContaining('These are totals only'), findsOneWidget);
    });

    testWidgets('a partner who is no longer active is told, not left guessing',
        (tester) async {
      PartnerDashboardStore.instance.debugSeed(
        partner: const CarePartner(
          id: 'cp_x',
          name: 'Dr Meera Rao',
          type: CarePartnerType.doctor,
          status: PartnerStatus.pending,
          expertId: 'exp_meera',
        ),
        impact: const PartnerImpact(),
      );
      await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: DoctorImpactScreen())));
      await tester.pump();
      expect(find.text(PartnerStatus.pending.label), findsOneWidget);
    });
  });

  group('DoctorReferralKitScreen — the entry point to everything', () {
    testWidgets('a verified partner gets a real, scannable QR', (tester) async {
      PartnerDashboardStore.instance
          .debugSeed(partner: _partner, token: 'KM7QX2PDVR');
      await tester.pumpWidget(
          const MaterialApp(home: DoctorReferralKitScreen()));
      await tester.pump();
      final qr = tester.widget<QrImageView>(find.byType(QrImageView));
      final encoded =
          (qr.key as ValueKey<String>).value.replaceFirst('care-qr:', '');
      // The SERVER's token, not a computed one.
      expect(encoded, CarePartnerEngine.linkFor('KM7QX2PDVR'));
      expect(encoded, contains('/care/'));
      // Never the parent-invite path: two systems, two code spaces.
      expect(encoded, isNot(contains('/invite/')));
    });

    testWidgets('the code on screen is the code inside the QR', (tester) async {
      PartnerDashboardStore.instance
          .debugSeed(partner: _partner, token: 'KM7QX2PDVR');
      await tester.pumpWidget(
          const MaterialApp(home: DoctorReferralKitScreen()));
      await tester.pump();
      expect(find.text('KM7QX2PDVR'), findsOneWidget);
    });

    testWidgets('a partner with NO server token prints nothing — a computed '
        'code would scan, look right and credit nobody', (tester) async {
      PartnerDashboardStore.instance.debugSeed(partner: _partner);
      await tester.pumpWidget(
          const MaterialApp(home: DoctorReferralKitScreen()));
      await tester.pump();
      expect(find.byType(QrImageView), findsNothing);
      expect(find.textContaining('no referral code has been issued'),
          findsOneWidget);
    });

    testWidgets('an unapproved doctor is told, not handed a broken code',
        (tester) async {
      PartnerDashboardStore.instance.reset();
      await tester.pumpWidget(
          const MaterialApp(home: DoctorReferralKitScreen()));
      await tester.pump();
      expect(find.byType(QrImageView), findsNothing);
      expect(find.textContaining('Not set up yet'), findsOneWidget);
    });

    testWidgets('nothing on the kit mentions money — patients see this screen',
        (tester) async {
      PartnerDashboardStore.instance
          .debugSeed(partner: _partner, token: 'KM7QX2PDVR');
      await tester.pumpWidget(
          const MaterialApp(home: DoctorReferralKitScreen()));
      await tester.pump();
      for (final word in ['commission', 'earn', '₹', 'per referral']) {
        expect(find.textContaining(word, findRichText: true), findsNothing,
            reason: 'the referral kit must not mention "$word"');
      }
    });
  });

  group('DoctorImpactTab', () {
    testWidgets('opens on Impact, with Earnings one tap away', (tester) async {
      PartnerDashboardStore.instance.debugSeed(
          partner: _partner,
          impact: const PartnerImpact(familiesReferred: 3));
      await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: DoctorImpactTab())));
      await tester.pump();
      expect(find.byType(DoctorImpactScreen), findsOneWidget);
      expect(find.text('Earnings'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------
  // The half of this feature that is not Dart.
  // ---------------------------------------------------------------------
  group('migration 0037 keeps partners out of family rows', () {
    final sql =
        File('supabase/migrations/0037_care_partners.sql').readAsStringSync();

    test('the two partner-facing functions are SECURITY DEFINER with a pinned '
        'search_path', () {
      for (final fn in ['partner_impact', 'partner_earnings']) {
        final start = sql.indexOf('function public.$fn(');
        expect(start, greaterThan(-1), reason: '$fn is missing');
        final body = sql.substring(start, sql.indexOf(r'$$;', start));
        expect(body.contains("security definer set search_path = ''"), isTrue,
            reason: '$fn must be security definer with a pinned search_path');
      }
    });

    test('both check the caller owns the partner before returning anything',
        () {
      for (final fn in ['partner_impact', 'partner_earnings']) {
        final start = sql.indexOf('function public.$fn(');
        final body = sql.substring(start, sql.indexOf(r'$$;', start));
        expect(body.contains('ea.user_id = auth.uid()'), isTrue,
            reason: '$fn must be scoped to the calling expert account');
      }
    });

    test('partner_impact returns counts only — no user ids in its signature',
        () {
      final start = sql.indexOf('function public.partner_impact(');
      final sig = sql.substring(start, sql.indexOf('language sql', start));
      expect(sig.contains('user_id'), isFalse,
          reason: 'partner_impact must never return a family identifier');
      expect(sig.contains('bigint'), isTrue);
    });

    test('there is no policy anywhere granting a partner select on a family '
        'table', () {
      // partner_attributions and parent_timeline hold family rows. Their only
      // select policies must be the parent reading her own.
      for (final table in ['partner_attributions', 'parent_timeline']) {
        final policies = RegExp(
                'create policy "[^"]*" on public\\.$table\\s+for (\\w+)[^;]*;',
                multiLine: true)
            .allMatches(sql);
        for (final m in policies) {
          if (m.group(1) == 'select') {
            expect(m.group(0)!.contains('auth.uid()'), isTrue,
                reason: '$table select policy must be scoped to the user');
            expect(m.group(0)!.contains('care_partners'), isFalse,
                reason: 'no $table policy may key off a partner');
          }
        }
      }
    });
  });
}
