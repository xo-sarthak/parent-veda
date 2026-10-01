// =============================================================================
//  The first run: the sequence per stage, the questions, the wiring.
// -----------------------------------------------------------------------------
//  Google sign-in and the OTP cannot run here, so the tests start the flow past
//  them where they must, and pin what can be pinned: which screens each stage
//  sees and in what order, that the questions give something back and never a
//  probability, that the splash pushes the new flow and routes every stage to
//  its own home, and that the three homes default to V3.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/auth/onboarding/onboarding_flow.dart';
import 'package:parentveda/screens/auth/onboarding/onboarding_questions.dart';
import 'package:parentveda/services/family_profile.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _read(String p) => File(p).readAsStringSync();
Iterable<String> _code(String src) =>
    src.split('\n').where((l) => !l.trimLeft().startsWith('//'));

void main() {
  group('the question bank', () {
    test('every stage has two or three questions, none more', () {
      for (final s in ['trying', 'pregnancy', 'parenting', 'skilling']) {
        final n = onboardingQuestionsFor(s).length;
        expect(n, inInclusiveRange(2, 3), reason: s);
      }
      expect(onboardingQuestionsFor('nonsense'), isEmpty);
    });

    test(
      'every single-select option gives something back; multi-selects give one line',
      () {
        for (final s in ['trying', 'pregnancy', 'parenting', 'skilling']) {
          for (final q in onboardingQuestionsFor(s, childName: 'Aarav')) {
            if (q.multi) {
              expect(q.multiGiveBack, isNotNull, reason: q.id);
              expect(q.multiGiveBack!.trim(), isNotEmpty, reason: q.id);
            } else {
              for (final o in q.options) {
                expect(
                  o.giveBack.trim(),
                  isNotEmpty,
                  reason: '${q.id}/${o.id}',
                );
              }
            }
          }
        }
      },
    );

    test('no give-back line is a personalised probability or a target', () {
      // The clinical invariant (CLAUDE.md): population facts that reduce
      // pressure are allowed; "your chance", percentages and "on track" are not.
      final banned = RegExp(
        r'\byour chance\b|\d+\s?%|\bon track\b|\bchances? (are|is)\b',
        caseSensitive: false,
      );
      for (final s in ['trying', 'pregnancy', 'parenting', 'skilling']) {
        for (final q in onboardingQuestionsFor(s)) {
          for (final o in q.options) {
            expect(
              banned.hasMatch(o.giveBack),
              isFalse,
              reason: '${q.id}/${o.id}: ${o.giveBack}',
            );
          }
          if (q.multiGiveBack != null) {
            expect(banned.hasMatch(q.multiGiveBack!), isFalse);
          }
        }
      }
    });

    test('the child\'s name lands in the parenting and skilling titles', () {
      expect(
        onboardingQuestionsFor('parenting', childName: 'Aarav').first.title,
        contains('Aarav'),
      );
      expect(
        onboardingQuestionsFor('skilling', childName: 'Aarav').first.title,
        contains('Aarav'),
      );
      expect(
        onboardingQuestionsFor('parenting').first.title,
        contains('your child'),
      );
    });

    test(
      'applying an answer writes the profile store, and re-applying is idempotent',
      () {
        final store = FamilyProfileStore.instance;
        final parity = onboardingQuestionsFor(
          'pregnancy',
        ).firstWhere((q) => q.id == 'preg_parity');
        parity.apply(store, {'subsequent'});
        expect(store.parity, Parity.subsequent);
        parity.apply(store, {'first'});
        expect(store.parity, Parity.first);

        final pri = onboardingQuestionsFor(
          'pregnancy',
        ).firstWhere((q) => q.id == 'preg_priorities');
        pri.apply(store, {'sleep', 'anxiety'});
        expect(store.pregPriorities, {
          PregPriority.sleep,
          PregPriority.anxiety,
        });
        pri.apply(store, {'sleep', 'anxiety'});
        expect(
          store.pregPriorities,
          {PregPriority.sleep, PregPriority.anxiety},
          reason: 'toggle-based setters must not flip on a second apply',
        );
        pri.apply(store, {'sleep'});
        expect(store.pregPriorities, {PregPriority.sleep});
      },
    );
  });

  group('wiring', () {
    test(
      'the splash pushes OnboardingFlow and no longer pushes AuthFlowScreen directly',
      () {
        final live = _code(_read('lib/screens/splash_screen.dart')).join('\n');
        expect(live.contains('OnboardingFlow('), isTrue);
        expect(
          live.contains('builder: (_) => AuthFlowScreen('),
          isFalse,
          reason: 'the old first run is kept only as a comment',
        );
      },
    );

    test('every stage routes to its own home from the splash', () {
      final live = _code(_read('lib/screens/splash_screen.dart')).join('\n');
      expect(live.contains('_parentingRoute()'), isTrue);
      expect(live.contains('_skillingRoute()'), isTrue);
      expect(live.contains('_ttcRoute()'), isTrue);
      expect(live.contains('_fatherRoute()'), isTrue);
    });

    test('the three homes default to V3', () {
      expect(
        _code(
          _read('lib/screens/today_home_screen.dart'),
        ).join('\n').contains('TodayVersion _v = TodayVersion.v3;'),
        isTrue,
      );
      expect(
        _code(
          _read('lib/screens/post_pregnancy/pp_home_version.dart'),
        ).join('\n').contains('PpHomeVersion _v = PpHomeVersion.v3;'),
        isTrue,
      );
      expect(
        _code(
          _read('lib/screens/ttc/ttc_home_version.dart'),
        ).join('\n').contains('TtcHomeVersion _v = TtcHomeVersion.v3;'),
        isTrue,
      );
    });

    test(
      'the partner and doctor branches reach the old screen on the right branch',
      () {
        final src = _read('lib/screens/auth/onboarding/onboarding_flow.dart');
        expect(src.contains("initialScreen: 'pairCode'"), isTrue);
        expect(
          _read(
            'lib/screens/auth/auth_flow_screen.dart',
          ).contains('late String _screen = widget.initialScreen;'),
          isTrue,
        );
      },
    );

    test('the OTP sheet has six boxes, the pairing code is six characters', () {
      expect(
        _read(
          'lib/screens/auth/onboarding/onboarding_flow.dart',
        ).contains('static const _len = 6;'),
        isTrue,
      );
      final sql = _read(
        'supabase/migrations/0082_onboarding_stage_and_code.sql',
      );
      expect(sql.contains('for i in 1..6 loop'), isTrue);
      expect(
        sql.contains("'trying', 'pregnancy', 'parenting', 'skilling'"),
        isTrue,
        reason: 'life_stage must accept skilling before the flow writes it',
      );
    });

    test(
      'the referral is told, not asked, when it arrived through the install',
      () {
        final src = _read('lib/screens/auth/onboarding/onboarding_flow.dart');
        expect(src.contains('referral.hasRedeemed'), isTrue);
        expect(src.contains("'Have a code?'"), isTrue);
        expect(src.contains('code applied'), isTrue);
      },
    );
  });

  group('the screens render and the sequence holds', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    /// ⚠️ THE DEFAULT TEST SURFACE IS 800x600 AND THAT IS NOT A PHONE.
    /// These screens are a 340pt illustration band over a scrolling body, so
    /// in a 600pt-tall window the body's viewport is a sliver and `ListView`
    /// — which builds lazily — never constructs the title, let alone the
    /// buttons below it. The first run of this suite "failed" on a welcome
    /// screen that renders perfectly on the device.
    ///
    /// Sizing every walk to a real phone is the fix, and it is worth more
    /// than the one assertion it repaired: a test that lays out at 600pt
    /// cannot see an overflow, a clipped line or a control pushed off the
    /// bottom on any device anybody owns.
    void phone(WidgetTester t) {
      t.view.physicalSize = const Size(1170, 2532);
      t.view.devicePixelRatio = 3.0;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
    }

    Widget app() => MaterialApp(
      home: OnboardingFlow(
        pregnancy: PregnancyController(now: DateTime(2026, 9, 17)),
        onDone: (_, _) {},
      ),
    );

    testWidgets('pregnant path: who → stage → name → beat → date', (t) async {
      phone(t);
      // ⚠️ REWRITTEN FOR THE V2 ORDER, 2026-09-22. This used to start at
      // `ObStep.hello` — the screen that showed back the name Google gave us
      // — because sign-in was the FIRST step and a widget test cannot run
      // Google. With the account moved to the end there is nothing to skip
      // past, so the walk starts at the top and the name is typed.
      await t.pumpWidget(
        MaterialApp(
          home: OnboardingFlow(
            pregnancy: PregnancyController(now: DateTime(2026, 9, 17)),
            onDone: (_, _) {},
            startAt: ObStep.who,
            startName: 'Priya Menon',
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Which of you is this?'), findsOneWidget);
      await t.tap(find.text('Mother'));
      await t.pumpAndSettle();
      expect(find.text('Where are you right now?'), findsOneWidget);
      await t.tap(find.text('Pregnant'));
      await t.pumpAndSettle();
      // ⚠️ THE STEP THAT WAS UNREACHABLE. The stage card went straight to the
      // date after the reorder, so `name` and its beat were built and never
      // rendered. This is the assertion that would have caught it.
      expect(find.text('What should we call you?'), findsOneWidget);
      await t.tap(find.text('Continue'));
      await t.pumpAndSettle();
      expect(
        find.textContaining('Priya'),
        findsWidgets,
        reason: 'the beat greets her by the name she gave',
      );
      await t.tap(find.text('Continue'));
      await t.pumpAndSettle();
      expect(find.text('When is the baby due?'), findsOneWidget);
      // The chips are the point: a clinic-owned date is recorded as such.
      expect(find.text("Doctor's date"), findsOneWidget);
      expect(find.text('IVF transfer'), findsOneWidget);
      // Continue is disabled until a date is chosen — no way past it blank.
      await t.tap(find.text('Continue'));
      await t.pumpAndSettle();
      expect(find.text('When is the baby due?'), findsOneWidget);
    });

    testWidgets(
      'trying path: stage → questions → reach, with no date and no reveal',
      (t) async {
        phone(t);
        await t.pumpWidget(
          MaterialApp(
            home: OnboardingFlow(
              pregnancy: PregnancyController(now: DateTime(2026, 9, 17)),
              onDone: (_, _) {},
              startAt: ObStep.stage,
              startName: 'Priya',
            ),
          ),
        );
        await t.pumpAndSettle();
        await t.tap(find.text('Trying to conceive'));
        await t.pumpAndSettle();
        // Name, then its beat, then the questions — trying has no date step.
        expect(find.text('What should we call you?'), findsOneWidget);
        await t.tap(find.text('Continue'));
        await t.pumpAndSettle();
        await t.tap(find.text('Continue'));
        await t.pumpAndSettle();
        expect(find.text('How long have you been trying?'), findsOneWidget);
        // ⚠️ THE BAR, AND ONLY HERE. `onboarding_chrome` narrowed the old "no
        // progress bar anywhere" rule to allow one over the question run —
        // named with the stage, which is the half that makes it a subject
        // rather than a chore. Both halves are asserted so neither can be
        // quietly dropped.
        expect(find.text('ABOUT WHERE YOU ARE'), findsOneWidget);
        expect(find.text('1 of 3'), findsOneWidget);
        // Choosing an answer reveals the give-back before any Continue.
        await t.tap(find.text('Just starting'));
        await t.pumpAndSettle();
        expect(find.text('GOOD TO KNOW'), findsOneWidget);
        expect(find.textContaining('within a year'), findsOneWidget);
        await t.tap(find.text('Continue'));
        await t.pumpAndSettle();
        expect(find.text('Are your cycles fairly regular?'), findsOneWidget);
        // Skip is always there.
        await t.tap(find.text('Skip'));
        await t.pumpAndSettle();
        // ⚠️ THE BEAT LANDS HERE, AND SKIPPING DOES NOT SKIP IT. It is not a
        // question — it is the app saying what it will never do — so it sits
        // between question two and question three whichever way she leaves
        // two, by answering or by skipping. Asserted rather than tapped
        // past, because a promise the flow can route around is not one.
        expect(find.text('What we will never do.'), findsOneWidget);
        await t.tap(find.text('Good'));
        await t.pumpAndSettle();
        await t.tap(find.text('Skip'));
        await t.pumpAndSettle();
        // Building runs on timers; let them all fire.
        await t.pump(const Duration(seconds: 3));
        await t.pumpAndSettle();
        // ⚠️ THE ACCOUNT COMES LAST NOW, and trying still has no reveal —
        // there is no week to show and nothing honest to compute.
        expect(find.textContaining('Keep all of this'), findsOneWidget);
        expect(find.text('Continue with Google'), findsOneWidget);
      },
    );

    testWidgets('parent path: baby screen needs a birthday, name is optional', (
      t,
    ) async {
      phone(t);
      await t.pumpWidget(
        MaterialApp(
          home: OnboardingFlow(
            pregnancy: PregnancyController(now: DateTime(2026, 9, 17)),
            onDone: (_, _) {},
            startAt: ObStep.stage,
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.text('Parent — 0 to 5'));
      await t.pumpAndSettle();
      await t.tap(find.text('Continue')); // name
      await t.pumpAndSettle();
      await t.tap(find.text('Continue')); // the beat
      await t.pumpAndSettle();
      expect(find.text('Tell us about your baby.'), findsOneWidget);
      expect(find.text("Baby's name — optional".toUpperCase()), findsOneWidget);
      expect(find.text('BIRTHDAY'), findsOneWidget);
      expect(find.text('Boy'), findsOneWidget);
    });

    testWidgets('welcome asks nobody to sign in', (t) async {
      phone(t);
      // ⚠️ THE WHOLE POINT OF THE V2 ORDER, AS A TEST. Every question-led
      // onboarding read on Mobbin asks first and signs up last; ours opened
      // on Google. If sign-in ever creeps back to the front this fails, and
      // it should.
      await t.pumpWidget(app());
      await t.pumpAndSettle();
      expect(find.text('Continue with Google'), findsNothing);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
      // 2026-09-30: no doctor path in the parent app. Kept for revert:
      // expect(find.text("I'm a doctor"), findsOneWidget);
      expect(find.text("I'm a doctor"), findsNothing);
      expect(find.text('Have a code?'), findsOneWidget);
      expect(
        find.text('For the whole journey — trying, expecting, raising.'),
        findsOneWidget,
      );
      // No progress indicator anywhere on the first screen.
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
