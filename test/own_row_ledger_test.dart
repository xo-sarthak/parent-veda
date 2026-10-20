// =============================================================================
//  OwnRowLedger: newer-wins sync for one person's rows (0106, sync log step 8)
// -----------------------------------------------------------------------------
//  The Pregnancy tables are own-only, so the phone's edit time wins, a removal
//  is a soft delete that travels, and keyed tables (a mood per `day`, an
//  affirmation per `text`) carry their key as the book's id. These cases run
//  the merge and the upload decision directly, with no network.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/remote/own_row_ledger.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Row = Map<String, dynamic>;

String iso(int ms) =>
    DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toIso8601String();

final t0 = DateTime.utc(2026, 10, 20, 9).millisecondsSinceEpoch;
const minute = 60000;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('id-keyed tables (calendar, bump, notes, reminders)', () {
    OwnRowLedger events() => OwnRowLedger('calendar_personal_events', 't_ev');

    Row ev(String id, {required int at, int? removedAt, String title = 'Scan'}) =>
        {
          'id': id,
          'title': title,
          'user_id': 'me',
          'updated_at': iso(at),
          'removed_at': removedAt == null ? null : iso(removedAt),
        };

    test('a newer cloud edit is taken', () {
      final l = events()..book.touch('e1', at: t0);
      final taken = l.apply(
          liveKeys: ['e1'], rows: [ev('e1', at: t0 + minute, title: 'New')]);
      expect(taken.single['title'], 'New');
      expect(l.book.dirty, isEmpty);
    });

    test('a newer edit here waits to upload', () {
      final l = events()..book.touch('e1', at: t0 + minute);
      final taken = l.apply(liveKeys: ['e1'], rows: [ev('e1', at: t0)]);
      expect(taken, isEmpty);
      expect(l.book.dirty, contains('e1'));
    });

    test('a removal here stays removed against an older live copy', () {
      final l = events()..book.remove('e1', {'id': 'e1'}, at: t0 + minute);
      final taken = l.apply(liveKeys: [], rows: [ev('e1', at: t0)]);
      expect(taken, isEmpty, reason: 'the old copy must not come back');
      expect(l.book.dirty, contains('e1'));
    });

    test("her other phone's newer removal is taken as a removal", () {
      final l = events()..book.touch('e1', at: t0);
      final taken = l.apply(
          liveKeys: ['e1'],
          rows: [ev('e1', at: t0 + minute, removedAt: t0 + minute)]);
      expect(taken.single['removed_at'], isNotNull);
    });

    test('a legacy row with no stamp takes the cloud copy', () {
      final l = events();
      final taken = l.apply(liveKeys: ['e1'], rows: [ev('e1', at: t0)]);
      expect(taken.single['id'], 'e1');
    });

    test('a row the cloud has never seen waits to upload', () {
      final l = events();
      l.apply(liveKeys: ['e_new'], rows: []);
      expect(l.book.dirty, contains('e_new'));
    });

    test('the upload carries the times and is ours', () {
      final l = events()..book.remove('e1', {'id': 'e1', 'title': 'x'}, at: t0);
      final up = l.uploadFor('e1', {}, uid: 'me')!;
      expect(up['user_id'], 'me');
      expect(up['removed_at'], iso(t0));
      expect(up['title'], 'x', reason: 'NOT NULL columns still filled');
      expect(l.onConflict, 'id');
    });
  });

  group('keyed tables (moods, affirmations, missions)', () {
    OwnRowLedger moods() =>
        OwnRowLedger('daily_moods', 't_md', keyColumn: 'day');

    test('a cloud row gets its key as id, and conflicts on user_id + key', () {
      final l = moods();
      final taken = l.apply(liveKeys: [], rows: [
        {'day': 12, 'mood_id': 'calm', 'updated_at': iso(t0)},
      ]);
      expect(taken.single['id'], '12');
      expect(l.onConflict, 'user_id,day');
    });

    test('a cleared mood uploads from its columns at removal', () {
      final l = moods()
        ..touch('12', columns: {'day': 12, 'mood_id': 'calm'})
        ..remove('12', {'day': 12, 'mood_id': 'calm'});
      final up = l.uploadFor('12', {}, uid: 'me')!;
      expect(up['day'], 12, reason: 'the key keeps its type');
      expect(up['removed_at'], isNotNull);
    });

    test('an un-kept affirmation is not brought back by an older keep', () {
      final l = OwnRowLedger('kept_affirmations', 't_ka', keyColumn: 'text')
        ..book.remove('Breathe', {'text': 'Breathe'}, at: t0 + minute);
      final taken = l.apply(liveKeys: [], rows: [
        {'text': 'Breathe', 'updated_at': iso(t0)},
      ]);
      expect(taken, isEmpty);
      expect(l.book.dirty, contains('Breathe'));
    });
  });

  group('state tables (movement answers)', () {
    OwnRowLedger movement() => OwnRowLedger('daily_movement_responses', 't_mv',
        keyColumn: 'day', hasRemovedAt: false);

    test('sends no removed_at', () {
      final l = movement()
        ..touch('3', columns: {'day': 3, 'response': 'not_yet'});
      final up = l.uploadFor('3', {}, uid: 'me')!;
      expect(up.containsKey('removed_at'), isFalse);
      expect(up['response'], 'not_yet');
    });

    test('a change here takes part in the merge even if not listed live', () {
      final l = movement()..book.touch('3', at: t0 + minute);
      final taken = l.apply(liveKeys: [], rows: [
        {'day': 3, 'response': 'yes', 'updated_at': iso(t0)},
      ]);
      expect(taken, isEmpty, reason: "the older 'yes' must not win");
    });
  });

  test('logged out, nothing is sent and the change keeps waiting', () async {
    final l = OwnRowLedger('reminders', 't_rm')..touch('r1');
    await l.push(() => {
          'r1': {'id': 'r1'}
        });
    expect(l.hasPending, isTrue);
  });
}
