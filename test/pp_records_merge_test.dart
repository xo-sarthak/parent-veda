// =============================================================================
//  The rest of the child's record syncs newer-wins (0104, sync log step 6)
// -----------------------------------------------------------------------------
//  Documents, health, milestones, vaccines and the emergency card moved to
//  `ChildLogLedger`. Milestones, vaccines and the card are COMPOSITE-KEY tables
//  (one row per child + milestone / dose / child), so the ledger runs in keyed
//  mode for them. Vaccine reminders are shared: the time syncs and each phone
//  arms its own alarm. These cases run the merge, the upload decision, the
//  question-id adoption and the alarm plan directly, with no network, and read
//  the stores' source to check they are wired.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_health_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_vaccine_data.dart';
import 'package:parentveda/services/remote/child_scoped_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Row = Map<String, dynamic>;

String iso(int ms) =>
    DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toIso8601String();

final t0 = DateTime.utc(2026, 10, 17, 9).millisecondsSinceEpoch;
const minute = 60000;

Row ms(String key, {String note = ''}) =>
    {'milestone_id': key, 'observed_on': iso(t0), 'note': note};

Row cloudMs(String key,
        {required int at,
        int? removedAt,
        String owner = 'me',
        String child = 'kid_a'}) =>
    {
      ...ms(key),
      'child_id': child,
      'user_id': owner,
      'updated_at': iso(at),
      'removed_at': removedAt == null ? null : iso(removedAt),
    };

