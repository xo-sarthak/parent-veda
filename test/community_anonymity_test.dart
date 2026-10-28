// Anonymity is a column problem (0121 header). These checks hold the shape
// that makes a community-name post truly anonymous:
//  1. the app's roles have no table rights on any community table, so a
//     post row (with its user_id) can never be selected directly;
//  2. nothing the read functions return carries a user id;
//  3. the phone's model has no user id field to fill;
//  4. a photo's storage path is the post id, never the uid.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final sql = File('supabase/migrations/0121_community.sql').readAsStringSync();
  final media = File('supabase/migrations/0122_community_media.sql').readAsStringSync();
  final model = File('lib/models/pv_community.dart').readAsStringSync();
  final store = File('lib/services/pv_community_store.dart').readAsStringSync();

  final tables = [
    for (final m in RegExp(r'create table if not exists public\.(community_\w+)').allMatches(sql)) m.group(1)!,
  ];

  test('every community table has RLS on and no rights for the app roles', () {
    expect(tables.length, greaterThanOrEqualTo(13));
    final revoke = RegExp(r'revoke all on public\.community_profiles([\s\S]*?)from anon, authenticated;')
        .firstMatch(sql)!
        .group(0)!;
    for (final t in tables) {
      expect(RegExp('alter table public\\.$t\\s+enable row level security').hasMatch(sql), isTrue,
          reason: '$t has no RLS');
      expect(revoke, contains('public.$t'), reason: '$t keeps default privileges for the app');
    }
    expect(RegExp(r'grant (select|insert|update|delete)[^;]*public\.community_').hasMatch(sql), isFalse,
        reason: 'a community table was granted to a role');
    expect(RegExp(r'create policy[^;]*on public\.community_').hasMatch(sql), isFalse,
        reason: 'a policy opens a community table; reads must go through functions');
  });

  test('no function hands a user id to the app', () {
    expect(sql.contains("'user_id'"), isFalse, reason: "a json object carries 'user_id'");
    expect(sql.contains("'reporter'"), isFalse);
    expect(sql.contains("'blocked'"), isFalse);
    expect(sql.contains("'actor'"), isFalse);
  });

  test('the author is resolved on the server, never joined to the other face', () {
    // The body only (after `as $$`): the signature names both parameters.
    final author = RegExp(r'function public\.community_author\([\s\S]*?\$\$;')
        .firstMatch(sql)!
        .group(0)!
        .split(r'as $$')
        .last;
    // The anonymous face reads only the pseudonym; the named face only the
    // label stored on the post. Neither branch reads the other's source.
    final anon = author.split('else').first;
    final named = author.split('else').last;
    expect(anon, contains('pseudonym'));
    expect(anon.contains('p_label'), isFalse);
    expect(named.contains('pseudonym'), isFalse);
  });

  test('the phone model has no user id to leak', () {
    expect(model.contains('user_id'), isFalse);
    expect(model.contains('userId'), isFalse);
  });

  test('photo paths are the post id, never the uid', () {
    expect(store, contains(r"path: '$id/${newId()}.jpg'"));
    expect(media.contains('foldername(name))[1] = auth.uid()'), isFalse);
    expect(media, contains("split_part(p_name, '/', 1)"));
  });
}
