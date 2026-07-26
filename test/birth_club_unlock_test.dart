// =============================================================================
//  Birth Club unlocks + reward celebration
// -----------------------------------------------------------------------------
//  The ladder used to be presentational — a tick beside a milestone and nothing
//  behind it. These pin that it now GRANTS, exactly once, permanently.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/community_data.dart';
import 'package:parentveda/referral/birth_club_store.dart';
import 'package:parentveda/screens/referral/reward_celebration.dart';
import 'package:parentveda/services/community_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final club = BirthClubStore.instance;
  setUp(club.resetAll);
  tearDown(club.resetAll);

  group('the ladder actually grants', () {
    test('one joined friend puts her IN the club room, not just a tick', () {
      final newly = club.evaluate(club: '2026-10', joined: 1);
      expect(newly, [1]);
      expect(CommunityStore.instance.isJoined(birthClubRoomId('2026-10')),
          isTrue, reason: 'rung 1 must join the room, not merely display it');
    });

    test('the room she joins is a REAL community room, not an invented id', () {
      // The original bug: 'birthclub_2026-10' existed nowhere, so she was a
      // member of a room that never rendered.
      final id = birthClubRoomId('2026-10');
      expect(id, 'oct2026');
      expect(communityById(id), isNotNull,
          reason: 'a joined room that resolves to null renders as nothing');
      expect(communityById(id)!.name, 'October 2026 Moms');
    });

    test('a joined birth club appears in her joined list', () {
      club.evaluate(club: '2027-03', joined: 1);
      final joined = CommunityStore.instance.joinedCommunities.map((c) => c.id);
      expect(joined, contains('mar2027'));
    });

    test('a month that WAS hand-seeded resolves to that same room', () {
      // 'nov2026' is in kCommunities; deriving it must not create a duplicate.
      expect(birthClubRoomId('2026-11'), 'nov2026');
      expect(communityById('nov2026')!.name, 'November 2026 Moms');
      expect(allCommunities(dueDate: DateTime(2026, 11, 20)).length,
          kCommunities.length,
          reason: 'a seeded month must not be listed twice');
    });

    test('a derived club is added for an unseeded month', () {
      final all = allCommunities(dueDate: DateTime(2027, 5, 2));
      expect(all.length, kCommunities.length + 1);
      expect(all.first.id, 'may2027');
      expect(all.first.members, 0,
          reason: 'inventing a member count would be a small, corrosive lie');
    });

    test('a malformed club key joins nothing rather than a junk room', () {
      expect(birthClubRoomId('nonsense'), '');
      expect(birthClubRoomId('2026-99'), '');
    });

    test('three opens the Q&A, five makes her a founding member', () {
      club.evaluate(club: '2026-10', joined: 5);
      expect(club.qaOpen('2026-10'), isTrue);
      expect(club.isFoundingMember('2026-10'), isTrue);
    });

    test('crossing several rungs at once reports each one', () {
      expect(club.evaluate(club: '2026-11', joined: 5), [1, 3, 5]);
    });

    test('re-evaluating grants nothing new — safe to call on every build', () {
      club.evaluate(club: '2026-10', joined: 3);
      expect(club.evaluate(club: '2026-10', joined: 3), isEmpty);
      expect(club.evaluate(club: '2026-10', joined: 3), isEmpty);
    });

    test('an unlock is PERMANENT — a later blocked invite cannot claw it back',
        () {
      club.evaluate(club: '2026-10', joined: 3);
      expect(club.qaOpen('2026-10'), isTrue);
      // The count drops (an invite was blocked for fraud). She keeps the Q&A.
      club.evaluate(club: '2026-10', joined: 1);
      expect(club.qaOpen('2026-10'), isTrue,
          reason: 'taking back something already given is the worse failure');
    });

    test('clubs are independent — one month does not unlock another', () {
      club.evaluate(club: '2026-10', joined: 5);
      expect(club.qaOpen('2027-03'), isFalse);
    });

    test('too few friends unlocks nothing', () {
      expect(club.evaluate(club: '2026-10', joined: 0), isEmpty);
      expect(club.hasAnyUnlock, isFalse);
    });

    test('an empty club key is refused rather than creating a junk unlock', () {
      expect(club.evaluate(club: '', joined: 5), isEmpty);
      expect(club.hasAnyUnlock, isFalse);
    });
  });

  group('celebration', () {
    testWidgets('shows what was earned and dismisses', (t) async {
      t.view.physicalSize = const Size(1170, 2400);
      t.view.devicePixelRatio = 3.0;
      addTearDown(t.view.reset);

      await t.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showRewardCelebration(ctx,
                    title: 'You earned 1 free consultation',
                    body: 'A friend you invited finished setting up.'),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ));
      await t.tap(find.text('go'));
      await t.pumpAndSettle();

      expect(find.text('You earned 1 free consultation'), findsOneWidget);
      expect(find.text('Lovely'), findsOneWidget);

      await t.tap(find.text('Lovely'));
      await t.pumpAndSettle();
      expect(find.text('You earned 1 free consultation'), findsNothing);
    });
  });
}
