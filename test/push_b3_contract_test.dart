// =============================================================================
//  Phase 6b, B3: campaigns, bookings and the rules that decide them (0143)
// -----------------------------------------------------------------------------
//  The rules live in SQL, which `flutter test` cannot run. The real proof is
//  supabase/seed/verify_push_campaigns.sql against the database. This test
//  pins what can drift without anyone noticing: the columns B4 and B5 will
//  read, the decided constants (one a week, 10%, 7 days, 14 days, 21:00,
//  10:00), the order of the rules, the text checks, the grants, the link
//  kinds the phone can open, and the phone's wider quiet flag.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/notification_opener.dart';
import 'package:parentveda/services/push_audience.dart';
import 'package:parentveda/services/push_wire.dart';
import 'package:parentveda/ttc/ttc_phase.dart';

const _migration = 'supabase/migrations/0143_push_campaigns_and_sends.sql';
const _verify = 'supabase/seed/verify_push_campaigns.sql';

String _sql() => File(_migration).readAsStringSync();

/// The SQL with `--` comments removed, so a rule in a comment never passes.
String _live() => _sql()
    .split('\n')
    .map((l) {
      final i = l.indexOf('--');
      return i < 0 ? l : l.substring(0, i);
    })
    .join('\n');

String _code(String path) => File(path)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

List<String> _columns(String sql, String table) {
  final m = RegExp(
    'create table if not exists public\\.$table \\((.*?)\\n\\);',
    dotAll: true,
  ).firstMatch(sql);
  expect(m, isNotNull, reason: '$table is not created in $_migration');
  final out = <String>[];
  for (final line in m!.group(1)!.split('\n')) {
    final t = line.trim();
    if (t.isEmpty ||
        t.startsWith('--') ||
        t.startsWith('constraint') ||
        t.startsWith('check') ||
        t.startsWith('or ') ||
        t.startsWith('and ') ||
        t.startsWith("'") ||
        t.startsWith('(')) {
      continue;
    }
    final word = t.split(RegExp(r'\s+')).first;
    if (RegExp(r'^[a-z_]+$').hasMatch(word)) out.add(word);
  }
  return out;
}

/// The body of `create or replace function public.<fn>`, up to its `$$;`.
String _fn(String sql, String fn) {
  final m = RegExp(
    'create or replace function public\\.$fn\\(.*?\\\$\\\$(.*?)\\\$\\\$;',
    dotAll: true,
  ).firstMatch(sql);
  expect(m, isNotNull, reason: '$fn is not created in $_migration');
  return m!.group(1)!;
}

/// The week-or-day-number check, from Postgres's regex dialect into Dart's
/// (`\m` and `\M` are word edges there), case-insensitive as `!~*` is.
RegExp _numberCheck() {
  final m = RegExp(
    r"push_campaigns_no_week_or_day_number\s*check \(\(title \|\| ' ' \|\| body\) !~\*\s*'([^']*)'",
  ).firstMatch(_sql());
  expect(m, isNotNull, reason: 'the week/day number check is missing');
  final pg = m!.group(1)!.replaceAll(r'\m', r'\b').replaceAll(r'\M', r'\b');
  return RegExp(pg, caseSensitive: false);
}

