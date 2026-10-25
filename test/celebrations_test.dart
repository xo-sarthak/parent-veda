// =============================================================================
//  The celebration pages (2026-10-25, STAGE-TRANSITIONS F4 and F5)
// -----------------------------------------------------------------------------
//  Calm: a painting, the name, one line, what changes and what stays, one ink
//  button. The positive test keeps its own page (the user, 2026-10-25). The
//  birth page follows "Baby has arrived" from all three places it is said.
//  Turning six asks the parent, rests 7, 14 then 30 days on "Not now", and
//  keeps the child's home Parenting until a grown-up says yes.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/skilling/sk_child_store.dart';
import 'package:parentveda/screens/skilling/sk_turning_six.dart';
import 'package:parentveda/screens/v2/pv_celebration.dart';
import 'package:parentveda/screens/v2/pv_family_switch.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pp_messages_store.dart';

Child _kid(String id, String name, DateTime dob, {bool boy = false, bool sexGiven = true}) => Child(
    id: id, name: name, isBoy: boy, sexGiven: sexGiven, dob: dob, weightKg: 0, heightCm: 0, headCm: 0);

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  final now = DateTime(2026, 10, 25, 10);

  group('F4: the birth page', () {
    test('her name, the day, and what stays', () {
      final w = birthCelebrationWords(name: 'Kiara', dob: DateTime(2026, 10, 25));
      expect(w.title, 'Welcome, Kiara');
      expect(w.line, 'Born 25 October. Rest when you can; the rest can wait.');
      expect(w.changes, contains('Your pregnancy is kept: photos, letters, journal'));
      expect(w.primary, "Open Kiara's home");
    });

    test('no name yet: "little one", never "Your baby" as a name', () {
      final w = birthCelebrationWords(name: Child.placeholder, dob: DateTime(2026, 10, 25));
      expect(w.title, 'Welcome, little one');
      expect(w.primary, "Open your baby's home");
    });

    test('an older child is named as kept', () {
      expect(birthCelebrationWords(name: 'Kiara', dob: now, olderNames: ['Aarav']).changes,
          contains("Aarav's home stays exactly as it is"));
      expect(birthCelebrationWords(name: 'Kiara', dob: now, olderNames: ['Aarav', 'Myra']).changes,
          contains("Your other children's homes stay exactly as they are"));
    });

    testWidgets('the page: title, ticks, one ink button that does its one thing', (t) async {
      var done = false;
      await t.pumpWidget(MaterialApp(
          home: PvCelebrationScreen(
        painting: const ColoredBox(color: Colors.white),
        title: 'Welcome, Kiara',
        line: 'Born 25 October.',
        changes: const ['One', 'Two', 'Three'],
        primary: "Open Kiara's home",
        onPrimary: (_) => done = true,
      )));
      expect(find.byKey(const ValueKey('pv_celebration_title')), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));
      expect(find.byKey(const ValueKey('pv_celebration_secondary')), findsNothing);
      // The page scrolls on a short window; the button is at its foot.
      await t.ensureVisible(find.byKey(const ValueKey('pv_celebration_primary')));
      await t.pump();
      await t.tap(find.byKey(const ValueKey('pv_celebration_primary')));
      expect(done, isTrue);
    });

    testWidgets('it fits a 360pt phone at large text', (t) async {
      t.view.physicalSize = const Size(1080, 1920);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
          home: MediaQuery(
        data: const MediaQueryData(size: Size(360, 640), textScaler: TextScaler.linear(1.5)),
        child: PvCelebrationScreen(
          painting: const ColoredBox(color: Colors.white),
          title: 'Welcome, Kiara',
          line: 'Born 25 October. Rest when you can; the rest can wait.',
          changes: const ['Kiara has a home and records of their own now', 'Your pregnancy is kept: photos, letters, journal', "Aarav's home stays exactly as it is"],
          primary: "Open Kiara's home",
          onPrimary: (_) {},
          secondary: 'Not now',
        ),
      )));
      expect(t.takeException(), isNull);
    });

    test('every "Baby has arrived" goes through the birth page', () {
      for (final path in [
        'lib/screens/profile/pv_you_content.dart',
        'lib/screens/pregnancy/preg_hero_extras.dart',
        'lib/screens/pregnancy/preg_messages_screen.dart',
      ]) {
        expect(_code(path), contains('await openBirthCelebration('), reason: path);
      }
    });

    test('the positive test keeps its own page (the user, 2026-10-25)', () {
      expect(_code('lib/screens/ttc/ttc_strings.dart'), contains("'A beautiful new chapter begins'"));
    });
  });

  group('F4/F5: turning six', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      SkChildStore.instance.debugReset();
      SkTurningSixPrompt.instance.resetForTest();
    });

    test('Not now rests 7 days, then 14, then 30, and 30 after', () {
      expect(skTurningSixRest(1).inDays, 7);
      expect(skTurningSixRest(2).inDays, 14);
      expect(skTurningSixRest(3).inDays, 30);
      expect(skTurningSixRest(9).inDays, 30);
    });

    test('from the sixth birthday, until a grown-up says yes, and never daily', () async {
      final prompt = SkTurningSixPrompt.instance;
      final five = _kid('c5', 'Aarav', DateTime(2021, 3, 1), boy: true);
      final six = _kid('c6', 'Myra', DateTime(2020, 10, 25));
      expect(prompt.showsFor(five, now: now), isFalse);
      expect(prompt.showsFor(six, now: now), isTrue);
      await prompt.notNow(six, now: now);
      expect(prompt.showsFor(six, now: now.add(const Duration(days: 6))), isFalse);
      expect(prompt.showsFor(six, now: now.add(const Duration(days: 7))), isTrue, reason: 'it comes back');
      await prompt.notNow(six, now: now.add(const Duration(days: 7)));
      expect(prompt.showsFor(six, now: now.add(const Duration(days: 20))), isFalse);
      expect(prompt.showsFor(six, now: now.add(const Duration(days: 21))), isTrue);
      // Her own yes (F5): the space is keyed by her id.
      SkChildStore.instance.debugSetAgeYears(6, name: 'Myra', childId: 'c6');
      expect(prompt.showsFor(six, now: now.add(const Duration(days: 60))), isFalse,
          reason: 'the space is open');
    });

    test('the words: her pronouns, her age today, and the younger one kept', () {
      final myra = _kid('c6', 'Myra', DateTime(2020, 10, 25));
      final w = turningSixWords(myra, youngerNames: ['Aarav']);
      expect(w.title, 'Myra is six');
      expect(w.line, 'She is ready for a space of her own, to learn, make and play.');
      expect(w.changes, ['A grown-up says yes first, once', "Everything in it is for Myra's age today", 'Aarav keeps the Parenting home']);
      expect(w.primary, 'Set up her space');
      final rumi = _kid('c7', 'Rumi', DateTime(2020, 1, 1), sexGiven: false);
      expect(turningSixWords(rumi).primary, "Set up Rumi's space");
      expect(turningSixWords(rumi).changes.last, "Rumi's baby years stay in the parenting records");
    });

    test('the family switch keeps a six-year-old on Parenting until the space is open', () {
      List<FamilyProfile> fam(bool open) => familyProfilesFrom(
            stage: LifeStage.parenting,
            pregnancyEnded: false,
            pregnancyWeek: null,
            children: [_kid('c6', 'Myra', DateTime(2020, 5, 1))],
            skillingName: '',
            now: now,
            learningOpen: open,
          );
      expect(fam(false).single.home, FamilyHome.parenting);
      expect(fam(false).single.line, '6 years · Parenting · learning space ready');
      expect(fam(true).single.home, FamilyHome.learning);
      // Per child since F5 (2026-10-25); was
      // contains('learningOpen: SkChildStore.instance.consented').
      expect(_code('lib/screens/v2/pv_family_switch.dart'), contains('learningOpenIds: SkChildStore.instance.consentedIds'));
    });

    test('the sixth birthday message says the space is ready', () {
      final ms = ppMessageCandidates(
          PpMessageFacts(dob: DateTime(2020, 10, 27), name: 'Myra', realChild: true), DateTime(2026, 10, 25));
      final m = ms.firstWhere((m) => m.id == 'age:m72');
      expect(m.title, 'Myra is 6 years today');
      expect(m.body, "Myra's learning space is ready, whenever you are.");
    });

    testWidgets('the card on her parenting home, and Not now puts it away', (t) async {
      final store = ChildProfileStore.instance..resetForTest();
      await t.runAsync(() async {
        await store.addChild(name: 'Myra', isBoy: false, dob: DateTime.now().subtract(const Duration(days: 6 * 366)));
      });
      await t.pumpWidget(MaterialApp(home: Scaffold(body: PpLearningSpaceCard(p: V2PaletteStore.instance.current))));
      await t.pump();
      expect(find.byKey(const ValueKey('pp_learning_space_card')), findsOneWidget);
      expect(find.text("Myra's learning space is ready"), findsOneWidget);
      expect(find.textContaining('You decide when she sees it.'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('pp_learning_space_not_now')));
      await t.pump();
      expect(find.byKey(const ValueKey('pp_learning_space_card')), findsNothing);
    });

    test('the card sits on the parenting home', () {
      expect(_code('lib/screens/post_pregnancy/pp_home_v3.dart'), contains('PpLearningSpaceCard(p: p)'));
    });
  });
}
