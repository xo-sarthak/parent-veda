// =============================================================================
//  Records, appointments and the ritual: removals that stay removed (0098)
// -----------------------------------------------------------------------------
//  STILL-OPEN-BACKEND §1: these three stores pulled with a union and removed
//  with a hard delete, so a removal made offline, racing an upload, or undone
//  by the other phone came back on the next pull. And all three tables are
//  couple-scoped, so the old push stamped HER user_id on HIS rows.
//
//  Network-free: the stores' merges take cloud rows directly
//  (`applyCloudRows`), and `TtcRowBook` is pure Dart.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_records_store.dart';
import 'package:parentveda/ttc/ttc_ritual_store.dart';
import 'package:parentveda/ttc/ttc_row_merge.dart';

const _old = '2020-01-01T00:00:00.000Z';
const _new = '2100-01-01T00:00:00.000Z';

Map<String, dynamic> _recordRow(String id,
        {String at = _new, String? removed, String owner = 'her', String label = 'AMH'}) =>
    {
      'id': id,
      'user_id': owner,
      'label': label,
      'value': '2.1',
      'unit': 'ng/mL',
      'taken_on': '2026-09-06',
      'for_partner': false,
      'updated_at': at,
      'removed_at': removed,
    };

String _today() {
  final d = DateTime.now();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

Map<String, dynamic> _tick(String owner, TtcRitualPart part,
        {String at = _old, String? removed}) =>
    {
      'user_id': owner,
      'part': part.name,
      'completed_on': _today(),
      'updated_at': at,
      'removed_at': removed,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUpAll(() async {
    await TtcRecordsStore.instance.ensureLoaded();
  });

  final cancelled = <int>[];
  setUp(() {
    TtcRecordsStore.instance.resetForTest();
    TtcAppointmentsStore.instance.resetForTest();
    TtcRitualStore.instance.resetForTest();
    cancelled.clear();
    TtcAppointmentsStore.schedulePhone = ({
      required int id,
      required String title,
      required String body,
      required DateTime when,
    }) async {};
    TtcAppointmentsStore.cancelPhone = (id) async => cancelled.add(id);
  });

  // ===========================================================================
  group('TtcRowBook: newer wins, removals included', () {
    test('a removal survives an older live copy, and waits to upload', () {
      final b = TtcRowBook()..remove('a', {'label': 'AMH'});
      final take = b.merge(const [], [_recordRow('a', at: _old)]);
      expect(take, isEmpty, reason: 'the older live copy must not come back');
      expect(b.dirty, contains('a'));
    });

    test('a newer cloud removal is taken', () {
      final b = TtcRowBook()..touch('a', at: 0);
      final take = b.merge(['a'], [_recordRow('a', removed: _new)]);
      expect(take.single['id'], 'a');
      expect(b.removed, contains('a'));
      expect(b.dirty, isNot(contains('a')));
    });

    test('a row from before this release loses to the cloud copy', () {
      final b = TtcRowBook();
      expect(b.merge(['a'], [_recordRow('a', at: _old)]).single['id'], 'a');
    });

    test('a row the cloud has never seen waits to upload', () {
      final b = TtcRowBook();
      expect(b.merge(['b'], const []), isEmpty);
      expect(b.dirty, contains('b'));
    });

    test('the cloud owner is remembered', () {
      final b = TtcRowBook()..merge(const [], [_recordRow('a', owner: 'him')]);
      expect(b.owners['a'], 'him');
    });

    test('an Undo is a newer live change: no removal left to send', () {
      final b = TtcRowBook()
        ..remove('a', {'label': 'AMH'}, at: 1)
        ..touch('a', at: 2);
      expect(b.removed, isEmpty);
      expect(b.times('a').removedAt, isNull);
      expect(b.dirty, contains('a'));
    });

    test('a confirmed upload stays waiting if she changed it meanwhile', () {
      final b = TtcRowBook()..touch('a', at: 1);
      b.touch('a', at: 2);
      b.confirmed('a', ok: true, sent: 1);
      expect(b.dirty, contains('a'));
      b.confirmed('a', ok: true, sent: 2);
      expect(b.dirty, isEmpty);
    });

    test('the book survives the local cache', () {
      final b = TtcRowBook()
        ..remove('a', {'label': 'AMH'}, at: 5)
        ..merge(const [], [_recordRow('c', owner: 'him')]);
      final c = TtcRowBook()..loadJson(b.toJson());
      expect(c.removed['a'], 5);
      expect(c.removedRows['a'], {'label': 'AMH'});
      expect(c.owners['c'], 'him');
      expect(c.dirty, b.dirty);
    });
  });

  // ===========================================================================
  group('records', () {
    final store = TtcRecordsStore.instance;

    test('a removal made on the other phone is taken here', () {
      final r = store.add(label: 'AMH', takenOn: DateTime(2026, 9, 6));
      store.applyCloudRows([_recordRow(r.id, removed: _new)]);
      expect(store.records, isEmpty);
    });

    test('a removal here is not undone by an older cloud copy', () {
      final r = store.add(label: 'AMH', takenOn: DateTime(2026, 9, 6));
      store.remove(r.id);
      store.applyCloudRows([_recordRow(r.id, at: _old)]);
      expect(store.records, isEmpty);
      expect(store.hasPendingPush, isTrue,
          reason: 'the removal still has to reach the cloud');
    });

    test('a newer edit from the other phone keeps the files on this one', () {
      final r = store.add(label: 'AMH', takenOn: DateTime(2026, 9, 6));
      store.replace(r.copyWith(attachments: ['local/scan.pdf']));
      store.applyCloudRows([_recordRow(r.id, label: 'AMH (repeat)')]);
      final got = store.records.single;
      expect(got.label, 'AMH (repeat)');
      expect(got.attachments, ['local/scan.pdf']);
    });

    test("the partner's result keeps his owner", () {
      store.applyCloudRows([_recordRow('ttcr_his', owner: 'him')]);
      expect(store.records.single.id, 'ttcr_his');
      expect(store.bookForTest.owners['ttcr_his'], 'him');
    });

    test('remove then Undo ends live, with nothing removed left to send', () {
      final r = store.add(label: 'AMH', takenOn: DateTime(2026, 9, 6));
      store.remove(r.id);
      store.restore([r]);
      expect(store.records.single.id, r.id);
      expect(store.bookForTest.removed, isEmpty);
      expect(store.hasPendingPush, isTrue);
    });
  });

  // ===========================================================================
  group('appointments', () {
    final store = TtcAppointmentsStore.instance;
    Map<String, dynamic> row(String id, DateTime startsUtc, {String? removed}) => {
          'id': id,
          'user_id': 'her',
          'title': 'Scan',
          'with_whom': '',
          'starts_utc': startsUtc.toIso8601String(),
          'note': null,
          'updated_at': _new,
          'removed_at': removed,
        };

    test('a visit removed on the other phone cancels its reminder here', () {
      final a = store.add(
        title: 'Scan',
        startsLocal: DateTime.now().add(const Duration(days: 5)),
        remindEveningBefore: true,
      );
      cancelled.clear();
      store.applyCloudRows([row(a.id, a.startsUtc, removed: _new)]);
      expect(store.all, isEmpty);
      expect(cancelled, contains(ttcAppointmentReminderId(a.id)));
    });

    test("a newer edit keeps this phone's reminder", () {
      final a = store.add(
        title: 'Scan',
        startsLocal: DateTime.now().add(const Duration(days: 5)),
        remindEveningBefore: true,
      );
      store.applyCloudRows([row(a.id, a.startsUtc)..['title'] = 'Dating scan']);
      final got = store.all.single;
      expect(got.title, 'Dating scan');
      expect(got.remindEveningBefore, isTrue);
      expect(got.remindAtUtc, a.remindAtUtc);
    });
  });

  // ===========================================================================
  group('ritual: shared parts are the couple’s, the rest are each person’s',
      () {
    final store = TtcRitualStore.instance;

    test('the shared part has one shared kind', () {
      expect(kTtcSharedRitualParts, {TtcRitualPart.conversation});
    });

    test('his tick on the conversation shows for her', () {
      store.applyCloudRows([_tick('him', TtcRitualPart.conversation)],
          me: 'her');
      expect(store.isDone(TtcRitualPart.conversation), isTrue);
    });

    test('her newer un-tick beats his older tick, and stays un-ticked', () {
      final rows = [_tick('him', TtcRitualPart.conversation)];
      store.applyCloudRows(rows, me: 'her');
      store.toggle(TtcRitualPart.conversation);
      expect(store.isDone(TtcRitualPart.conversation), isFalse);
      store.applyCloudRows(rows, me: 'her');
      expect(store.isDone(TtcRitualPart.conversation), isFalse);
      expect(store.hasPendingPush, isTrue);
    });

    test('his newer tick beats her older un-tick', () {
      store.applyCloudRows([
        _tick('her', TtcRitualPart.conversation, removed: _old),
        _tick('him', TtcRitualPart.conversation, at: _new),
      ], me: 'her');
      expect(store.isDone(TtcRitualPart.conversation), isTrue);
    });

    test('his breath is not hers, but still counts for the couple', () {
      store.applyCloudRows([_tick('him', TtcRitualPart.breath)], me: 'her');
      expect(store.isDone(TtcRitualPart.breath), isFalse);
      expect(store.completedToday(), 0);
      expect(store.streak(), 1);
    });

    test('her own un-tick stays un-ticked against an older cloud row', () {
      store.applyCloudRows([_tick('her', TtcRitualPart.breath)], me: 'her');
      expect(store.isDone(TtcRitualPart.breath), isTrue);
      store.toggle(TtcRitualPart.breath);
      store.applyCloudRows([_tick('her', TtcRitualPart.breath)], me: 'her');
      expect(store.isDone(TtcRitualPart.breath), isFalse);
    });
  });
}
