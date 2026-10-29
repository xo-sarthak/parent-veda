// =============================================================================
//  Parenting relevance gap, Step 4a (PP 16, 2026-10-29)
// -----------------------------------------------------------------------------
//  A vaccine visit with her own opt-in alarm gets no automatic 3-day message,
//  on the phone or in the inbox, so one visit is never reminded twice. The
//  alarm is read per child (`VaxStore.hasAlarmFor`): a sibling with no alarm
//  for the same visit still gets the automatic one. Every clock is injected.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_vaccine_data.dart';
import 'package:parentveda/services/pp_messages_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ChildProfileStore.instance.resetForTest();
    VaxStore.instance.debugReset();
    PpMessagesStore.instance.resetForTest();
  });

  final dob = DateTime(2026, 6, 29);
  final now = DateTime(2027, 3, 1, 12);
  final mo9 = (id: 'mo9', label: '9 months', date: DateTime(2027, 3, 29), shortNames: ['MR', 'PCV']);
  final mo12 = (id: 'mo12', label: '12 months', date: DateTime(2027, 6, 29), shortNames: ['Hep A']);

  PpMessageFacts facts({Set<String> alarmed = const {}, String prefix = ''}) => PpMessageFacts(
      dob: dob, name: 'Meera', realChild: true, visits: [mo9, mo12], alarmed: alarmed, idPrefix: prefix);

  Set<String> vaxIds(List<PpMessage> ms) =>
      {for (final m in ms) if (m.kind == PpMessageKind.vaccine) m.id};

  test('no alarm: the automatic reminder 3 days before, as before', () {
    expect(vaxIds(ppMessageCandidates(facts(), now)), {'vax:mo9', 'vax:mo12'});
  });

  test('her own alarm: no automatic message for that visit, the next keeps its own', () {
    expect(vaxIds(ppMessageCandidates(facts(alarmed: {'mo9'}), now)), {'vax:mo12'});
  });

  test('nor in the inbox: a skipped visit is never delivered', () {
    final s = PpMessagesStore.instance;
    final later = DateTime(2027, 3, 27, 12); // past the 3-day moment for mo9
    s.apply(ppMessageCandidates(facts(alarmed: {'mo9'}), later), later);
    expect(s.delivered(now: later).map((m) => m.id), isNot(contains('vax:mo9')));
    expect(s.pending(now: later).map((m) => m.id), isNot(contains('vax:mo9')));
  });

  test('two children: only the one with the alarm loses the automatic reminder', () {
    final ms = [
      ...ppMessageCandidates(facts(alarmed: {'mo9'}), now),
      ...ppMessageCandidates(facts(prefix: 'child:b|'), now),
    ];
    final ids = vaxIds(ms);
    expect(ids, isNot(contains('vax:mo9')), reason: 'the first child has her own alarm');
    expect(ids, contains('child:b|vax:mo9'), reason: 'the sibling has none, so keeps it');
  });

  group('VaxStore.hasAlarmFor reads per child', () {
    Future<(String, String)> twins() async {
      final store = ChildProfileStore.instance;
      final born = DateTime.now().subtract(const Duration(days: 120));
      final a = await store.addChild(name: 'Aarav', isBoy: true, dob: born);
      await Future<void>.delayed(const Duration(milliseconds: 2));
      final b = await store.addChild(name: 'Meera', isBoy: false, dob: born);
      await store.switchTo(a.id);
      return (a.id, b.id);
    }

    test('an alarm on one twin is not the other twin\'s', () async {
      final (a, b) = await twins();
      final v = kVaxVisits.firstWhere((v) => !VaxStore.instance.isOptionalVisit(v) && v.ageDays > 120);
      VaxStore.instance.setReminder(v.id, true, at: DateTime.now().add(const Duration(days: 30)));
      expect(VaxStore.instance.hasAlarmFor(a, v.id), isTrue);
      expect(VaxStore.instance.hasAlarmFor(b, v.id), isFalse);

      final family = PpMessageFacts.familyFromStores();
      expect(family, hasLength(2));
      expect(family[0].alarmed, contains(v.id));
      expect(family[1].alarmed, isEmpty);
    });

    test('a reminder with no time, or a dose given, is not an alarm', () async {
      final (a, _) = await twins();
      final v = kVaxVisits.firstWhere((v) => !VaxStore.instance.isOptionalVisit(v) && v.ageDays > 120);
      VaxStore.instance.setReminder(v.id, true);
      expect(VaxStore.instance.hasAlarmFor(a, v.id), isFalse, reason: 'nothing fires without a time');
      VaxStore.instance.setReminder(v.id, true, at: DateTime.now().add(const Duration(days: 30)));
      VaxStore.instance.markDone(v.id);
      expect(VaxStore.instance.hasAlarmFor(a, v.id), isFalse, reason: 'given: the alarm has nothing left to say');
    });
  });
}
