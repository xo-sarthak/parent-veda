// =============================================================================
//  TTC - records, appointments, "Can I...?" and the shared community layer
// -----------------------------------------------------------------------------
//  The four tiles that were "Soon", plus the community move onto the shared
//  social layer.
//
//  The rules worth pinning here are the couple-first ones. A records folder
//  that only holds her results, or a community without a partner room, would
//  rebuild the exact asymmetry this stage exists to correct - and both are the
//  kind of thing that erodes quietly rather than breaking loudly.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/community_data.dart';
import 'package:parentveda/models/community_models.dart';
import 'package:parentveda/screens/ttc/ttc_appointments_screen.dart';
import 'package:parentveda/screens/ttc/ttc_can_i_screen.dart';
import 'package:parentveda/screens/ttc/ttc_community_screen.dart';
import 'package:parentveda/screens/ttc/ttc_nutrition_screen.dart';
import 'package:parentveda/screens/ttc/ttc_records_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/services/community_store.dart';
import 'package:parentveda/ttc/ttc_can_i_data.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_journal_store.dart';
import 'package:parentveda/ttc/ttc_records_store.dart';
import 'package:parentveda/ttc/ttc_tests_data.dart';

Future<void> pumpTall(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1200, 8000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    TtcRecordsStore.instance.resetForTest();
    TtcAppointmentsStore.instance.resetForTest();
    TtcJournalStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  // ===========================================================================
  group('health records hold both people', () {
    test('a result can belong to either partner', () {
      final s = TtcRecordsStore.instance;
      s.add(label: 'AMH', value: '2.1', unit: 'ng/mL', takenOn: DateTime(2026, 6, 1));
      s.add(
          label: 'Semen analysis',
          value: 'Normal',
          takenOn: DateTime(2026, 6, 2),
          forPartner: true);
      expect(s.forPerson(partner: false).length, 1);
      expect(s.forPerson(partner: true).length, 1);
      expect(s.count, 2);
    });

    test('newest first - how a folder of reports is actually read', () {
      final s = TtcRecordsStore.instance;
      s.add(label: 'old', takenOn: DateTime(2026, 1, 1));
      s.add(label: 'new', takenOn: DateTime(2026, 6, 1));
      expect(s.records.first.label, 'new');
    });

    test('a repeat reads as a trend, oldest first', () {
      final s = TtcRecordsStore.instance;
      s.add(label: 'TSH', testId: 'tsh', value: '4.1', takenOn: DateTime(2026, 1, 1));
      s.add(label: 'TSH', testId: 'tsh', value: '2.2', takenOn: DateTime(2026, 6, 1));
      final history = s.historyFor('tsh');
      expect(history.length, 2);
      expect(history.first.value, '4.1');
    });

    test('the value is text, so real reports survive', () {
      // Real Indian lab reports say these things. A double would lose them.
      final s = TtcRecordsStore.instance;
      for (final v in ['12.4', 'Normal', '<0.5', 'Grade II']) {
        s.add(label: 'x', value: v, takenOn: DateTime(2026, 1, 1));
      }
      expect(s.records.map((r) => r.value).toSet(),
          {'12.4', 'Normal', '<0.5', 'Grade II'});
    });

    test('a record round-trips through encoding', () {
      final s = TtcRecordsStore.instance;
      final r = s.add(
          label: 'AMH',
          testId: 'amh',
          value: '2.1',
          unit: 'ng/mL',
          takenOn: DateTime(2026, 6, 1),
          forPartner: false);
      final back = TtcRecord.fromJson(r.toJson());
      expect(back!.label, 'AMH');
      expect(back.testId, 'amh');
      expect(back.display, '2.1 ng/mL');
      expect(back.takenOn, DateTime(2026, 6, 1));
    });

    test('a corrupt row is dropped rather than breaking the folder', () {
      expect(TtcRecord.fromJson('nonsense'), isNull);
      expect(TtcRecord.fromJson({'id': 1}), isNull);
    });

    test('anything can be typed in - the library is not a gate', () {
      // No library covers every test an Indian lab runs.
      final r = TtcRecordsStore.instance
          .add(label: 'Something my lab invented', takenOn: DateTime.now());
      expect(r.testId, isNull);
      expect(TtcRecordsStore.instance.count, 1);
    });

    testWidgets('the screen invites when empty', (tester) async {
      await pumpTall(tester, const TtcRecordsScreen());
      expect(find.text(const TtcS(false).recordsEmptyTitle), findsOneWidget);
    });

    testWidgets('Reports shows only library results, Records shows everything',
        (tester) async {
      TtcRecordsStore.instance
        ..add(label: 'AMH', testId: 'amh', takenOn: DateTime(2026, 6, 1))
        ..add(label: 'My own note', takenOn: DateTime(2026, 6, 2));

      await pumpTall(tester, const TtcRecordsScreen());
      expect(find.text('My own note'), findsOneWidget);

      await pumpTall(tester, const TtcRecordsScreen(resultsOnly: true));
      expect(find.text('My own note'), findsNothing);
      expect(find.text('AMH'), findsOneWidget);
    });

    testWidgets("a library result carries the test's plain-language note",
        (tester) async {
      TtcRecordsStore.instance
          .add(label: 'AMH', testId: 'amh', value: '2.1', takenOn: DateTime.now());
      await pumpTall(tester, const TtcRecordsScreen());
      expect(find.text(ttcTestById('amh')!.reading(false)), findsOneWidget);
    });
  });

  // ===========================================================================
  group('appointments', () {
    test('sorted soonest first, and split by upcoming', () {
      final s = TtcAppointmentsStore.instance;
      s.add(
          title: 'later',
          startsLocal: DateTime.now().add(const Duration(days: 5)));
      s.add(
          title: 'sooner',
          startsLocal: DateTime.now().add(const Duration(days: 1)));
      s.add(
          title: 'past',
          startsLocal: DateTime.now().subtract(const Duration(days: 3)));
      expect(s.upcoming.first.title, 'sooner');
      expect(s.upcoming.length, 2);
      expect(s.past.single.title, 'past');
    });

    test('times are stored UTC and read back local', () {
      final local = DateTime(2026, 7, 4, 15, 30);
      final a = TtcAppointmentsStore.instance
          .add(title: 'Scan', startsLocal: local);
      expect(a.startsUtc.isUtc, isTrue);
      expect(a.startsLocal, local);
    });

    test('found by day, in local time', () {
      final day = DateTime.now().add(const Duration(days: 2));
      TtcAppointmentsStore.instance.add(
          title: 'Consult',
          startsLocal: DateTime(day.year, day.month, day.day, 11));
      expect(TtcAppointmentsStore.instance.on(day).length, 1);
      expect(
          TtcAppointmentsStore.instance
              .on(day.add(const Duration(days: 1)))
              .length,
          0);
    });

    test('round-trips through encoding', () {
      final a = TtcAppointmentsStore.instance.add(
          title: 'Dr Rao',
          withWhom: 'Fertility clinic',
          startsLocal: DateTime(2026, 7, 4, 10));
      final back = TtcAppointment.fromJson(a.toJson());
      expect(back!.title, 'Dr Rao');
      expect(back.withWhom, 'Fertility clinic');
      expect(back.startsUtc, a.startsUtc);
    });

    test('removing works', () {
      final a = TtcAppointmentsStore.instance
          .add(title: 'x', startsLocal: DateTime.now());
      TtcAppointmentsStore.instance.remove(a.id);
      expect(TtcAppointmentsStore.instance.all, isEmpty);
    });

    testWidgets('the screen builds and invites when empty', (tester) async {
      await pumpTall(tester, const TtcAppointmentsScreen());
      expect(find.text(const TtcS(false).appointmentsEmptyTitle), findsOneWidget);
    });

    testWidgets('saved doctor questions surface here', (tester) async {
      TtcJournalStore.instance
          .add(kind: TtcEntryKind.question, text: 'Should we test AMH?');
      await pumpTall(tester, const TtcAppointmentsScreen());
      expect(find.text('Should we test AMH?'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('"Can I...?" answers calmly', () {
    test('most answers while trying are yes - not a wall of no', () {
      // A safety checker that says no to everything in a stage where nothing
      // has happened yet is manufacturing anxiety, not being careful.
      final permissive = ttcCanI
          .where((q) =>
              q.verdict == TtcVerdict.safe || q.verdict == TtcVerdict.moderate)
          .length;
      expect(permissive, greaterThan(ttcCanI.length / 2));
    });

    test('"avoid" is reserved, not sprayed around', () {
      final avoid = ttcCanI.where((q) => q.verdict == TtcVerdict.avoid).toList();
      expect(avoid.length, lessThanOrEqualTo(2),
          reason: 'only the things with genuinely clear evidence');
      expect(avoid.map((q) => q.id), contains('smoking'));
    });

    test('every entry is bilingual and carries its Indian line', () {
      for (final q in ttcCanI) {
        for (final hi in [true, false]) {
          expect(q.question(hi), isNotEmpty, reason: q.id);
          expect(q.short(hi), isNotEmpty, reason: q.id);
          expect(q.why(hi), isNotEmpty, reason: q.id);
          expect(q.indian(hi), isNotEmpty, reason: q.id);
        }
        expect(q.why(true), isNot(q.why(false)), reason: q.id);
      }
    });

    test('ids are unique, and at least one question is his', () {
      final ids = ttcCanI.map((q) => q.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(ttcCanI.any((q) => q.forPartner), isTrue);
    });

    test('the papaya myth is answered as safe, not hedged into a fear', () {
      expect(ttcCanIById('papaya')!.verdict, TtcVerdict.safe);
    });

    test('every verdict has calm wording in both languages', () {
      for (final v in TtcVerdict.values) {
        for (final hi in [true, false]) {
          final label = v.label(hi).toLowerCase();
          expect(label, isNotEmpty);
          expect(label, isNot(contains('danger')));
          expect(label, isNot(contains('never')));
        }
      }
    });

    testWidgets('the screen builds and search narrows it', (tester) async {
      await pumpTall(tester, const TtcCanIScreen());
      expect(find.text(ttcCanIById('chai')!.question(false)), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'papaya');
      await tester.pump();
      expect(find.text(ttcCanIById('chai')!.question(false)), findsNothing);
      expect(find.text(ttcCanIById('papaya')!.question(false)), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the nutrition planner agrees with Today', () {
    test('the week comes from the same rotation the daily card uses', () {
      final day = DateTime(2026, 7, 27);
      final week = TtcNutritionScreen.weekFrom(day);
      expect(week.length, 7);
      // Day one of the planner IS today's nutrition card.
      expect(week.first.$2.id,
          ttcPickForToday(ttcNutrition, now: day, offset: 1).id);
    });

    testWidgets('the screen builds', (tester) async {
      await pumpTall(tester, const TtcNutritionScreen());
      expect(tester.takeException(), isNull);
    });
  });

  // ===========================================================================
  group('the community runs on the shared social layer', () {
    test('TTC rooms are real Community objects, not a private list', () {
      expect(TtcCommunityScreen.rooms, same(kTtcCommunities));
      for (final c in kTtcCommunities) {
        expect(c, isA<Community>());
        expect(c.name, isNotEmpty);
        expect(c.description, isNotEmpty);
      }
    });

    test('room ids are unique and do not collide with the other stages', () {
      final ttc = kTtcCommunities.map((c) => c.id).toSet();
      expect(ttc.length, kTtcCommunities.length);
      expect(ttc.intersection(kCommunities.map((c) => c.id).toSet()), isEmpty);
      expect(ttc.intersection(kParentingCommunityIds), isEmpty);
      expect(ttc, kTtcCommunityIds);
    });

    test('joining uses the SAME store the other stages use', () {
      // This is the whole point: a room joined while trying is still joined
      // after a positive test.
      final store = CommunityStore.instance;
      final id = kTtcCommunities.first.id;
      final was = store.isJoined(id);
      store.toggleJoin(id);
      expect(store.isJoined(id), !was);
      store.toggleJoin(id); // put it back
    });

    test('posts are attributed to the trying stage', () {
      expect(kTtcPosts, isNotEmpty);
      for (final p in kTtcPosts) {
        expect(p.stage, 'Trying', reason: p.id);
        expect(kTtcCommunityIds.contains(p.communityId), isTrue,
            reason: '${p.id} points at a room that does not exist');
      }
    });

    test('post ids do not collide with the other stages', () {
      final ttc = kTtcPosts.map((p) => p.id).toSet();
      expect(ttc.length, kTtcPosts.length);
      expect(ttc.intersection(kSeedPosts.map((p) => p.id).toSet()), isEmpty);
      expect(ttc.intersection(kParentingPosts.map((p) => p.id).toSet()), isEmpty);
    });

    test('the hard rooms exist - loss, and a room of his own', () {
      final names = kTtcCommunities.map((c) => c.name.toLowerCase()).toList();
      expect(names.any((n) => n.contains('loss')), isTrue);
      expect(names.any((n) => n.contains('partner')), isTrue);
      expect(names.any((n) => n.contains('male fertility')), isTrue);
    });

    test('no emoji avatars - TTC renders monograms, like parenting', () {
      for (final c in kTtcCommunities) {
        expect(c.emoji, isEmpty, reason: c.id);
      }
      for (final p in kTtcPosts) {
        expect(p.authorEmoji, isEmpty, reason: p.id);
      }
    });

    testWidgets('the screen renders rooms and the feed', (tester) async {
      await pumpTall(tester, const TtcCommunityScreen());
      expect(find.text('Trying Naturally'), findsWidgets);
      expect(find.text('Loss & Recovery'), findsWidgets);
      // A real post body, not a placeholder.
      expect(find.textContaining('Month nine.'), findsOneWidget);
    });

    testWidgets('liking a post goes through the shared store', (tester) async {
      final store = CommunityStore.instance;
      final id = kTtcPosts.first.id;
      final was = store.isLiked(id);
      await pumpTall(tester, const TtcCommunityScreen());
      await tester.tap(find.text('${store.likeCount(kTtcPosts.first)}').first);
      await tester.pump();
      expect(store.isLiked(id), !was);
      store.toggleLike(id); // put it back
    });
  });
}
