// =============================================================================
//  Every child's messages, in every stage (2026-10-25, STAGE-TRANSITIONS F3)
// -----------------------------------------------------------------------------
//  Was: the parenting stage only, and the active child only. A mother pregnant
//  again heard nothing about her toddler, and with two children only the one
//  last opened got messages. Vaccine reminders stay with the active child
//  until each child has its own vaccine record (B11).
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phases_data.dart';
import 'package:parentveda/services/father_preview.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pp_messages_store.dart';

class _QuietPhone implements PpMessagePhone {
  @override
  Future<void> schedule({required int id, required String title, required String body, required DateTime when}) async {}
  @override
  Future<void> cancel(int id) async {}
}

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  final store = ChildProfileStore.instance;
  late Child aarav, kiara;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store.resetForTest();
    LifeStageStore.instance.resetForTest();
    PpMessagesStore.instance.resetForTest();
    PpMessagesStore.instance.phone = _QuietPhone();
    if (FatherPreview.instance.on) FatherPreview.instance.toggle();
    final now = DateTime.now();
    aarav = await store.addChild(name: 'Aarav', isBoy: true, dob: DateTime(now.year - 2, now.month, 1));
    // Ids are child_<microseconds>; a test can add two within one.
    await Future<void>.delayed(const Duration(milliseconds: 2));
    kiara = await store.addChild(name: 'Kiara', isBoy: false, dob: now.subtract(const Duration(days: 40)));
  });

  group('messages: every child', () {
    test('one set of facts per child: the first keeps the bare ids, the next is prefixed', () {
      final fam = PpMessageFacts.familyFromStores();
      expect(fam, hasLength(2));
      expect(fam[0].name, 'Aarav');
      expect(fam[0].idPrefix, '');
      expect(fam[1].name, 'Kiara');
      expect(fam[1].idPrefix, 'child:${kiara.id}|');
      expect(fam.every((f) => f.named), isTrue);
      expect(fam[1].sexGiven && !fam[1].isBoy, isTrue);
    });

    // Before B11 the vaccine record was one for the family, so only the open
    // child had visits. Kept for revert:
    //   expect(fam[0].visits, isEmpty, reason: 'Aarav is not open');
    //   expect(fam[1].visits, isNotEmpty, reason: 'Kiara is open and has visits ahead');
    test('every child has their own vaccine visits, open or not (B11)', () async {
      await store.switchTo(kiara.id);
      final fam = PpMessageFacts.familyFromStores();
      expect(fam[0].visits, isNotEmpty, reason: 'Aarav is not open, and still has his own');
      expect(fam[1].visits, isNotEmpty, reason: 'Kiara is open and has visits ahead');
    });

    test('switching child keeps the other child\'s messages waiting', () async {
      final s = PpMessagesStore.instance;
      await s.refresh();
      bool hasKiara() => s.pending().any((m) => m.id.startsWith('child:${kiara.id}|'));
      bool hasAarav() => s.pending().any((m) => !m.id.startsWith('child:'));
      expect(hasKiara(), isTrue);
      expect(hasAarav(), isTrue);
      await store.switchTo(aarav.id);
      await s.refresh();
      expect(hasKiara(), isTrue, reason: 'before F3 the inactive child\'s pending were dropped');
      expect(hasAarav(), isTrue);
    });

    test('with two children every title says whose it is', () {
      final now = DateTime(2026, 10, 25);
      final f = PpMessageFacts(
        dob: DateTime(2026, 6, 29),
        name: 'Kiara',
        realChild: true,
        named: true,
        sexGiven: true,
        isBoy: false,
        idPrefix: 'child:k|',
        visits: [(id: 'mo9', label: '9 months', date: DateTime(2027, 3, 29), shortNames: ['MR'])],
      );
      final ms = ppMessageCandidates(f, now);
      expect(ms.firstWhere((m) => m.kind == PpMessageKind.vaccine).title, "Kiara's 9 months vaccines are coming up");
      expect(ms.firstWhere((m) => m.kind == PpMessageKind.milestones).title, startsWith('A new stage for Kiara: '));
      expect(ms.firstWhere((m) => m.kind == PpMessageKind.activity).title, 'Something to try with Kiara this week');
      expect(ms.where((m) => m.kind == PpMessageKind.activity).every((m) => m.id.startsWith('child:k|act:')), isTrue);
    });

    test('one child: the titles are as before', () {
      final ms = ppMessageCandidates(
          PpMessageFacts(dob: DateTime(2026, 6, 29), name: 'Meera', realChild: true,
              visits: [(id: 'mo9', label: '9 months', date: DateTime(2027, 3, 29), shortNames: ['MR'])]),
          DateTime(2026, 10, 25));
      expect(ms.firstWhere((m) => m.kind == PpMessageKind.vaccine).title, 'The 9 months vaccines are coming up');
      expect(ms.firstWhere((m) => m.kind == PpMessageKind.activity).title, 'Something to try this week');
      expect(ms.firstWhere((m) => m.kind == PpMessageKind.activity).id, startsWith('act:'));
    });

    test('an authored line speaks of the child it names, not the open one', () {
      const line = 'Let him hold his own cup.';
      expect(ppFillChildFor(line, sexGiven: true, isBoy: true, name: 'Aarav'), line);
      expect(ppFillChildFor(line, sexGiven: true, isBoy: false, name: 'Kiara'), 'Let her hold her own cup.');
      expect(ppFillChildFor(line, sexGiven: false, isBoy: true, name: 'Rumi'), "Let Rumi hold Rumi's own cup.");
    });

    test('a message names its child: prefixed ids, else the first child', () {
      final ids = ['c1', 'c2'];
      expect(ppMessageChildId('age:m5', ids), 'c1');
      expect(ppMessageChildId('child:c2|vax:mo9', ids), 'c2');
      expect(ppMessageChildId('child:gone|age:m5', ids), 'c1');
      expect(ppMessageChildId('age:m5', const []), isNull);
    });
  });

  group('messages: every stage', () {
    for (final stage in [LifeStage.pregnancy, LifeStage.tryingToConceive, LifeStage.skilling, LifeStage.parenting]) {
      test('a real child speaks while the stage is ${stage.name}', () {
        LifeStageStore.instance.setStage(stage);
        expect(PpMessageFacts.familyFromStores().every((f) => f.speaks), isTrue);
      });
    }

    test('the partner\'s side stays silent in every stage', () {
      LifeStageStore.instance.setStage(LifeStage.pregnancy);
      FatherPreview.instance.toggle();
      expect(PpMessageFacts.familyFromStores().any((f) => f.speaks), isFalse);
      FatherPreview.instance.toggle();
    });

    test('no child, nothing', () {
      store.resetForTest();
      final fam = PpMessageFacts.familyFromStores();
      expect(fam.single.speaks, isFalse);
    });
  });

  group('messages: the way in from any stage', () {
    test('Settings on Pregnancy and TTC has her children\'s messages, only with a child', () {
      final code = _code('lib/screens/profile/pv_you_content.dart');
      expect(code, contains('notificationThings: [_pregMessages(), _ppChildMessages()]'));
      expect(code, contains('notificationThings: [_ttcMessages(), _ppChildMessages()]'));
      final row = code.substring(code.indexOf('PvYouThing _ppChildMessages()'));
      expect(row.substring(0, row.indexOf(');')), contains('shown: () => ChildProfileStore.instance.hasRealChild'));
      expect(_code('lib/screens/profile/pv_you_screen.dart'),
          contains('for (final t in content.notificationThings)\n            if (t.shown?.call() ?? true) thing(t),'));
    });

    test('a tapped message opens its own child, and her home over any root', () {
      final code = _code('lib/screens/post_pregnancy/pp_messages_screen.dart');
      expect(code, contains('ppMessageChildId(m.id, [for (final c in kids.children) c.id])'));
      expect(code, contains('kids.switchTo(whose)'));
      expect(code, contains('openStageDoor(nav.context, StageDoor.parenting)'));
    });

    test('the store reads every child, not the active one', () {
      expect(_code('lib/services/pp_messages_store.dart'), contains('PpMessageFacts.familyFromStores()'));
    });
  });
}
