// =============================================================================
//  ParentVeda+ shell — reachability, the ledger contract, and the money rules
// -----------------------------------------------------------------------------
//  Three things this repo has been bitten by, pinned for the doctor app:
//
//  1. UNWIRED-BUT-CORRECT CODE. The 2026-09-18 rework retired five screens and
//     replaced them with *_tab.dart files. Test counts prove nothing about
//     reachability, so this reads the scaffold's source and asserts which
//     files it actually opens — and that main_doctor still opens the scaffold.
//
//  2. SILENT SCHEMA DRIFT. Every read the ledger makes goes through an RPC
//     whose name and parameters are strings on both sides. A renamed function
//     or column fails silently (the store keeps its cache). The names are
//     pinned against the migration text, in the spirit of
//     ttc_schema_contract_test.
//
//  3. MONEY COMPUTED ON THE PHONE. The whole point of 0084 is that no screen
//     multiplies a price by a share. kDoctorSharePct must not be referenced
//     by any live doctor file.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/doctor/doctor_ledger.dart';
import 'package:parentveda/screens/doctor/doctor_chrome.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  group('the shell opens the live screens and none of the retired ones', () {
    final scaffold = _read('lib/screens/doctor/doctor_scaffold.dart');
    final live = scaffold.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');

    test('main_doctor boots DoctorScaffold behind DoctorAuthScreen', () {
      final main = _read('lib/main_doctor.dart');
      expect(main, contains('const DoctorScaffold()'));
      expect(main, contains('DoctorAuthScreen('));
    });

    test('five tabs, in the decided order', () {
      for (final tab in const [
        'DoctorHomeTab(',
        'DoctorAppointmentsTab(',
        'DoctorAvailabilityTab(',
        'DoctorEarningsTab(',
        'DoctorProfileTab(',
      ]) {
        expect(live, contains(tab), reason: '$tab is not reachable from the shell');
      }
      expect(live.indexOf('DoctorHomeTab('), lessThan(live.indexOf('DoctorAppointmentsTab(')));
      expect(live.indexOf('DoctorAvailabilityTab('), lessThan(live.indexOf('DoctorEarningsTab(')));
      expect(live.indexOf('DoctorEarningsTab('), lessThan(live.indexOf('DoctorProfileTab(')));
    });

    test('the retired screens are not opened by the shell', () {
      for (final old in const [
        'DoctorHomeScreen(',
        'DoctorAppointmentsScreen(',
        'DoctorScheduleScreen(',
        'DoctorImpactTab(',
        'DoctorProfileScreen(',
        'DoctorEarningsScreen(',
      ]) {
        expect(live, isNot(contains(old)), reason: '$old came back');
      }
    });

    test('the shell uses the shared PvNavBar, not its own bar', () {
      expect(live, contains('PvNavBar('));
      expect(live, isNot(contains('BottomNavigationBar(')));
    });

    test('every pushed doctor route is named, so the Ask FAB and tests can see it', () {
      final files = Directory('lib/screens/doctor')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('_tab.dart') ||
              f.path.endsWith('doctor_source_screen.dart') ||
              f.path.endsWith('doctor_payouts_screen.dart'));
      for (final f in files) {
        final src = _read(f.path);
        final pushes = 'MaterialPageRoute'.allMatches(src).length;
        final named = 'RouteSettings(name:'.allMatches(src).length;
        expect(named, greaterThanOrEqualTo(pushes),
            reason: '${f.path}: $pushes pushes, $named named');
      }
    });
  });

  group('no live doctor screen computes money', () {
    test('kDoctorSharePct is referenced only by the retired earnings pair', () {
      final dir = Directory('lib/screens/doctor').listSync().whereType<File>();
      for (final f in dir) {
        final name = f.path.replaceAll('\\', '/').split('/').last;
        if (name == 'doctor_earnings_screen.dart') continue; // retired, kept
        expect(_read(f.path), isNot(contains('kDoctorSharePct')),
            reason: '$name multiplies a price by a share on the phone');
      }
      final ledger = _read('lib/doctor/doctor_ledger.dart');
      expect(ledger, isNot(contains('kDoctorSharePct')));
      expect(ledger, isNot(contains('* 0.8')));
    });
  });

  group('the ledger contract — Dart strings match 0084', () {
    final sql = _read('supabase/migrations/0084_expert_earnings.sql');
    final ledger = _read('lib/doctor/doctor_ledger.dart');
    final session = _read('lib/doctor/doctor_session.dart');

    test('every RPC the client calls is created and granted to authenticated', () {
      for (final fn in const [
        'my_earnings_summary',
        'my_earnings',
        'my_payouts',
        'my_payout_items',
        'my_videos',
        'my_share_rates',
        'claim_expert_invite',
      ]) {
        expect(sql, contains('create or replace function public.$fn('), reason: '$fn missing');
        expect(sql, matches(RegExp('grant execute on function public\\.$fn\\([^)]*\\)\\s+to authenticated')),
            reason: '$fn not granted to authenticated');
        expect('$ledger\n$session', contains("'$fn'"), reason: '$fn not called by the client');
      }
    });

    test('the RPC parameter names agree', () {
      expect(sql, contains('p_from timestamptz, p_to timestamptz'));
      expect(ledger, contains("'p_from'"));
      expect(ledger, contains("'p_to'"));
      expect(sql, contains('p_source text default null'));
      expect(ledger, contains("'p_source'"));
      expect(sql, contains('my_payout_items(p_payout_id text)'));
      expect(ledger, contains("'p_payout_id'"));
    });

    test('the summary json keys the client reads are the ones the SQL builds', () {
      for (final key in const [
        'owed_paise', 'accrued_paise', 'paid_paise', 'lifetime_paise',
        'period_paise', 'period_upcoming', 'next_payout', 'by_source',
      ]) {
        expect(sql, contains("'$key',"), reason: '$key not built by my_earnings_summary');
        expect(ledger, contains("'$key'"), reason: '$key not read by LedgerSummary');
      }
    });

    test('the payout-account columns the client writes exist, and status is forced pending', () {
      for (final col in const ['account_name', 'account_number', 'ifsc', 'pan', 'upi_id', 'status', 'reason', 'submitted_at']) {
        expect(sql, contains(RegExp('\\n\\s+$col\\s')), reason: '$col missing from expert_payout_accounts');
        expect(ledger, contains("'$col'"));
      }
      expect(sql, contains("with check (expert_id in (select public.my_expert_ids()) and status = 'pending')"));
    });

    test('book_slot gained price_paise and the client sends it', () {
      expect(sql, contains('p_price_paise  int  default null'));
      expect(sql, contains('drop function if exists public.book_slot('));
      expect(_read('lib/services/remote/supabase_repo.dart'), contains("'p_price_paise': priceMinor"));
      expect(_read('lib/booking/booking_store.dart'), contains('priceMinor:'));
    });

    test('share_bps is not capped at 50% — a delivery share is not a commission', () {
      expect(sql, contains('share_bps      int         not null check (share_bps between 0 and 10000)'));
    });

    test('the placeholder seed says so on every row', () {
      final seed = sql.substring(sql.indexOf('insert into public.expert_share_rules'), sql.indexOf('on conflict do nothing'));
      final rows = seed.split('\n').where((l) => l.trim().startsWith("('"));
      expect(rows.length, 7);
      for (final r in rows) {
        expect(r, contains('PLACEHOLDER'), reason: 'a seeded rate without the placeholder note: $r');
      }
    });

    test('the sources agree on both sides (0085 widened them)', () {
      const sources = ['consultation', 'masterclass', 'cohort', 'course', 'video', 'article', 'affiliate', 'sponsorship', 'product', 'referral', 'other'];
      final sql85 = _read('supabase/migrations/0085_expert_share_rates.sql');
      // 0085 writes the list across two lines; compare without whitespace.
      final flat = sql85.replaceAll(RegExp(r'\s+'), '');
      expect(flat, contains("check(sourcein('${sources.join("','")}'))"));
      expect(EarningSource.values.map((e) => e.name).toList(), sources);
    });

    test('0085 carries the workbook, and the workbook corrected 13.0', () {
      final sql85 = _read('supabase/migrations/0085_expert_share_rates.sql');
      // Consultations: a flat 80%, and no 85% tier anywhere in the real rows.
      expect(sql85, contains("('consultation', 'platform', 0, 8000,"));
      expect(sql85, isNot(contains('8500')));
      // Recorded courses: 30% through ours, 55% through the doctor's code.
      expect(sql85, contains("('course',       'platform', 0, 3000,"));
      expect(sql85, contains("('course',       'own_code', 0, 5500,"));
      // Live courses 55%, content 20%, sponsorship 35%, products 10%.
      expect(sql85, contains("('masterclass',  'platform', 0, 5500,"));
      expect(sql85, contains("('video',        'platform', 0, 2000,"));
      expect(sql85, contains("('sponsorship',  'platform', 0, 3500,"));
      expect(sql85, contains("('product',      'platform', 0, 1000,"));
      // No placeholder survives with an open end.
      expect(sql85, contains("where note like 'PLACEHOLDER%'"));
      // The arity trap: every changed signature is dropped first.
      for (final fn in const ['resolve_share_bps', 'write_expert_earning', 'my_earnings', 'my_share_rates', 'add_manual_expert_earning']) {
        expect(sql85, contains('drop function if exists public.$fn('), reason: '$fn re-created without dropping the old arity');
      }
      // The client reads the channel the SQL now returns.
      expect(_read('lib/doctor/doctor_ledger.dart'), contains("j['channel']"));
    });
  });

  group('formatting a clinician can read', () {
    test('rupees group the Indian way', () {
      expect(dcRupees(0), '₹0');
      expect(dcRupees(80000), '₹800');
      expect(dcRupees(120000000), '₹12,00,000');
      expect(dcRupees(1234567800), '₹1,23,45,678');
      expect(dcRupees(-64000), '−₹640');
      expect(dcRupees(64050, showPaise: true), '₹640.50');
    });

    test('percent from basis points', () {
      expect(dcPercent(8000), '80%');
      expect(dcPercent(8250), '82.5%');
      expect(dcPercent(0), '0%');
    });

    test('a period is half-open at local midnight', () {
      final now = DateTime(2026, 9, 18, 15);
      expect(LedgerPeriod.thisMonth.range(now), (DateTime(2026, 9), DateTime(2026, 10)));
      expect(LedgerPeriod.lastMonth.range(now), (DateTime(2026, 8), DateTime(2026, 9)));
      expect(LedgerPeriod.thisYear.range(now), (DateTime(2026), DateTime(2027)));
    });
  });

  group('the summary parses what the server sends', () {
    test('by_source rows and the headline numbers', () {
      final s = LedgerSummary.fromJson({
        'owed_paise': 4200000,
        'accrued_paise': 160000,
        'paid_paise': 9000000,
        'lifetime_paise': 13200000,
        'period_paise': 4200000,
        'period_upcoming': 160000,
        'next_payout': '2026-10-07',
        'by_source': [
          {'source': 'consultation', 'expert_paise': 4000000, 'gross_paise': 5000000, 'items': 50, 'share_bps': 8000},
          {'source': 'video', 'expert_paise': 200000, 'gross_paise': 400000, 'items': 1, 'share_bps': 5000},
        ],
      });
      expect(s.owedPaise, 4200000);
      expect(s.nextPayout, DateTime(2026, 10, 7));
      expect(s.forSource(EarningSource.consultation)!.items, 50);
      expect(s.forSource(EarningSource.video)!.shareBps, 5000);
      expect(s.forSource(EarningSource.cohort), isNull);
    });

    test('a row with a counterparty leads with the parent, otherwise the title', () {
      final consult = EarningRow.fromJson({
        'id': 'ern_1', 'source': 'consultation', 'ref_kind': 'booking', 'title': 'Consultation',
        'counterparty': 'Priya S.', 'occurred_at': '2026-09-14T10:30:00Z',
        'gross_paise': 80000, 'share_bps': 8000, 'expert_paise': 64000, 'platform_paise': 16000, 'status': 'payable',
      });
      expect(consult.headline, 'Priya S.');
      expect(consult.status, EarningStatus.payable);
      final video = EarningRow.fromJson({
        'id': 'ern_2', 'source': 'video', 'ref_kind': 'video', 'title': 'Video: Sleep basics',
        'occurred_at': '2026-09-30T00:00:00Z', 'gross_paise': 400000, 'share_bps': 5000,
        'expert_paise': 200000, 'platform_paise': 200000, 'status': 'paid',
      });
      expect(video.headline, 'Video: Sleep basics');
      expect(video.isReversal, isFalse);
    });
  });
}
