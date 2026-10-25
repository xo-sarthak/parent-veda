// =============================================================================
//  One learning space per child (STAGE-TRANSITIONS F5, 2026-10-25)
// -----------------------------------------------------------------------------
//  The learning space was one record per phone, so a second child of six or
//  more walked into the first one's space (her name, her practice, her photos,
//  her private journal), was never asked for, and "forget her" forgot both.
//  Now each child has her own space, one of them open; the pre-F5 space is
//  adopted by the child it provably belonged to.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/skilling/sk_child_store.dart';
import 'package:parentveda/screens/skilling/sk_consent_verifier.dart';
import 'package:parentveda/screens/skilling/sk_parent_gate_screen.dart';
import 'package:parentveda/screens/skilling/sk_portfolio.dart';
import 'package:parentveda/screens/skilling/sk_practice_store.dart';
import 'package:parentveda/screens/skilling/sk_turning_six.dart';
import 'package:parentveda/screens/v2/pv_family_switch.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/remote/sync_registry.dart';

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

DateTime _yearsAgo(int y) {
  final n = DateTime.now();
  return DateTime(n.year - y, n.month, n.day).subtract(const Duration(days: 3));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final sk = SkChildStore.instance;
  final practice = SkPracticeStore.instance;
  final photos = SkPortfolioStore.instance;
  late Child myra; // 8
  late Child kabir; // 6

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LifeStageStore.instance.resetForTest();
    ChildProfileStore.instance.resetForTest();
    sk.debugReset();
    practice.debugReset();
    photos.debugReset();
    SkTurningSixPrompt.instance.resetForTest();
    myra = await ChildProfileStore.instance.addChild(name: 'Myra', isBoy: false, dob: _yearsAgo(8));
    kabir = await ChildProfileStore.instance.addChild(name: 'Kabir', isBoy: true, dob: _yearsAgo(6));
  });

  void yes(Child c) =>
      sk.consent(name: c.name, dob: c.dob, verification: SkVerification.stub, childId: c.id);

  group('F5 · each child her own space', () {
    test('each consents separately; the open one answers the screens', () {
      yes(myra);
      expect(sk.consentedFor(myra.id), isTrue);
      expect(sk.consentedFor(kabir.id), isFalse, reason: "Myra's yes is not Kabir's");
      expect(sk.name, 'Myra');
      expect(sk.ageYears, 8);
      yes(kabir);
      expect(sk.openId, kabir.id, reason: 'the child just let in is the open one');
      expect(sk.name, 'Kabir');
      expect(sk.ageYears, 6);
      sk.open(myra.id);
      expect(sk.name, 'Myra');
      expect(sk.consentedIds, {myra.id, kabir.id});
    });

    test('practice and photos are hers: a brother sees only his own', () {
      yes(myra);
      practice.record(doorId: 'thinking', itemId: 'a', title: 'Puzzle', kind: SkPractice.tried);
      photos.debugAdd(SkPortfolioPhoto(
          id: 'p1', doorId: 'making', path: 'x.jpg', at: DateTime.now(), child: myra.id));
      expect(practice.hasPractised('thinking'), isTrue);
      expect(photos.hasPhotos('making'), isTrue);
      yes(kabir);
      expect(practice.hasPractised('thinking'), isFalse);
      expect(practice.wordFor('thinking', 'a'), '');
      expect(photos.hasPhotos('making'), isFalse);
      sk.open(myra.id);
      expect(practice.hasPractised('thinking'), isTrue);
    });

    test("voice and photo permission are per child; the PIN is the family's", () {
      yes(myra);
      sk.setVoiceAllowed(true);
      sk.setPin('1234');
      yes(kabir);
      expect(sk.voiceAllowed, isFalse, reason: "a yes to recording Myra is not a yes for Kabir");
      expect(sk.hasPin, isTrue);
      expect(sk.checkPin('1234'), isTrue);
    });

    test('forgetting one space leaves the other, and the PIN goes only with the last', () {
      yes(myra);
      practice.record(doorId: 'thinking', itemId: 'a', title: 'Puzzle', kind: SkPractice.tried);
      sk.setPin('1234');
      yes(kabir);
      practice.record(doorId: 'coding', itemId: 'b', title: 'Steps', kind: SkPractice.tried);
      practice.forgetChild(kabir.id);
      sk.forget();
      expect(sk.consentedFor(kabir.id), isFalse);
      expect(sk.consentedFor(myra.id), isTrue);
      expect(sk.openId, myra.id);
      expect(practice.hasPractised('thinking'), isTrue, reason: "Myra's practice stays");
      expect(sk.hasPin, isTrue);
      practice.forgetChild(myra.id);
      sk.forget();
      expect(sk.hasPin, isFalse);
      expect(sk.openId, isNull);
    });

    test("the turning-six card still asks for Kabir after Myra's yes", () {
      yes(myra);
      expect(SkTurningSixPrompt.instance.showsFor(kabir), isTrue);
      yes(kabir);
      expect(SkTurningSixPrompt.instance.showsFor(kabir), isFalse);
    });

    test('the family switch opens the learning space only for a child with a yes', () {
      yes(myra);
      final profiles = familyProfilesFrom(
        stage: LifeStage.parenting,
        pregnancyEnded: false,
        pregnancyWeek: null,
        children: [myra, kabir],
        skillingName: sk.unmatchedName,
        now: DateTime.now(),
        learningOpenIds: sk.consentedIds,
      );
      expect(profiles.firstWhere((p) => p.id == myra.id).home, FamilyHome.learning);
      expect(profiles.firstWhere((p) => p.id == kabir.id).home, FamilyHome.parenting);
      expect(profiles.where((p) => p.id == 'skilling'), isEmpty);
    });
  });

  group('F5 · the old single space is adopted, nothing lost', () {
    test('a v1 record and its untagged practice go to the child with that birthday', () async {
      final d = myra.dob;
      SharedPreferences.setMockInitialValues({
        'sk_child': jsonEncode({
          'name': 'Myra',
          'dob': d.toIso8601String(),
          'consentedAt': DateTime(2026, 9, 1).toIso8601String(),
          'verification': 'stub',
          'pinHash': null,
          'pinSalt': null,
          'voiceAllowed': true,
          'photosAllowed': false,
        }),
        'sk_practice': jsonEncode([
          {'door': 'thinking', 'item': 'a', 'title': 'Puzzle', 'kind': 'tried', 'at': DateTime(2026, 9, 2).toIso8601String()},
        ]),
      });
      SyncRegistry.resetAll();
      ChildProfileStore.instance.resetForTest();
      myra = await ChildProfileStore.instance.addChild(name: 'Myra', isBoy: false, dob: d);
      kabir = await ChildProfileStore.instance.addChild(name: 'Kabir', isBoy: true, dob: _yearsAgo(6));
      await sk.load();
      await practice.load();
      expect(sk.consentedFor(myra.id), isTrue, reason: 'the one space was Myra\'s');
      expect(sk.legacyOwner, myra.id);
      expect(sk.voiceAllowed, isTrue);
      expect(sk.unmatchedName, '', reason: 'no second row for her in the switch');
      expect(practice.hasPractised('thinking'), isTrue, reason: 'her old practice is still hers');
      sk.open(kabir.id);
      expect(practice.hasPractised('thinking'), isFalse, reason: 'and never Kabir\'s');
      final prefs = await SharedPreferences.getInstance();
      expect((jsonDecode(prefs.getString('sk_child')!) as Map)['v'], 2,
          reason: 'saved in the new shape');
    });

    test('a record no parenting child matches keeps its own row', () async {
      sk.update(name: 'Zoya', dob: DateTime(2016, 1, 1)); // no child with that birthday
      expect(sk.unmatchedName, 'Zoya');
    });
  });

  group('F5 · the gate fills in the tapped child', () {
    testWidgets('Kabir\'s card fills in Kabir, not the elder', (tester) async {
      tester.view.physicalSize = const Size(400, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: SkParentGateScreen(child: kabir)));
      await tester.pump();
      expect(find.widgetWithText(TextField, 'Kabir'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Myra'), findsNothing);
    });
  });

  group('F5 · wiring gate', () {
    test('every place that picks a child opens or asks by her id', () {
      expect(_code('lib/screens/skilling/sk_turning_six.dart'), contains('consentedFor(child.id)'));
      expect(_code('lib/screens/skilling/sk_turning_six.dart'), contains('child: child,'));
      expect(_code('lib/screens/v2/pv_family_switch.dart'), contains('SkChildStore.instance.open(to.id)'));
      expect(_code('lib/screens/profile/pv_child_screen.dart'), contains('sk.open(c.id)'));
      final grown = _code('lib/screens/skilling/sk_grown_up_screen.dart');
      expect(grown, contains('SkJournalStore.instance.forgetChild('));
      expect(grown, isNot(contains('SkPracticeStore.instance.forgetAll()')),
          reason: "forgetting one child's space must not forget every child's");
    });
  });
}
