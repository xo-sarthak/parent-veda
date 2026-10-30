// The community's wire contract, pinned against the migration.
//
// Every write and read the app makes is a call to a function in a community
// migration (0121, then 0137 and on; the LAST definition wins, as it does in
// Postgres — test/support/community_sql.dart). A parameter-name mismatch between
// the store and the SQL fails silently in production: PostgREST answers "no
// such function" and the store treats it as "no connection", so a post sits
// queued forever. This test reads both sources and fails the build first.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/community_sql.dart';

void main() {
  final cs = CommunitySql.load();
  final seed0121 = File('supabase/migrations/0121_community.sql').readAsStringSync();
  final media = File('supabase/migrations/0122_community_media.sql').readAsStringSync();
  final store = File('lib/services/pv_community_store.dart').readAsStringSync();

  /// function name -> declared parameter names (last definition wins).
  Map<String, Set<String>> declared() => cs.functions().map((k, v) => MapEntry(k, v.params));

  /// Every `_call('fn', {...})` in the store, with the keys it sends.
  Map<String, Set<String>> called() {
    final out = <String, Set<String>>{};
    final re = RegExp(r"_call\(\s*(?:isPost \? )?'(\w+)'(?:\s*:\s*'(\w+)')?(?:,\s*\{([^}]*)\})?", multiLine: true);
    for (final m in re.allMatches(store)) {
      final keys = {for (final k in RegExp(r"'(p_\w+)'").allMatches(m.group(3) ?? '')) k.group(1)!};
      out.putIfAbsent(m.group(1)!, () => {}).addAll(keys);
      if (m.group(2) != null) out.putIfAbsent(m.group(2)!, () => {});
    }
    return out;
  }

  test('the reader sees every community migration, 0121 first', () {
    expect(cs.files.first.$1, '0121_community.sql');
    expect(cs.files.map((f) => f.$1), contains('0137_community_phase2.sql'));
  });

  test('every function the store calls exists in a community migration', () {
    final d = declared();
    final c = called();
    expect(c.keys, isNotEmpty);
    for (final fn in c.keys) {
      expect(d.containsKey(fn), isTrue, reason: 'store calls $fn, which no community migration creates');
    }
  });

  test('every parameter the store sends is declared on that function', () {
    final d = declared();
    called().forEach((fn, keys) {
      for (final k in keys) {
        expect(d[fn], contains(k), reason: '$fn is sent $k, which it does not declare');
      }
    });
  });

  test('the outbox sends the create functions their exact parameters', () {
    final d = declared();
    // The outbox stores params maps rather than calling inline; pin them.
    for (final k in [
      'p_id', 'p_room', 'p_identity', 'p_title', 'p_body', 'p_poll_options', 'p_poll_days', //
      'p_about_kind', 'p_about_id',
    ]) {
      expect(store, contains("'$k':"), reason: 'post params lost $k');
      expect(d['community_create_post'], contains(k));
    }
    for (final k in ['p_id', 'p_post', 'p_parent', 'p_identity', 'p_body']) {
      expect(d['community_comment'], contains(k));
    }
  });

  test('every app-callable function is granted to authenticated and not to anon', () {
    // A grant written BEFORE a function was dropped and re-created died with
    // the old function, so it only counts from the file of the last drop on.
    for (final fn in called().keys) {
      final from = cs.lastDrop(fn);
      final granted = cs.grants().any((g) => g.$1 >= from && g.$2.contains('public.$fn('));
      final revoked = cs.anonRevokes().any((g) => g.$1 >= from && g.$2.contains('public.$fn('));
      expect(granted, isTrue, reason: '$fn is not granted to authenticated');
      expect(revoked, isTrue, reason: '$fn is still callable by anon');
    }
  });

  test('the rooms the old door links name exist', () {
    for (final id in ['potty', 'mothers_4th_trimester', 'ttc_loss', 'ttc_pcos', 'anything']) {
      expect(seed0121, contains("('$id',"), reason: 'room $id is linked from a door but not seeded');
    }
  });

  test('each seeded room has its own drawn mark', () {
    // The seed blocks only: 0121's list, plus every later `insert … values`
    // seed that ends in `on conflict (id) do update` (functions that create a
    // room on demand, such as a birth club, are not seeds).
    final seeds = [
      seed0121.split('insert into public.community_rooms').last,
      for (final f in cs.files.skip(1))
        for (final m in RegExp(r'insert into public\.community_rooms \(id, title, blurb, stage_tag, mark, hue, sort\) values([\s\S]*?)on conflict \(id\) do update')
            .allMatches(f.$2))
          m.group(1)!,
    ];
    final marks = [
      for (final seed in seeds)
        for (final m in RegExp(r"'(tab|tool):(\w+)'").allMatches(seed)) '${m.group(1)}:${m.group(2)}',
    ];
    expect(marks.length, greaterThan(15));
    expect(marks.toSet().length, marks.length, reason: 'two rooms share a mark');
  });

  test('photos live in a private bucket', () {
    expect(media, contains("'community-media', 'community-media', false"));
    expect(store, contains("kCommunityMediaBucket = 'community-media'"));
  });
}
