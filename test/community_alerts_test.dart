// =============================================================================
//  Community phase 3, C3-2: reply alerts (0147)
// -----------------------------------------------------------------------------
//  What this file holds, in order of how much it would hurt to lose:
//
//    1. ONE "replied to you" rule. community_activity, community_me's unread
//       count and the reply trigger all call community_replied_to, and the
//       rule is 0121's, condition for condition. (The SQL proof that the
//       queue and Replies to you agree on real rows is check 12 of
//       supabase/seed/verify_community_alerts.sql.)
//    2. The shared sender's functions were extended, not rewritten: every
//       line of the latest earlier pv_push_due / pv_push_mark /
//       pv_push_any_due is still there, and push-send is untouched.
//    3. C13: triggers only, never a rewrite of community_comment or
//       _community_timetable_notice.
//    4. C2: the lock screen words are fixed, carry nothing from a post, and
//       are the app's preview words.
//    5. C4 and P0-3: 3 a day, the 3-minute burst window, quiet 21:00 to
//       08:00, moderation at any hour and high priority.
//    6. Link kinds, linkVersion 2, the channels, the grants.
//    7. The store: asked once, optimistic switches that roll back, mute.
//    8. The wiring: every door to the screen, and no push in the doctor app.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/community/community_alerts_screen.dart';
import 'package:parentveda/screens/notification_opener.dart';
import 'package:parentveda/services/community_alerts.dart';
import 'package:parentveda/services/push_service.dart';

const _mig = 'supabase/migrations/0147_community_alerts.sql';

String _read(String path) => File(path).readAsStringSync().replaceAll('\r\n', '\n');

/// The migration with `--` comments removed, so a "kept for revert" line
/// never counts as live code.
String _live([String path = _mig]) =>
    _read(path).split('\n').map((l) => l.replaceFirst(RegExp(r'--.*$'), '')).join('\n');

/// The body of the LAST `create or replace function public.<name>(` in [sql],
/// from the function head to its closing `$$;`.
String _fn(String sql, String name) {
  final head = 'create or replace function public.$name(';
  final at = sql.lastIndexOf(head);
  expect(at, greaterThanOrEqualTo(0), reason: '$name not found');
  final open = sql.indexOf(r'$$', at);
  final close = sql.indexOf(r'$$', open + 2);
  return sql.substring(at, close + 2);
}

/// The latest migration BEFORE 0147 that defines `public.<name>`.
String _previous(String name) {
  final files = Directory('supabase/migrations')
      .listSync()
      .whereType<File>()
      .map((f) => f.path.replaceAll('\\', '/'))
      .where((p) => p.endsWith('.sql') && p.split('/').last.compareTo('0147') < 0)
      .toList()
    ..sort();
  for (final p in files.reversed) {
    if (_read(p).contains('create or replace function public.$name(')) return p;
  }
  fail('no earlier definition of $name');
}

