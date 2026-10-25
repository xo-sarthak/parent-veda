// =============================================================================
//  Development tools, the backend (tools pass 17-21, sync step 19, 2026-10-25)
// -----------------------------------------------------------------------------
//  DevStore kept check-in answers by the question's wording and one "done" set
//  for the family, so a sibling in the same age band opened the check-in with
//  the other child's answers ticked, and a fresh install arrived with a fake
//  saved and a fake done activity. Now the owner rides in the item key, the
//  starter state is empty, and items from before the split are read only
//  while the family has one child (BACKEND-PATTERNS §16pp).
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';
import 'package:parentveda/services/pp_use_consent.dart';
import 'package:parentveda/services/remote/cloud_merged_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, Map<String, dynamic>> server;
  String? child;
  int children = 0;
  const q = 'Does he smile back when you smile at him?';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    server = {};
    CloudMergeIo.isLoggedIn = () => true;
    CloudMergeIo.nowMs = () => 1000000;
    CloudMergeIo.loadLegacy = (k) async => null;
    CloudMergeIo.merge = (key, items) async {
      server[key] = MergedItems.merge(server[key] ?? {}, items, nowMs: 1000000);
      return Map<String, dynamic>.from(server[key]!);
    };
    child = null;
    children = 0;
    DevStore.activeChild = () => child;
    DevStore.childCount = () => children;
    DevStore.instance.applyCloudItems(const {});
  });
  tearDown(() {
    CloudMergeIo.restore();
    DevStore.activeChild = () => null;
    DevStore.childCount = () => 0;
  });

  test('a new install starts with nothing saved and nothing done', () {
    // The singleton is shared across tests, so its first state is read from
    // the source: the old seeds ('peekaboo' saved, 'tummy_play' done) must
    // stay commented out.
    final src = File('lib/screens/post_pregnancy/pp_development_data.dart').readAsLinesSync();
    final live = src.where((l) => !l.trimLeft().startsWith('//'));
    expect(live.where((l) => l.contains("{'peekaboo'}") || l.contains("{'tummy_play'}")), isEmpty);
  });

  test("twins: one child's answers and tries never show for the other", () {
    final s = DevStore.instance;
    children = 2;
    child = 'A';
    s.setCheckIn(q, false, on: DateTime(2026, 10, 25));
    s.markTried('peekaboo', on: DateTime(2026, 10, 24));
    expect(s.checkInAnswer(q), isFalse);
    expect(s.answerFor(q)!.at, DateTime(2026, 10, 25));
    expect(s.triedOn('peekaboo'), DateTime(2026, 10, 24));

    child = 'B';
    expect(s.checkInAnswer(q), isNull);
    expect(s.isCompleted('peekaboo'), isFalse);
    expect(s.checkInsAnswered, 0);

    child = 'A';
    s.clearCheckIns([q]);
    expect(s.checkInAnswer(q), isNull);
    s.untry('peekaboo');
    expect(s.isCompleted('peekaboo'), isFalse);
  });

  test('an answer from before the split is read with one child, not with two', () {
    final s = DevStore.instance;
    s.applyCloudItems({'q|$q': true, 'c|peekaboo': true});
    child = 'A';
    children = 1;
    expect(s.checkInAnswer(q), isTrue, reason: 'one child: it can only be theirs');
    expect(s.answerFor(q)!.at, isNull, reason: 'an old answer kept no day');
    expect(s.isCompleted('peekaboo'), isTrue);
    children = 2;
    expect(s.checkInAnswer(q), isNull, reason: 'two children: nobody can say whose');
    expect(s.isCompleted('peekaboo'), isFalse);
    // Nothing was deleted: the unowned items still go up as they were.
    expect(s.cloudItems().keys, containsAll(['q|$q', 'c|peekaboo']));
  });

  test('the owner rides in the item key on the server, and comes back down', () async {
    final s = DevStore.instance;
    children = 2;
    child = 'kid-1';
    s.setCheckIn(q, true, on: DateTime(2026, 10, 25));
    s.markTried('narrate', on: DateTime(2026, 10, 25));
    await s.syncMergedFromCloud();
    final items = server['pp_development:items']!;
    expect(items['q|kid-1|$q']!['v'], {'yes': true, 'at': '2026-10-25'});
    expect(items['c|kid-1|narrate']!['v'], '2026-10-25');

    // What another phone applies after its merge.
    s.applyCloudItems({for (final e in items.entries) e.key: e.value['v']});
    expect(s.checkInAnswer(q), isTrue);
    expect(s.triedOn('narrate'), DateTime(2026, 10, 25));
    child = 'kid-2';
    expect(s.checkInAnswer(q), isNull);
  });

  test('a reworded question keeps its owned answer', () {
    final s = DevStore.instance;
    final from = kCheckInRenames.keys.first;
    final to = kCheckInRenames[from]!;
    child = 'A';
    children = 2;
    s.applyCloudItems({'q|A|$from': {'yes': true, 'at': '2026-10-01'}});
    expect(s.checkInAnswer(to), isTrue);
    expect(s.cloudItems().keys, contains('q|A|$to'));
  });

  // The item key is `kind|owner|id` (BACKEND-PATTERNS §16pp). It parses only
  // because no question wording and no activity id holds a bar.
  test('no question or activity id contains the key separator', () {
    final texts = [...kCheckIns0to6, ...kCheckIns6to12, ...kCheckIns1to2, ...kCheckIns2to3, ...kCheckIns3plus, kCheckInLostSkill]
        .map((q) => q.text);
    expect(texts.where((t) => t.contains('|')), isEmpty);
    expect(kDevActivities.where((a) => a.id.contains('|')), isEmpty);
  });

  test('development is its own ask-once kind, with words for You', () {
    expect(PpUseKind.development.name, 'development', reason: 'persisted: never rename');
    expect(PpUseKind.development.label, isNotEmpty);
    expect(PpUseKind.development.why, contains('Before you see the doctor'));
  });
}