List<Row> pull(ChildLogLedger l, List<Row> local, List<Row> rows,
        {String child = 'kid_a', String key = 'milestone_id'}) =>
    l.apply<Row>(
      childId: child,
      local: local,
      rows: rows,
      idOf: (r) => r[key] as String,
      fromRow: (r) => r,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  ChildLogLedger milestones() => ChildLogLedger(
      'pp_milestone_observations', 't_ms', keyColumn: 'milestone_id');

  group('keyed tables (milestones, vaccines)', () {
    test('an un-ticked milestone stays un-ticked against an older cloud copy',
        () {
      final l = milestones()..touch('m1', 'kid_a', columns: ms('m1'));
      l.book.remove('kid_a|m1', ms('m1'), at: t0 + 2 * minute);
      final out = pull(l, [], [cloudMs('m1', at: t0 + minute)]);
      expect(out, isEmpty);
      expect(l.book.dirty, contains('kid_a|m1'));
    });

    test('the same milestone of two children is two rows', () {
      final l = milestones()..touch('m1', 'kid_b', columns: ms('m1'));
      l.book.dirty.clear();
      pull(l, [], [cloudMs('m1', at: t0)]);
      expect(l.book.stamps.keys, containsAll(['kid_a|m1', 'kid_b|m1']));
      expect(l.book.dirty, isEmpty,
          reason: "kid_b's m1 is not missing from kid_a's rows");
    });

    test("the other parent's keyed row is an UPDATE on child + key", () {
      final l = milestones();
      pull(l, [], [cloudMs('m1', at: t0, owner: 'partner')]);
      l.touch('m1', 'kid_a', columns: ms('m1', note: 'fixed'));
      final up = l.uploadFor('kid_a|m1', {'m1': ms('m1', note: 'fixed')},
          uid: 'me', fallbackChildId: 'kid_a')!;
      expect(up.asUpdate, isTrue);
      expect(up.row.containsKey('user_id'), isFalse);
      expect(up.row['milestone_id'], 'm1');
      expect(up.row['child_id'], 'kid_a');
      expect(up.row['note'], 'fixed');
    });

    test('our own keyed row upserts on the composite key', () {
      final l = milestones()..touch('m1', 'kid_a', columns: ms('m1'));
      final up = l.uploadFor('kid_a|m1', {'m1': ms('m1')},
          uid: 'me', fallbackChildId: 'kid_a')!;
      expect(up.asUpdate, isFalse);
      expect(up.row['user_id'], 'me');
      expect(l.onConflict, 'child_id,milestone_id');
    });

    test("a child not on screen still uploads from the row's last columns", () {
      final l = milestones()..touch('m1', 'kid_b', columns: ms('m1', note: 'b'));
      final up = l.uploadFor('kid_b|m1', const {},
          uid: 'me', fallbackChildId: 'kid_a')!;
      expect(up.row['child_id'], 'kid_b');
      expect(up.row['note'], 'b');
    });

    test('a keyed change needs a child; before one exists nothing is booked', () {
      final l = milestones()..touch('m1', null, columns: ms('m1'));
      expect(l.hasPending, isFalse);
    });

    test('a dose un-ticked here beats the older "done" in the cloud', () {
      final l = ChildLogLedger('pp_vaccine_doses', 't_vax',
          keyColumn: 'vaccine_id', hasRemovedAt: false);
      const undone = VaxDoseRow(id: 'v1', done: false, reminder: false);
      l.book.touch('kid_a|v1', at: t0 + 2 * minute);
      l.childOf['kid_a|v1'] = 'kid_a';
      expect(l.keysFor('kid_a'), ['v1'],
          reason: 'an un-ticked dose is in no set, but the book remembers it');
      final out = l.apply<VaxDoseRow>(
        childId: 'kid_a',
        local: [undone],
        rows: [
          {
            'vaccine_id': 'v1',
            'child_id': 'kid_a',
            'user_id': 'partner',
            'done': true,
            'updated_at': iso(t0 + minute),
          },
        ],
        idOf: (d) => d.id,
        fromRow: VaxDoseRow.fromCloud,
      );
      expect(out.single.done, isFalse);
      final up = l.uploadFor('kid_a|v1', {'v1': undone.toCloud()},
          uid: 'me', fallbackChildId: 'kid_a')!;
      expect(up.row.containsKey('removed_at'), isFalse,
          reason: 'pp_vaccine_doses has no removed_at column');
      expect(up.row['done'], isFalse);
    });

    test('a dose row carries the reminder time both ways', () {
      final at = DateTime(2026, 11, 2, 9);
      final row = VaxDoseRow(id: 'v1', done: false, reminder: true, reminderAt: at)
          .toCloud();
      final back = VaxDoseRow.fromCloud(row);
      expect(back.reminder, isTrue);
      expect(back.reminderAt, at);
    });
  });

  group('the emergency card', () {
    ChildLogLedger card() => ChildLogLedger(
        'pp_emergency_cards', 't_card',
        keyColumn: 'child_id', ownerIsLastEditor: true);
    const filled = {
      'card': {'name': 'A', 'bloodGroup': 'O+'},
    };

    test('it is always saved as us, even over the other parent\'s card', () {
      final l = card();
      l.apply<Row>(
        childId: 'kid_a',
        local: const [],
        rows: [
          {
            'child_id': 'kid_a',
            'user_id': 'partner',
            ...filled,
            'updated_at': iso(t0),
          },
        ],
        idOf: (r) => r['child_id'] as String,
        fromRow: (r) => r,
      );
      l.touch('kid_a', 'kid_a', columns: filled);
      final up = l.uploadFor('kid_a|kid_a', {'kid_a': filled},
          uid: 'me', fallbackChildId: 'kid_a')!;
      expect(up.asUpdate, isFalse,
          reason: 'its UPDATE policy pins user_id to the caller');
      expect(up.row['user_id'], 'me');
      expect(l.onConflict, 'child_id');
    });

    test('Clear uploads as a removal, with the card for the NOT NULL column', () {
      final l = card()..remove('kid_a', filled, 'kid_a');
      final up = l.uploadFor('kid_a|kid_a', const {},
          uid: 'me', fallbackChildId: 'kid_a')!;
      expect(up.row['removed_at'], isNotNull);
      expect(up.row['card'], isNotNull);
    });

    test("the other parent's newer Clear clears it here", () {
      final l = card();
      l.book.touch('kid_a|kid_a', at: t0);
      l.childOf['kid_a|kid_a'] = 'kid_a';
      final out = l.apply<Row>(
        childId: 'kid_a',
        local: [
          {'child_id': 'kid_a', ...filled},
        ],
        rows: [
          {
            'child_id': 'kid_a',
            'user_id': 'partner',
            ...filled,
            'updated_at': iso(t0 + minute),
            'removed_at': iso(t0 + minute),
          },
        ],
        idOf: (r) => r['child_id'] as String,
        fromRow: (r) => r,
      );
      expect(out, isEmpty);
    });
  });

  group('doctor questions get ids', () {
    test('a question saved before ids adopts the cloud row with its text', () {
      final out = adoptQuestionIds(['Fever?'], [''], [
        {'id': 'c1', 'question': 'Fever?'},
      ]);
      expect(out.single.id, 'c1');
      expect(out.single.isNew, isFalse);
    });

    test('two equal questions stay two', () {
      final out = adoptQuestionIds(['Fever?', 'Fever?', 'Rash?'], ['', '', 'q9'], [
        {'id': 'c1', 'question': 'Fever?'},
      ]);
      expect(out[0].id, 'c1');
      expect(out[1].isNew, isTrue, reason: 'c1 is taken; this one is new');
      expect(out[1].id, isNot('c1'));
      expect(out[2].id, 'q9');
    });

    test('a removed cloud row is never adopted', () {
      final out = adoptQuestionIds(['Fever?'], [''], [
        {'id': 'c1', 'question': 'Fever?', 'removed_at': iso(t0)},
      ]);
      expect(out.single.isNew, isTrue);
    });
  });

  group('shared vaccine alarms', () {
    final now = DateTime(2026, 10, 18, 12);
    final soon = DateTime(2026, 10, 20, 9);
    final later = DateTime(2026, 10, 25, 9);
    final past = DateTime(2026, 10, 1, 9);

    test("the other parent's new reminder arms here", () {
      final c = vaxAlarmChanges({}, {'v1': soon}, now);
      expect(c.arm, {'v1': soon});
      expect(c.cancel, isEmpty);
    });

    test('a reminder switched off, or a dose given, cancels', () {
      final c = vaxAlarmChanges({'v1': soon}, {}, now);
      expect(c.cancel, {'v1'});
      expect(c.arm, isEmpty);
    });

    test('a moved reminder is cancelled and armed again', () {
      final c = vaxAlarmChanges({'v1': soon}, {'v1': later}, now);
      expect(c.cancel, {'v1'});
      expect(c.arm, {'v1': later});
    });

    test('nothing changes when nothing moved', () {
      final c = vaxAlarmChanges({'v1': soon}, {'v1': soon}, now);
      expect(c.arm, isEmpty);
      expect(c.cancel, isEmpty);
    });

    test('a time already passed is never armed', () {
      expect(vaxAlarmChanges({}, {'v1': past}, now).arm, isEmpty);
    });

    test('arming and cancelling use one id', () {
      expect(vaxAlarmId('vis_6w'), vaxAlarmId('vis_6w'));
      expect(vaxAlarmId('vis_6w'), 'vis_6w'.hashCode & 0x7fffffff,
          reason: 'alarms armed by older versions stay cancellable');
    });
  });

  test('every step-6 store is on a ledger and calls none of the old helpers', () {
    String live(String path) => File(path)
        .readAsStringSync()
        .split('\n')
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');
    const dir = 'lib/screens/post_pregnancy';
    for (final f in [
      '$dir/pp_documents_data.dart',
      '$dir/pp_milestones_data.dart',
      '$dir/pp_vaccine_data.dart',
      '$dir/pp_health_data.dart',
    ]) {
      final src = live(f);
      expect(src, contains('ChildLogLedger('), reason: f);
      expect(src, contains('SyncRegistry.registerPending(_hasPending)'),
          reason: '$f: the sign-out sheet must see waiting changes');
      for (final old in [
        'ChildSync.merge<',
        'ChildSync.push(',
        'ChildSync.remove(',
        'ChildSync.removeKeyed(',
      ]) {
        expect(src, isNot(contains(old)), reason: '$f still calls $old');
      }
    }
    // ChildSync.pushKeyed survives only inside the kept-for-revert helpers.
    final health = live('$dir/pp_health_data.dart');
    expect(RegExp(r'await _pullTable\(').allMatches(health).length, 6);
    // expect(health, contains('await _pullQuestions(childId)')); // before B11
    // Every child since B11 (2026-10-25), the one on screen first.
    expect(health, contains('await _pullQuestions(c)'));
    // expect(health, contains('await _pullEmergency(childId)')); // before B11
    expect(health, contains('await _pullEmergency(c)'));
    expect(RegExp(r"_after\(\(\) => _remove\('pp_\w+', row\.id, _\w+Row\(row\)\)\)")
            .allMatches(health)
            .length,
        6,
        reason: 'each removal carries its columns');
    // The screens no longer arm the alarm themselves: the store does.
    for (final f in ['$dir/vax_detail_screen.dart', '$dir/vax_tracker_screen.dart']) {
      expect(live(f), isNot(contains('scheduleOneOff(')), reason: f);
      expect(live(f), contains('setReminder('), reason: f);
    }
  });
}
