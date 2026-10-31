// =============================================================================
//  Phase 6b leftover L3: the phone's quiet, as dates (0151)
// -----------------------------------------------------------------------------
//  The yes/no `quiet` was as fresh as her last app open, so an offer could be
//  booked in her two-week wait if she had not opened the app since her
//  fertile window. Now the phone sends WHICH evenings in the next 14 days are
//  quiet, and the server reads the date. The yes/no stays the fallback.
//
//  The SQL proof is supabase/seed/verify_push_quiet_evenings.sql. This pins:
//  the day walk (pure), the wire, the wiring, the fallback rule in
//  pv_push_check, that 0151's pv_push_check is 0143's with ONLY the quiet
//  rule changed, and that the server still never reads a TTC table.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/services/push_audience.dart';
import 'package:parentveda/services/push_wire.dart';

const _migration = 'supabase/migrations/0151_push_quiet_evenings.sql';
const _b3 = 'supabase/migrations/0143_push_campaigns_and_sends.sql';

String _live(String path) => File(path)
    .readAsStringSync()
    .split('\n')
    .map((l) {
      final i = l.indexOf('--');
      return i < 0 ? l : l.substring(0, i);
    })
    .where((l) => l.trim().isNotEmpty)
    .join('\n');

String _code(String path) => File(path)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

String _fn(String sql, String fn) {
  final m = RegExp(
    'create or replace function public\\.$fn\\(.*?\\\$\\\$(.*?)\\\$\\\$;',
    dotAll: true,
  ).firstMatch(sql);
  expect(m, isNotNull, reason: '$fn is not created');
  return m!.group(1)!;
}

