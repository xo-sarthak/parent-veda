// Three small items from the pregnancy gap analysis (2026-09-30):
//   · "Movement counting" (P3): teach when and why to know the pattern
//   · "A medical note on every page" (P3): the home had none
//   · "Talk to experts, with named people" (P2): a block on the home, roles only
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/screens/home_v3_screen.dart';
import 'package:parentveda/screens/learn/pv_learn_catalog.dart';
import 'package:parentveda/screens/tools/baby_movement_screen.dart';
import 'package:parentveda/services/home_content_controller.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PregnancyController pregnancy;
  late HomeContentController home;

  setUpAll(() async {
    final n = DateTime.now();
    final due = DateTime(n.year, n.month, n.day).add(const Duration(days: 144));
    SharedPreferences.setMockInitialValues({PregnancyController.kDueDateKey: due.toIso8601String()});
    pregnancy = PregnancyController(dueDate: due);
    await pregnancy.load();
    home = HomeContentController();
    await home.load();
  });

  group('knowing the pattern', () {
    test('it links two reads that already exist, and says nothing new clinically', () {
      for (final id in ['${kPregWeekReadPrefix}movement_awareness', 'preg_cond_read_less_movement']) {
        expect(pregnancyReadById(id), isNotNull, reason: id);
      }
      final s = _code('lib/screens/tools/baby_movement_screen.dart');
      expect(s, contains(r"'${kPregWeekReadPrefix}movement_awareness'"));
      expect(s, contains('preg_cond_read_less_movement'));
      expect(s, contains('You do not need to count unless your doctor asks you to.'));
    });

    testWidgets('shows on the tracker beside the records row', (t) async {
      t.view.physicalSize = const Size(360, 2000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(home: BabyMovementScreen(controller: pregnancy)));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text("Knowing your baby's pattern"), findsOneWidget);
      expect(find.byKey(const ValueKey('movement_read_awareness')), findsOneWidget);
      expect(find.byKey(const ValueKey('movement_read_less')), findsOneWidget);
      expect(find.byKey(const ValueKey('movement_records_row')), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('the home', () {
    Future<void> pumpHome(WidgetTester t, {double width = 360}) async {
      t.view.physicalSize = Size(width, 4200);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(home: Scaffold(body: HomeV3Screen(pregnancy: pregnancy, home: home))));
      await t.pump(const Duration(milliseconds: 500));
      final tip = find.byWidgetPredicate((w) => w is Dialog || w is AlertDialog);
      if (tip.evaluate().isNotEmpty) {
        await t.tapAt(const Offset(5, 5));
        await t.pump(const Duration(milliseconds: 300));
      }
    }

    testWidgets('ends with the same medical note every door ends with', (t) async {
      await pumpHome(t);
      final note = find.byKey(const ValueKey('preg_home_medical_note'), skipOffstage: false);
      expect(note, findsOneWidget);
      expect(find.textContaining('This is general information, not medical advice', skipOffstage: false), findsOneWidget);
      expect(find.textContaining('if anything here disagrees with them, they are right', skipOffstage: false),
          findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('Talk to someone lists four roles, no names, and opens the consults', (t) async {
      await pumpHome(t);
      expect(find.text('Talk to someone', skipOffstage: false), findsOneWidget);
      for (final r in kPregHomeExpertRoles) {
        expect(find.byKey(ValueKey('preg_home_expert_${r.id}'), skipOffstage: false), findsOneWidget, reason: r.id);
      }
      expect(kPregHomeExpertRoles.map((r) => r.title),
          ['Obstetrician', 'Nutritionist', 'Counsellor', 'Lactation consultant']);
      // Roles only: nobody is named on the home (the roster lives behind the tap).
      for (final r in kPregHomeExpertRoles) {
        expect(r.title + r.line, isNot(contains('Dr')), reason: 'a name on the home: ${r.title}');
      }
      expect(find.byKey(const ValueKey('preg_home_expert_all'), skipOffstage: false), findsOneWidget);
    });

    test('every role is a specialist the consult catalogue knows', () {
      for (final r in kPregHomeExpertRoles) {
        expect(PvLearnCatalog.instance.byId(r.id), isNotNull, reason: '${r.id} is not in the catalogue');
      }
      final s = _code('lib/screens/home_v3_screen.dart');
      expect(s, contains('ConsultationsScreen(lang: pregnancy.language, onlyRole: r.id)'));
    });
  });
}
