// =============================================================================
//  The family switch: "Aarav ▾" in the centre of every home's header
//  (2026-10-25, STAGE-TRANSITIONS "Switching profiles", phase 1)
// -----------------------------------------------------------------------------
//  Each pregnancy and each child is its own profile; the open one picks the
//  home. One profile draws the date alone, as before. The header is the same
//  three slots on all four homes: avatar and Talk, the switch over the date,
//  Messages and Calendar (the learning space: Saved, no Calendar yet).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/v2/pv_family_switch.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/services/life_stage_store.dart';

Child _kid(String id, String name, DateTime dob) => Child(
    id: id, name: name, isBoy: true, dob: dob, weightKg: 0, heightCm: 0, headCm: 0);

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  final now = DateTime(2026, 10, 25);

  group('family switch: who is in the family', () {
    test('a pregnancy with an older child: the pregnancy first, then the child', () {
      final all = familyProfilesFrom(
        stage: LifeStage.pregnancy,
        pregnancyEnded: false,
        pregnancyWeek: 9,
        children: [_kid('c1', 'Aarav', DateTime(2026, 3, 10))],
        skillingName: '',
        now: now,
      );
      expect(all.map((x) => x.name), ['Baby-to-be', 'Aarav']);
      expect(all.first.line, 'Week 9 · Pregnancy');
      expect(all.last.home, FamilyHome.parenting);
      expect(all.last.line, '7 months · Parenting');
    });

    test('a pregnancy that ended is not offered', () {
      final all = familyProfilesFrom(
        stage: LifeStage.pregnancy,
        pregnancyEnded: true,
        pregnancyWeek: 12,
        children: [_kid('c1', 'Aarav', DateTime(2026, 3, 10))],
        skillingName: '',
        now: now,
      );
      expect(all.map((x) => x.id), ['c1']);
    });

    test('a child of 6 or more opens the learning space', () {
      final all = familyProfilesFrom(
        stage: LifeStage.parenting,
        pregnancyEnded: false,
        pregnancyWeek: null,
        children: [_kid('c1', 'Myra', DateTime(2020, 5, 1)), _kid('c2', 'Aarav', DateTime(2026, 3, 10))],
        skillingName: '',
        now: now,
      );
      expect(all.first.home, FamilyHome.learning);
      expect(all.first.line, '6 years · Learning space');
      expect(all.last.home, FamilyHome.parenting);
    });

    test('the parenting stage never lists a pregnancy (phase 1 cannot tell one is ongoing)', () {
      final all = familyProfilesFrom(
        stage: LifeStage.parenting,
        pregnancyEnded: false,
        pregnancyWeek: 40,
        children: [_kid('c1', 'Aarav', DateTime(2026, 3, 10))],
        skillingName: '',
        now: now,
      );
      expect(all.where((x) => x.kind == FamilyProfileKind.pregnancy), isEmpty);
    });

    test('trying with a child: her trying, then the child', () {
      final all = familyProfilesFrom(
        stage: LifeStage.tryingToConceive,
        pregnancyEnded: false,
        pregnancyWeek: null,
        children: [_kid('c1', 'Aarav', DateTime(2024, 1, 10))],
        skillingName: '',
        now: now,
      );
      expect(all.map((x) => x.home), [FamilyHome.trying, FamilyHome.parenting]);
      expect(all.last.line, '2 years · Parenting');
    });

    test('the open profile on Parenting is the active child', () {
      final all = familyProfilesFrom(
        stage: LifeStage.parenting,
        pregnancyEnded: false,
        pregnancyWeek: null,
        children: [_kid('c1', 'Aarav', DateTime(2026, 3, 10)), _kid('c2', 'Kiara', DateTime(2026, 9, 1))],
        skillingName: '',
        now: now,
      );
      expect(openProfileIn(all, FamilyHome.parenting, 'c2')?.name, 'Kiara');
      expect(openProfileIn(all, FamilyHome.parenting, 'gone')?.name, 'Aarav');
    });

    test('ages read the way a parent says them', () {
      expect(familyAgeWords(DateTime(2026, 10, 20), now), 'Newborn');
      expect(familyAgeWords(DateTime(2026, 9, 20), now), '5 weeks');
      expect(familyAgeWords(DateTime(2026, 3, 10), now), '7 months');
      expect(familyAgeWords(DateTime(2023, 10, 1), now), '3 years');
    });
  });

  group('family switch: the header centre', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      ChildProfileStore.instance.resetForTest();
      LifeStageStore.instance.resetForTest();
      LifeStageStore.instance.setStage(LifeStage.parenting);
    });

    Widget host() => MaterialApp(
        home: Scaffold(
            body: Center(
                child: PvFamilyTitle(
          p: V2PaletteStore.instance.current,
          here: FamilyHome.parenting,
          dateText: '25 October',
          date: const Text('25 October', key: ValueKey('the_date')),
        ))));

    testWidgets('one profile: the date alone, exactly as before', (t) async {
      await ChildProfileStore.instance.addChild(name: 'Aarav', isBoy: true, dob: DateTime(2026, 3, 10));
      await t.pumpWidget(host());
      expect(find.byKey(const ValueKey('the_date')), findsOneWidget);
      expect(find.byKey(const ValueKey('pv_family_switch')), findsNothing);
    });

    testWidgets('two children: the name over the date, the sheet, and the switch', (t) async {
      final store = ChildProfileStore.instance;
      final a = await store.addChild(name: 'Aarav', isBoy: true, dob: DateTime(2026, 3, 10));
      // Ids are child_<microseconds>; two adds in one microsecond would share
      // one, which only a test is fast enough to do.
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2)));
      final b = await store.addChild(name: 'Kiara', isBoy: false, dob: DateTime(2026, 9, 1));
      await store.switchTo(a.id);
      await t.pumpWidget(host());
      expect(find.byKey(const ValueKey('pv_family_switch')), findsOneWidget);
      expect(find.text('Aarav'), findsOneWidget);
      expect(find.byKey(const ValueKey('pv_family_switch_date')), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('pv_family_switch')));
      await t.pumpAndSettle();
      expect(find.text('Your family'), findsOneWidget);
      expect(find.byKey(const ValueKey('pv_family_switch_add_child')), findsOneWidget);
      await t.tap(find.byKey(ValueKey('pv_family_switch_${b.id}')));
      await t.pumpAndSettle();
      expect(store.active.id, b.id);
      expect(find.text('Kiara'), findsOneWidget);
    });
  });

  group('family switch: one header on every home', () {
    test('every home puts the switch in its header centre', () {
      for (final (path, home) in [
        ('lib/screens/ttc/ttc_home_v3.dart', 'FamilyHome.trying'),
        ('lib/screens/v2/v3_preg_hero.dart', 'FamilyHome.pregnancy'),
        ('lib/screens/post_pregnancy/pp_home_v3.dart', 'FamilyHome.parenting'),
        ('lib/screens/skilling/skilling_preview_screen.dart', 'FamilyHome.learning'),
      ]) {
        final code = _code(path);
        expect(code, contains('PvFamilyTitle('), reason: path);
        expect(code, contains('here: $home'), reason: path);
      }
    });

    test('Parenting: Messages and Calendar on the right, Saved moved to You', () {
      final code = _code('lib/screens/post_pregnancy/pp_home_v3.dart');
      expect(code, contains("ValueKey('pp_hero_messages')"));
      expect(code, contains("ValueKey('pp_hero_calendar')"));
      expect(code, contains('onMessages: () => openPpMessages(context)'));
      // The child's own calendar since F7 (2026-10-25); the vaccines were the
      // stand-in until it existed.
      expect(code, contains('onCalendar: () => openPpChildCalendar(context)'));
      // The child switch under the age would be a second control for one thing.
      final painted = code.substring(code.indexOf('class _PaintedHero'));
      expect(painted, isNot(contains('PpChildSwitch(p: p)')));
    });

    test('the learning space: avatar, Talk, the switch, Saved; no Calendar yet', () {
      final code = _code('lib/screens/skilling/skilling_preview_screen.dart');
      final hero = code.substring(code.indexOf('class _Hero'), code.indexOf('class _SkRound'));
      expect(hero, contains("semantic: 'Profile'"));
      expect(hero, contains('openPvYou(context, stage: LifeStage.skilling)'));
      expect(hero, contains("semantic: 'Talk to an expert'"));
      expect(hero, contains("semantic: 'Saved'"));
      expect(hero, isNot(contains("semantic: 'Calendar'")));
    });

    test('switching never changes the stage', () {
      expect(_code('lib/screens/v2/pv_family_switch.dart'), isNot(contains('setStage(')));
    });
  });
}
