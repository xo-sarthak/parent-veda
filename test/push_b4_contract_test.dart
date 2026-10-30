// =============================================================================
//  Phase 6b, B4: the sender and its two functions (0144, push-send)
// -----------------------------------------------------------------------------
//  The SQL is proved by supabase/seed/verify_push_send.sql against the
//  database, and the FCM half by pv_campaign_test reaching a phone. This test
//  pins what can drift without anyone noticing: the sender touches nothing
//  but pv_push_due and pv_push_mark (the Community contract), the row shape
//  both sides read, the 19:00 start and the cutoff living in SQL, the booking
//  id in the push data and the phone's parser accepting it, UNREGISTERED
//  tokens dropped, the every-minute cron calling only the tick, and no
//  function open to the app.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/services/notification_link.dart';

const _migration = 'supabase/migrations/0144_push_send.sql';
const _sender = 'supabase/functions/push-send/index.ts';
const _verify = 'supabase/seed/verify_push_send.sql';

/// The SQL with `--` comments removed, so a rule in a comment never passes.
String _live() => File(_migration)
    .readAsStringSync()
    .split('\n')
    .map((l) {
      final i = l.indexOf('--');
      return i < 0 ? l : l.substring(0, i);
    })
    .join('\n');

/// The sender with `//` comment lines removed.
String _ts() => File(_sender)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

/// The body of `create or replace function public.<fn>`, up to its `$$;`.
String _fn(String sql, String fn) {
  final m = RegExp(
    'create or replace function public\\.$fn\\(.*?\\\$\\\$(.*?)\\\$\\\$;',
    dotAll: true,
  ).firstMatch(sql);
  expect(m, isNotNull, reason: '$fn is not created in $_migration');
  return m!.group(1)!;
}

