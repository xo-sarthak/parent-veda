// =============================================================================
//  R2 (2026-10-25): his phone follows her stage and her loss
// -----------------------------------------------------------------------------
//  His paired phone read his own profile row for two facts that are hers.
//  Now her row answers there (0009 already lets him read it), his phone never
//  writes either, and her phone never follows his.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/partner_side.dart';

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => PartnerSide.resetForTest());
  tearDown(() => PartnerSide.resetForTest());

  group('who follows whom', () {
    test('only the father phone, and only while paired', () {
      expect(followsPartnerFor(role: 'father', partnerId: 'her'), isTrue);
      expect(followsPartnerFor(role: 'father', partnerId: null), isFalse);
      expect(followsPartnerFor(role: 'father', partnerId: ''), isFalse);
      // Pairing is symmetric; her phone has his id too and must not follow.
      expect(followsPartnerFor(role: 'mother', partnerId: 'him'), isFalse);
      expect(followsPartnerFor(role: null, partnerId: 'him'), isFalse);
    });
  });

  group('which row is read', () {
    final asked = <String>[];

    void seams({String? partner, Map<String, dynamic>? hers, Map<String, dynamic>? own}) {
      asked.clear();
      PartnerSide.partnerIdOf = () async => partner;
      PartnerSide.rowOf = (id, cols) async {
        asked.add('hers:$id');
        return hers;
      };
      PartnerSide.ownRow = (cols) async {
        asked.add('own');
        return own;
      };
    }

    test('his paired phone reads her row, and says so', () async {
      SharedPreferences.setMockInitialValues({'user_role': 'father'});
      seams(partner: 'her-id', hers: {'life_stage': 'parenting'}, own: {'life_stage': 'pregnancy'});
      final r = await PartnerSide.readStageRow('life_stage');
      expect(r.hers, isTrue);
      expect(r.row!['life_stage'], 'parenting');
      expect(asked, ['hers:her-id']);
      expect(PartnerSide.following, isTrue);
    });

    test('her phone reads her own row, even though she is paired', () async {
      SharedPreferences.setMockInitialValues({'user_role': 'mother'});
      seams(partner: 'his-id', hers: {'life_stage': 'pregnancy'}, own: {'life_stage': 'parenting'});
      final r = await PartnerSide.readStageRow('life_stage');
      expect(r.hers, isFalse);
      expect(r.row!['life_stage'], 'parenting');
      expect(asked, ['own']);
      expect(PartnerSide.following, isFalse);
    });

    test('a father not yet paired reads his own row (he set up on his own)', () async {
      SharedPreferences.setMockInitialValues({'user_role': 'father'});
      seams(partner: null, own: {'life_stage': 'trying'});
      final r = await PartnerSide.readStageRow('life_stage');
      expect(r.hers, isFalse);
      expect(asked, ['own']);
    });

    test('her row unreadable is NOT a fall back to his own (offline keeps what he has)', () async {
      SharedPreferences.setMockInitialValues({'user_role': 'father'});
      seams(partner: 'her-id', hers: null, own: {'life_stage': 'pregnancy'});
      final r = await PartnerSide.readStageRow('life_stage');
      expect(r.hers, isTrue);
      expect(r.row, isNull);
      expect(asked, ['hers:her-id'], reason: 'his own stale row must not be read in her place');
    });
  });

  group('wiring (the wiring gate)', () {
    test('the stage reads through it, and his phone never pushes the stage', () {
      final src = _code('lib/services/life_stage_store.dart');
      final pull = src.substring(src.indexOf('Future<void> pullFromCloud()'), src.indexOf('Future<void> pushToCloud()'));
      expect(pull, contains("PartnerSide.readStageRow('life_stage, life_stage_at')"));
      expect(pull, isNot(contains('fetchMyProfile(')));
      final push = src.substring(src.indexOf('Future<void> pushToCloud()'));
      expect(push.indexOf('if (PartnerSide.following) return;'), lessThan(push.indexOf('sendTracked(')));
    });

    test('the loss reads through it, and his phone never sends the column', () {
      final src = _code('lib/services/pregnancy_ended_store.dart');
      final sync = src.substring(src.indexOf('Future<void> syncFromCloud()'), src.indexOf('Future<void> _persist()'));
      expect(sync, contains('PartnerSide.readStageRow(kColumn)'));
      expect(sync, isNot(contains('fetchMyProfile(')));
      // Her answer is taken and the function returns before any seeding send.
      final hers = sync.indexOf('if (read.hers) {');
      expect(hers, greaterThan(-1));
      expect(hers, lessThan(sync.indexOf('PendingProfile.send(')));
      expect(sync.substring(hers, sync.indexOf('PendingProfile.send(')), contains('return;'));
    });

    test('no migration: 0009 already lets a paired partner read her row', () {
      final sql = File('supabase/migrations/0009_pairing.sql').readAsStringSync();
      expect(sql, contains('using (auth.uid() = id or id = public.my_partner_id())'));
    });
  });
}
