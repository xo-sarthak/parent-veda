// =============================================================================
//  Per-item merge for the light stores (sync log step 13, 0110)
// -----------------------------------------------------------------------------
//  Two phones and a server in one process: the server is
//  `MergedItems.merge` (the Dart twin of `pv_state_merge`), each phone a
//  small store on the CloudMergedStore mixin with its own book.
// =============================================================================

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reading_data.dart';
import 'package:parentveda/services/remote/cloud_merged_store.dart';
import 'package:parentveda/services/remote/sync_registry.dart';

/// A ticked-items store: one item per ticked id.
class _Ticks extends ChangeNotifier with CloudMergedStore {
  _Ticks(this.phone, {this.legacy}) {
    // Like the step-12 resets: clear memory and notify. Registered first, so
    // it runs while the mixin still thinks it is ready.
    SyncRegistry.registerReset(_forget);
  }
  void _forget() {
    ticked.clear();
    notifyListeners();
  }

  final String phone;
  final String? legacy;
  final Set<String> ticked = {};

  void tick(String id) {
    ticked.add(id);
    notifyListeners();
  }

  void untick(String id) {
    ticked.remove(id);
    notifyListeners();
  }

  @override
  String get cloudKey => 'ticks';
  @override
  String get mergedBookKey => 'book_$phone';
  @override
  String? get legacyBlobKey => legacy;
  @override
  Map<String, Object?> cloudItems() => {for (final id in ticked) id: true};
  @override
  void applyCloudItems(Map<String, Object?> items) {
    ticked
      ..clear()
      ..addAll(items.keys);
  }

  @override
  void applyLegacyBlob(Object blob) {
    ticked
      ..clear()
      ..addAll((blob as List).map((e) => e.toString()));
  }

  @override
  Future<void> persistLocalCache() async {}
}

/// An answers store: one item per question.
class _Answers extends ChangeNotifier with CloudMergedStore {
  _Answers(this.phone);
  final String phone;
  final Map<String, String> answers = {};

  void answer(String q, String a) {
    answers[q] = a;
    notifyListeners();
  }

  @override
  String get cloudKey => 'answers';
  @override
  String get mergedBookKey => 'book_$phone';
  @override
  Map<String, Object?> cloudItems() => Map<String, Object?>.from(answers);
  @override
  void applyCloudItems(Map<String, Object?> items) {
    answers
      ..clear()
      ..addAll(items.map((k, v) => MapEntry(k, v.toString())));
  }

  @override
  Future<void> persistLocalCache() async {}
}

/// A store whose item values are maps.
class _Maps extends ChangeNotifier with CloudMergedStore {
  _Maps(this.phone);
  final String phone;
  final Map<String, Map<String, Object?>> values = {};

  void set(String k, Map<String, Object?> v) {
    values[k] = v;
    notifyListeners();
  }

  @override
  String get cloudKey => 'maps';
  @override
  String get mergedBookKey => 'book_$phone';
  @override
  Map<String, Object?> cloudItems() => Map<String, Object?>.from(values);
  @override
  void applyCloudItems(Map<String, Object?> items) {
    values
      ..clear()
      ..addAll(items.map(
          (k, v) => MapEntry(k, Map<String, Object?>.from(v as Map))));
  }

