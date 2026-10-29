// =============================================================================
//  PP 21 (2026-10-29): a child's health conditions live on the child
// -----------------------------------------------------------------------------
//  docs/door-relevance/PARENTING-GAP.md item 21; docs/FAMILY-MODEL.md (the
//  child owns child records). Conditions were already per child on her phone
//  (B1's buckets); they now ride the child's own row (`children.conditions`,
//  0129) so the other parent's phone learns them. The child's copy is the
//  truth when it exists; null means "not said", empty means "none".
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_relevance.dart';
import 'package:parentveda/services/family_profile.dart';
import 'package:parentveda/services/remote/sync_row_book.dart';

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

final _now = DateTime(2026, 10, 29, 9);
final _dob = _now.subtract(const Duration(days: 245));

Child _kid(String id, {List<String>? conditions}) => Child(
  id: id,
  name: 'Dev',
  isBoy: true,
  dob: _dob,
  weightKg: 0,
  heightCm: 0,
  headCm: 0,
  conditions: conditions,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final kids = ChildProfileStore.instance;
  final fam = FamilyProfileStore.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    kids.resetForTest();
    fam.clearConditions();
    await fam.init(); // registers the child-switch listener, as the app does
  });

  group('the child carries them', () {
    test('null, empty and a list each survive the phone\'s cache', () {
      for (final c in [
        null,
        <String>[],
        ['eczema', 'reflux'],
      ]) {
        final back = Child.fromJson(_kid('c1', conditions: c).toJson());
        expect(back.conditions, c);
      }
    });

    test(
      'a cloud row: a missing column and a null both read as "not said"',
      () {
        final row = _kid('c1').toRow()..remove('conditions');
        expect(Child.fromRow(row).conditions, isNull);
        expect(Child.fromRow({...row, 'conditions': null}).conditions, isNull);
        expect(
          Child.fromRow({...row, 'conditions': <String>[]}).conditions,
          isEmpty,
        );
        expect(
          Child.fromRow({
            ...row,
            'conditions': ['hearing'],
          }).conditions,
          ['hearing'],
        );
      },
    );

    test('the row names the column only once 0129 is run', () {
      expect(
        _kid('c1', conditions: ['eczema']).toRow().containsKey('conditions'),
        kChildConditionsColumn,
      );
    });

    test(
      'a pull: a row that has not said keeps this phone\'s; "none" from the other parent is taken',
      () {
        final row = {
          ..._kid('c1').toRow(),
          'user_id': 'her',
          'updated_at': _now.toUtc().toIso8601String(),
          'removed_at': null,
        };
        final keep = childrenMerge(
          book: SyncRowBook()
            ..touch(
              'c1',
              at: _now
                  .subtract(const Duration(hours: 1))
                  .millisecondsSinceEpoch,
            ),
          live: [
            _kid('c1', conditions: ['eczema']),
          ],
          removed: [],
          rows: [
            {...row, 'conditions': null},
          ],
        );
        expect(keep.live.single.conditions, ['eczema']);
        final none = childrenMerge(
          book: SyncRowBook()
            ..touch(
              'c1',
              at: _now
                  .subtract(const Duration(hours: 1))
                  .millisecondsSinceEpoch,
            ),
          live: [
            _kid('c1', conditions: ['eczema']),
          ],
          removed: [],
          rows: [
            {...row, 'conditions': <String>[]},
          ],
        );
        expect(none.live.single.conditions, isEmpty);
      },
    );
  });

  group('one answer on both phones', () {
    test('a toggle writes this phone and the child\'s row together', () async {
      final c = await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
      fam.toggleCondition(HealthCondition.eczema);
      expect(fam.conditions, {HealthCondition.eczema});
      expect(kids.children.firstWhere((x) => x.id == c.id).conditions, [
        'eczema',
      ]);
      fam.clearConditions();
      expect(
        kids.children.firstWhere((x) => x.id == c.id).conditions,
        isEmpty,
        reason: '"none" is an answer the other phone must take',
      );
    });

    test(
      'the other parent\'s phone: nothing in its own bucket, the child\'s copy is read',
      () async {
        final c = await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
        expect(fam.conditions, isEmpty);
        await kids.setConditions(c.id, ['reflux', 'hearing']);
        expect(fam.conditions, {
          HealthCondition.reflux,
          HealthCondition.hearing,
        });
        expect(fam.hasCondition(HealthCondition.reflux), isTrue);
        expect(fam.recoBoosts().keys, containsAll(['reflux', 'hearing']));
        expect(fam.matchesSignal('Easing reflux'), isTrue);
        expect(ppAskVedaContext(now: _now).conditions, ['hearing', 'reflux']);
      },
    );

    test('the child\'s "none" beats a stale answer on this phone', () async {
      final c = await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
      fam.toggleCondition(HealthCondition.eczema);
      // The other parent cleared it; the pull brought the row.
      await kids.setConditions(c.id, const []);
      expect(fam.conditions, isEmpty);
      // And her next toggle starts from what she sees, not her old bucket.
      fam.toggleCondition(HealthCondition.colic);
      expect(fam.conditions, {HealthCondition.colic});
    });

    test('two children: each keeps their own, on their own row', () async {
      final older = await kids.addChild(
        name: 'Riya',
        isBoy: false,
        dob: _now.subtract(const Duration(days: 1100)),
      );
      final baby = await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
      await kids.switchTo(baby.id);
      fam.toggleCondition(HealthCondition.eczema);
      await kids.switchTo(older.id);
      fam.toggleCondition(HealthCondition.vision);
      Child row(String id) => kids.children.firstWhere((x) => x.id == id);
      expect(row(baby.id).conditions, ['eczema']);
      expect(row(older.id).conditions, ['vision']);
      expect(fam.conditions, {HealthCondition.vision});
    });
  });

  group('what was on her phone before 0129', () {
    test('onboarding: chosen before the child exists, they reach its row', () async {
      fam.toggleCondition(HealthCondition.cmpa);
      final c = await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
      expect(kids.children.firstWhere((x) => x.id == c.id).conditions, ['cmpa']);
      expect(fam.conditions, {HealthCondition.cmpa});
    });

    test(
      'a child whose row never had conditions takes this phone\'s, once',
      () async {
        final first = await kids.addChild(
          name: 'Riya',
          isBoy: false,
          dob: _now.subtract(const Duration(days: 1100)),
        );
        fam.toggleCondition(HealthCondition.asthma);
        // As an install from before PP 21: the answer only in her bucket.
        first.conditions = null;
        // Any change to the child list runs the carry (here, a second child).
        await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
        expect(kids.children.firstWhere((x) => x.id == first.id).conditions, [
          'asthma',
        ]);
      },
    );

    test(
      'an empty answer is not carried: null already reads as this phone\'s',
      () async {
        final first = await kids.addChild(
          name: 'Riya',
          isBoy: false,
          dob: _dob,
        );
        first.conditions = null;
        await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
        expect(
          kids.children.firstWhere((x) => x.id == first.id).conditions,
          isNull,
        );
      },
    );
  });

  group('wiring', () {
    test('the migration adds the column the row names, with no value check', () {
      final sql = File(
        'supabase/migrations/0129_children_conditions.sql',
      ).readAsStringSync();
      expect(
        sql,
        contains(
          'alter table public.children add column if not exists conditions text[];',
        ),
      );
      expect(sql.toLowerCase(), isNot(contains('add constraint')));
      expect(
        _code('lib/screens/post_pregnancy/pp_child_profile.dart'),
        contains("if (kChildConditionsColumn) 'conditions': conditions,"),
      );
    });

    test(
      'every condition read goes through the getter; writes reach the child',
      () {
        final src = _code('lib/services/family_profile.dart');
        expect(src, contains('_conditionsToChild();'));
        expect(src, contains('_backfillChildConditions();'));
        expect(
          src,
          contains(
            'hasCondition(HealthCondition c) => conditions.contains(c);',
          ),
        );
        for (final stale in [
          'for (final c in _conditions) {\n      add(',
          '_conditions.isNotEmpty ||',
          'ProfileField.health => _conditions',
        ]) {
          expect(src, isNot(contains(stale)), reason: stale);
        }
      },
    );

    test('Ask Veda no longer silences two children', () {
      expect(
        _code('lib/screens/post_pregnancy/pp_relevance.dart'),
        isNot(contains('child.children.length <= 1')),
      );
    });
  });
}