void main() {
  group('the tables B4 and B5 read', () {
    test('push_campaigns has every planned column, priority included', () {
      expect(_columns(_sql(), 'push_campaigns'), [
        'id', 'kind', 'title', 'body', 'link_kind', 'link_id', 'stages',
        'week_from', 'week_to', 'child_months_from', 'child_months_to',
        'starts_on', 'ends_on', 'priority', 'status', 'created_at',
        'approved_at', 'cancelled_at',
      ]);
    });

    test('push_sends has the cutoff and tapped_at (rows 16, 20)', () {
      expect(_columns(_sql(), 'push_sends'), [
        'id', 'campaign_id', 'user_id', 'send_on', 'send_before', 'status',
        'error', 'devices_sent', 'sent_at', 'tapped_at', 'created_at',
      ]);
      expect(_sql(),
          contains("check (status in ('queued', 'sent', 'failed', 'skipped'))"));
    });

    test('one campaign per person ever, and one an evening as a constraint',
        () {
      final sql = _live();
      expect(sql, contains('constraint push_sends_once unique (campaign_id, user_id)'));
      expect(
          sql,
          contains('create unique index if not exists push_sends_one_an_evening\n'
              '  on public.push_sends (user_id, send_on)\n'
              "  where status <> 'skipped';"));
    });

    test('stages are profiles.life_stage words, the same as consent (B2)', () {
      expect(
          _sql(),
          contains("stages <@ array['${PushWire.stageTrying}', "
              "'${PushWire.stagePregnancy}', '${PushWire.stageParenting}']"));
    });
  });

  group('the decided constants', () {
    test('ONE a week, 7 days grace, 14 days after a birth (rows 17, 18, 22)',
        () {
      final check = _fn(_live(), 'pv_push_check');
      expect(check, contains('select 1  as weekly_cap,'));
      expect(check, contains('7  as grace_days,'));
      expect(check, contains('14 as birth_quiet_days'));
      // Seven rolling days, counting only what was booked or sent.
      expect(check, contains('s.send_on between p_on - 6 and p_on'));
      expect(check, contains("s.status in ('queued', 'sent')) >= k.weekly_cap"));
    });

    test('a 10% holdout on md5 of user_id, never hashtext (row 15)', () {
      final h = _fn(_live(), 'pv_push_holdout');
      expect(h, contains("md5('pv-push-holdout-v1:' || p_user::text)"));
      expect(h, contains('% 100 < 10'));
      expect(_live(), isNot(contains('hashtext')));
    });

    test('the cutoff is 21:00 IST and the cron runs at 10:00 IST', () {
      final e = _fn(_live(), 'pv_push_enqueue');
      expect(e, contains("(v_day + time '21:00') at time zone 'Asia/Kolkata'"));
      expect(e, contains('if cutoff <= now() then'));
      expect(_live(), contains("'push-enqueue-daily',\n  '30 4 * * *',"));
      expect(_live(), contains(r'$$ select public.pv_push_enqueue(); $$'));
    });
  });

  group('the rules, once, in order', () {
    const order = [
      'not_live', 'no_consent', 'no_device', 'holdout', 'new_user',
      'pregnancy_loss', 'phone_quiet', 'new_baby', 'not_targeted',
      'already_reached', 'busy_evening', 'booked_tonight', 'weekly_cap',
    ];

    test('pv_push_check gives each reason in the documented order', () {
      final check = _fn(_live(), 'pv_push_check');
      var at = -1;
      for (final r in order) {
        final i = check.indexOf("then '$r'");
        expect(i, greaterThan(at), reason: '$r is missing or out of order');
        at = i;
      }
    });

    test('the comment lists the same reasons as the code', () {
      final doc = _sql().substring(0, _sql().indexOf('create or replace function public.pv_push_check'));
      for (final r in order) {
        expect(doc, contains('--   $r'), reason: '$r is not documented');
      }
    });

    test('enqueue and dry run both read pv_push_check, and nothing else decides',
        () {
      final e = _fn(_live(), 'pv_push_enqueue');
      expect(e, contains('from public.pv_push_check(v_day) c'));
      expect(e, contains('where c.reason is null'));
      // Row 19: priority, then the sooner end.
      expect(e, contains('order by c.priority desc, c.ends_on asc, c.campaign_id'));
      expect(e, contains('where x.rn = 1'));
      expect(e, contains('on conflict do nothing'));
      final d = _fn(_live(), 'pv_campaign_dry_run');
      expect(d, contains('public.pv_push_check(v_day, p_id)'));
      expect(d, contains("'another_campaign_wins'"));
      expect(d, contains("'would_send'"));
    });

    test('the loss rule is 0112, word for word', () {
      final check = _fn(_live(), 'pv_push_check');
      expect(check, contains('when pp.pregnancy_ended_at is not null\n'
          '       and not (pp.life_stage_at is not null\n'
          '                and pp.pregnancy_ended_at < pp.life_stage_at)'));
      // A missing audience row is not quiet.
      expect(check, contains('when coalesce(a.quiet, false)'));
    });

    test('the week is read through wa_pregnancy_week, never recomputed', () {
      final check = _fn(_live(), 'pv_push_check');
      expect(check, contains('public.wa_pregnancy_week(pp.due_date, p_on)'));
      expect(check, isNot(contains('last_period')));
      expect(check, isNot(contains('ttc_')));
    });

    test('the server reads no TTC table (decided: only the quiet flag)', () {
      expect(RegExp(r'public\.ttc_').hasMatch(_live()), isFalse);
      expect(_live(), isNot(contains('cycle_')));
    });

    test('a removed child counts for nothing, a partner\'s child counts', () {
      final check = _fn(_live(), 'pv_push_check');
      expect('ch.removed_at is null'.allMatches(check).length, 2);
      expect(
          '(ch.user_id = pp.id or ch.user_id = pp.partner_id)'
              .allMatches(check)
              .length,
          2);
    });
  });

  group('the text rules hold for every writer (table checks)', () {
    test('title 50, body 150, no placeholders (rows 10, 21)', () {
      final sql = _live();
      expect(sql, contains('check (length(btrim(title)) between 1 and 50)'));
      expect(sql, contains('check (length(btrim(body)) between 1 and 150)'));
      expect(sql, contains(r"check (title !~ '\{\{|\}\}' and body !~ '\{\{|\}\}')"));
    });

    test('a week or day number is refused, a hyphenated trial is not', () {
      final r = _numberCheck();
      for (final bad in [
        'You are in week 20',
        'Only 3 days left',
        'Your 20th week',
        'At 24 weeks, try this',
        'Day 1 of the plan',
      ]) {
        expect(r.hasMatch(bad), isTrue, reason: bad);
      }
      for (final ok in [
        'Garbh Sanskar, live this Sunday',
        'A 7-day free trial of the course',
        'This week: a calm class for two',
        '20% off the feeding pillow',
      ]) {
        expect(r.hasMatch(ok), isFalse, reason: ok);
      }
    });

    test('every link kind is one this build opens, and each has a version', () {
      final m = RegExp(r"check \(link_kind in \(([^)]*)\)\)").firstMatch(_sql());
      final kinds = [
        for (final v in m!.group(1)!.split(',')) v.trim().replaceAll("'", ''),
      ];
      expect(kinds, ['course', 'product', 'expert', 'read']);
      final needs = _fn(_live(), 'pv_push_link_needs');
      for (final k in kinds) {
        expect(NotificationOpener.kinds, contains(k));
        expect(needs, contains("when '$k'"));
      }
      expect(needs, contains('else 2147483647'));
    });
  });

  group('who may call what', () {
    const fns = [
      'pv_push_holdout(uuid)',
      'pv_push_link_needs(text)',
      'pv_push_check(date, text)',
      'pv_push_enqueue(date)',
      'pv_campaign_create(text, text, text, text, text, text, text[], date, date, int, int, int, int, int)',
      'pv_campaign_dry_run(text, date)',
      'pv_campaign_approve(text)',
      'pv_campaign_cancel(text)',
    ];

    test('no function is open to the app; only service_role', () {
      final sql = _live();
      for (final f in fns) {
        expect(sql,
            contains('revoke all on function public.$f from public, anon, authenticated;'),
            reason: f);
        expect(sql, contains('grant execute on function public.$f to service_role;'),
            reason: f);
      }
      expect(RegExp(r'grant execute on function public\.pv_[a-z_]+\([^)]*\) to [a-z_, ]*authenticated')
          .hasMatch(sql), isFalse);
    });

    test('every function created here is in that list', () {
      final made = RegExp(r'create or replace function public\.(\w+)\(')
          .allMatches(_live())
          .map((m) => m.group(1))
          .toSet();
      expect(made, {for (final f in fns) f.substring(0, f.indexOf('('))});
    });

    test('she reads her own bookings, and a campaign only once booked for her',
        () {
      final sql = _live();
      expect(sql, contains('create policy push_sends_own_select on public.push_sends\n'
          '  for select to authenticated\n'
          '  using (user_id = (select auth.uid()));'));
      expect(sql, contains('create policy push_campaigns_booked_select'));
      expect(sql, contains("using (status = 'approved'\n         and exists"));
      expect(RegExp(r'grant (insert|update|delete)').hasMatch(sql), isFalse);
    });

    test('cancel frees the evening and keeps what was sent', () {
      final c = _fn(_live(), 'pv_campaign_cancel');
      expect(c, contains("set status = 'skipped', error = 'cancelled'"));
      expect(c, contains("where campaign_id = p_id and status = 'queued'"));
    });

    test('only a draft can be rewritten or approved', () {
      expect(_fn(_live(), 'pv_campaign_create'),
          contains("where public.push_campaigns.status = 'draft';"));
      expect(_fn(_live(), 'pv_campaign_approve'), contains("and status = 'draft'"));
    });
  });

  group('the phone\'s quiet flag (row 18)', () {
    bool q({
      bool trying = true,
      bool loss = false,
      TtcDayPhase phase = TtcDayPhase.beforeWindow,
      bool treating = false,
    }) =>
        pushTtcQuietFrom(
          trying: trying,
          afterLoss: loss,
          phase: phase,
          treatmentActive: treating,
        );

    test('quiet after a loss, in the two-week wait, late, or in treatment', () {
      expect(q(), isFalse);
      expect(q(loss: true), isTrue);
      expect(q(phase: TtcDayPhase.waiting), isTrue);
      expect(q(phase: TtcDayPhase.late), isTrue);
      expect(q(treating: true), isTrue);
      for (final p in [
        TtcDayPhase.period,
        TtcDayPhase.beforeWindow,
        TtcDayPhase.window,
        TtcDayPhase.any,
      ]) {
        expect(q(phase: p), isFalse, reason: '$p');
      }
    });

    test('never quiet outside trying, whatever the TTC data says', () {
      expect(
          q(trying: false, loss: true, phase: TtcDayPhase.late, treating: true),
          isFalse);
    });

    test('read from the stores, gated on the stage, unknown reads as quiet', () {
      final src = _code('lib/services/push_audience.dart');
      expect(src, contains('LifeStageStore.instance.stage != LifeStage.tryingToConceive'));
      expect(src, contains('c.restartOn != null && c.lastPeriodStart == null'));
      expect(src, contains('ttcDayContext(t, now: t).phase'));
      expect(src, contains('ttcTreatmentActive(TtcTreatmentStore.instance.cycle, t)'));
      expect(src, contains('} catch (_) {\n    return true;\n  }'));
      expect(_code('lib/services/family_phone_plan.dart'),
          contains('quiet: pushTtcQuiet(now: now)'));
    });
  });

  test('the hand-run verify file exists and covers each rule', () {
    final v = File(_verify).readAsStringSync();
    for (final r in [
      'no_consent', 'no_device', 'holdout', 'new_user', 'pregnancy_loss',
      'phone_quiet', 'new_baby', 'not_targeted', 'already_reached',
      'busy_evening', 'booked_tonight', 'weekly_cap', 'another_campaign_wins',
      'push_campaigns_title_length', 'push_campaigns_no_week_or_day_number',
    ]) {
      expect(v, contains(r), reason: '$_verify does not test $r');
    }
  });
}
