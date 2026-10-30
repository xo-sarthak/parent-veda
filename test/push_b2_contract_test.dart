// =============================================================================
//  Phase 6b, B2: the phone's push writes must match 0140, and reach it
// -----------------------------------------------------------------------------
//  Every push write swallows its error (a cloud failure is never a crash), so
//  a `p_` key that does not match the SQL fails on every phone with nothing
//  to show for it. The same trap as test/ttc_schema_contract_test.dart, one
//  layer over: here the phone calls functions, so the contract is each
//  function's parameter list, plus the stage, source and platform words the
//  table checks accept.
//
//  Also pinned: the opt-out queue (a "no" is kept until the server answers,
//  latest wins, other accounts wait), the busy-evenings shape, and the wiring
//  (sign-out order, the wipe keep-list, FamilyPhone, all three stores).
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/auth/local_wipe.dart';
import 'package:parentveda/services/push_audience.dart';
import 'package:parentveda/services/push_consent.dart';
import 'package:parentveda/services/push_service.dart';
import 'package:parentveda/services/push_wire.dart';

const _migration = 'supabase/migrations/0140_push_devices_consent_audience.sql';

String _sql() => File(_migration).readAsStringSync();

String _code(String path) => File(path)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

/// The parameter names of `public.<fn>(...)` as created in the migration.
List<String> _params(String sql, String fn) {
  final m = RegExp(
    'create or replace function public\\.$fn\\((.*?)\\)\\s*returns',
    dotAll: true,
  ).firstMatch(sql);
  expect(m, isNotNull, reason: '$fn is not created in $_migration');
  return [
    for (final part in m!.group(1)!.split(','))
      if (part.trim().isNotEmpty) part.trim().split(RegExp(r'\s+')).first,
  ];
}

/// The columns of `public.<table>` as created in the migration.
List<String> _columns(String sql, String table) {
  final m = RegExp(
    'create table if not exists public\\.$table \\((.*?)\\n\\);',
    dotAll: true,
  ).firstMatch(sql);
  expect(m, isNotNull, reason: '$table is not created in $_migration');
  final out = <String>[];
  for (final line in m!.group(1)!.split('\n')) {
    final t = line.trim();
    if (t.isEmpty || t.startsWith('--') || t.startsWith('primary key')) {
      continue;
    }
    out.add(t.split(RegExp(r'\s+')).first);
  }
  return out;
}

/// The values a column's `check (... in (...))` accepts.
List<String> _checkValues(String sql, String table, String column) {
  final cols = RegExp(
    'create table if not exists public\\.$table \\((.*?)\\n\\);',
    dotAll: true,
  ).firstMatch(sql)!.group(1)!;
  final m = RegExp("$column\\s.*?check \\($column in \\(([^)]*)\\)\\)")
      .firstMatch(cols);
  expect(m, isNotNull, reason: '$table.$column has no in-list check');
  return [
    for (final v in m!.group(1)!.split(',')) v.trim().replaceAll("'", ''),
  ];
}