/// Every non-blank line of [old], in order, inside [now]: an extension, not
/// a rewrite that dropped something (§16zzi). A trailing `;` is ignored, so
/// an expression that gained an `or exists (...)` after its last line still
/// counts as kept.
void _keepsEveryLine(String old, String now, String what) {
  String norm(String l) => l.trimRight().replaceFirst(RegExp(r';$'), '');
  final want = old.split('\n').map(norm).where((l) => l.trim().isNotEmpty).toList();
  final have = now.split('\n').map(norm).toList();
  var i = 0;
  for (final line in want) {
    while (i < have.length && have[i] != line) {
      i++;
    }
    expect(i, lessThan(have.length), reason: '$what dropped or changed the line: "$line"');
    i++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===========================================================================
  group('1. one "replied to you" rule', () {
    test("the rule is 0121's, condition for condition", () {
      final rule = _fn(_live(), 'community_replied_to');
      for (final c in [
        'c.user_id <> p_me',
        "c.status = 'live'",
        'c.deleted_at is null',
        'p.deleted_at is null',
        'public.community_reply_recipient(c, p, p_parent_user) = p_me',
        'not public.community_blocked_between(p_me, c.user_id)',
      ]) {
        expect(rule, contains(c), reason: c);
      }
      // Addressed to: the reply it answers, else the post.
      expect(_fn(_live(), 'community_reply_recipient'),
          contains('case when c.parent_id is not null then p_parent_user else p.user_id end'));
      // 0121's own copy, for comparison: the same three pieces.
      final old = _fn(_live('supabase/migrations/0121_community.sql'), 'community_activity');
      expect(old, contains('(pc.user_id = auth.uid() or (c.parent_id is null and p.user_id = auth.uid()))'));
    });

    test('activity, the unread count and the trigger all read it', () {
      expect(_fn(_live(), 'community_activity'), contains('public.community_replied_to(c, p, pc.user_id, auth.uid())'));
      expect(_fn(_live(), 'community_me'), contains('public.community_replied_to(c, p, pc.user_id, me)'));
      final trig = _fn(_live(), 'community_reply_alert');
      expect(trig, contains('public.community_reply_recipient(new, p, v_par)'));
      expect(trig, contains('public.community_replied_to(new, p, v_par, v_to)'));
      // No live copy of the old rule anywhere in 0147.
      expect(_live(), isNot(contains('c.parent_id is null and p.user_id = auth.uid()')));
      expect(_live(), isNot(contains('(p.user_id = me or pc.user_id = me)\n       and not public.community_blocked_between')));
    });

    test('the narrowing can only remove what the rule would remove', () {
      // Every reply the rule accepts is on her post or under her reply, so
      // "p.user_id = me or pc.user_id = me" is a superset: it is ANDed, never ORed.
      expect(_fn(_live(), 'community_activity'), contains('and (p.user_id = auth.uid() or pc.user_id = auth.uid())'));
      expect(_fn(_live(), 'community_me'), contains('and (p.user_id = me or pc.user_id = me)'));
    });

    test('community_me rewrote only its unread count (every 0137 output key kept)', () {
      final me = _fn(_live(), 'community_me');
      for (final k in ['signed_in', 'joined', 'pseudonym', 'seed', 'first_name', 'can_rename_at', 'muted_until',
          'banned', 'is_mod', 'expert', 'unread']) {
        expect(me, contains("'$k'"), reason: k);
      }
      expect(_previous('community_me'), endsWith('0137_community_phase2.sql'));
    });

    test('a held reply rings on approval only; a restored one does not ring twice', () {
      final trig = _fn(_live(), 'community_reply_alert');
      expect(trig, contains("if new.status <> 'live' then return null; end if;"));
      expect(trig, contains("if old.status <> 'held' then return null; end if;"));
    });
  });

  // ===========================================================================
  group('2. the shared sender, extended, never rewritten', () {
    for (final name in ['pv_push_due', 'pv_push_mark', 'pv_push_any_due', 'pv_push_link_needs']) {
      test('$name keeps every line of its latest earlier definition', () {
        final prev = _previous(name);
        _keepsEveryLine(_fn(_read(prev), name), _fn(_read(_mig), name), '$name (vs $prev)');
      });
    }

    test("pv_push_due builds on B5's 0146, not 0144 (the campaign channel stays)", () {
      expect(_previous('pv_push_due'), endsWith('0146_push_channel_and_tap.sql'));
      final due = _fn(_live(), 'pv_push_due');
      expect("'offers_news'::text".allMatches(due).length, 2);
      expect(due, contains('return query select * from public.community_push_due(n);'));
    });

    test('push-send is not edited: it knows no community table', () {
      final send = _read('supabase/functions/push-send/index.ts');
      expect(send, isNot(contains('community')));
    });

    test("community_push_due's limit is not named like a queue column (found on the live DB)", () {
      // With `#variable_conflict use_column`, a variable sharing a column's
      // name reads as the column, and `limit n` fails because the queue has a
      // column n. Every plpgsql variable here must avoid the queue's columns.
      final due = _fn(_live(), 'community_push_due');
      expect(due, contains('limit v_limit'));
      expect(due, isNot(contains('limit n\n')));
      final cols = RegExp(r'^\s+(\w+)\s', multiLine: true)
          .allMatches(_live().substring(_live().indexOf('create table if not exists public.community_push_queue'),
              _live().indexOf('create unique index if not exists community_push_queue_merge')))
          .map((m) => m.group(1)!)
          .toSet();
      expect(cols, contains('n'));
      final declare = due.substring(due.indexOf('declare'), due.indexOf('begin'));
      for (final v in RegExp(r'^\s+(\w+)\s+\w+', multiLine: true).allMatches(declare).map((m) => m.group(1)!)) {
        expect(cols, isNot(contains(v)), reason: 'variable $v shares a queue column name');
      }
    });

    test('the mark branch and the idle check include the community queue', () {
      expect(_fn(_live(), 'pv_push_mark'), contains("elsif p_queue = 'community_push_queue' then"));
      expect(_fn(_live(), 'pv_push_mark'), contains("where q.id = p_row_id and q.status = 'queued'"));
      expect(_fn(_live(), 'pv_push_any_due'), contains('public.community_push_is_due(q, now())'));
    });
  });

  // ===========================================================================
  group('3. triggers only (C13)', () {
    test('community_comment and _community_timetable_notice are not rewritten', () {
      expect(_live(), isNot(contains('function public.community_comment(')));
      expect(_live(), isNot(contains('function public._community_timetable_notice(')));
      expect(_live(), contains('after insert or update of status on public.community_comments'));
      expect(_live(), contains('after insert on public.community_posts'));
    });

    test('every trigger keeps the write it follows: a savepoint, and a warning', () {
      for (final t in ['community_reply_alert', 'community_moved_alert', 'community_crisis_alert']) {
        final f = _fn(_live(), t);
        expect(f, contains('exception when others then'), reason: t);
        expect(f, contains('raise warning'), reason: t);
        expect(f, contains('return null;'), reason: t);
      }
    });

    test('a moved session: seat holders on that slot, minus a pregnancy class after a loss (C6)', () {
      final f = _fn(_live(), 'community_moved_alert');
      expect(f, contains("bb.slot_id = 'ps_' || new.about_id"));
      expect(f, contains("bb.status <> 'cancelled'"));
      expect(f, contains("b.stage = 'pregnancy' and public.community_after_loss(b.user_id)"));
      expect(f, contains('new.moved_from is null'));
      // The 0112 condition, word for word as 0143 has it.
      final loss = _fn(_live(), 'community_after_loss');
      expect(loss, contains('pp.pregnancy_ended_at is not null'));
      expect(loss, contains('and not (pp.life_stage_at is not null\n                and pp.pregnancy_ended_at < pp.life_stage_at))'));
      expect(_read('supabase/migrations/0143_push_campaigns_and_sends.sql'),
          contains('and not (pp.life_stage_at is not null\n                and pp.pregnancy_ended_at < pp.life_stage_at)'));
    });

    test('crisis: moderators only, never the author, posts and replies, once', () {
      final f = _fn(_live(), 'community_crisis_alert');
      expect(f, contains('from public.community_moderators cm'));
      expect(f, contains('cm.user_id is distinct from new.user_id'));
      expect(f, contains('if old.crisis then return null; end if;'));
      expect(_live(), contains('after insert or update of crisis on public.community_posts'));
      expect(_live(), contains('after insert or update of crisis on public.community_comments'));
    });
  });

  // ===========================================================================
  group('4. the lock screen shows no content (C2)', () {
    test("0147's words are the app's words", () {
      final t = _fn(_live(), 'community_push_text');
      for (final w in [kAlertReplyTitle, kAlertReplyBody, kAlertMovedTitle, kAlertMovedBody, kAlertModTitle, kAlertModBody]) {
        expect(t, contains("'$w'"), reason: w);
      }
      expect(t, contains("' new replies to your post.'"));
      expect(t, contains("' new replies to your post overnight.'"));
    });

    test('the text reads only the kind and the count, never a post', () {
      final t = _fn(_live(), 'community_push_text');
      final refs = RegExp(r'\bq\.(\w+)').allMatches(t).map((m) => m.group(1)).toSet();
      expect(refs, {'kind', 'n', 'overnight'});
      expect(t, isNot(contains('community_posts')));
      expect(t, isNot(contains('title,')));
    });

    testWidgets('the in-app preview shows exactly those words', (t) async {
      await t.pumpWidget(const MaterialApp(home: Scaffold(body: CommunityAlertPreview())));
      expect(find.text(kAlertReplyTitle), findsOneWidget);
      expect(find.text(kAlertReplyBody), findsOneWidget);
    });
  });

  // ===========================================================================
  group('5. the limits (C4, P0-3)', () {
    test('3 a day, a 3-minute burst window, quiet 21:00 to 08:00', () {
      final q = _fn(_live(), 'community_push_enqueue');
      expect(q, contains("k_daily  constant int      := 3;"));
      expect(q, contains("k_wait   constant interval := interval '3 minutes';"));
      expect(q, contains("return 'capped';"));
      expect(q, contains(">= k_daily then"));
      final quiet = _fn(_live(), 'community_quiet_at');
      expect(quiet, contains(">= time '21:00'"));
      expect(quiet, contains("<  time '08:00'"));
    });

    test('moderation: any hour, high priority, its own channel', () {
      expect(_fn(_live(), 'community_push_is_due'), contains("q.kind = 'moderation' or not public.community_quiet_at(p_at)"));
      final due = _fn(_live(), 'community_push_due');
      expect(due, contains("case l.kind when 'moderation' then 'high' else 'normal' end"));
    });

    test('replies to one post merge: a unique index, and one tag on the phone', () {
      expect(_live(), contains('on public.community_push_queue (user_id, kind, post_id) where status = \'queued\''));
      expect(_fn(_live(), 'community_push_due'), contains("'community-post-' || l.post_id"));
    });

    test('defaults: replies off, bookings on, moderation on', () {
      final a = _fn(_live(), 'community_push_allowed');
      expect(a, contains("kind = 'replies'), false)"));
      expect(a, contains("kind = 'bookings'), true)"));
      expect(a, contains("kind = 'moderation'), true)"));
      // Re-checked when sending: a switch off after queuing still stops it.
      expect(_fn(_live(), 'community_push_due'), contains("set status = 'skipped', error = 'off'"));
    });
  });

  // ===========================================================================
  group('6. kinds, version, channels, grants', () {
    test('the three link kinds need 2, and this build opens them', () {
      final needs = _fn(_live(), 'pv_push_link_needs');
      for (final k in ['community_post', 'booking', 'community_moderation']) {
        expect(RegExp("when '$k'\\s+then 2").hasMatch(needs), isTrue, reason: k);
        expect(NotificationOpener.kinds, contains(k));
      }
      expect(PushService.linkVersion, 2);
    });

    test("the channels the server names are the app's channels", () {
      final due = _fn(_live(), 'community_push_due');
      for (final id in CommunityAlerts.channels.keys) {
        expect(due, contains("'$id'"), reason: id);
      }
      expect(CommunityAlerts.channels.values.map((v) => v.$1), ['Replies', 'Your bookings', 'Moderation']);
    });

    test('the app reaches three functions; the queue and the sender branch are closed to it', () {
      final sql = _live();
      for (final f in ['community_alerts_get()', 'community_alerts_set(text, boolean)', 'community_post_mute(text, boolean)']) {
        expect(sql, contains('grant execute on function public.$f to authenticated;'), reason: f);
        expect(sql, contains('revoke all on function public.$f from public, anon;'), reason: f);
      }
      expect(sql, contains('grant execute on function public.community_push_due(int) to service_role;'));
      expect(sql, contains('revoke all on function public.community_push_due(int) from public, anon, authenticated;'));
      expect(sql, contains('revoke all on function public.community_push_enqueue(uuid, text, text, text) from public, anon, authenticated;'));
      expect(sql, contains('revoke all on public.community_push_queue from anon, authenticated;'));
      expect(sql, contains('revoke all on public.community_push_consent, public.community_post_mutes from anon, authenticated;'));
    });

    test('the store calls the names 0147 defines', () {
      for (final f in [CommunityAlerts.fnGet, CommunityAlerts.fnSet, CommunityAlerts.fnMute]) {
        expect(_live(), contains('create or replace function public.$f('), reason: f);
      }
      for (final k in [CommunityAlerts.kindReplies, CommunityAlerts.kindBookings, CommunityAlerts.kindModeration]) {
        expect(_live(), contains("'$k'"), reason: k);
      }
    });
  });

  // ===========================================================================
  group('7. the store', () {
    late List<(String, Map<String, dynamic>)> calls;
    late Map<String, dynamic> server;
    late bool fail;
    final a = CommunityAlerts.instance;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      a.debugReset();
      calls = [];
      fail = false;
      server = {
        'signed_in': true,
        'replies': false,
        'asked': false,
        'bookings': true,
        'moderation': null,
        'muted': <Map<String, dynamic>>[],
      };
      a.debugSignedIn = true;
      a.debugBackend = (fn, p) async {
        calls.add((fn, p));
        if (fail) throw Exception('offline');
        if (fn == CommunityAlerts.fnGet) return server;
        return {'ok': true};
      };
      CommunityAlerts.phoneAllows = () async => true;
      CommunityAlerts.askPhone = () async => true;
    });

    test('asked once: only on her live post, and never after any answer', () async {
      expect(await a.shouldAsk(postIsMineAndLive: false), isFalse);
      expect(await a.shouldAsk(postIsMineAndLive: true), isTrue);
      await a.answerAsk(yes: false);
      expect(calls.last.$1, CommunityAlerts.fnSet);
      expect(calls.last.$2, {'p_kind': 'replies', 'p_on': false});
      expect(await a.shouldAsk(postIsMineAndLive: true), isFalse);
    });

    test('an offline "Not now" is still never asked again on this phone', () async {
      fail = true;
      expect(await a.answerAsk(yes: false), isFalse);
      fail = false;
      a.debugReset();
      a.debugSignedIn = true;
      a.debugBackend = (fn, p) async => server;
      expect(await a.shouldAsk(postIsMineAndLive: true), isFalse);
    });

    test('asked on another phone (the server says so): not asked here', () async {
      server['asked'] = true;
      expect(await a.shouldAsk(postIsMineAndLive: true), isFalse);
    });

    test('signed out: never asked, nothing sent', () async {
      a.debugSignedIn = false;
      expect(await a.shouldAsk(postIsMineAndLive: true), isFalse);
      expect(await a.setSwitch('bookings', false), isFalse);
      expect(calls, isEmpty);
      expect(a.bookings, isTrue);
    });

    test('a switch flips at once and flips back if the server did not take it', () async {
      await a.load();
      fail = true;
      final f = a.setSwitch('bookings', false);
      expect(a.bookings, isFalse);
      expect(await f, isFalse);
      expect(a.bookings, isTrue);
    });

    test('a member has no moderator switch; a moderator does', () async {
      await a.load();
      expect(a.moderation, isNull);
      server['moderation'] = true;
      await a.load();
      expect(a.moderation, isTrue);
    });

    test('mute: optimistic, listed, rolled back on failure', () async {
      await a.load();
      expect(await a.mute('p1', on: true, title: 'Night feeds'), isTrue);
      expect(a.isMuted('p1'), isTrue);
      expect(calls.last.$2, {'p_post': 'p1', 'p_on': true});
      fail = true;
      expect(await a.mute('p1', on: false), isFalse);
      expect(a.isMuted('p1'), isTrue);
    });

    test('muted posts come back from the server', () async {
      server['muted'] = [
        {'post_id': 'p9', 'title': 'Dream feed', 'room': 'Baby sleep', 'mine': false},
        {'bad': true},
      ];
      await a.load();
      expect(a.muted.map((m) => m.postId), ['p9']);
      expect(a.muted.single.room, 'Baby sleep');
    });

    testWidgets('the screen: switches, the moderator row only for moderators, the phone-off note', (t) async {
      await a.load();
      await _pump(_screen(), t);
      expect(find.text('Replies to your posts'), findsOneWidget);
      expect(find.text('Your bookings'), findsOneWidget);
      expect(find.text('Posts that may need a moderator'), findsNothing);
      expect(find.text('9 pm to 8 am'), findsOneWidget);
      expect(find.text(kAlertsPhoneOff, findRichText: true), findsNothing);

      server['moderation'] = true;
      CommunityAlerts.phoneAllows = () async => false;
      await a.load();
      await t.pumpAndSettle();
      expect(find.text('Posts that may need a moderator'), findsOneWidget);
      expect(find.textContaining('Notifications are off for ParentVeda'), findsOneWidget);
      // A blocked phone shows every switch off: none of them can ring.
      expect(t.widgetList<Switch>(find.byType(Switch)).every((s) => !s.value), isTrue);
    });
  });

  // ===========================================================================
  group('8. wiring', () {
    String code(String p) => _read(p).split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');

    test('the ask after her first live post', () {
      final s = code('lib/screens/community/community_post_screen.dart');
      expect(s, contains('await maybeAskCommunityAlerts(context,'));
      expect(s, contains("p.author.isMine && !p.author.team && !p.sending && p.status == 'live'"));
    });

    test('Turn off replies for this post, in the post menu', () {
      final s = code('lib/screens/community/community_chrome.dart');
      expect(s, contains('label: muted ? kAlertsMuteOn : kAlertsMuteOff'));
      expect(s, contains('(store.comments(post.id) ?? const []).any((c) => c.author.isMine)'));
      expect(s, contains("case 'mute':"));
    });

    test('the doors to Community alerts: Settings in all three stages, and the gear', () {
      final you = code('lib/screens/profile/pv_you_content.dart');
      expect('_communityAlerts()],'.allMatches(you).length, 3);
      expect(you, contains('open: openCommunityAlerts'));
      expect(code('lib/screens/community/community_activity_screen.dart'),
          contains('onPressed: () => openCommunityAlerts(context)'));
    });

    test('channels made at start in the parent app; never in the doctor or partner app', () {
      expect(code('lib/main.dart'), contains('CommunityAlerts.instance.init();'));
      for (final m in ['lib/main_doctor.dart', 'lib/main_partner.dart']) {
        expect(code(m), isNot(contains('CommunityAlerts')), reason: m);
        expect(code(m), isNot(contains('PushService')), reason: m);
      }
    });
  });
}

Widget _screen() => const MaterialApp(home: CommunityAlertsScreen());

Future<void> _pump(Widget w, WidgetTester t) async {
  await t.pumpWidget(w);
  await t.pumpAndSettle();
}
