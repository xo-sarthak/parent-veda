// =============================================================================
//  Referral — store, links, screens
// -----------------------------------------------------------------------------
//  The engine's rules are pinned in referral_engine_test. This covers the wiring:
//  the store's counts, link parsing (the Firebase Dynamic Links replacement),
//  and that the screens render the real numbers rather than decoration.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/referral/referral_analytics.dart';
import 'package:parentveda/referral/referral_links.dart';
import 'package:parentveda/referral/referral_models.dart';
import 'package:parentveda/referral/referral_store.dart';
import 'package:parentveda/screens/referral/birth_club_screen.dart';
import 'package:parentveda/screens/referral/invite_friends_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final store = ReferralStore.instance;
  setUp(() {
    store.resetAll();
    ReferralLinks.clearPending();
  });
  tearDown(store.resetAll);

  Invite invite(InviteStatus s, {DateTime? at}) => Invite(
        id: 'i_${s.name}_${at?.millisecondsSinceEpoch ?? 0}',
        code: 'ABCD234',
        status: s,
        sentAt: at ?? DateTime.now(),
      );

  group('store counts', () {
    test('friends joined counts registered and beyond, never blocked', () {
      store.debugSeed([
        invite(InviteStatus.sent),
        invite(InviteStatus.installed),
        invite(InviteStatus.registered),
        invite(InviteStatus.credited),
        invite(InviteStatus.blocked),
      ]);
      expect(store.totalInvites, 5);
      expect(store.friendsJoined, 2);
    });

    test('pending rewards are the qualified-but-not-yet-paid', () {
      store.debugSeed([
        invite(InviteStatus.qualified),
        invite(InviteStatus.qualified),
        invite(InviteStatus.credited),
      ]);
      expect(store.pendingRewards, 2);
    });

    test('daily and monthly counts only include the right window', () {
      final now = DateTime.now();
      store.debugSeed([
        invite(InviteStatus.sent, at: now),
        invite(InviteStatus.sent, at: now.subtract(const Duration(days: 2))),
        invite(InviteStatus.sent, at: DateTime(now.year - 1, now.month, 1)),
      ]);
      expect(store.sentToday, 1);
      expect(store.sentThisMonth, greaterThanOrEqualTo(1));
    });

    test('hitting the daily cap blocks further inviting, with a reason', () {
      store.debugSeed(
          List.generate(20, (_) => invite(InviteStatus.sent, at: DateTime.now())));
      expect(store.invitingProblem, contains('today'));
    });
  });

  group('links — the Firebase Dynamic Links replacement', () {
    test('the /invite/ path form yields the code', () {
      expect(
          ReferralLinks.codeFromUri(
              Uri.parse('https://parentveda.in/invite/ABCD234')),
          'ABCD234');
    });

    test('the ?r= query form yields the code', () {
      expect(
          ReferralLinks.codeFromUri(
              Uri.parse('https://parentveda.in/?r=abcd234')),
          'ABCD234');
    });

    test('somebody else\'s domain is ignored', () {
      expect(
          ReferralLinks.codeFromUri(
              Uri.parse('https://evil.example.com/invite/ABCD234')),
          isNull);
    });

    test('a malformed code in a valid link is refused', () {
      expect(
          ReferralLinks.codeFromUri(
              Uri.parse('https://parentveda.in/invite/OI01')),
          isNull);
    });

    test('an opened link holds the code for onboarding rather than losing it',
        () {
      expect(ReferralLinks.hasPending, isFalse);
      ReferralLinks.handleLink(Uri.parse('https://parentveda.in/invite/ABCD234'));
      expect(ReferralLinks.pending, 'ABCD234');
    });

    test('applying with nothing pending is a harmless no-op', () async {
      expect(await ReferralLinks.applyPending(), isNull);
    });
  });

  group('redemption refuses the obvious abuse offline', () {
    test('a parent cannot redeem their own code', () async {
      store.debugSeed(const []);
      final problem = await store.redeem(store.code);
      expect(problem, 'You cannot invite yourself');
    });

    test('a nonsense code is refused before any network call', () async {
      store.debugSeed(const []);
      expect(await store.redeem('zzz'), 'That code does not look right');
    });
  });

  group('analytics', () {
    test('a sink that throws can never break a parent inviting a friend', () {
      ReferralAnalytics.setSink(_ExplodingSink());
      addTearDown(() => ReferralAnalytics.setSink(const DebugReferralSink()));
      expect(() => ReferralAnalytics.shared('whatsapp'), returnsNormally);
      expect(() => ReferralAnalytics.codeAccepted(), returnsNormally);
    });
  });

  group('screens', () {
    Future<void> pump(WidgetTester t, Widget w) async {
      t.view.physicalSize = const Size(1170, 4200);
      t.view.devicePixelRatio = 3.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(home: w));
      await t.pump();
      await t.pump(const Duration(milliseconds: 250));
    }

    testWidgets('Invite Friends shows the code and the real counts', (t) async {
      store.debugSeed([
        invite(InviteStatus.registered),
        invite(InviteStatus.credited),
      ], rewards: 1);
      await pump(t, const InviteFriendsScreen());

      expect(find.text('YOUR CODE'), findsOneWidget);
      expect(find.text(store.code), findsOneWidget);
      expect(find.text('Invites sent'), findsOneWidget);
      expect(find.text('2'), findsWidgets); // invites + joined
    });

    testWidgets('an empty invite list encourages rather than showing nothing',
        (t) async {
      store.debugSeed(const []);
      await pump(t, const InviteFriendsScreen());
      expect(find.text('No invites yet'), findsOneWidget);
    });

    testWidgets('Birth Club asks for a due date before inventing a cohort',
        (t) async {
      store.debugSeed(const []);
      await pump(t, const BirthClubScreen());
      expect(find.text('Set your due date first'), findsOneWidget);
    });
  });
}

class _ExplodingSink implements ReferralAnalyticsSink {
  @override
  void record(ReferralEvent event, {String? detail}) =>
      throw StateError('sink down');
}
