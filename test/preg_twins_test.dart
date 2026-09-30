// "Twins or more" (2026-09-30, gap analysis P2, "Make the twins promise true"):
// one answer, set in You › Details or the hospital bag, read by the hero, the
// week page and Learn.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pv_door_twins.dart';
import 'package:parentveda/screens/pregnancy/preg_learn_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_twins.dart';
import 'package:parentveda/services/family_profile.dart';
import 'package:parentveda/services/ready_birth_context_store.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ReadyBirthContextStore.instance.setTwins(false);
  });

  test('one answer: the sheet, the bag and the profile engine read the same value', () async {
    expect(pregExpectingTwins, isFalse);
    await ReadyBirthContextStore.instance.setTwins(true);
    expect(pregExpectingTwins, isTrue);
    expect(FamilyProfileStore.instance.expectingTwins, isTrue, reason: 'the engine already read it');
    expect(pregTwinsValue(), 'Twins or more');
    await ReadyBirthContextStore.instance.setTwins(false);
    expect(pregTwinsValue(), 'One baby');
  });

  test('the words change only for twins', () async {
    expect(pregBabies(), 'baby');
    expect(pregSizeLineFor('About the size of a banana'), 'About the size of a banana');
    await ReadyBirthContextStore.instance.setTwins(true);
    expect(pregBabies(), 'babies');
    expect(pregBabies(capital: true), 'Babies');
    expect(pregSizeLineFor('About the size of a banana'), 'Each about the size of a banana');
    expect(pregSizeLineFor('A banana'), 'A banana', reason: 'a line in another shape is left alone');
  });

  test('the twin note says nothing about a chance, a sex or a due date', () {
    final n = kPregTwinWeekNote.toLowerCase();
    for (final banned in ['chance', 'boy', 'girl', 'due date', 'recalculate', 'risk']) {
      expect(n, isNot(contains(banned)), reason: banned);
    }
    expect(n, contains('your scans'));
  });

  testWidgets('the sheet sets it and offers no way to touch the due date', (t) async {
    t.view.physicalSize = const Size(360, 800);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      home: Builder(
        builder: (c) => Scaffold(
          body: Center(child: TextButton(onPressed: () => showPregTwinsSheet(c), child: const Text('open'))),
        ),
      ),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('Carrying more than one?'), findsOneWidget);
    expect(find.textContaining('Your due date stays as your doctor or your scan gave it'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('twins_more')));
    await t.pumpAndSettle();
    expect(ReadyBirthContextStore.instance.twins, isTrue);
    await t.tap(find.byKey(const ValueKey('twins_one')));
    await t.pumpAndSettle();
    expect(ReadyBirthContextStore.instance.twins, isFalse);
    expect(t.takeException(), isNull);
  });

  test('Learn: Twins and more leads when it is on, and nothing is hidden', () {
    final all = pregLearnTopics().map((t) => t.bracket.id).toList();
    expect(all, contains(kPregTwinsBracket.id));
    final src = _code('lib/screens/pregnancy/preg_learn_screen.dart');
    expect(src, contains('pregExpectingTwins'));
    expect(src, contains('ReadyBirthContextStore.instance'), reason: 'Learn must rebuild when it changes');
  });

  test('it is reachable and everything that reads it listens', () {
    expect(_code('lib/screens/profile/pv_you_content.dart'), contains("label: 'Twins or more'"));
    expect(_code('lib/screens/profile/pv_you_content.dart'), contains('showPregTwinsSheet('));
    expect(_code('lib/screens/profile/pv_you_screen.dart'), contains('ReadyBirthContextStore.instance'));
    expect(_code('lib/screens/home_v3_screen.dart'), contains('pregSizeLineFor('));
    expect(_code('lib/screens/home_v3_screen.dart'), contains('ReadyBirthContextStore.instance'));
    expect(_code('lib/screens/preg_week_screen.dart'), contains('pregBabies()'));
    expect(_code('lib/main.dart'), contains('ReadyBirthContextStore.instance.init()'),
        reason: 'else a cold start forgets twins until the hospital bag opens');
    // Nothing here may recalculate her due date.
    expect(_code('lib/screens/pregnancy/preg_twins.dart'), isNot(contains('setDueDate')));
  });
}
