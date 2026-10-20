// =============================================================================
//  The child profile and the name votes sync newer-wins (0105, sync log step 7)
// -----------------------------------------------------------------------------
//  `children` is the access root: every pp_* policy reads it through
//  public.my_child_ids(). So a removal is a soft delete (records kept, the
//  child restorable), a child the other parent created goes up as a plain
//  UPDATE with no user_id, and the growth figures (a mirror of the growth log)
//  never move the clock. Name votes are one person's own rows; a skip is
//  liked = false. These cases run the pure merge and upload rules directly,
//  with no network, and read the source to check they are wired.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_names_data.dart';
import 'package:parentveda/services/remote/sync_row_book.dart';

typedef Row = Map<String, dynamic>;

String iso(int ms) =>
    DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toIso8601String();

final t0 = DateTime.utc(2026, 10, 20, 9).millisecondsSinceEpoch;
const minute = 60000;

Child kid(String id, {String name = 'Aarav', double weight = 0}) => Child(
      id: id,
      name: name,
      isBoy: true,
      dob: DateTime(2026, 6, 29),
      weightKg: weight,
      heightCm: 0,
      headCm: 0,
    );

Row cloudKid(String id,
        {required int at,
        String name = 'Aarav',
        double weight = 0,
        int? removedAt,
        String owner = 'me'}) =>
    {
      ...kid(id, name: name, weight: weight).toRow(),
      'user_id': owner,
      'updated_at': iso(at),
      'removed_at': removedAt == null ? null : iso(removedAt),
    };

Row vote(String name, {required bool liked, required int at}) =>
    {'user_id': 'me', 'name': name, 'liked': liked, 'updated_at': iso(at)};