void main() {
  group('one sender, many queues (agreed with Community phase 3)', () {
    test('the sender calls only pv_push_due and pv_push_mark', () {
      final rpcs = RegExp(r'''\.rpc\(\s*["']([a-z_]+)["']''')
          .allMatches(_ts())
          .map((m) => m.group(1))
          .toSet();
      expect(rpcs, {'pv_push_due', 'pv_push_mark'});
    });

    test('the sender reads no table', () {
      // `db.from(...)` is a table read; `Array.from` is not.
      expect(_ts(), isNot(contains('db.from(')));
      expect(_ts(), isNot(contains('.schema(')));
      for (final t in ['push_sends', 'push_tests', 'push_devices', 'push_campaigns']) {
        expect(_ts(), isNot(contains(t)), reason: 'the sender names $t');
      }
    });

    test('pv_push_due returns the agreed shape, plus tokens, priority, channel',
        () {
      final m = RegExp(
        r'create or replace function public\.pv_push_due\(p_limit int default 500\)\s*'
        r'returns table \((.*?)\)\s*language',
        dotAll: true,
      ).firstMatch(_live());
      expect(m, isNotNull);
      final cols = m!
          .group(1)!
          .split(',')
          .map((c) => c.trim().split(RegExp(r'\s+')).first)
          .toList();
      expect(cols, [
        'queue', 'row_id', 'user_id', 'tokens', 'title', 'body', 'data',
        'collapse_key', 'priority', 'channel',
      ]);
      // The sender's Due type reads the same names.
      for (final c in cols) {
        expect(_ts(), contains('  $c:'), reason: 'Due lacks $c');
      }
    });

    test('pv_push_mark keeps the agreed arguments, dead tokens last', () {
      expect(
          _live(),
          contains('create or replace function public.pv_push_mark(\n'
              '  p_queue        text,\n'
              '  p_row_id       uuid,\n'
              '  p_status       text,\n'
              '  p_devices_sent int  default 0,\n'
              '  p_error        text default null,\n'
              "  p_dead_tokens  text[] default '{}'\n"
              ')'));
    });

    test('the sender passes every pv_push_mark argument by name', () {
      for (final a in [
        'p_queue', 'p_row_id', 'p_status', 'p_devices_sent', 'p_error',
        'p_dead_tokens',
      ]) {
        expect(_ts(), contains('$a:'), reason: 'the sender never sends $a');
      }
    });
  });

  group('the push_sends branch', () {
    test('due at 19:00 IST or later, and only before send_before', () {
      final due = _fn(_live(), 'pv_push_due');
      expect(due,
          contains("now() >= (s.send_on + time '19:00') at time zone 'Asia/Kolkata'"));
      expect(due, contains('now() <  s.send_before'));
      final any = _fn(_live(), 'pv_push_any_due');
      expect(any,
          contains("now() >= (s.send_on + time '19:00') at time zone 'Asia/Kolkata'"));
      expect(any, contains('now() <  s.send_before'));
    });

    test('past the cutoff a row is skipped with past_cutoff, never handed out',
        () {
      for (final fn in ['pv_push_due', 'pv_push_tick']) {
        expect(
            _fn(_live(), fn),
            contains("set status = 'skipped', error = 'past_cutoff', claimed_at = null"),
            reason: fn);
      }
      expect(_fn(_live(), 'pv_push_tick'),
          contains("where status = 'queued' and now() >= send_before"));
    });

    test('a row is claimed with skip locked, and a claim lapses after 5 minutes',
        () {
      final due = _fn(_live(), 'pv_push_due');
      expect(due, contains("lease interval := interval '5 minutes'"));
      expect(due, contains('for update of s skip locked'));
      expect(due, contains('(s.claimed_at is null or s.claimed_at < now() - lease)'));
      expect(_live(),
          contains('alter table public.push_sends add column if not exists claimed_at timestamptz;'));
    });

    test('only devices that can open the link get it', () {
      expect(
          _fn(_live(), 'pv_push_due'),
          contains('d.link_version >= public.pv_push_link_needs(c.link_kind)'));
    });

    test('a mark changes only a row still queued', () {
      final mark = _fn(_live(), 'pv_push_mark');
      expect(mark, contains("where s.id = p_row_id and s.status = 'queued'"));
      expect(mark, contains("where t.id = p_row_id and t.status = 'queued'"));
      expect(mark, contains("sent_at      = case when p_status = 'sent' then now() else s.sent_at end"));
    });
  });

  group('the push data and the phone', () {
    test('the booking id and its queue ride in the data (B5 fills tapped_at)',
        () {
      final due = _fn(_live(), 'pv_push_due');
      expect(
          due,
          contains("jsonb_build_object('link_kind', c.link_kind, 'link_id', c.link_id,\n"
              "                            'queue', 'push_sends', 'row_id', k.id::text)"));
    });

    test('the phone still opens a push whose data carries the extra keys', () {
      final link = NotificationLink.fromData({
        'link_kind': 'course',
        'link_id': 'garbh-sanskar-live',
        'queue': 'push_sends',
        'row_id': '00000000-0000-0000-0000-000000000001',
      });
      expect(link, const NotificationLink('course', 'garbh-sanskar-live'));
    });

    test('data values are strings, as FCM requires', () {
      expect(_ts(), contains('data[k] = String(v);'));
    });

    test('collapse_key is FCM collapse_key and the Android tag', () {
      expect(_ts(), contains('notification.tag = row.collapse_key'));
      expect(_ts(), contains('collapse_key: row.collapse_key'));
    });
  });

  group('FCM HTTP v1', () {
    test('the v1 endpoint, the messaging scope, the service-account secret', () {
      expect(_ts(),
          contains(r'https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send'));
      expect(_ts(), contains('https://www.googleapis.com/auth/firebase.messaging'));
      expect(_ts(), contains('Deno.env.get("FCM_SERVICE_ACCOUNT")'));
    });

    test('UNREGISTERED tokens are dropped through pv_push_mark', () {
      expect(_ts(), contains('text.includes("UNREGISTERED")'));
      expect(_ts(), contains('p_dead_tokens: dead'));
      expect(_fn(_live(), 'pv_push_mark'),
          contains('delete from public.push_devices d where d.token = any (p_dead_tokens);'));
    });

    test('a short failure goes back to queued, so the next minute retries', () {
      expect(_ts(), contains('res.status === 429 || res.status >= 500'));
      expect(_ts(), contains('? "queued"'));
    });

    test('only the cron, holding PUSH_SEND_SECRET, may run it', () {
      expect(_ts(), contains('Deno.env.get("PUSH_SEND_SECRET")'));
      expect(_ts(), contains(r'`Bearer ${secret}`'));
      expect(_ts(), contains('return json({ error: "forbidden" }, 403);'));
    });
  });

  group('every minute, free when idle', () {
    test('the cron runs every minute and calls only the tick', () {
      expect(
          _live(),
          contains("select cron.schedule(\n"
              "  'push-send-every-minute',\n"
              "  '* * * * *',\n"
              r"  $$ select public.pv_push_tick(); $$"));
    });

    test('the tick calls push-send only when something is due', () {
      final tick = _fn(_live(), 'pv_push_tick');
      final guard = tick.indexOf('if not public.pv_push_any_due() then');
      final call = tick.indexOf('net.http_post(');
      expect(guard, greaterThan(0));
      expect(call, greaterThan(guard));
      expect(tick, contains("'Authorization', 'Bearer ' || v_secret"));
    });
  });

  group('pv_campaign_test', () {
    test('queues in push_tests, never push_sends, for the named account', () {
      final t = _fn(_live(), 'pv_campaign_test');
      expect(t, contains('insert into public.push_tests (campaign_id, user_id)'));
      expect(t, isNot(contains('push_sends')));
      expect(t, contains('where lower(u.email) = lower(btrim(p_email))'));
    });

    test('a test goes now and goes stale after 10 minutes', () {
      expect(_live(),
          contains("send_before  timestamptz not null default now() + interval '10 minutes'"));
      final due = _fn(_live(), 'pv_push_due');
      expect(due, contains("'queue', 'push_tests', 'row_id', k.id::text"));
    });
  });

  group('grants', () {
    test('no B4 function is open to the app; the sender role can run them',
        () {
      const sigs = [
        'pv_push_due(int)',
        'pv_push_mark(text, uuid, text, int, text, text[])',
        'pv_campaign_test(text, text)',
        'pv_push_any_due()',
        'pv_push_tick()',
      ];
      for (final s in sigs) {
        expect(_live(),
            contains('revoke all on function public.$s from public, anon, authenticated;'));
        expect(_live(), contains('grant execute on function public.$s to service_role;'));
      }
      expect(_live(),
          contains('revoke all on table public.push_tests from anon, authenticated;'));
      expect(_live(),
          contains('alter table public.push_tests enable row level security;'));
    });
  });

  test('the verify file exists and checks the 19:00 rule and the cutoff', () {
    final v = File(_verify).readAsStringSync();
    expect(v, contains('a booking before 19:00 is not due'));
    expect(v, contains('past the cutoff it is skipped, past_cutoff'));
    expect(v, contains('the booking id is in the push data'));
  });
}
