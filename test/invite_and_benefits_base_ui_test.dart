// =============================================================================
//  Invite a friend + Employer benefits, on the base UI (2026-09-29)
// -----------------------------------------------------------------------------
//  The user, from the TTC More tab's Benefits section: Employer benefits had
//  "that purplish tint in the background of the whole screen", and Invite a
//  friend was "the screen we used to have way before … hideous". Both are
//  shared by every stage and were redrawn on the base UI. These hold it:
//
//   · Employer benefits' ground is white, not `surfaceContainer`, and its
//     empty state (the page most people see) renders the mark, the sentence
//     and the one action.
//   · Invite shows the code; Copy puts the code on the clipboard; Share calls
//     the share action with the invite text and still records the share.
//   · One ink primary button on Invite, and nothing violet.
//   · No overflow at 360dp and 1.5x text, and Copy and Share are labelled
//     buttons to a screen reader.
//   · On Trying to conceive the invite text does not say "pregnancy", and the
//     Birth Club (a due-date cohort) is not offered.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/referral/referral_models.dart';
import 'package:parentveda/referral/referral_store.dart';
import 'package:parentveda/screens/enterprise/employer_benefits_screen.dart';
import 'package:parentveda/screens/referral/invite_friends_screen.dart';
import 'package:parentveda/screens/ttc/doors/ttc_tab_art.dart';
import 'package:parentveda/services/credits_store.dart';
import 'package:parentveda/services/entitlement_store.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final store = ReferralStore.instance;

  setUp(() {
    store.resetAll();
    LifeStageStore.instance.resetForTest();
  });
  tearDown(() {
    store.resetAll();
    LifeStageStore.instance.resetForTest();
    EntitlementStore.instance.setForTest();
    CreditsStore.instance.setForTest();
  });

  Future<void> pump(
    WidgetTester t,
    Widget w, {
    double width = 390,
    double scale = 1.0,
  }) async {
    t.view.physicalSize = Size(width * 3, 2400 * 3 / 1);
    t.view.devicePixelRatio = 3.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: w,
          ),
        ),
      ),
    );
    await t.pump();
    await t.pump(const Duration(milliseconds: 250));
  }

  Invite invite(InviteStatus s) => Invite(
    id: 'i_${s.name}',
    code: 'ABCD234',
    status: s,
    sentAt: DateTime.now(),
    dueMonth: s == InviteStatus.registered ? '2027-03' : null,
  );

  // ===========================================================================
  //  Employer benefits
  // ===========================================================================
  group('Employer benefits', () {
    testWidgets('the ground and the bar are white, not the lilac', (t) async {
      EntitlementStore.instance.setForTest();
      await pump(t, const EmployerBenefitsScreen());

      final scaffold = t.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, Colors.white);
      expect(scaffold.backgroundColor, isNot(AppTheme.surfaceContainer));
      // Kept for revert (2026-09-29) — the old ground, pinned nowhere before:
      // expect(scaffold.backgroundColor, AppTheme.surfaceContainer);
      final bar = t.widget<AppBar>(find.byType(AppBar));
      expect(bar.backgroundColor, Colors.white);
    });

    testWidgets('the empty state renders: mark, sentence, one action', (
      t,
    ) async {
      EntitlementStore.instance.setForTest();
      await pump(t, const EmployerBenefitsScreen());

      expect(
        find.byKey(const ValueKey('employer_benefits_empty')),
        findsOneWidget,
      );
      expect(find.byType(TtcTabArt), findsOneWidget);
      expect(find.text('No employer benefit is active.'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('employer_benefits_activate')),
        findsOneWidget,
      );
      expect(find.text(kEmployerBenefitsActivate), findsOneWidget);
    });

    testWidgets('an active benefit keeps every line, with no tinted slab', (
      t,
    ) async {
      EntitlementStore.instance.setForTest(
        capabilities: {
          Caps.consultationCredit,
          Caps.masterclassAccess,
          Caps.sponsorEvents,
          Caps.sponsorResources,
        },
        sponsor: const SponsorInfo(
          id: 's1',
          name: 'Acme',
          supportContact: 'hr@acme.example',
        ),
      );
      CreditsStore.instance.setForTest(available: 1, spent: 1);
      await pump(t, const EmployerBenefitsScreen());

      expect(find.text('ParentVeda Premium'), findsOneWidget);
      expect(find.text('Provided by Acme'), findsOneWidget);
      expect(find.text('Consultations'), findsOneWidget);
      expect(find.text('1 used so far.'), findsOneWidget);
      expect(find.text('Masterclasses'), findsOneWidget);
      expect(find.text('Company sessions'), findsOneWidget);
      expect(find.text('Company resources'), findsOneWidget);
      expect(find.text('Questions about the benefit'), findsOneWidget);
      expect(find.text('What Acme sees'), findsOneWidget);

      // No slab: nothing on the page is filled with the old lilacs.
      final slabs = t.widgetList<Container>(find.byType(Container)).where((c) {
        final d = c.decoration;
        return d is BoxDecoration &&
            (d.color == AppTheme.surfaceContainerLow ||
                d.color == AppTheme.surfaceContainer ||
                d.color == AppTheme.primary100);
      });
      expect(slabs, isEmpty);
    });

    for (final active in [false, true]) {
      testWidgets(
        'no overflow at 360dp and 1.5x (${active ? 'active' : 'empty'})',
        (t) async {
          EntitlementStore.instance.setForTest(
            capabilities: active
                ? {Caps.consultationCredit, Caps.masterclassAccess}
                : const {},
            sponsor: active
                ? const SponsorInfo(
                    id: 's1',
                    name: 'A company with a long name',
                    supportContact: 'hr@acme.example',
                  )
                : null,
          );
          CreditsStore.instance.setForTest(available: 2);
          await pump(t, const EmployerBenefitsScreen(), width: 360, scale: 1.5);
          expect(t.takeException(), isNull);
        },
      );
    }

    testWidgets('the activate action is a labelled button', (t) async {
      final h = t.ensureSemantics();
      EntitlementStore.instance.setForTest();
      await pump(t, const EmployerBenefitsScreen());
      expect(
        t.getSemantics(
          find.byKey(const ValueKey('employer_benefits_activate')),
        ),
        matchesSemantics(
          label: kEmployerBenefitsActivate,
          isButton: true,
          hasTapAction: true,
        ),
      );
      h.dispose();
    });
  });

  // ===========================================================================
  //  Invite a friend
  // ===========================================================================
  group('Invite a friend', () {
    testWidgets('shows the code on a white ground', (t) async {
      store.debugSeed(const []);
      await pump(t, const InviteFriendsScreen());

      expect(find.byKey(const ValueKey('invite_code')), findsOneWidget);
      expect(find.text(store.code), findsOneWidget);
      final scaffold = t.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, Colors.white);
      expect(find.text('How it works'), findsOneWidget);
    });

    testWidgets('Copy puts the code on the clipboard', (t) async {
      store.debugSeed(const []);
      String? clip;
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            clip = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await pump(t, const InviteFriendsScreen());
      await t.tap(find.byKey(const ValueKey('invite_copy_code')));
      await t.pump();
      expect(clip, store.code);
      expect(find.text('Code copied'), findsOneWidget);
    });

    testWidgets('Share calls the share action and records the share', (
      t,
    ) async {
      store.debugSeed(const []);
      final shared = <String>[];
      await pump(
        t,
        InviteFriendsScreen(shareAction: (text) async => shared.add(text)),
      );
      final before = store.totalInvites;

      await t.tap(find.byKey(const ValueKey('invite_share_button')));
      await t.pump();

      expect(shared, hasLength(1));
      expect(shared.single, contains(store.code));
      expect(store.totalInvites, before + 1);
    });

    testWidgets('exactly one ink primary button, and nothing violet', (
      t,
    ) async {
      store.debugSeed([invite(InviteStatus.credited)], rewards: 1);
      await pump(t, const InviteFriendsScreen());

      final inkFills = t
          .widgetList<Material>(find.byType(Material))
          .where((m) => m.color == kInviteInk)
          .length;
      final inkBoxes = t
          .widgetList<Container>(find.byType(Container))
          .where(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration as BoxDecoration).color == kInviteInk,
          );
      expect(inkFills + inkBoxes.length, 1);
      expect(kInviteInk, const Color(0xFF2F2C30));

      // The old screen's violet (ppPurple) and lilac gradient are gone.
      final violet = t
          .widgetList<Container>(find.byType(Container))
          .where(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration as BoxDecoration).gradient != null,
          );
      expect(violet, isEmpty);
    });

    testWidgets('Copy and Share are labelled buttons', (t) async {
      final h = t.ensureSemantics();
      store.debugSeed(const []);
      await pump(t, const InviteFriendsScreen());
      expect(find.bySemanticsLabel(kInviteShareLabel), findsOneWidget);
      expect(find.bySemanticsLabel('Copy code ${store.code}'), findsOneWidget);
      expect(
        t.getSemantics(find.bySemanticsLabel(kInviteShareLabel)),
        matchesSemantics(
          label: kInviteShareLabel,
          isButton: true,
          hasTapAction: true,
        ),
      );
      h.dispose();
    });

    for (final seeded in [false, true]) {
      testWidgets(
        'no overflow at 360dp and 1.5x (${seeded ? 'with invites' : 'empty'})',
        (t) async {
          store.debugSeed(
            seeded
                ? [
                    invite(InviteStatus.registered),
                    invite(InviteStatus.credited),
                    invite(InviteStatus.blocked),
                  ]
                : const [],
            rewards: seeded ? 1 : 0,
          );
          await pump(t, const InviteFriendsScreen(), width: 360, scale: 1.5);
          expect(t.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'on Trying to conceive: no pregnancy in the text, no Birth Club',
      (t) async {
        LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
        store.debugSeed(const []);
        final shared = <String>[];
        await pump(
          t,
          InviteFriendsScreen(shareAction: (text) async => shared.add(text)),
        );

        expect(find.textContaining('Birth Club'), findsNothing);
        await t.tap(find.byKey(const ValueKey('invite_share_button')));
        await t.pump();
        expect(shared.single.toLowerCase(), isNot(contains('pregnan')));
        expect(shared.single, contains(store.code));
      },
    );

    testWidgets('elsewhere the Birth Club door is still there', (t) async {
      store.debugSeed(const []);
      await pump(t, const InviteFriendsScreen());
      expect(find.text('Your Birth Club'), findsOneWidget);
    });
  });
}
