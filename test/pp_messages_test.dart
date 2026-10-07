// =============================================================================
//  The parenting app speaks first (gap analysis P1, Behind · Messages)
// -----------------------------------------------------------------------------
//  Monthly and weekly age notes, vaccines 3 days ahead on THIS child's dates, a
//  new stage, an activity a week; sent once, moved by a corrected birth date,
//  never for a placeholder child or the partner's side.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/pp_messages_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PpMessagesStore.instance.resetForTest();
  });

  final dob = DateTime(2026, 6, 29);
  PpMessageFacts facts({bool real = true, bool partner = false, List<PpVaxFact> visits = const []}) =>
      PpMessageFacts(dob: dob, name: 'Meera', realChild: real, partner: partner, visits: visits);

  test('the month note on the monthly birthday, in her child\'s name', () {
    final now = DateTime(2026, 10, 27);
    final m = ppMessageCandidates(facts(), now).firstWhere((m) => m.id == 'age:m4');
    expect(m.title, 'Meera is 4 months today');
    expect(m.at, DateTime(2026, 10, 29, 9));
    expect(m.kind, PpMessageKind.age);
  });

  test('weekly notes in the first eight weeks', () {
    final ms = ppMessageCandidates(facts(), DateTime(2026, 7, 1));
    expect(ms.any((m) => m.id == 'age:w1' && m.title == 'Meera is 1 week old today'), isTrue);
  });

  test('a vaccine reminder 3 days before the visit', () {
    final visit = (id: 'mo9', label: '9 months', date: DateTime(2027, 3, 29), shortNames: ['MR', 'PCV']);
    final m = ppMessageCandidates(facts(visits: [visit]), DateTime(2027, 3, 1)).firstWhere((m) => m.id == 'vax:mo9');
    expect(m.at, DateTime(2027, 3, 26, 10));
    expect(m.body, contains('MR, PCV'));
    expect(m.body, contains('paediatrician'));
  });

  test('nothing for a placeholder child or on the partner side', () {
    expect(ppMessageCandidates(facts(real: false), DateTime(2026, 10, 1)), isEmpty);
    expect(ppMessageCandidates(facts(partner: true), DateTime(2026, 10, 1)), isEmpty);
  });

  test('sent once: a delivered message never comes back, pending follows the date', () {
    final s = PpMessagesStore.instance;
    final now = DateTime(2026, 10, 29, 12);
    s.apply(ppMessageCandidates(facts(), now), now);
    final delivered = s.delivered(now: now).map((m) => m.id).toSet();
    expect(delivered, contains('age:m4'));
    s.apply(ppMessageCandidates(facts(), now), now);
    expect(s.delivered(now: now).where((m) => m.id == 'age:m4'), hasLength(1));
    expect(s.pending(now: now).any((m) => m.id == 'age:m5'), isTrue);
  });

  test('on by default: age, vaccines and stages; the activity waits to be chosen', () {
    final s = PpMessagesStore.instance;
    expect(s.isOn(PpMessageKind.age), isTrue);
    expect(s.isOn(PpMessageKind.vaccine), isTrue);
    expect(s.isOn(PpMessageKind.milestones), isTrue);
    expect(s.isOn(PpMessageKind.activity), isFalse);
  });

  test('wired: started after the reminder wipe, and a Messages row in Settings', () {
    final main = File('lib/main.dart').readAsStringSync();
    final preg = main.indexOf('PregMessagesStore.instance.init()');
    final pp = main.indexOf('PpMessagesStore.instance.init()');
    expect(pp, greaterThan(preg));
    expect(File('lib/screens/profile/pv_you_content.dart').readAsStringSync(), contains('notificationThings: [_ppMessages()]'));
  });
}
