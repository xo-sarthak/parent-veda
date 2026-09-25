// The journal follows her to every phone (2026-09-23). The user: "the whole
// record is maintained not locally but wherever she logs in, on whichever
// device." Each case below is one of the four holes the audit found, walked
// without a network through the pure merge both journals use.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/models/journal_entry.dart';
import 'package:parentveda/services/journal_sync.dart';

JournalEntry _e(String id,
        {String title = 't', DateTime? updated, String? place}) =>
    JournalEntry(
      id: id,
      type: JournalEntryType.memory,
      title: title,
      description: '',
      date: DateTime(2026, 9, 1),
      weekNumber: 12,
      place: place,
      createdAt: DateTime(2026, 9, 1),
      updatedAt: updated ?? DateTime(2026, 9, 1),
    );

void main() {
  final t0 = DateTime(2026, 9, 1, 10);
  final t1 = DateTime(2026, 9, 1, 11);

  test('an edit made offline wins over the older cloud copy, and is pushed', () {
    final m = mergeJournal(
      local: [_e('a', title: 'edited', updated: t1)],
      cloud: [_e('a', title: 'old', updated: t0)],
      tombstones: {},
      seen: {'a'},
    );
    expect(m.keep.single.title, 'edited');
    expect(m.push.single.id, 'a');
  });

  test('a newer cloud copy (edited on another phone) wins here', () {
    final m = mergeJournal(
      local: [_e('a', title: 'here', updated: t0)],
      cloud: [_e('a', title: 'there', updated: t1)],
      tombstones: {},
      seen: {'a'},
    );
    expect(m.keep.single.title, 'there');
    expect(m.push, isEmpty);
  });

  test('a delete made offline is finished, not resurrected', () {
    final m = mergeJournal(
      local: const [],
      cloud: [_e('a')],
      tombstones: {'a'},
      seen: {'a'},
    );
    expect(m.keep, isEmpty);
    expect(m.deleteRemote, ['a']);
    expect(m.seen, isNot(contains('a')));
  });

  test('a delete on another phone is not undone by this one', () {
    final m = mergeJournal(
      local: [_e('a')],
      cloud: const [],
      tombstones: {},
      seen: {'a'}, // this phone saw it in the cloud before
    );
    expect(m.keep, isEmpty);
    expect(m.push, isEmpty);
  });

  test('a new entry written offline is kept and uploaded', () {
    final m = mergeJournal(
      local: [_e('new')],
      cloud: const [],
      tombstones: {},
      seen: {},
    );
    expect(m.keep.single.id, 'new');
    expect(m.push.single.id, 'new');
    expect(m.seen, contains('new'));
  });

  test('an entry from another phone arrives here', () {
    final m = mergeJournal(
      local: const [],
      cloud: [_e('b')],
      tombstones: {},
      seen: {},
    );
    expect(m.keep.single.id, 'b');
    expect(m.seen, contains('b'));
  });

  test('a place is not wiped by a cloud that has no column for it yet', () {
    final m = mergeJournal(
      local: [_e('a', place: "Maa's house", updated: t0)],
      cloud: [_e('a', updated: t0)],
      tombstones: {},
      seen: {'a'},
    );
    expect(m.keep.single.place, "Maa's house");
  });

  test('place goes to the cloud and comes back', () {
    final row = journalEntryRow(_e('a', place: 'The terrace'));
    expect(row['place'], 'The terrace');
    final back = journalEntryFromRow({...row, 'user_id': 'u'});
    expect(back.place, 'The terrace');
    expect(back.id, 'a');
  });

  // The contract: every key the app writes is a column in both tables. A
  // mismatch fails SILENTLY at runtime (fire-and-forget writes), so it is
  // pinned here against the migrations themselves.
  test('every key written is a column in both journal tables', () {
    final sql = Directory('supabase/migrations')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.sql'))
        .map((f) => f.readAsStringSync())
        .join('\n');
    for (final table in ['journal_entries', 'father_journal_entries']) {
      final create = RegExp('create table public\\.$table \\(([\\s\\S]*?)\\n\\);')
          .firstMatch(sql);
      expect(create, isNotNull, reason: table);
      final cols = <String>{
        for (final line in create!.group(1)!.split('\n'))
          if (RegExp(r'^\s+([a-z_]+)\s').firstMatch(line) case final m?)
            m.group(1)!,
        for (final m in RegExp('alter table public\\.$table\\s+add column if not exists ([a-z_]+)')
            .allMatches(sql))
          m.group(1)!,
      };
      for (final key in journalEntryRow(_e('x')).keys) {
        expect(cols, contains(key), reason: '$table lacks "$key"');
      }
    }
  });

  test('both journals use the one merge', () {
    for (final f in [
      'lib/services/journal_store.dart',
      'lib/services/father_journal_store.dart',
    ]) {
      final src = File(f).readAsStringSync();
      expect(src, contains('mergeJournal('), reason: f);
      expect(src, contains('journalUpsert('), reason: f);
      expect(src, contains('_tombstones.add(id)'), reason: f);
    }
  });
}
