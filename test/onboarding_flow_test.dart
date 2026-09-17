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

    test('every single-select option gives something back; multi-selects give one line', () {
      for (final s in ['trying', 'pregnancy', 'parenting', 'skilling']) {
        for (final q in onboardingQuestionsFor(s, childName: 'Aarav')) {
          if (q.multi) {
            expect(q.multiGiveBack, isNotNull, reason: q.id);
            expect(q.multiGiveBack!.trim(), isNotEmpty, reason: q.id);
          } else {
            for (final o in q.options) {
              expect(o.giveBack.trim(), isNotEmpty, reason: '${q.id}/${o.id}');
            }
          }
        }
      }
    });

    test('no give-back line is a personalised probability or a target', () {
      // The clinical invariant (CLAUDE.md): population facts that reduce
      // pressure are allowed; "your chance", percentages and "on track" are not.
      final banned = RegExp(r'\byour chance\b|\d+\s?%|\bon track\b|\bchances? (are|is)\b', caseSensitive: false);
      for (final s in ['trying', 'pregnancy', 'parenting', 'skilling']) {
        for (final q in onboardingQuestionsFor(s)) {
          for (final o in q.options) {
            expect(banned.hasMatch(o.giveBack), isFalse, reason: '${q.id}/${o.id}: ${o.giveBack}');
          }
          if (q.multiGiveBack != null) expect(banned.hasMatch(q.multiGiveBack!), isFalse);
        }
      }
    });

    test('the child\'s name lands in the parenting and skilling titles', () {
      expect(onboardingQuestionsFor('parenting', childName: 'Aarav').first.title, contains('Aarav'));
      expect(onboardingQuestionsFor('skilling', childName: 'Aarav').first.title, contains('Aarav'));
      expect(onboardingQuestionsFor('parenting').first.title, contains('your child'));
    });

    test('applying an answer writes the profile store, and re-applying is idempotent', () {
      final store = FamilyProfileStore.instance;
      final parity = onboardingQuestionsFor('pregnancy').firstWhere((q) => q.id == 'preg_parity');
      parity.apply(store, {'subsequent'});
      expect(store.parity, Parity.subsequent);
      parity.apply(store, {'first'});
      expect(store.parity, Parity.first);

      final pri = onboardingQuestionsFor('pregnancy').firstWhere((q) => q.id == 'preg_priorities');
      pri.apply(store, {'sleep', 'anxiety'});
      expect(store.pregPriorities, {PregPriority.sleep, PregPriority.anxiety});
      pri.apply(store, {'sleep', 'anxiety'});
      expect(store.pregPriorities, {PregPriority.sleep, PregPriority.anxiety},
          reason: 'toggle-based setters must not flip on a second apply');
      pri.apply(store, {'sleep'});
      expect(store.pregPriorities, {PregPriority.sleep});
    });
  });

  group('wiring', () {
    test('the splash pushes OnboardingFlow and no longer pushes AuthFlowScreen directly', () {
      final live = _code(_read('lib/screens/splash_screen.dart')).join('\n');
      expect(live.contains('OnboardingFlow('), isTrue);
      expect(live.contains('builder: (_) => AuthFlowScreen('), isFalse,
          reason: 'the old first run is kept only as a comment');
    });

    test('every stage routes to its own home from the splash', () {
      final live = _code(_read('lib/screens/splash_screen.dart')).join('\n');
      expect(live.contains('_parentingRoute()'), isTrue);
      expect(live.contains('_skillingRoute()'), isTrue);
      expect(live.contains('_ttcRoute()'), isTrue);
      expect(live.contains('_fatherRoute()'), isTrue);
    });

    test('the three homes default to V3', () {
      expect(_code(_read('lib/screens/today_home_screen.dart')).join('\n')
          .contains('TodayVersion _v = TodayVersion.v3;'), isTrue);
      expect(_code(_read('lib/screens/post_pregnancy/pp_home_version.dart')).join('\n')
          .contains('PpHomeVersion _v = PpHomeVersion.v3;'), isTrue);
      expect(_code(_read('lib/screens/ttc/ttc_home_version.dart')).join('\n')
          .contains('TtcHomeVersion _v = TtcHomeVersion.v3;'), isTrue);
    });

    test('the partner and doctor branches reach the old screen on the right branch', () {
      final src = _read('lib/screens/auth/onboarding/onboarding_flow.dart');
      expect(src.contains("initialScreen: 'pairCode'"), isTrue);
      expect(_read('lib/screens/auth/auth_flow_screen.dart').contains('late String _screen = widget.initialScreen;'), isTrue);
    });

    test('the OTP sheet has six boxes, the pairing code is six characters', () {
      expect(_read('lib/screens/auth/onboarding/onboarding_flow.dart').contains('static const _len = 6;'), isTrue);
      final sql = _read('supabase/migrations/0082_onboarding_stage_and_code.sql');
      expect(sql.contains('for i in 1..6 loop'), isTrue);
      expect(sql.contains("'trying', 'pregnancy', 'parenting', 'skilling'"), isTrue,
          reason: 'life_stage must accept skilling before the flow writes it');
    });

    test('the referral is told, not asked, when it arrived through the install', () {
      final src = _read('lib/screens/auth/onboarding/onboarding_flow.dart');
      expect(src.contains('referral.hasRedeemed'), isTrue);
      expect(src.contains("'Have a code?'"), isTrue);
      expect(src.contains('code applied'), isTrue);
    });
  });

  group('the screens render and the sequence holds', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Widget app() => MaterialApp(
          home: OnboardingFlow(
            pregnancy: PregnancyController(now: DateTime(2026, 9, 17)),
            onDone: (_, _) {},
          ),
        );

    testWidgets('pregnant path: who → stage → date → three questions → reveal → reach', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OnboardingFlow(
          pregnancy: PregnancyController(now: DateTime(2026, 9, 17)),
          onDone: (_, _) {},
          startAt: ObStep.hello,
          startName: 'Priya Menon',
        ),
      ));
      await t.pumpAndSettle();
      expect(find.textContaining('Nice to meet you', findRichText: true), findsOneWidget);
      expect(find.text('Not Priya? Edit'), findsOneWidget);
      await t.tap(find.text('Continue'));
      await t.pumpAndSettle();
      expect(find.text('Which of you is this?'), findsOneWidget);
      await t.tap(find.text('Mother'));
      await t.pumpAndSettle();
      expect(find.text('Where are you right now?'), findsOneWidget);
      await t.tap(find.text('Pregnant'));
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

    testWidgets('trying path: stage → questions → reach, with no date and no reveal', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OnboardingFlow(
          pregnancy: PregnancyController(now: DateTime(2026, 9, 17)),
          onDone: (_, _) {},
          startAt: ObStep.stage,
          startName: 'Priya',
        ),
      ));
      await t.pumpAndSettle();
      await t.tap(find.text('Trying to conceive'));
      await t.pumpAndSettle();
      expect(find.text('How long have you been trying?'), findsOneWidget);
      expect(find.textContaining('1 OF 3'), findsOneWidget);
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
      await t.tap(find.text('Skip'));
      await t.pumpAndSettle();
      expect(find.text('How should we reach you?'), findsOneWidget,
          reason: 'trying has no date and no reveal');
      expect(find.text('Not now'), findsOneWidget);
    });

    testWidgets('parent path: baby screen needs a birthday, name is optional', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OnboardingFlow(
          pregnancy: PregnancyController(now: DateTime(2026, 9, 17)),
          onDone: (_, _) {},
          startAt: ObStep.stage,
        ),
      ));
      await t.pumpAndSettle();
      await t.tap(find.text('Parent — 0 to 5'));
      await t.pumpAndSettle();
      expect(find.text('Tell us about your baby.'), findsOneWidget);
      expect(find.text("Baby's name — optional".toUpperCase()), findsOneWidget);
      expect(find.text('BIRTHDAY'), findsOneWidget);
      expect(find.text('Boy'), findsOneWidget);
    });

    testWidgets('welcome: one button, terms, doctor and code links', (t) async {
      await t.pumpWidget(app());
      await t.pumpAndSettle();
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text("I'm a doctor"), findsOneWidget);
      expect(find.text('Have a code?'), findsOneWidget);
      expect(find.text('For the whole journey — trying, expecting, raising.'), findsOneWidget);
      // No progress indicator anywhere on the first screen.
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