  @override
  Future<void> persistLocalCache() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, Map<String, dynamic>> server;
  late int clock;
  late bool online;
  late Map<String, Object?> legacyBlobs;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    server = {};
    clock = 1000000;
    online = true;
    legacyBlobs = {};
    CloudMergeIo.isLoggedIn = () => true;
    CloudMergeIo.nowMs = () => clock;
    CloudMergeIo.loadLegacy = (k) async => legacyBlobs[k];
    CloudMergeIo.merge = (key, items) async {
      if (!online) throw const SocketException('offline');
      final merged =
          MergedItems.merge(server[key] ?? {}, items, nowMs: clock);
      server[key] = merged;
      return Map<String, dynamic>.from(merged);
    };
  });
  tearDown(CloudMergeIo.restore);

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('MergedItems.merge (the rule pv_state_merge also runs)', () {
    test('newer wins, a tie keeps the base', () {
      final base = {
        'a': {'v': 1, 't': 10},
        'b': {'v': 1, 't': 10},
      };
      final m = MergedItems.merge(base, {
        'a': {'v': 2, 't': 11},
        'b': {'v': 2, 't': 10},
        'c': {'v': 3, 't': 5},
      }, nowMs: 100);
      expect(m['a']!['v'], 2);
      expect(m['b']!['v'], 1);
      expect(m['c']!['v'], 3);
    });

    test('an older copy never replaces a newer one', () {
      final m = MergedItems.merge({
        'a': {'v': 'new', 't': 50},
      }, {
        'a': {'v': 'old', 't': 40},
      }, nowMs: 100);
      expect(m['a']!['v'], 'new');
    });

    test('a clock from the future is pulled back to now', () {
      final m = MergedItems.merge({}, {
        'a': {'v': 1, 't': 100 + 10 * 60 * 1000},
      }, nowMs: 100);
      expect(m['a']!['t'], 100);
    });

    test('tombstones past the server window go, live items stay', () {
      const day = 86400000;
      final now = 200 * day;
      final m = MergedItems.merge({
        'old_gone': {'v': null, 't': now - 91 * day, 'd': true},
        'new_gone': {'v': null, 't': now - 10 * day, 'd': true},
        'old_live': {'v': 1, 't': now - 400 * day},
      }, {}, nowMs: now);
      expect(m.keys, unorderedEquals(['new_gone', 'old_live']));
    });

    test('the SQL runs the same rule', () {
      final sql = File('supabase/migrations/0110_state_merge_and_records.sql')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(sql, contains('security invoker'));
      expect(sql, contains('for update'));
      expect(sql, contains('if vt > now_ms + 300000 then'));
      expect(MergedItems.futureSlackMs, 300000);
      expect(sql,
          contains("vt > coalesce((cur->k->>'t')::numeric, 0)::bigint"));
      expect(sql, contains('90::bigint * 86400000'));
      expect(MergedItems.serverKeep, const Duration(days: 90));
      expect(MergedItems.phoneKeep < MergedItems.serverKeep, isTrue);
    });
  });

  group('two phones', () {
    test('each ticks a different item: both ticks stay', () async {
      final a = _Ticks('a'), b = _Ticks('b');
      await a.syncMergedFromCloud();
      await b.syncMergedFromCloud();
      clock += 10;
      a.tick('nappies');
      clock += 10;
      b.tick('shawl');
      await settle();
      await a.syncMergedFromCloud();
      expect(a.ticked, {'nappies', 'shawl'});
      expect(b.ticked, {'nappies', 'shawl'});
    });

    test('a removal travels and is not undone by the other phone', () async {
      final a = _Ticks('a'), b = _Ticks('b');
      await a.syncMergedFromCloud();
      await b.syncMergedFromCloud();
      clock += 10;
      a.tick('x');
      await settle();
      await b.syncMergedFromCloud();
      expect(b.ticked, {'x'});
      clock += 10;
      b.untick('x');
      await settle();
      await a.syncMergedFromCloud();
      expect(a.ticked, isEmpty);
      clock += 10;
      a.tick('x'); // ticked again later: the newer edit wins
      await settle();
      await b.syncMergedFromCloud();
      expect(b.ticked, {'x'});
    });

    test('the same answer on two phones: the later edit wins', () async {
      final a = _Answers('a'), b = _Answers('b');
      await a.syncMergedFromCloud();
      await b.syncMergedFromCloud();
      clock += 10;
      online = false;
      a.answer('q1', 'yes');
      await settle();
      online = true;
      clock += 10;
      b.answer('q1', 'no');
      await settle();
      await a.syncMergedFromCloud();
      expect(a.answers['q1'], 'no');
      expect(a.mergedChangeWaiting, isFalse);
    });
  });

  group('one phone', () {
    test('an offline edit waits, survives a restart and goes up', () async {
      final a = _Ticks('a');
      await a.syncMergedFromCloud();
      online = false;
      clock += 10;
      a.tick('bottle');
      await settle();
      expect(a.mergedChangeWaiting, isTrue);
      expect(server['ticks:items']?['bottle'], isNull);
      // The app closes; a new instance on the same phone reads its book.
      final again = _Ticks('a')..ticked.add('bottle');
      online = true;
      await again.syncMergedFromCloud();
      expect(server['ticks:items']!['bottle']!['v'], true);
      expect(again.mergedChangeWaiting, isFalse);
    });

    test('what a phone already holds on its first run is kept, at t = 0',
        () async {
      final a = _Ticks('a')..ticked.addAll({'p', 'q'});
      await a.syncMergedFromCloud();
      expect(server['ticks:items']!['p']!['t'], 0);
      expect(a.ticked, {'p', 'q'});
    });

    test('a phone holding nothing reads the old whole blob once', () async {
      legacyBlobs['ticks_v1'] = ['old1', 'old2'];
      final a = _Ticks('a', legacy: 'ticks_v1');
      await a.syncMergedFromCloud();
      expect(a.ticked, {'old1', 'old2'});
      expect(server['ticks:items']!.keys, containsAll(['old1', 'old2']));
    });

    test('a store with demo seeds still takes the old blob on a new phone',
        () async {
      legacyBlobs['ticks_v1'] = ['real'];
      final a = _Ticks('a', legacy: 'ticks_v1')..ticked.add('demo_seed');
      await a.syncMergedFromCloud();
      expect(a.ticked, {'real'});
    });

    test('an old change still waiting to upload beats the old blob', () async {
      SharedPreferences.setMockInitialValues(
          {'pv_blob_waiting_ticks_v1': true});
      legacyBlobs['ticks_v1'] = ['older'];
      final a = _Ticks('a', legacy: 'ticks_v1')..ticked.add('mine');
      await a.syncMergedFromCloud();
      expect(a.ticked, {'mine'});
    });

    test('the phone drops a settled removal after 80 days', () async {
      const day = 86400000;
      final a = _Ticks('a');
      await a.syncMergedFromCloud();
      clock += 10;
      a.tick('z');
      await settle();
      clock += 10;
      a.untick('z');
      await settle();
      expect(a.debugBook['z']!['d'], true);
      clock += 81 * day;
      await a.syncMergedFromCloud();
      expect(a.debugBook.containsKey('z'), isFalse);
    });

    test('a map value the server reorders is not read as an edit', () async {
      // jsonb keeps object keys in its own order.
      CloudMergeIo.merge = (key, items) async {
        final merged =
            MergedItems.merge(server[key] ?? {}, items, nowMs: clock);
        server[key] = merged;
        return {
          for (final e in merged.entries)
            e.key: {
              ...e.value,
              if (e.value['v'] is Map)
                'v': Map.fromEntries(
                    (e.value['v'] as Map).entries.toList().reversed),
            },
        };
      };
      final a = _Answers('a');
      await a.syncMergedFromCloud();
      clock += 10;
      a.answers['q'] = 'x';
      a.notifyListeners();
      await settle();
      final stamped = server['answers:items']!['q']!['t'];
      final m = _Maps('m');
      await m.syncMergedFromCloud();
      clock += 10;
      m.set('k', {'b': 1, 'a': 2});
      await settle();
      final t1 = server['maps:items']!['k']!['t'];
      clock += 10;
      m.notifyListeners(); // nothing changed
      await settle();
      expect(server['maps:items']!['k']!['t'], t1);
      expect(m.mergedChangeWaiting, isFalse);
      expect(stamped, isNotNull);
    });

    test('a sign-out empties the store without sending removals', () async {
      final a = _Ticks('a');
      await a.syncMergedFromCloud();
      clock += 10;
      a.tick('keep');
      await settle();
      // A store's own reset clears it and notifies while the registry resets.
      SyncRegistry.resetAll();
      await settle();
      expect(a.ticked, isEmpty);
      expect(a.mergedChangeWaiting, isFalse);
      expect(server['ticks:items']!['keep']!['d'], isNot(true),
          reason: 'emptying the phone is not her deleting anything');
    });

    test('an edit made logged out waits for the sign-in', () async {
      CloudMergeIo.isLoggedIn = () => false;
      final a = _Ticks('a');
      await a.syncMergedFromCloud();
      clock += 10;
      a.tick('k');
      await settle();
      expect(server, isEmpty);
      expect(a.mergedChangeWaiting, isTrue);
      CloudMergeIo.isLoggedIn = () => true;
      await a.syncMergedFromCloud();
      expect(server['ticks:items']!['k']!['v'], true);
    });
  });

  // The last two whole-blob stores, converted after step 13 (2026-10-22).
  // Each real store runs once here, against the same fake server.
  group('the Parenting stores', () {
    test('DevStore: an answer under a reworded question moves to the new '
        'wording on the server, and the old one is removed', () async {
      final from = kCheckInRenames.keys.first;
      final to = kCheckInRenames[from]!;
      // Another phone, still on the old wording, answered it.
      server['pp_development:items'] = {
        'q|$from': {'v': true, 't': 500},
      };
      final s = DevStore.instance;
      s.applyCloudItems(const {}); // no demo seeds in the way
      await s.syncMergedFromCloud();
      expect(s.checkInAnswer(to), isTrue);
      expect(s.checkInAnswer(from), isNull);

      // Her next change carries the rename up with it.
      clock += 10;
      s.toggleSave('peekaboo');
      await settle();
      await settle();
      final items = server['pp_development:items']!;
      expect(items['s|peekaboo']!['v'], true);
      expect(items['q|$to']!['v'], true);
      expect(items['q|$from']!['d'], true);
    });

    test('ReadingStore: progress on two articles from two phones both stay',
        () async {
      // The other phone read article a; this phone reads article b.
      server['pp_reading:items'] = {
        'p|a': {'v': 0.5, 't': 500},
      };
      final r = ReadingStore.instance;
      r.applyCloudItems(const {}); // no demo seeds in the way
      await r.syncMergedFromCloud();
      expect(r.progressOf('a'), 0.5);

      clock += 10;
      r.setProgress('b', 0.4);
      await r.syncMergedFromCloud(); // the 5 s debounce, not waited for
      final items = server['pp_reading:items']!;
      expect(items['p|a']!['v'], 0.5);
      expect(items['p|b']!['v'], 0.4);
      expect(r.progressOf('a'), 0.5);
      expect(r.progressOf('b'), 0.4);
    });
  });
}
