// =============================================================================
//  B11: each child's records read per child (2026-10-25, STAGE-TRANSITIONS B11)
// -----------------------------------------------------------------------------
//  Growth, documents, health records, milestones and vaccines kept every
//  child in one list or one map, and the reads never asked whose a row was, so
//  twins' records blended on each other's pages. Holds: each stays with its
//  child, an edit by on-screen index reaches the right row, a record from
//  before B11 joins the child on screen, two children's alarms never share an
//  id, every child's visits reach the messages, and every list store pulls
//  every child.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_documents_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_growth_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_health_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_milestones_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_vaccine_data.dart';
import 'package:parentveda/services/pp_messages_store.dart';
import 'package:parentveda/services/remote/child_scoped_store.dart';

Medication _med(String name) => Medication(
    name: name, reason: '', doctor: '', dosage: '', duration: '', completed: false, date: '');

EmergencyProfile _card(String blood) => EmergencyProfile(
    name: 'x', dob: '', weight: '', bloodGroup: blood, allergies: '', pediatrician: '', contacts: const [], medications: '');

String _code(String path) => File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ChildProfileStore.instance.resetForTest();
    GrowthStore.instance.debugReset();
    BabyDocumentsStore.instance.debugReset();
    HealthStore.instance.debugReset();
    MilestoneStore.instance.debugReset();
    VaxStore.instance.debugReset();
  });

  Future<(String, String)> twins() async {
    final store = ChildProfileStore.instance;
    final dob = DateTime.now().subtract(const Duration(days: 120));
    final a = await store.addChild(name: 'Aarav', isBoy: true, dob: dob);
    await Future<void>.delayed(const Duration(milliseconds: 2));
    final b = await store.addChild(name: 'Meera', isBoy: false, dob: dob);
    await store.switchTo(a.id);
    return (a.id, b.id);
  }

  test('growth and documents stay with their child', () async {
    final (a, b) = await twins();
    GrowthStore.instance.log(date: DateTime.now(), weightKg: 6.1, heightCm: 61);
    BabyDocumentsStore.instance.addDocument(
        const BabyDocument(id: 'doc_a', title: 'Birth certificate', category: 'Identity', date: ''));

    await ChildProfileStore.instance.switchTo(b);
    expect(GrowthStore.instance.all, isEmpty);
    expect(GrowthStore.instance.isEmpty, isTrue);
    expect(BabyDocumentsStore.instance.documents, isEmpty);
    BabyDocumentsStore.instance.addDocument(
        const BabyDocument(id: 'doc_b', title: 'Aadhaar', category: 'Identity', date: ''));

    await ChildProfileStore.instance.switchTo(a);
    expect(GrowthStore.instance.all.single.weightKg, 6.1);
    expect(BabyDocumentsStore.instance.documents.single.id, 'doc_a');
    // Index 0 on Aarav's screen is Aarav's paper, though Meera's is first in
    // the whole list.
    BabyDocumentsStore.instance.removeDocument(0);
    expect(BabyDocumentsStore.instance.documents, isEmpty);
    await ChildProfileStore.instance.switchTo(b);
    expect(BabyDocumentsStore.instance.documents.single.id, 'doc_b');
  });

  test('health records, questions and the emergency card stay with their child', () async {
    final (a, b) = await twins();
    final h = HealthStore.instance;
    h.addMedication(_med('Paracetamol drops'));
    h.addQuestion('Is this rash normal?');
    h.setEmergency(_card('B+'));

    await ChildProfileStore.instance.switchTo(b);
    expect(h.medications, isEmpty);
    expect(h.questions, isEmpty);
    expect(h.emergency, isNull, reason: "Aarav's blood group must never show on Meera's card");
    expect(h.hasAnyEntry, isFalse);
    h.addMedication(_med('Vitamin D'));
    h.setEmergency(_card('O+'));
    // Edit by on-screen index: Meera's only medicine, not Aarav's.
    h.updateMedication(0, _med('Vitamin D3'));

    await ChildProfileStore.instance.switchTo(a);
    expect(h.medications.single.name, 'Paracetamol drops');
    expect(h.questions.single, 'Is this rash normal?');
    expect(h.emergency!.bloodGroup, 'B+');
    await ChildProfileStore.instance.switchTo(b);
    expect(h.medications.single.name, 'Vitamin D3');
    expect(h.emergency!.bloodGroup, 'O+');
  });

  test('milestones and doses stay with their child', () async {
    final (a, b) = await twins();
    MilestoneStore.instance.markObserved('soc_smile');
    VaxStore.instance.markDone('birth');

    await ChildProfileStore.instance.switchTo(b);
    expect(MilestoneStore.instance.isObserved('soc_smile'), isFalse);
    expect(MilestoneStore.instance.observedCount, 0);
    expect(VaxStore.instance.isDone('birth'), isFalse, reason: "Aarav's birth dose is not Meera's");
    expect(VaxStore.instance.nothingRecorded, isTrue);

    await ChildProfileStore.instance.switchTo(a);
    expect(MilestoneStore.instance.isObserved('soc_smile'), isTrue);
    expect(VaxStore.instance.isDone('birth'), isTrue);
    expect(VaxStore.instance.isDoneFor(a, 'birth'), isTrue);
    expect(VaxStore.instance.isDoneFor(b, 'birth'), isFalse);
  });

  test('every child gets their own vaccine visits in the messages', () async {
    final (a, b) = await twins();
    VaxStore.instance.markDone('birth');
    final facts = PpMessageFacts.familyFromStores();
    expect(facts, hasLength(2));
    expect(facts[0].visits.map((v) => v.id), isNot(contains('birth')), reason: 'Aarav had his');
    expect(facts[1].visits.map((v) => v.id), contains('birth'), reason: 'Meera has not');
    expect(a, isNot(b));
  });

  group('PerChild: a value from before B11 joins the child on screen', () {
    test('only the child on screen takes it, and only once', () {
      final p = PerChild<Set<String>>(() => {});
      p.byChild[PerChild.legacy] = {'birth'};
      expect(p.of('b', 'a'), isEmpty, reason: 'the twin not on screen does not take it');
      expect(p.of('a', 'a'), {'birth'});
      expect(p.byChild.containsKey(PerChild.legacy), isFalse);
      expect(p.of('a', 'a'), {'birth'});
    });

    test('a child that already has a value keeps it', () {
      final p = PerChild<String>();
      p.put('a', 'a', 'mine');
      p.byChild[PerChild.legacy] = 'old';
      expect(p.peek('a', 'a'), 'mine');
    });

    test('no child yet: it waits', () {
      final p = PerChild<String>();
      p.put(null, null, 'saved before a child');
      expect(p.peek(null, null), 'saved before a child');
      expect(p.peek('a', 'a'), 'saved before a child');
    });

    test('round trip', () {
      final p = PerChild<bool>()..put('a', 'a', true);
      final q = PerChild<bool>()..loadJson(p.toJson((b) => b), (v) => v == true ? true : null);
      expect(q.peek('a', 'a'), isTrue);
    });
  });

  test("two children's alarms for one visit never share an id; the first keeps the old one", () {
    expect(vaxAlarmIdFor('birth', childId: 'c1', firstChildId: 'c1'), vaxAlarmId('birth'));
    expect(vaxAlarmIdFor('birth', childId: null, firstChildId: null), vaxAlarmId('birth'));
    expect(vaxAlarmIdFor('birth', childId: 'c2', firstChildId: 'c1'), isNot(vaxAlarmId('birth')));
  });

  test("the alarm's words are that child's", () {
    final dob = DateTime(2026, 1, 1);
    final kid = Child(id: 'c2', name: 'Meera', isBoy: false, dob: dob, weightKg: 0, heightCm: 0, headCm: 0);
    final t = vaxReminderText(kVaxVisits.first, DateTime(2025, 12, 31, 9), child: kid);
    expect(t.body, "Meera's ${kVaxVisits.first.lead.shortName} (At birth) is due tomorrow - 1 Jan 2026.");
  });

  test('every child-scoped store pulls every child, not only the one on screen', () {
    for (final f in [
      'pp_care_log_data.dart',
      'pp_documents_data.dart',
      'pp_feeding_data.dart',
      'pp_growth_data.dart',
      'pp_sleep_data.dart',
      'pp_health_data.dart',
    ]) {
      final code = _code('lib/screens/post_pregnancy/$f');
      expect(code, contains('pullEvery<'), reason: f);
    }
    for (final f in ['pp_milestones_data.dart', 'pp_vaccine_data.dart']) {
      expect(_code('lib/screens/post_pregnancy/$f'),
          contains('ChildProfileStore.instance.childIds.where((x) => x != childId)'), reason: f);
    }
    expect(_code('lib/screens/post_pregnancy/pp_health_data.dart'), contains('for (final c in _childOrder)'));
  });
}
