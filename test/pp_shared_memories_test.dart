// =============================================================================
//  Shared child memories: each parent sees the other's, read-only (2026-10-07)
// -----------------------------------------------------------------------------
//  Gap analysis P1 (Behind · Partner): the paired father on the parenting
//  home, "read only for her own notes". A partner's memories of the CHILD show
//  in the parenting journal, marked, with no Delete; her private journal is
//  never shown. The database already enforces it (0009_pairing: partner may
//  select, only the owner may update or delete).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/models/journal_entry.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/jv2_store.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/pp_journal_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/services/journal_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  JournalEntry partner(String id, String child, String title) => JournalEntry(
        id: id,
        type: JournalEntryType.memory,
        title: title,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        tags: ['$kPpChildTag$child', '${kPpKindTag}moment'],
        isPartner: true,
      );

  test('the partner\'s memory of this child is in the journal, marked as theirs', () {
    final child = ChildProfileStore.instance.activeChildId ?? 'local';
    JournalStore.instance.partnerChildEntriesForTest([
      partner('p1', child, 'First giggle at bath time'),
      partner('p2', 'another_child', 'Not this child'),
    ]);
    final mine = PpJournalStore.instance.entries;
    final p1 = mine.where((e) => e.id == 'p1');
    expect(p1, hasLength(1));
    expect(p1.single.fromPartner, isTrue);
    expect(mine.any((e) => e.id == 'p2'), isFalse, reason: 'only this child');
    JournalStore.instance.partnerChildEntriesForTest(const []);
  });

  test('only child memories are fetched; the private journal stays private', () {
    final src = File('lib/services/journal_store.dart').readAsStringSync();
    expect(src, contains("fetchByUser('journal_entries', partnerId)"));
    expect(src, contains('when isChildMemory(e)'));
  });

  test('a partner memory offers no Delete', () {
    final src = File('lib/screens/post_pregnancy/journal_v2/pp_journal_screen.dart').readAsStringSync();
    expect(src, contains('if (e.fromPartner)'));
    expect(src, contains('Added by your partner. Only they can change it.'));
  });

  testWidgets('the journal still renders with a partner memory in it', (t) async {
    final child = ChildProfileStore.instance.activeChildId ?? 'local';
    JournalStore.instance.partnerChildEntriesForTest([partner('p3', child, 'Rolled over on the mat')]);
    t.view.physicalSize = const Size(390 * 3, 2400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: PpJournalScreen()));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    JournalStore.instance.partnerChildEntriesForTest(const []);
  });
}
