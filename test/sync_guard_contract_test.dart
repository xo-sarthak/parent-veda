// =============================================================================
//  The server-side "newer wins" guard covers every synced table (0100)
// -----------------------------------------------------------------------------
//  0100 attaches `pv_sync_newer_wins` to each table whose updated_at is the
//  phone's edit time: an older write is skipped, a clock from the future is
//  pulled back to now. A table the app syncs WITHOUT that trigger silently
//  goes back to "only the phone decides", so this test fails the build when a
//  new synced table is not added to 0100's list (sync log step 4).
//
//  Source-reading, like the schema contract test: no database here. The live
//  behaviour is checked by the block at the bottom of the migration.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'ttc_schema_contract_test.dart' show written;

void main() {
  final guard = File('supabase/migrations/0100_sync_guard_newer_wins.sql')
      .readAsStringSync()
      .replaceAll('\r\n', '\n');

  /// The table names in the `foreach t in array array[ ... ]` list of every
  /// migration that attaches the guard: 0100, and each later one that adds
  /// tables to it (0101, the Parenting logs).
  final guarded = () {
    final out = <String>{};
    for (final f in Directory('supabase/migrations').listSync()) {
      if (f is! File || !f.path.endsWith('.sql')) continue;
      final sql = f.readAsStringSync().replaceAll('\r\n', '\n');
      // One `do $$ ... end $$;` block per loop: only the block that creates
      // the trigger counts (0104 also loops to add columns).
      for (final block in sql.split(r'end $$;')) {
        if (!block.contains('execute function public.pv_sync_newer_wins()')) {
          continue;
        }
        final m = RegExp(r'foreach t in array array\[(.*?)\]', dotAll: true)
            .firstMatch(block);
        if (m == null) continue; // the commented check block in 0100
        for (final q in RegExp(r"'([a-z_]+)'").allMatches(m.group(1)!)) {
          out.add(q.group(1)!);
        }
      }
    }
    return out;
  }();

  test('the rest of the child record is guarded (0104)', () {
    for (final t in [
      'pp_documents',
      'pp_medications',
      'pp_prescriptions',
      'pp_allergies',
      'pp_symptoms',
      'pp_reports',
      'pp_doctor_visits',
      'pp_doctor_questions',
      'pp_milestone_observations',
      'pp_emergency_cards',
      'pp_vaccine_doses',
    ]) {
      expect(guarded, contains(t));
    }
  });

  test('the Parenting logs are guarded (0101)', () {
    for (final t in [
      'pp_feed_logs',
      'pp_sleep_logs',
      'pp_nappy_logs',
      'pp_pump_logs',
      'pp_tummy_logs',
      'pp_growth_measurements',
    ]) {
      expect(guarded, contains(t));
    }
  });

  /// Every table a migration later gives a soft delete with `alter table`.
  final softDeletedLater = () {
    final out = <String>{};
    for (final f in Directory('supabase/migrations').listSync()) {
      if (f is! File || !f.path.endsWith('.sql')) continue;
      final sql = f.readAsStringSync().replaceAll('\r\n', '\n');
      for (final m in RegExp(
              r'alter table public\.([a-z_]+)\s+add column if not exists removed_at')
          .allMatches(sql)) {
        out.add(m.group(1)!);
      }
    }
    return out;
  }();

  test('every TTC table written with the clock and a soft delete is guarded',
      () {
    final synced = [
      for (final e in written.entries)
        if (e.value.contains('updated_at') && e.value.contains('removed_at'))
          e.key,
    ];
    expect(synced, isNotEmpty);
    for (final t in synced) {
      expect(guarded, contains(t), reason: '$t syncs newer-wins but 0100 skips it');
    }
  });

  test('every table a migration gives removed_at later is guarded', () {
    expect(softDeletedLater, isNotEmpty);
    for (final t in softDeletedLater) {
      expect(guarded, contains(t), reason: '$t got a soft delete but no guard');
    }
  });

  test('the other newer-wins tables are guarded too', () {
    // saved_items (0081) and the journals (§16l) merge on the phone's
    // updated_at as well.
    for (final t in ['saved_items', 'journal_entries', 'father_journal_entries']) {
      expect(guarded, contains(t));
    }
  });

  test('the rule itself: clamp a future clock, skip an older update', () {
    expect(guard, contains("if new.updated_at > now() + interval '5 minutes' then"));
    expect(guard, contains('new.updated_at := now();'));
    expect(
        guard,
        contains("if tg_op = 'UPDATE' and new.updated_at < old.updated_at then"),
        reason: 'strictly older only: equal stamps (old app versions) pass');
    expect(guard, contains('return null;'));
    expect(guard, contains('before insert or update'));
  });

  test('nothing stamps the upload time over the edit time', () {
    // Only a stamp from the future is changed; see 0097's header.
    final assigns = RegExp(r'new\.updated_at\s*:=').allMatches(guard).length;
    expect(assigns, 1);
  });
}