void main() {
  group('the wire matches 0140', () {
    final sql = _sql();

    test('each builder sends exactly the function\'s parameters', () {
      final sent = {
        PushWire.register: PushWire.registerParams(
            deviceId: 'd' * 32, token: 't' * 40, platform: 'android',
            linkVersion: PushService.linkVersion),
        PushWire.unregister: PushWire.unregisterParams('d' * 32),
        PushWire.consent: PushWire.consentParams(
            stage: PushWire.stageTrying, granted: false,
            source: PushWire.sourceCard, decidedAt: DateTime(2026, 10, 30)),
        PushWire.audience: PushWire.audienceParams(
            busyEvenings: [DateTime(2026, 10, 31)], quiet: true),
      };
      for (final e in sent.entries) {
        expect(e.value.keys.toList(), _params(sql, e.key), reason: e.key);
      }
    });

    test('the three tables have the columns the plan names', () {
      expect(_columns(sql, 'push_devices'), [
        'user_id', 'device_id', 'token', 'platform', 'link_version',
        'created_at', 'last_seen_at',
      ]);
      expect(_columns(sql, 'push_consent'), [
        'user_id', 'stage', 'granted', 'decided_at', 'source', 'updated_at',
      ]);
      expect(_columns(sql, 'push_audience'),
          ['user_id', 'busy_evenings', 'quiet', 'planned_at']);
    });

    test('the stage, source and platform words are the ones the checks take',
        () {
      expect(_checkValues(sql, 'push_consent', 'stage'), [
        PushWire.stageTrying, PushWire.stagePregnancy, PushWire.stageParenting,
      ]);
      expect(_checkValues(sql, 'push_consent', 'source'),
          [PushWire.sourceCard, PushWire.sourceSwitch]);
      expect(_checkValues(sql, 'push_devices', 'platform'), ['android', 'ios']);
    });

    test('the stage words are profiles.life_stage\'s (the B3 join)', () {
      final stages = File('supabase/migrations/0082_onboarding_stage_and_code.sql')
          .readAsStringSync();
      for (final s in [
        PushWire.stageTrying, PushWire.stagePregnancy, PushWire.stageParenting,
      ]) {
        expect(stages, contains("'$s'"), reason: s);
      }
    });

    test('dates go as Postgres dates, the decision time in UTC', () {
      expect(PushWire.dateKey(DateTime(2026, 1, 5, 19)), '2026-01-05');
      final p = PushWire.consentParams(
          stage: PushWire.stageParenting, granted: true,
          source: PushWire.sourceSwitch,
          decidedAt: DateTime.utc(2026, 10, 30, 13, 30));
      expect(p['p_decided_at'], '2026-10-30T13:30:00.000Z');
    });

    test('nothing is writable directly; every write goes through a function',
        () {
      for (final t in ['push_devices', 'push_consent', 'push_audience']) {
        expect(sql, contains('alter table public.$t enable row level security'));
        expect(sql,
            contains('revoke all on table public.$t from anon, authenticated'));
        expect(sql, isNot(contains(RegExp('grant (insert|update|delete|all)'
            '[^;]*on table public\\.$t'))));
      }
      // Only consent may be read, and only her own.
      expect(sql, contains('grant select on table public.push_consent to authenticated'));
      expect(RegExp('create policy').allMatches(sql).length, 1);
      expect(sql, contains('using (user_id = (select auth.uid()))'));
      for (final fn in [
        PushWire.register, PushWire.unregister, PushWire.consent,
        PushWire.audience,
      ]) {
        final body = RegExp('function public\\.$fn\\(.*?\\\$\\\$;', dotAll: true)
            .firstMatch(sql)!.group(0)!;
        expect(body, contains('security definer set search_path = \'\''),
            reason: fn);
        expect(body, contains('if uid is null then'), reason: fn);
        expect(sql, contains(RegExp('grant execute on function public\\.$fn\\(')),
            reason: fn);
      }
    });

    test('one token, one row: unique, and taken from any other account', () {
      expect(sql, contains('create unique index if not exists push_devices_token_key'));
      expect(sql, contains('d.token = p_token or d.device_id = p_device_id'));
    });

    test('the newest decision wins, by when she decided', () {
      expect(sql, contains('where public.push_consent.decided_at <= excluded.decided_at'));
      expect(sql, contains('least(coalesce(p_decided_at, now()), now())'));
    });
  });

  group('the opt-out queue', () {
    late List<Map<String, dynamic>> calls;
    late bool failing;
    String? uid;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      calls = [];
      failing = false;
      uid = 'u1';
      PushWire.userId = () => uid;
      PushWire.call = (fn, params) async {
        if (failing) throw Exception('offline');
        calls.add({'fn': fn, ...params});
        return true;
      };
      PushConsent.instance.debugReset();
    });

    tearDown(() => PushConsent.instance.debugReset());

    test('a "no" is on disk before the network, and stays when it fails',
        () async {
      failing = true;
      await PushConsent.instance.record(
          stage: PushWire.stageTrying, granted: false,
          source: PushWire.sourceCard);
      await PushConsent.instance.flush();
      final q = await PushConsent.instance.pending();
      expect(q.keys, ['u1|trying']);
      expect(q['u1|trying']!['granted'], false);
      expect(calls, isEmpty);

      failing = false;
      await PushConsent.instance.flush();
      expect(await PushConsent.instance.pending(), isEmpty);
      expect(calls.single['fn'], PushWire.consent);
      expect(calls.single['p_granted'], false);
      expect(calls.single['p_stage'], 'trying');
    });

    test('a "yes" is sent once and never queued', () async {
      failing = true;
      await PushConsent.instance.record(
          stage: PushWire.stagePregnancy, granted: true,
          source: PushWire.sourceSwitch);
      await pumpEventQueue();
      expect(await PushConsent.instance.pending(), isEmpty);
    });

    test('a later "yes" clears a queued "no" for that stage only', () async {
      failing = true;
      await PushConsent.instance.record(
          stage: PushWire.stageParenting, granted: false,
          source: PushWire.sourceCard);
      await PushConsent.instance.record(
          stage: PushWire.stagePregnancy, granted: false,
          source: PushWire.sourceCard);
      await PushConsent.instance.record(
          stage: PushWire.stageParenting, granted: true,
          source: PushWire.sourceSwitch);
      await pumpEventQueue();
      expect((await PushConsent.instance.pending()).keys, ['u1|pregnancy']);
    });

    test('an entry waits for its own account', () async {
      failing = true;
      await PushConsent.instance.record(
          stage: PushWire.stageTrying, granted: false,
          source: PushWire.sourceCard);
      await pumpEventQueue(); // the record's own try has failed
      failing = false;
      uid = 'u2';
      await PushConsent.instance.flush();
      expect(calls, isEmpty);
      expect((await PushConsent.instance.pending()).keys, ['u1|trying']);
      uid = 'u1';
      await PushConsent.instance.flush();
      expect(calls.single['p_stage'], 'trying');
    });

    test('logged out records nothing', () async {
      uid = null;
      await PushConsent.instance.record(
          stage: PushWire.stageTrying, granted: false,
          source: PushWire.sourceCard);
      expect(await PushConsent.instance.pending(), isEmpty);
    });

    test('the queue and the device id survive the sign-out wipe', () {
      expect(LocalWipe.keep, contains(PushConsent.prefsKey));
      expect(LocalWipe.keep, contains(PushService.deviceIdKey));
    });
  });

  group('busy evenings and the quiet flag', () {
    final now = DateTime(2026, 10, 30, 9);

    test('evenings only, from today to 14 days, each once, in order', () {
      final out = pushBusyEvenings([
        DateTime(2026, 11, 2, 19),
        DateTime(2026, 10, 30, 7, 30), // a morning: not an evening
        DateTime(2026, 10, 30, 19),
        DateTime(2026, 11, 2, 20), // the same evening again
        DateTime(2026, 10, 29, 19), // yesterday
        DateTime(2026, 11, 13, 19), // day 14: kept
        DateTime(2026, 11, 14, 19), // day 15: past what the phone arms
      ], now);
      expect(out, [
        DateTime(2026, 10, 30), DateTime(2026, 11, 2), DateTime(2026, 11, 13),
      ]);
    });

    test('nothing armed is an empty list, which reads as all free', () {
      expect(pushBusyEvenings(const [], now), isEmpty);
    });

    test('an upload sends once per changed plan, and not logged out', () async {
      final sent = <Map<String, dynamic>>[];
      PushWire.call = (fn, params) async {
        sent.add({'fn': fn, ...params});
      };
      PushAudience.instance.debugReset();
      PushWire.userId = () => null;
      PushAudience.instance.upload(rings: [DateTime(2026, 10, 30, 19)],
          quiet: false, now: now);
      expect(sent, isEmpty);

      PushWire.userId = () => 'u1';
      for (var i = 0; i < 3; i++) {
        PushAudience.instance.upload(rings: [DateTime(2026, 10, 30, 19)],
            quiet: false, now: now);
      }
      PushAudience.instance.upload(rings: [DateTime(2026, 10, 30, 19)],
          quiet: true, now: now);
      await pumpEventQueue();
      expect(sent.length, 2);
      expect(sent.first['fn'], PushWire.audience);
      expect(sent.first['p_busy_evenings'], ['2026-10-30']);
      expect(sent.last['p_quiet'], true);
    });

    test('quiet is TTC after a loss until her first period', () {
      final src = _code('lib/services/push_audience.dart');
      expect(src, contains('c.restartOn != null && c.lastPeriodStart == null'));
    });
  });

  group('wiring (the call sites exist)', () {
    test('FamilyPhone uploads after arming, all three stores loaded', () {
      final src = _code('lib/services/family_phone_plan.dart');
      expect(RegExp(r'_tellServer\(now,').allMatches(src).length, 2);
      expect(src, contains('PushAudience.instance.upload('));
      expect(src, contains('quiet: pushTtcQuiet(now: now)'));
      expect(src, contains('ttc.phonePlanned(now: now)'));
    });

    test('all three stores record her answer, card and switch', () {
      final stores = {
        'lib/ttc/ttc_messages_store.dart': 'PushWire.stageTrying',
        'lib/services/preg_messages_store.dart': 'PushWire.stagePregnancy',
        'lib/services/pp_messages_store.dart': 'PushWire.stageParenting',
      };
      for (final e in stores.entries) {
        final src = _code(e.key);
        expect(src, contains('PushConsent.instance.record('), reason: e.key);
        expect(src, contains(e.value), reason: e.key);
        expect(src, contains('PushWire.sourceSwitch'), reason: e.key);
      }
      for (final f in [
        'lib/ttc/ttc_messages_store.dart',
        'lib/services/preg_messages_store.dart',
      ]) {
        expect(_code(f), contains('PushWire.sourceCard'), reason: f);
      }
      expect(_code('lib/services/pp_messages_store.dart'),
          contains('String source = PushWire.sourceCard'));
    });

    test('sign-out unregisters BEFORE the session goes', () {
      final src = _code('lib/screens/profile/pv_account_actions.dart');
      final push = src.indexOf('PushService.instance.signOut()');
      final auth = src.indexOf('Supabase.instance.client.auth.signOut()');
      expect(push, greaterThan(0));
      expect(push, lessThan(auth));
    });

    test('PushService registers, unregisters and flushes through the wire',
        () {
      final src = _code('lib/services/push_service.dart');
      expect(src, contains('PushWire.registerParams('));
      expect(src, contains('PushWire.unregisterParams('));
      expect(src, contains('PushConsent.instance.flush()'));
      expect(src, contains('AuthChangeEvent.initialSession'));
      expect(src, contains('AuthChangeEvent.signedOut'));
      expect(src, contains('onTokenRefresh.listen('));
      // The token is asked for only once Firebase started.
      expect(src, contains('if (!_ready || PushWire.userId() == null) return;'));
    });

    test('the push classes reach Supabase only through the wire', () {
      for (final f in [
        'lib/services/push_service.dart',
        'lib/services/push_consent.dart',
        'lib/services/push_audience.dart',
      ]) {
        expect(_code(f), isNot(contains('.rpc(')), reason: f);
        expect(_code(f), isNot(contains(".from('push_")), reason: f);
      }
    });
  });

  group('PushService with no Firebase', () {
    tearDown(() {
      PushService.instance.debugReset();
    });

    test('no token is asked for and sign-out still flushes consent', () async {
      SharedPreferences.setMockInitialValues({});
      PushService.startFirebase = () async => throw Exception('no config');
      var watched = false;
      PushService.watchAccount = (_) => watched = true;
      var asked = 0;
      PushService.fetchToken = () async {
        asked++;
        return 'x' * 40;
      };
      final calls = <String>[];
      PushWire.userId = () => 'u1';
      PushWire.call = (fn, params) async => calls.add(fn);
      await PushService.instance.init();
      expect(PushService.instance.ready, isFalse);
      expect(watched, isTrue, reason: 'consent still flows with no Firebase');
      await PushService.instance.register();
      expect(asked, 0);
      await PushService.instance.signOut();
      expect(calls, isNot(contains(PushWire.unregister)));
    });

    test('ready: registers this install with the link version', () async {
      SharedPreferences.setMockInitialValues({});
      PushService.startFirebase = () async {};
      PushService.listenForTaps = (_) async {};
      PushService.watchAccount = (_) {};
      PushService.fetchToken = () async => 'tok-${'x' * 40}';
      var dropped = 0;
      PushService.dropToken = () async => dropped++;
      final calls = <Map<String, dynamic>>[];
      PushWire.userId = () => 'u1';
      PushWire.call = (fn, params) async => calls.add({'fn': fn, ...params});
      await PushService.instance.init();
      await PushService.instance.register();
      final reg = calls.single;
      expect(reg['fn'], PushWire.register);
      expect(reg['p_link_version'], PushService.linkVersion);
      expect(reg['p_device_id'], hasLength(32));
      final id = reg['p_device_id'];
      expect(await PushService.deviceId(), id, reason: 'minted once');

      await PushService.instance.signOut();
      expect(calls.last['fn'], PushWire.unregister);
      expect(calls.last['p_device_id'], id);
      expect(dropped, 1);
    });
  });
}
