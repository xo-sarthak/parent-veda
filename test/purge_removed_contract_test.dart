// =============================================================================
//  The purge and the phones' own forgetting (sync log step 12, 2026-10-21)
// -----------------------------------------------------------------------------
//  0109 hard-deletes soft-deleted rows after 90 days, from an EXPLICIT list.
//  The first test reads every migration and checks that list against the
//  tables that really have a `removed_at`, so a new soft-delete table is
//  never silently left out, and `children` can never be added.
//
//  The phone forgets a confirmed removal after 80 days: before the server
//  does, so it can never upload a removal the server has already purged.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/auth/local_wipe.dart';
import 'package:parentveda/services/remote/sync_row_book.dart';

/// Every table some migration gives a `removed_at` column.
Set<String> tablesWithRemovedAt() {
  final out = <String>{};
  final files = Directory('supabase/migrations')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.sql') && !f.path.contains('0109_'));
  for (final f in files) {
    final sql = f.readAsStringSync().replaceAll('\r\n', '\n');
    // alter table public.x  add column if not exists removed_at
    for (final m in RegExp(
            r'alter table public\.(\w+)\s+add column if not exists removed_at')
        .allMatches(sql)) {
      out.add(m.group(1)!);
    }
    // create table ... ( ... removed_at ... );
    // (The body is cut at the closing "\n);", not at a ';': column comments
    // like "-- tombstone; null = live" carry semicolons.)
    for (final m in RegExp(r'create table if not exists public\.(\w+)\s*\(')
        .allMatches(sql)) {
      final close = sql.indexOf('\n);', m.end);
      if (close < 0) continue;
      final body = sql.substring(m.end, close);
      if (RegExp(r'^\s*removed_at\s', multiLine: true).hasMatch(body)) {
        out.add(m.group(1)!);
      }
    }
    // foreach t in array array[ 'a', 'b' ] loop ... add column ... removed_at ..., t)
    const loopAdd = "add column if not exists removed_at timestamptz', t)";
    var at = sql.indexOf(loopAdd);
    while (at >= 0) {
      final head = sql.lastIndexOf('foreach t in array array[', at);
      final end = sql.indexOf(']', head);
      for (final m in RegExp(r"'(\w+)'").allMatches(sql.substring(head, end))) {
        out.add(m.group(1)!);
      }
      at = sql.indexOf(loopAdd, at + 1);
    }
  }
  return out;
}

/// The newest migration that (re)defines the purge: 0109, then each later one
/// that adds tables to its list (0110, step 13).
String latestPurgeSql() {
  final files = Directory('supabase/migrations')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.sql'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  String? last;
  for (final f in files) {
    final sql = f.readAsStringSync().replaceAll('\r\n', '\n');
    if (sql.contains('create or replace function public.pv_purge_removed(')) {
      last = sql;
    }
  }
  return last!;
}

Set<String> purgeList() {
  // Kept for revert (before 0110): read 0109 only.
  //   final sql = File('supabase/migrations/0109_purge_removed.sql')
  //       .readAsStringSync().replaceAll('\r\n', '\n');
  final sql = latestPurgeSql();
  final fn =
      sql.indexOf('create or replace function public.pv_purge_removed(');
  final head = sql.indexOf('foreach t in array array[', fn);
  final end = sql.indexOf(']', head);
  return {
    for (final m in RegExp(r"'(\w+)'").allMatches(sql.substring(head, end)))
      m.group(1)!,
  };
}

