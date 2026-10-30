// =============================================================================
//  A solo doctor's Impact screen holds back small numbers (R3, 0141)
// -----------------------------------------------------------------------------
//  Decided by the user 2026-10-30 (STILL-OPEN §5.1e, option A): what families
//  DID is withheld below the server's min_cohort, for doctors as for
//  employers, schools and IVF centres. Families referred and active stay.
//
//  Two halves, as partner_dashboard_test: the migration (read on its LATEST
//  definition, so a later create-or-replace that drops the rule fails here),
//  and the screen (a dash and the reason, never a 0).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/care_partner/care_partner_models.dart';
import 'package:parentveda/care_partner/partner_dashboard_store.dart';
import 'package:parentveda/screens/doctor/doctor_impact_screen.dart';

List<File> _migrations() =>
    Directory('supabase/migrations')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.sql'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

String _code(String sql) =>
    sql.split('\n').where((l) => !l.trimLeft().startsWith('--')).join('\n');

/// The LAST definition of public.[name] (`create function` or
/// `create or replace function`), and the file it is in.
({String file, String body}) _last(String name) {
  final head = RegExp('create (or replace )?function public\\.$name\\(');
  String? file;
  String? body;
  for (final f in _migrations()) {
    final code = _code(f.readAsStringSync().replaceAll('\r\n', '\n'));
    final all = head.allMatches(code).toList();
    if (all.isEmpty) continue;
    final at = all.last.start;
    final open = code.indexOf(r'$$', at);
    final close = code.indexOf(r'$$', open + 2);
    file = f.uri.pathSegments.last;
    body = code.substring(at, close);
  }
  if (body == null) fail('no definition of public.$name');
  return (file: file!, body: body);
}

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

  group('0141 · partner_impact and partner_funnel', () {
    final impact = _last('partner_impact');
    final funnel = _last('partner_funnel');
    final all = _migrations().map((f) => _code(f.readAsStringSync())).join();

    test('both live in 0141 now, still gated by caller_owns_partner only', () {
      expect(impact.file, '0141_doctor_impact_small_numbers.sql');
      expect(funnel.file, '0141_doctor_impact_small_numbers.sql');
      for (final b in [impact.body, funnel.body]) {
        expect(b, contains('public.caller_owns_partner(p_partner_id)'));
        expect(b, contains("security definer set search_path = ''"));
        expect(
          b,
          contains('public.sponsor_analytics_config'),
          reason: 'one privacy dial for sponsors, centres and doctors',
        );
      }
    });

    test('a changed return type is dropped first, and the grant restated', () {
      final sql = _code(
        File(
          'supabase/migrations/0141_doctor_impact_small_numbers.sql',
        ).readAsStringSync().replaceAll('\r\n', '\n'),
      );
      expect(
        sql.indexOf('drop function if exists public.partner_impact(text);'),
        lessThan(sql.indexOf('create function public.partner_impact(')),
      );
      expect(
        all,
        contains(
          'grant execute on function public.partner_impact(text) to authenticated;',
        ),
      );
      expect(
        all,
        contains(
          'revoke execute on function public.partner_impact(text) from public, anon;',
        ),
      );
    });

    test('behaviour is null when held back; referral facts never are', () {
      // Five behaviour columns, each behind the threshold.
      expect(
        'case when (select h from held) then null'
            .allMatches(impact.body)
            .length,
        5,
      );
      for (final e in const [
        'pregnancy_added',
        'child_added',
        'consultation_completed',
        'vaccination_completed',
        'content_read',
      ]) {
        expect(impact.body, contains("t.event = '$e'"));
      }
      // Families and active are computed outside any case.
      final select = impact.body.substring(impact.body.lastIndexOf('select\n'));
      final firstCase = select.indexOf('case when');
      expect(select.indexOf('(select count(*) from fam)'), lessThan(firstCase));
      expect(select.indexOf("interval '30 days'"), lessThan(firstCase));
      // The funnel: only activated is held back.
      expect('case when'.allMatches(funnel.body).length, 1);
      expect(
        funnel.body.indexOf('case when'),
        greaterThan(funnel.body.indexOf('signed_up_at is not null')),
      );
    });

    test('the same counting definitions the other two readers rely on', () {
      // my_doctor_referrals (0133) and care_org_dashboard (0139) promise a
      // number reads the same everywhere. Pinned on the latest definitions.
      expect(impact.body, contains("t.at > now() - interval '30 days'"));
      expect(funnel.body, contains('where signed_up_at is not null'));
      expect(
        funnel.body,
        contains("t.event in ('pregnancy_added','child_added')"),
      );
    });

    test('still counts only: no family identifier in either signature', () {
      for (final b in [impact.body, funnel.body]) {
        final sig = b.substring(0, b.indexOf('language sql'));
        expect(sig.contains('user_id'), isFalse);
      }
      expect(impact.body, contains('suppressed'));
      expect(impact.body, contains('min_cohort'));
    });
  });

  group('the model', () {
    test('held back: behaviour is null even if a figure arrives with it', () {
      final i = PartnerImpact.fromMap({
        'families_referred': 2,
        'active_this_month': 1,
        'pregnancies_supported': 1,
        'suppressed': true,
        'min_cohort': 7,
      });
      expect(i.familiesReferred, 2);
      expect(i.activeThisMonth, 1);
      expect(i.pregnanciesSupported, isNull);
      expect(i.childrenAdded, isNull);
      expect(i.suppressed, isTrue);
      expect(i.minCohort, 7);
    });

    test(
      'not held back: numbers as they come; a missing column is still 0',
      () {
        final i = PartnerImpact.fromMap({
          'families_referred': 9,
          'pregnancies_supported': 3,
          'suppressed': false,
        });
        expect(i.pregnanciesSupported, 3);
        expect(i.contentConsumed, 0);
      },
    );

    test('a held-back funnel step is null, and so is its percentage', () {
      final f = PartnerFunnel.fromMap({'signed_up': 2, 'activated': null});
      expect(f.activated, isNull);
      expect(f.activationPct, isNull);
    });
  });

  group('the screen', () {
    testWidgets('dashes and the server threshold, families still shown', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 3600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      PartnerDashboardStore.instance.debugSeed(
        partner: _partner,
        impact: PartnerImpact.fromMap({
          'families_referred': 2,
          'active_this_month': 1,
          'suppressed': true,
          'min_cohort': 7,
        }),
        funnel: PartnerFunnel.fromMap({
          'scanned': 2,
          'installed': 2,
          'signed_up': 2,
          'activated': null,
        }),
      );
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DoctorImpactScreen())),
      );
      await tester.pump();
      expect(find.textContaining('2 families'), findsOneWidget);
      // Five held-back tiles and the funnel's "told us about their family".
      expect(find.text('—'), findsNWidgets(6));
      expect(find.textContaining('shown once 7 have joined'), findsOneWidget);
      expect(find.textContaining('shown once 5'), findsNothing);
    });

    testWidgets('above the threshold: no dash, no note', (tester) async {
      PartnerDashboardStore.instance.debugSeed(
        partner: _partner,
        impact: PartnerImpact.fromMap({
          'families_referred': 12,
          'active_this_month': 8,
          'pregnancies_supported': 4,
          'children_added': 2,
          'consultations_done': 6,
          'vaccinations_completed': 9,
          'content_consumed': 50,
          'suppressed': false,
          'min_cohort': 5,
        }),
      );
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DoctorImpactScreen())),
      );
      await tester.pump();
      expect(find.text('—'), findsNothing);
      expect(
        find.textContaining('What families did is shown once'),
        findsNothing,
      );
    });
  });
}