void main() {
  group('the day walk', () {
    final first = DateTime(2026, 10, 31);

    test('fifteen days, today to 14 on, by the calendar', () {
      final seen = <DateTime>[];
      pushQuietDays(first, (d) {
        seen.add(d);
        return false;
      });
      expect(seen.length, kPushAudienceDays + 1);
      expect(seen.first, first);
      expect(seen.last, DateTime(2026, 11, 14));
    });

    test('only the days the rule calls quiet', () {
      // Her two-week wait from 3 Nov to 9 Nov, as the phone would project it.
      final out = pushQuietDays(first, (d) =>
          !d.isBefore(DateTime(2026, 11, 3)) && !d.isAfter(DateTime(2026, 11, 9)));
      expect(out.first, DateTime(2026, 11, 3));
      expect(out.last, DateTime(2026, 11, 9));
      expect(out.length, 7);
    });

    test('each day asks the same rule as the yes/no', () {
      final src = _code('lib/services/push_audience.dart');
      final walk = src.substring(src.indexOf('List<DateTime> pushTtcQuietEvenings('),
          src.indexOf('List<DateTime> pushQuietDays('));
      expect(walk, contains('pushTtcQuietFrom('));
      expect(walk, contains('ttcDayContext(day, now: t).phase'));
      expect(walk, contains('ttcTreatmentActive(TtcTreatmentStore.instance.cycle, day)'));
      expect(walk, contains('c.restartOn != null && c.lastPeriodStart == null'));
      expect(walk, contains('LifeStage.tryingToConceive'));
      expect(walk, contains('PushWire.istDay(t)'));
      // An unknown day is quiet, as in pushTtcQuiet.
      expect(walk, contains('catch (_) {\n      return true;'));
    });
  });

  group('the wire', () {
    test('quiet evenings travel as dates, nothing else', () {
      final p = PushWire.audienceParams(
          busyEvenings: const [], quiet: true,
          quietEvenings: [DateTime(2026, 11, 3), DateTime(2026, 11, 4)]);
      expect(p['p_quiet_evenings'], ['2026-11-03', '2026-11-04']);
      expect(p['p_quiet'], true);
    });

    test('an upload carries them, and a change of dates is a new upload', () async {
      final sent = <Map<String, dynamic>>[];
      PushWire.call = (fn, params) async => sent.add({'fn': fn, ...params});
      PushWire.userId = () => 'u1';
      PushAudience.instance.debugReset();
      final now = DateTime.utc(2026, 10, 31, 4);
      PushAudience.instance.upload(rings: const [], quiet: false,
          quietEvenings: [DateTime(2026, 11, 3)], now: now);
      PushAudience.instance.upload(rings: const [], quiet: false,
          quietEvenings: [DateTime(2026, 11, 3)], now: now);
      PushAudience.instance.upload(rings: const [], quiet: false,
          quietEvenings: [DateTime(2026, 11, 3), DateTime(2026, 11, 4)], now: now);
      await pumpEventQueue();
      expect(sent.length, 2);
      expect(sent.first['p_quiet_evenings'], ['2026-11-03']);
      expect(sent.last['p_quiet_evenings'], ['2026-11-03', '2026-11-04']);
      PushAudience.instance.debugReset();
    });

    test('FamilyPhone sends them with the yes/no', () {
      final src = _code('lib/services/family_phone_plan.dart');
      expect(src, contains('quiet: pushTtcQuiet(now: now),'));
      expect(src, contains('quietEvenings: pushTtcQuietEvenings(now: now),'));
    });
  });

  group('the server', () {
    final sql = _live(_migration);

    test('the column is nullable: null means an older build', () {
      expect(sql, contains('add column if not exists quiet_evenings date[];'));
      expect(sql, isNot(contains('quiet_evenings date[] not null')));
    });

    test('the old two-argument function is dropped, the new one defaults', () {
      expect(sql, contains('drop function if exists public.pv_push_audience(date[], boolean);'));
      expect(sql, contains('p_quiet_evenings date[] default null'));
      expect(sql, contains(
          'grant execute on function public.pv_push_audience(date[], boolean, date[]) to authenticated;'));
      expect(sql, contains(
          'revoke all on function public.pv_push_audience(date[], boolean, date[]) from public, anon;'));
    });

    test('the dates are kept to the same fortnight as busy', () {
      final f = _fn(sql, 'pv_push_audience');
      expect(RegExp(r'where d between today and today \+ 14;').allMatches(f).length, 2);
      expect(f, contains('if p_quiet_evenings is not null then'));
    });

    test('phone_quiet: dates inside the upload\'s fortnight, else the yes/no', () {
      final c = _fn(sql, 'pv_push_check');
      expect(c, contains('when a.quiet_evenings is null\n'
          '               then coalesce(a.quiet, false)'));
      expect(c, contains(
          "when p_on between (a.planned_at at time zone 'Asia/Kolkata')::date\n"
          "                           and (a.planned_at at time zone 'Asia/Kolkata')::date + k.quiet_days\n"
          '               then p_on = any (a.quiet_evenings)'));
      expect(c, contains('else coalesce(a.quiet, false)'));
      expect(c, contains('14 as quiet_days'));
    });

    test('0151\'s pv_push_check is 0143\'s with only the quiet rule changed', () {
      List<String> lines(String body) => [
            for (final l in body.split('\n'))
              if (!l.contains('quiet')) l.trim(),
          ]..removeWhere((l) => l.isEmpty);
      final before = lines(_fn(_live(_b3), 'pv_push_check'));
      final after = lines(_fn(sql, 'pv_push_check'));
      // The fallback case adds "when", "then", "else", "end" lines around the
      // quiet ones; drop the case's own scaffolding and compare the rest.
      const scaffold = {
        'when case',
        'end',
        "when p_on between (a.planned_at at time zone 'Asia/Kolkata')::date",
      };
      expect(after.where((l) => !scaffold.contains(l)).toList(), before);
    });

    test('still no TTC table is read: dates only', () {
      final c = _fn(sql, 'pv_push_check');
      expect(RegExp(r'public\.ttc_').hasMatch(c), isFalse);
      expect(RegExp(r'public\.ttc_').hasMatch(_fn(sql, 'pv_push_audience')), isFalse);
    });

    test('pv_push_check stays service_role only', () {
      expect(sql, contains(
          'revoke all on function public.pv_push_check(date, text) from public, anon, authenticated;'));
      expect(sql, contains(
          'grant execute on function public.pv_push_check(date, text) to service_role;'));
    });
  });
}
