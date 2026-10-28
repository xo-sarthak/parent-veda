// The community's wire contract, pinned against the migration.
//
// Every write and read the app makes is a call to a function in
// supabase/migrations/0121_community.sql. A parameter-name mismatch between
// the store and the SQL fails silently in production: PostgREST answers "no
// such function" and the store treats it as "no connection", so a post sits
// queued forever. This test reads both sources and fails the build first.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final sql = File('supabase/migrations/0121_community.sql').readAsStringSync();
  final media = File('supabase/migrations/0122_community_media.sql').readAsStringSync();
  final store = File('lib/services/pv_community_store.dart').readAsStringSync();

  /// function name -> declared parameter names.
  Map<String, Set<String>> declared() {
    final out = <String, Set<String>>{};
    final re = RegExp(r'create or replace function public\.(\w+)\(([^)]*)\)', multiLine: true);
    for (final m in re.allMatches(sql)) {
      out[m.group(1)!] = {
        for (final p in m.group(2)!.split(','))
          if (p.trim().isNotEmpty) p.trim().split(RegExp(r'\s+')).first,
      };
    }
    return out;
  }

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

  test('every function the store calls exists in 0121', () {
    final d = declared();
    final c = called();
    expect(c.keys, isNotEmpty);
    for (final fn in c.keys) {
      expect(d.containsKey(fn), isTrue, reason: 'store calls $fn, which 0121 does not create');
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
    for (final k in ['p_id', 'p_room', 'p_identity', 'p_title', 'p_body', 'p_poll_options', 'p_poll_days']) {
      expect(store, contains("'$k':"), reason: 'post params lost $k');
      expect(d['community_create_post'], contains(k));
    }
    for (final k in ['p_id', 'p_post', 'p_parent', 'p_identity', 'p_body']) {
      expect(d['community_comment'], contains(k));
    }
  });

  test('every app-callable function is granted to authenticated and not to anon', () {
    final grant = RegExp(r'grant execute on function([\s\S]*?)to authenticated;').firstMatch(sql)!.group(1)!;
    final revoke = RegExp(r'revoke all on function([\s\S]*?)from public, anon;').firstMatch(sql)!.group(1)!;
    for (final fn in called().keys) {
      expect(grant, contains('public.$fn('), reason: '$fn is not granted to authenticated');
      expect(revoke, contains('public.$fn('), reason: '$fn is still callable by anon');
    }
  });

  test('the rooms the old door links name exist', () {
    for (final id in ['potty', 'mothers_4th_trimester', 'ttc_loss', 'ttc_pcos', 'anything']) {
      expect(sql, contains("('$id',"), reason: 'room $id is linked from a door but not seeded');
    }
  });

  test('each seeded room has its own drawn mark', () {
    final marks = [
      for (final m in RegExp(r"'(tab|tool):(\w+)'").allMatches(sql.split('insert into public.community_rooms').last))
        '${m.group(1)}:${m.group(2)}',
    ];
    expect(marks.length, greaterThan(15));
    expect(marks.toSet().length, marks.length, reason: 'two rooms share a mark');
  });

  test('photos live in a private bucket', () {
    expect(media, contains("'community-media', 'community-media', false"));
    expect(store, contains("kCommunityMediaBucket = 'community-media'"));
  });
}
