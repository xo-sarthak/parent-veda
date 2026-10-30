// Community phase 2's server rules, pinned against the migration
// (0137_community_phase2.sql). Each of these failed, or could fail, silently:
// a grant that died with a dropped function, a helper left callable by the
// app, a timetable change that tells nobody, a team post that names a
// moderator. Reading the source is the only check that runs before the
// user runs the file.
import 'package:flutter_test/flutter_test.dart';

import 'support/community_sql.dart';

void main() {
  final cs = CommunitySql.load();
  final fns = cs.functions();
  final p2 = cs.files.firstWhere((f) => f.$1 == '0137_community_phase2.sql').$2;

  const appCallable = [
    'community_offering_room',
    'community_room_seen',
    'community_birth_club',
    'community_search',
    'community_edit_post',
    'community_follow',
    'community_following_list',
    'community_ask_expert',
    'community_expert_queue',
    'community_expert_claim',
    'community_endorse',
    'community_create_prompt',
    'community_pin',
    'expert_my_offerings',
    'community_feed',
    'community_create_post',
  ];

  const internal = [
    'community_expert_of',
    'community_my_expert_id',
    'community_host_role',
    'community_is_host',
    'community_room_access',
    'community_room_unread',
    'community_offering_room_id',
    '_community_ensure_offering_room',
    '_community_timetable_notice',
    '_mirror_session',
  ];

  test('every new app function is granted to authenticated, revoked from anon', () {
    final i = cs.indexOf('0137_community_phase2.sql');
    for (final fn in appCallable) {
      expect(fns.containsKey(fn), isTrue, reason: '$fn is not defined');
      expect(cs.grants().any((g) => g.$1 >= i && g.$2.contains('public.$fn(')), isTrue,
          reason: '$fn is not granted to authenticated in 0137');
      expect(cs.anonRevokes().any((g) => g.$1 >= i && g.$2.contains('public.$fn(')), isTrue,
          reason: '$fn is still callable by anon');
    }
  });

  test('the helpers are not callable by the app', () {
    for (final fn in internal) {
      expect(fns.containsKey(fn), isTrue, reason: '$fn is not defined');
      expect(cs.appRevokes().any((g) => g.$2.contains('public.$fn(')), isTrue,
          reason: '$fn is callable by authenticated');
      for (final g in cs.grants()) {
        expect(g.$2.contains('public.$fn('), isFalse, reason: '$fn is granted to the app');
      }
    }
  });

  test('a changed signature drops the old one first, so there is one overload', () {
    expect(p2, contains('drop function if exists public.community_feed(text, text, text, text, text[], int, int);'));
    expect(p2, contains('drop function if exists public.community_create_post(text, text, text, text, text, jsonb, int);'));
    // The new arguments are defaulted, so a phone that sends only the old
    // ones still resolves to the new function.
    expect(fns['community_feed']!.params, containsAll(['p_scope', 'p_tag', 'p_about_kind', 'p_about_id']));
    expect(fns['community_create_post']!.params, containsAll(['p_room', 'p_about_kind', 'p_about_id']));
  });

  test('no json object hands the app a user id', () {
    expect(p2.contains("'user_id'"), isFalse);
    expect(p2.contains("'followee'"), isFalse);
    expect(p2.contains("'asked_by'"), isFalse);
    expect(p2.contains("'follower'"), isFalse);
  });

  test('only a team post may have no author', () {
    expect(p2, contains('alter column user_id drop not null'));
    expect(p2, contains("check (user_id is not null or identity = 'team')"));
    expect(p2, contains("check (identity in ('anon', 'named', 'team'))"));
  });

  test('every new table is locked: RLS on, no rights, no policies', () {
    for (final t in [
      'community_endorsements',
      'community_follows',
      'community_expert_requests',
      'community_room_seen',
    ]) {
      expect(p2, contains('create table if not exists public.$t'));
      expect(RegExp('alter table public\\.$t\\s+enable row level security').hasMatch(p2), isTrue, reason: t);
      expect(RegExp(r'revoke all on public\.community_endorsements[\s\S]*?from anon, authenticated;')
          .firstMatch(p2)!
          .group(0), contains('public.$t'));
    }
    expect(RegExp(r'create policy[^;]*on public\.community_').hasMatch(p2), isFalse);
  });

  test('a moved session writes a pinned team notice, after the slot moves', () {
    final mirror = fns['_mirror_session']!;
    expect(cs.files[mirror.file].$1, '0137_community_phase2.sql', reason: '0137 must hold the last definition');
    final body = mirror.body;
    // The old start is read BEFORE the upsert overwrites it …
    expect(body.indexOf('into v_old'), lessThan(body.indexOf('insert into public.booking_slots')));
    // … and the notice is written AFTER, only when someone holds a seat.
    final notice = body.indexOf('_community_timetable_notice');
    expect(notice, greaterThan(body.indexOf('update public.booking_bookings')));
    expect(body.substring(body.lastIndexOf('if v_old is not null')), contains("status = 'upcoming'"));

    final n = fns['_community_timetable_notice']!.body;
    expect(n, contains("'team'"));
    expect(n, contains('pinned_until'));
    expect(n, contains('moved_from'));
    expect(n, contains("'timetable_notice'"));
    expect(n, contains("'Asia/Kolkata'"), reason: 'times are told in India time');
  });

  test('the thread rule: moderators, route A hosts and a booked seat (D3)', () {
    final a = fns['has_course_access']!;
    expect(cs.files[a.file].$1, '0137_community_phase2.sql');
    final thread = a.body.substring(a.body.indexOf("if p_what = 'thread' then"));
    expect(thread, contains('community_is_mod()'));
    expect(thread, contains("ep.status = 'published'"));
    expect(thread, contains('expert_accounts'));
    expect(thread, contains('booking_bookings'));
    expect(thread.split("if p_what = 'seat'").first.contains('my_expert_ids'), isFalse,
        reason: 'an organisation login must not open every course room');
    // Recordings keep the wider rule.
    expect(a.body, contains("p_what = 'recording' and exists"));
  });

  test('the room is checked on every read, through community_can_see', () {
    expect(fns['community_can_see']!.body, contains('community_room_access(p.room_id)'));
    final access = fns['community_room_access']!.body;
    expect(access, contains("has_course_access(r.programme_id, 'thread', r.run_id)"));
    expect(access, contains("'birth_club'"));
  });

  test('the team voice: moderators write it, nobody can block it, its face does not open', () {
    final prompt = fns['community_create_prompt']!.body;
    expect(prompt, contains('community_is_mod()'));
    expect(prompt, contains("kind in ('room', 'birth_club', 'offering')"));
    expect(prompt, contains('community_mod_actions'));
    expect(fns['community_block']!.body, contains("if idn = 'team'"));
    expect(fns['community_face']!.body, contains("if face = 'team' then return null"));
    // Hosts may pin inside their course; moderators anywhere.
    expect(fns['community_pin']!.body, contains('community_is_host(p.room_id)'));
  });

  test('a crisis post is never sent to the expert queue (W20, user 2026-10-28)', () {
    expect(fns['community_ask_expert']!.body, contains("if p.crisis then return jsonb_build_object('ok', false, 'reason', 'crisis')"));
    expect(p2.contains('create trigger community_expert'), isFalse);
    expect(fns['community_expert_queue']!.body, contains("e.reason = 'asked'"));
  });

  test('For you leaves out course rooms and other months\' clubs', () {
    final feed = fns['community_feed']!.body;
    expect(feed, contains("r.kind not in ('offering', 'session')"));
    expect(feed, contains("r.kind <> 'birth_club' or m.user_id is not null"));
  });

  test('the Over-35 room is seeded', () {
    expect(p2, contains("('preg_over_35', 'Pregnant after 35'"));
  });
}