void main() {
  test('the purge covers every soft-delete sync table, and never children', () {
    final soft = tablesWithRemovedAt();
    final purge = purgeList();
    expect(soft, contains('children'), reason: 'the scan must see 0105');
    expect(purge, isNot(contains('children')),
        reason: 'a removed child must stay restorable (0105, my_child_ids)');
    expect(purge.where((t) => t.startsWith('sponsor_')), isEmpty);
    final expected = soft
        .where((t) => t != 'children' && !t.startsWith('sponsor_'))
        .toSet();
    expect(expected.difference(purge), isEmpty,
        reason: 'these have removed_at but 0109 never purges them: their '
            'removed rows stay for ever');
    expect(purge.difference(expected), isEmpty,
        reason: 'these are in 0109 but no migration gives them removed_at: '
            'the purge would fail on them');
  });

  test('0109 keeps 90 days, is scheduled, and no app user can call it', () {
    final sql =
        File('supabase/migrations/0109_purge_removed.sql').readAsStringSync();
    expect(sql, contains("cron.schedule(\n  'pv-purge-removed'"));
    expect(sql, contains('public.pv_purge_removed(90)'));
    expect(sql, contains('from public, anon, authenticated'));
    expect(sql, contains('if p_days < 30 then'));
  });

  test('the phone forgets before the server does', () {
    expect(SyncRowBook.keepRemovals, const Duration(days: 80));
    expect(SyncRowBook.keepRemovals < const Duration(days: 90), isTrue,
        reason: 'a removal kept past the purge would be uploaded back');
  });

  group('SyncRowBook.dropSettled', () {
    const day = 24 * 60 * 60 * 1000;
    final now = DateTime.utc(2026, 10, 21).millisecondsSinceEpoch;

    SyncRowBook bookWith(String id, int removedAt, {bool dirty = false}) {
      final b = SyncRowBook()..remove(id, {'id': id}, at: removedAt);
      if (!dirty) b.confirmed(id, ok: true, sent: removedAt);
      return b;
    }

    test('an old, confirmed removal is forgotten', () {
      final b = bookWith('a', now - 81 * day);
      expect(b.dropSettled(nowMs: now), {'a'});
      expect(b.removed, isEmpty);
      expect(b.stamps, isEmpty);
    });

    test('a recent removal is kept', () {
      final b = bookWith('a', now - 10 * day);
      expect(b.dropSettled(nowMs: now), isEmpty);
      expect(b.removed.keys, ['a']);
    });

    test('a removal the cloud has not confirmed is kept, however old', () {
      final b = bookWith('a', now - 200 * day, dirty: true);
      expect(b.dropSettled(nowMs: now), isEmpty);
      expect(b.dirty, {'a'});
    });

    test('after forgetting, the cloud\'s removed row is read as a removal, '
        'never brought back', () {
      final b = bookWith('a', now - 81 * day)..dropSettled(nowMs: now);
      final gone = DateTime.fromMillisecondsSinceEpoch(now - 81 * day, isUtc: true)
          .toIso8601String();
      final taken = b.merge(const [], [
        {'id': 'a', 'updated_at': gone, 'removed_at': gone},
      ]);
      expect(taken.single['removed_at'], isNotNull);
      expect(b.dirty, isEmpty, reason: 'nothing to upload');
    });
  });

  test('the device settings that survive a sign-out are named where they live',
      () {
    // A key renamed at its source would silently stop surviving the wipe.
    const where = {
      'install_referrer_checked_v1': 'lib/referral/install_referrer.dart',
      'profile_analytics_install_id': 'lib/services/profile_analytics.dart',
      'ttc_hinglish': 'lib/screens/ttc/ttc_strings.dart',
      'pv_ask_fab_hidden': 'lib/widgets/global_ask_fab.dart',
      'ttc_practice_sound': 'lib/ttc/ttc_cue_sounds.dart',
      'size_baby_mode': 'lib/services/size_view_pref.dart',
      'v3_block_art_vector': 'lib/screens/v2/v2_block_art.dart',
      'baby_voice_muted_home': 'lib/services/baby_voice_service.dart',
      'baby_voice_muted_journey': 'lib/services/baby_voice_service.dart',
      'baby_voice_muted': 'lib/services/baby_voice_service.dart',
      'preg_size_set': 'lib/services/preg_size_set_store.dart',
    };
    for (final e in where.entries) {
      expect(LocalWipe.keep, contains(e.key));
      expect(File(e.value).readAsStringSync(), contains("'${e.key}'"),
          reason: '${e.key} is no longer the key in ${e.value}');
    }
  });
}