void main() {
  group('child profile', () {
    test('an offline edit survives the pull', () {
      final book = SyncRowBook()..touch('c1', at: t0 + 5 * minute);
      final out = childrenMerge(
        book: book,
        live: [kid('c1', name: 'Kabir')],
        removed: [],
        rows: [cloudKid('c1', at: t0, name: 'Aarav')],
      );
      expect(out.live.single.name, 'Kabir');
      expect(book.dirty, contains('c1'));
    });

    test("the other parent's newer edit wins", () {
      final book = SyncRowBook()..touch('c1', at: t0);
      final out = childrenMerge(
        book: book,
        live: [kid('c1', name: 'Aarav')],
        removed: [],
        rows: [cloudKid('c1', at: t0 + minute, name: 'Kabir', owner: 'her')],
      );
      expect(out.live.single.name, 'Kabir');
      expect(book.dirty, isNot(contains('c1')));
    });

    test('a taken row keeps this phone\'s growth figures', () {
      final book = SyncRowBook()..touch('c1', at: t0);
      final out = childrenMerge(
        book: book,
        live: [kid('c1', weight: 7.2)],
        removed: [],
        rows: [cloudKid('c1', at: t0 + minute, name: 'Kabir', weight: 5.0)],
      );
      expect(out.live.single.name, 'Kabir');
      expect(out.live.single.weightKg, 7.2);
    });

    test('a removal stays removed when the other phone still holds the child',
        () {
      // Phone B never heard of the removal; the cloud has it, newer.
      final book = SyncRowBook()..touch('c1', at: t0);
      final out = childrenMerge(
        book: book,
        live: [kid('c1')],
        removed: [],
        rows: [cloudKid('c1', at: t0 + minute, removedAt: t0 + minute)],
      );
      expect(out.live, isEmpty);
      expect(out.removed.single.id, 'c1');
      expect(book.dirty, isEmpty, reason: 'B must not push the child back');
    });

    test('a restore beats the older removal', () {
      final book = SyncRowBook()
        ..remove('c1', kid('c1').toRow(), at: t0)
        ..touch('c1', at: t0 + minute);
      final out = childrenMerge(
        book: book,
        live: [kid('c1')],
        removed: [],
        rows: [cloudKid('c1', at: t0, removedAt: t0)],
      );
      expect(out.live.single.id, 'c1');
      expect(book.dirty, contains('c1'));
      final up = childUploadFor(book, 'c1', out.live.single, uid: 'me')!;
      expect(up.row['removed_at'], isNull);
    });

    test('a removal here uploads with removed_at and the columns', () {
      final book = SyncRowBook()..remove('c1', kid('c1').toRow(), at: t0);
      final up = childUploadFor(book, 'c1', null, uid: 'me')!;
      expect(up.asUpdate, isFalse);
      expect(up.row['removed_at'], iso(t0));
      expect(up.row['name'], 'Aarav');
      expect(up.row['user_id'], 'me');
    });

    test("the other parent's child goes as an UPDATE with no user_id", () {
      final book = SyncRowBook();
      childrenMerge(
        book: book,
        live: [],
        removed: [],
        rows: [cloudKid('c1', at: t0, owner: 'her')],
      );
      book.touch('c1', at: t0 + minute);
      final up = childUploadFor(book, 'c1', kid('c1', name: 'Kabir'), uid: 'me')!;
      expect(up.asUpdate, isTrue);
      expect(up.row.containsKey('user_id'), isFalse);
      expect(up.row.containsKey('id'), isFalse);
      expect(up.row['name'], 'Kabir');
    });

    test('a child the cloud has never seen is upserted as ours', () {
      final book = SyncRowBook();
      final out = childrenMerge(
        book: book,
        live: [kid('c_new')],
        removed: [],
        rows: [],
      );
      expect(out.live.single.id, 'c_new');
      expect(book.dirty, contains('c_new'));
      final up = childUploadFor(book, 'c_new', out.live.single, uid: 'me')!;
      expect(up.asUpdate, isFalse);
      expect(up.row['user_id'], 'me');
    });
  });

  group('name votes', () {
    test('a skip made offline stays skipped', () {
      final book = SyncRowBook()..touch('Aarav', at: t0 + minute);
      final out = nameVotesMerge(
        book: book,
        liked: [],
        skipped: {'Aarav'},
        rows: [vote('Aarav', liked: true, at: t0)],
      );
      expect(out.liked, isEmpty);
      expect(out.skipped, contains('Aarav'));
      expect(book.dirty, contains('Aarav'));
    });

    test("the other phone's stale like does not bring a name back", () {
      // This phone still lists Aarav as liked (from before); the cloud says
      // she skipped it later on the other phone.
      final book = SyncRowBook()..touch('Aarav', at: t0);
      final out = nameVotesMerge(
        book: book,
        liked: ['Aarav'],
        skipped: {},
        rows: [vote('Aarav', liked: false, at: t0 + minute)],
      );
      expect(out.liked, isEmpty);
      expect(out.skipped, contains('Aarav'));
      expect(book.dirty, isEmpty);
    });

    test('a like the cloud has never seen waits to upload', () {
      final book = SyncRowBook();
      final out = nameVotesMerge(
        book: book,
        liked: ['Meera'],
        skipped: {},
        rows: [],
      );
      expect(out.liked, ['Meera']);
      expect(book.dirty, contains('Meera'));
    });
  });

  test('the stores and screens are wired', () {
    String src(String p) => File(p).readAsStringSync();
    expect(src('lib/screens/post_pregnancy/pp_growth_data.dart'),
        contains('_child.setMeasures('));
    final profile = src('lib/screens/post_pregnancy/pp_child_profile.dart');
    expect(profile, contains('childrenMerge('));
    expect(profile, contains("updateSharedConfirmed('children'"));
    expect(src('lib/screens/post_pregnancy/pp_names_data.dart'),
        contains('nameVotesMerge('));
    expect(src('lib/screens/profile/pv_you_screen.dart'),
        contains('showPvRemovedChildrenSheet('));
    expect(src('lib/screens/profile/pv_you_sheets.dart'),
        contains('restoreChild('));
    expect(src('lib/screens/profile/pv_child_screen.dart'),
        contains('restoreChild('));
  });
}
