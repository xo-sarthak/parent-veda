// =============================================================================
//  PP 22 (2026-10-29): a child's other answers live on the child
// -----------------------------------------------------------------------------
//  docs/door-relevance/PARENTING-GAP.md item 22; docs/FAMILY-MODEL.md (the
//  child owns child records). Feeding, sleep, the vaccine schedule, a NICU
//  stay, a twin and "born early" were per child on her phone (B1's buckets)
//  but rode only HER cloud items. They now ride the child's own row (0130),
//  by PP 21's rule: the child's copy is the truth when it exists, and null is
//  "not said" for every field, the booleans included. Learning style became
//  the parent's own preference and stays off the child's row.
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

Child _kid(
  String id, {
  List<String>? feedings,
  List<String>? sleeps,
  String? vaxSchedule,
  bool? nicu,
  bool? multiple,
  bool? premature,
}) => Child(
  id: id,
  name: 'Dev',
  isBoy: true,
  dob: _dob,
  weightKg: 0,
  heightCm: 0,
  headCm: 0,
  feedings: feedings,
  sleeps: sleeps,
  vaxSchedule: vaxSchedule,
  nicu: nicu,
  multiple: multiple,
  premature: premature,
);

const _columns = [
  'feedings',
  'sleeps',
  'vax_schedule',
  'nicu',
  'multiple',
  'premature',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final kids = ChildProfileStore.instance;
  final fam = FamilyProfileStore.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    kids.resetForTest();
    fam
      ..setFeeding(null)
      ..setSleep(null)
      ..setBirth(premature: false, nicu: false, multiple: false);
    await fam.init(); // registers the child-switch listener, as the app does
  });

  Child row(String id) => kids.children.firstWhere((x) => x.id == id);

  group('the child carries them', () {
    test('null, "none" and an answer each survive the phone\'s cache', () {
      for (final k in [
        _kid('c1'),
        _kid(
          'c1',
          feedings: [],
          sleeps: [],
          nicu: false,
          multiple: false,
          premature: false,
        ),
        _kid(
          'c1',
          feedings: ['formula', 'breastfeeding'],
          sleeps: ['shortNaps'],
          vaxSchedule: 'iap',
          nicu: true,
          multiple: true,
          premature: true,
        ),
      ]) {
        final back = Child.fromJson(k.toJson());
        expect(back.feedings, k.feedings);
        expect(back.sleeps, k.sleeps);
        expect(back.vaxSchedule, k.vaxSchedule);
        expect(back.nicu, k.nicu);
        expect(back.multiple, k.multiple);
        expect(back.premature, k.premature);
      }
    });

    test(
      'a cloud row: a missing column and a null both read as "not said"',
      () {
        final full = _kid('c1').toRow();
        final row = {...full}..removeWhere((k, _) => _columns.contains(k));
        final c = Child.fromRow(row);
        expect([
          c.feedings,
          c.sleeps,
          c.vaxSchedule,
          c.nicu,
          c.multiple,
          c.premature,
        ], everyElement(isNull));
        final no = Child.fromRow({
          ...row,
          'nicu': false,
          'feedings': <String>[],
        });
        expect(no.nicu, isFalse, reason: 'false is "no", not "not said"');
        expect(no.feedings, isEmpty);
      },
    );

    test('the row names the columns only once 0130 is run', () {
      final r = _kid('c1', nicu: true).toRow();
      for (final col in _columns) {
        expect(r.containsKey(col), kChildAnswersColumns, reason: col);
      }
    });

    test(
      'a pull: a row that has not said keeps this phone\'s; a "no" is taken',
      () {
        final base = {
          ..._kid('c1').toRow(),
          'user_id': 'her',
          'updated_at': _now.toUtc().toIso8601String(),
          'removed_at': null,
        };
        SyncRowBook book() => SyncRowBook()
          ..touch(
            'c1',
            at: _now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
          );
        final keep = childrenMerge(
          book: book(),
          live: [
            _kid('c1', feedings: ['formula'], vaxSchedule: 'iap', nicu: true),
          ],
          removed: [],
          rows: [
            {...base, 'feedings': null, 'vax_schedule': null, 'nicu': null},
          ],
        ).live.single;
        expect(keep.feedings, ['formula']);
        expect(keep.vaxSchedule, 'iap');
        expect(keep.nicu, isTrue);
        final no = childrenMerge(
          book: book(),
          live: [_kid('c1', nicu: true)],
          removed: [],
          rows: [
            {...base, 'nicu': false},
          ],
        ).live.single;
        expect(no.nicu, isFalse);
      },
    );
  });

  group('one answer on both phones', () {
    test('every write reaches the child\'s row', () async {
      final c = await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
      fam.toggleFeeding(FeedingMethod.breastfeeding);
      fam.toggleFeeding(FeedingMethod.formula);
      fam.toggleSleep(SleepPattern.nightWaking);
      fam.setVaxSchedule(VaxSchedule.iap);
      fam.setBirth(nicu: true, multiple: true);
      fam.setBirthDetails(early: true, bornWeeks: 33);
      expect(row(c.id).feedings, [
        'breastfeeding',
        'formula',
      ], reason: 'pick order kept');
      expect(row(c.id).sleeps, ['nightWaking']);
      expect(row(c.id).vaxSchedule, 'iap');
      expect(row(c.id).nicu, isTrue);
      expect(row(c.id).multiple, isTrue);
      expect(row(c.id).premature, isTrue);
      fam.setFeeding(FeedingMethod.solids);
      fam.setSleep(SleepPattern.well);
      expect(row(c.id).feedings, ['solids']);
      expect(row(c.id).sleeps, ['well']);
    });

    test('setBirth writes only what was answered', () async {
      final c = await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
      fam.setBirth(nicu: true);
      expect(row(c.id).nicu, isTrue);
      expect(row(c.id).multiple, isNull, reason: 'not asked stays "not said"');
      expect(row(c.id).premature, isNull);
    });

    test(
      'the other parent\'s phone: nothing in its own bucket, the child\'s copy is read',
      () async {
        final c = await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
        expect(fam.feedings, isEmpty);
        expect(fam.nicu, isFalse);
        await kids.setAnswers(
          c.id,
          feedings: ['formula'],
          sleeps: ['nightWaking', 'shortNaps'],
          vaxSchedule: 'iap',
          nicu: true,
          multiple: true,
        );
        expect(fam.feedings, {FeedingMethod.formula});
        expect(fam.feeding, FeedingMethod.formula);
        expect(fam.sleep, SleepPattern.nightWaking);
        expect(fam.vaxSchedule, VaxSchedule.iap);
        expect(fam.nicu, isTrue);
        expect(fam.multiple, isTrue);
        expect(fam.premature, isFalse);
        expect(fam.recoBoosts().keys, containsAll(['formula', 'sleep']));
        expect(
          fam.aiContext(),
          allOf(contains('feeding: '), contains('sleep: ')),
        );
        expect(
          ppAskVedaContext(now: _now).signals,
          containsAll(['born_early', 'formula', 'twins']),
        );
      },
    );

    test(
      'the child\'s "no" beats a stale "yes" on this phone, and the next toggle starts from it',
      () async {
        final c = await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
        fam.setBirth(nicu: true);
        fam.toggleFeeding(FeedingMethod.breastfeeding);
        // The other parent answered; the pull brought the row.
        await kids.setAnswers(c.id, nicu: false, feedings: const []);
        expect(fam.nicu, isFalse);
        expect(fam.feedings, isEmpty);
        fam.toggleFeeding(FeedingMethod.formula);
        expect(fam.feedings, {FeedingMethod.formula});
      },
    );

    test(
      'the vaccine schedule: one schedule for the same baby on both phones',
      () async {
        final c = await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
        fam.setVaxSchedule(VaxSchedule.uip);
        await kids.setAnswers(c.id, vaxSchedule: 'iap');
        expect(fam.vaxSchedule, VaxSchedule.iap);
      },
    );

    test('two children: each keeps their own, on their own row', () async {
      final older = await kids.addChild(
        name: 'Riya',
        isBoy: false,
        dob: _now.subtract(const Duration(days: 1100)),
      );
      final baby = await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
      await kids.switchTo(baby.id);
      fam.toggleFeeding(FeedingMethod.breastfeeding);
      fam.setBirth(nicu: true);
      await kids.switchTo(older.id);
      fam.toggleFeeding(FeedingMethod.solids);
      expect(row(baby.id).feedings, ['breastfeeding']);
      expect(row(baby.id).nicu, isTrue);
      expect(row(older.id).feedings, ['solids']);
      expect(row(older.id).nicu, isNull);
      expect(fam.feedings, {FeedingMethod.solids});
      expect(fam.nicu, isFalse);
    });
  });

  group('what was on her phone before 0130', () {
    test(
      'onboarding: answered before the child exists, they reach its row',
      () async {
        fam.setFeeding(FeedingMethod.mixed);
        fam.setSleep(SleepPattern.earlyWaking);
        fam.setBirth(multiple: true);
        final c = await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
        expect(row(c.id).feedings, ['mixed']);
        expect(row(c.id).sleeps, ['earlyWaking']);
        expect(row(c.id).multiple, isTrue);
        expect(fam.feeding, FeedingMethod.mixed);
      },
    );

    test(
      'a child whose row never had them takes this phone\'s, once',
      () async {
        final first = await kids.addChild(
          name: 'Riya',
          isBoy: false,
          dob: _now.subtract(const Duration(days: 1100)),
        );
        fam.toggleSleep(SleepPattern.shortNaps);
        fam.setBirth(nicu: true);
        // As an install from before PP 22: the answers only in her bucket.
        first
          ..sleeps = null
          ..nicu = null;
        // Any change to the child list runs the carry (here, a second child).
        await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
        expect(row(first.id).sleeps, ['shortNaps']);
        expect(row(first.id).nicu, isTrue);
      },
    );

    test(
      'a "no" or an empty list is not carried: null already reads as this phone\'s',
      () async {
        final first = await kids.addChild(
          name: 'Riya',
          isBoy: false,
          dob: _dob,
        );
        first
          ..feedings = null
          ..nicu = null
          ..multiple = null;
        await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
        expect(row(first.id).feedings, isNull);
        expect(row(first.id).nicu, isNull);
        expect(row(first.id).multiple, isNull);
      },
    );
  });

  group('learning style is the parent\'s', () {
    test('it no longer flips when the child switches', () async {
      final older = await kids.addChild(
        name: 'Riya',
        isBoy: false,
        dob: _now.subtract(const Duration(days: 1100)),
      );
      final baby = await kids.addChild(name: 'Dev', isBoy: true, dob: _dob);
      await kids.switchTo(baby.id);
      if (!fam.learnings.contains(LearningStyle.videos)) {
        fam.toggleLearning(LearningStyle.videos);
      }
      final mine = fam.learnings;
      await kids.switchTo(older.id);
      expect(fam.learnings, mine);
      await kids.switchTo(baby.id);
      expect(fam.learnings, mine);
    });

    test('it travels as her own set, never inside a child bucket', () {
      final items = fam.cloudItems().keys;
      expect(
        items.where((k) => k.startsWith('child|') && k.contains('|learnings')),
        isEmpty,
      );
      final src = _code('lib/services/family_profile.dart');
      expect(
        src,
        contains("'learnings', // PP 22: the parent's now, one item per pick"),
      );
    });
  });

  group('wiring', () {
    test(
      'the migration adds every column the row names, with no value check and no default',
      () {
        final sql = File(
          'supabase/migrations/0130_children_answers.sql',
        ).readAsStringSync().replaceAll('\r\n', '\n');
        for (final (col, type) in [
          ('feedings', 'text[]'),
          ('sleeps', 'text[]'),
          ('vax_schedule', 'text'),
          ('nicu', 'boolean'),
          ('multiple', 'boolean'),
          ('premature', 'boolean'),
        ]) {
          expect(
            sql,
            contains(
              'alter table public.children add column if not exists $col $type;',
            ),
            reason: col,
          );
        }
        expect(sql.toLowerCase(), isNot(contains('add constraint')));
        expect(sql.toLowerCase(), isNot(contains(' default ')));
        final child = _code('lib/screens/post_pregnancy/pp_child_profile.dart');
        for (final col in _columns) {
          expect(
            child,
            contains("if (kChildAnswersColumns) '$col':"),
            reason: col,
          );
        }
      },
    );

    test('every read goes through the getters; writes reach the child', () {
      final src = _code('lib/services/family_profile.dart');
      expect(
        RegExp(r'_answerToChild\(').allMatches(src).length,
        greaterThanOrEqualTo(7),
      );
      expect(RegExp(r'_backfillChildAnswers\(\);').allMatches(src).length, 3);
      for (final stale in [
        'if (_feeding != null)',
        'if (_sleep != null)',
        '_sleep == SleepPattern.nightWaking',
        '_feeding == FeedingMethod.solids',
        'ProfileField.feeding => _feeding',
        'ProfileField.sleep => _sleep',
        'bool get nicu => _nicu;',
        'bool get multiple => _multiple;',
        'VaxSchedule? get vaxSchedule => _vaxSchedule;',
      ]) {
        expect(src, isNot(contains(stale)), reason: stale);
      }
    });
  });
}
