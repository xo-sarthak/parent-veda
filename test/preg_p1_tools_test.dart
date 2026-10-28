// =============================================================================
//  P1, Pregnancy look-ups and records (docs/preg-ttc-tool-plans/P1-lookups-records.md)
// -----------------------------------------------------------------------------
//  After a loss (D2), medicines added while trying (D3), the doctor-visit
//  summary's consent (D4), per-scan checklist ticks (D8), and the silent
//  saves that now say what they did. 2026-10-28.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/models/medication.dart';
import 'package:parentveda/models/reminder.dart';
import 'package:parentveda/screens/reminders_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/medicine_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/pregnancy_ended_store.dart';
import 'package:parentveda/services/pv_checklist_store.dart';
import 'package:parentveda/services/reminder_store.dart';

Reminder _r(String id, String category, {String? title}) =>
    Reminder(id: id, title: title ?? id, hour: 9, minute: 0, category: category);

Medication _m(String id, String name) =>
    Medication(id: id, name: name, type: MedType.medication, startDateIso: '');

/// Source without its comment lines, so a kept-for-revert line never passes
/// (or fails) a check on what runs.
String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PregnancyEndedStore.instance.resetForTest();
  });

  group('D2: Reminders after a loss', () {
    late PregnancyController c;
    setUp(() => c = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140))));

    Future<void> pump(WidgetTester t) async {
      t.view.physicalSize = const Size(800, 2400);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(home: RemindersScreen(controller: c)));
      await t.pumpAndSettle();
    }

    testWidgets('before a loss: the baby presets are offered, nothing is paused', (t) async {
      ReminderStore.instance.debugSeed([_r('bag_prep', 'bag', title: 'Pack the bag')]);
      await pump(t);
      expect(find.text('Read to your baby'), findsOneWidget);
      expect(find.text('Take your prenatal vitamin'), findsOneWidget);
      expect(find.byKey(const ValueKey('reminders_paused')), findsNothing);
    });

    testWidgets('after a loss: the paused ones say so and why; the baby presets step aside', (t) async {
      final store = ReminderStore.instance
        ..debugSeed([_r('bag_prep', 'bag', title: 'Pack the bag'), _r('water', 'water', title: 'Water')]);
      store.pauseForLoss();
      await PregnancyEndedStore.instance.markEnded();
      await pump(t);
      expect(find.text('Paused after your loss'), findsOneWidget);
      expect(find.textContaining('come back on if you go back to your pregnancy view'), findsOneWidget);
      expect(find.byKey(const ValueKey('reminder_paused_bag_prep')), findsOneWidget);
      expect(find.text('Water'), findsOneWidget, reason: 'hers stays in the main list');
      expect(find.text('Read to your baby'), findsNothing);
      expect(find.text('Take your prenatal vitamin'), findsNothing);
      expect(find.text('Sip some water'), findsOneWidget, reason: 'the presets that look after her stay');
    });

    testWidgets('the switch says what it did', (t) async {
      ReminderStore.instance.debugSeed([_r('water', 'water', title: 'Water')]);
      await pump(t);
      await t.tap(find.byType(Switch).first);
      await t.pump();
      expect(find.textContaining('Off: Water'), findsOneWidget);
    });

    test('no preset title carries an emoji', () {
      final src = _code('lib/localization/app_language.dart');
      final presets = RegExp(r"rmdSug(?:Kegel|Vitamin|Read|Water|Calm) =>\s*_p\('([^']*)', '([^']*)'\)").allMatches(src).toList();
      expect(presets, hasLength(5));
      for (final m in presets) {
        expect(RegExp(r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]', unicode: true).hasMatch('${m[1]}${m[2]}'), isFalse,
            reason: m[1]);
      }
    });
  });

  group('D2: the other tools read the loss', () {
    test('Is it safe? drops "For your weeks"; checklists drop "your next scan"', () {
      final door = _code('lib/screens/can_i/can_i_door.dart');
      expect(door, contains('PregnancyEndedStore.instance.ended'));
      expect(door, contains('if (!ended) ...['));
      final list = _code('lib/screens/brackets/pv_checklist_screen.dart');
      expect(list, contains('list.afterLossTitle'));
      expect(_code('lib/data/checklists/pv_checklist_scans.dart'),
          contains("afterLossTitle: 'Questions to take to your doctor'"));
    });
  });

  group('D3: medicines added while trying', () {
    final start = DateTime(2026, 9, 1);
    String idAt(String prefix, DateTime d) => '${prefix}_${d.microsecondsSinceEpoch}';

    test('a TTC id says it on its own; others count when made before the pregnancy', () {
      final s = MedicineStore.instance;
      for (final m in [...s.all]) {
        s.deleteMed(m.id);
      }
      s.addMed(_m(idAt('ttcm', DateTime(2026, 10, 5)), 'Progesterone'));
      s.addMed(_m(idAt('med', DateTime(2026, 8, 1)), 'Folic acid'));
      s.addMed(_m(idAt('med', DateTime(2026, 9, 20)), 'Iron'));
      s.addMed(_m('legacy-id', 'Calcium'));
      expect(s.addedBefore(start).map((m) => m.name).toSet(), {'Progesterone', 'Folic acid'},
          reason: 'Iron was added in pregnancy; an id that does not parse is not known');
      expect(MedicineStore.addedAt(_m('legacy-id', 'x')), isNull);
      for (final m in [...s.all]) {
        s.deleteMed(m.id);
      }
    });

    test('the card is wired on the Medication screen, keyed by her pregnancy', () {
      final src = _code('lib/screens/tools/medicine_tracker_screen.dart');
      expect(src, contains('store.addedBefore(start)'));
      expect(src, contains("'Added while you were trying'"));
      expect(src, contains('LifeStageStore.instance.enteredAt'));
      expect(src, contains("ValueKey('med_trying_stop_\${m.id}')"));
      // Pregnancy can put right a past day, through the same call TTC uses.
      expect(src, contains('store.toggleOn(m.id, d)'));
    });

    test('a deleted medicine comes back with its own id and its days', () async {
      final s = MedicineStore.instance;
      final m = _m(idAt('med', DateTime(2026, 9, 2)), 'Iron');
      await s.addMed(m);
      await s.toggleOn(m.id, DateTime(2026, 10, 1));
      final logs = s.logsFor(m.id);
      await s.deleteMed(m.id);
      expect(s.all.where((x) => x.id == m.id), isEmpty);
      await s.restoreMed(m, logs);
      expect(s.all.single.id, m.id);
      expect(s.isTakenOn(m.id, '2026-10-01'), isTrue);
      await s.deleteMed(m.id);
    });
  });

  group('D8: checklist ticks per scan', () {
    test('adopt moves the old one-key ticks once, and Clear all can be undone', () async {
      final s = PvChecklistStore.instance;
      await s.init('scan_questions');
      await s.toggle('scan_questions', 'prep_fast');
      await s.toggle('scan_questions', 'prep_cost');
      const now = 'scan_questions@Anomaly Scan';
      await s.init(now);
      await s.adopt('scan_questions', now);
      expect(s.ticked(now), {'prep_fast', 'prep_cost'});
      expect(s.count('scan_questions'), 0);
      await s.adopt('scan_questions', now); // a second run changes nothing
      expect(s.count(now), 2);

      final before = s.ticked(now).toSet();
      await s.clear(now);
      expect(s.count(now), 0);
      await s.restore(now, before);
      expect(s.ticked(now), before);
      await s.clear(now);
    });

    test('the screen keys ticks by scan, and Clear all asks first', () {
      final src = _code('lib/screens/brackets/pv_checklist_screen.dart');
      expect(src, contains("'\${list.id}@\$s'"));
      expect(src, contains('_clearAll(context, p)'));
      expect(src, isNot(contains('onTap: () => store.clear(list.id)')));
    });
  });

  group('D4: the doctor-visit summary asks first', () {
    test('four Pregnancy sections, each behind its own kind', () {
      final src = _code('lib/screens/profile/pv_doctor_notes_screen.dart');
      for (final k in ['pregReadings', 'pregConditions', 'pregReports', 'pregDoctorCalls']) {
        expect(src, contains('PpUseKind.$k'), reason: k);
      }
      expect(src, contains("'You chose to leave these out of this summary.'"));
    });

    test('each kind is asked on the tool that collects it', () {
      expect(_code('lib/screens/tools/readings_log_screen.dart'), contains('kind: PpUseKind.pregReadings'));
      expect(_code('lib/screens/conditions/conditions_home_screen.dart'), contains('kind: PpUseKind.pregConditions'));
      expect(_code('lib/screens/brackets/scan_reports_screen.dart'), contains('kind: PpUseKind.pregReports'));
      expect(_code('lib/screens/can_i/can_i_verdict_screen.dart'), contains('kind: PpUseKind.pregDoctorCalls'));
    });
  });

  group('the rest of P1', () {
    test('Find a condition: no gate on the standalone screen', () {
      final src = _code('lib/screens/conditions/conditions_home_screen.dart');
      expect(src, isNot(contains('_DoorGate(p: p, lang: lang, onAnswered')));
      expect(src, isNot(contains('_DoorChip(store: store')));
    });

    test('Ingredient checker: no emoji, no coming-soon card, a way on from no match', () {
      final src = _code('lib/screens/belly_skin/ingredient_checker_screen.dart');
      expect(src, isNot(contains('Text(emoji')));
      expect(src, isNot(contains('comingSoon: true')));
      expect(src, contains("ValueKey('bs_no_match_veda')"));
      expect(src, contains('PregToolScaffold('));
      expect(src, isNot(contains("'Type a product or ingredient'")));
    });

    test('Tests library: on the tool shell, opens on her trimester, one search entry', () {
      final src = _code('lib/screens/tools/tests_scans_reports_screen.dart');
      expect(src, contains('PregToolScaffold('));
      expect(src, contains('_openingFilter()'));
      final search = _code('lib/screens/global_search.dart');
      expect(RegExp(r'_Dest\(s\.tsrTitle').allMatches(search), hasLength(1));
      expect(_code('lib/data/tests_scans_reports_data.dart'), isNot(contains('8-18 cm')));
    });

    test('one name each: Is it safe? and My reports', () {
      final src = _code('lib/services/app_structure.dart');
      expect(src, contains("AppSurface('can_i', AppHome.tools, 'Is it safe?')"));
      expect(src, contains("AppSurface('reports', AppHome.tools, 'My reports')"));
    });

    test('no silent saves left in the P1 tools', () {
      expect(_code('lib/screens/tools/medicine_tracker_screen.dart'), contains("'Unticked \${m.name} for today.'"));
      expect(_code('lib/screens/conditions/condition_detail_screen.dart'), contains('from your journey.'));
      expect(_code('lib/screens/brackets/scan_report_edit_screen.dart'), contains("'Saved · \$title'"));
      expect(_code('lib/screens/can_i/can_i_verdict_screen.dart'), contains('Saved: your doctor said'));
      expect(_code('lib/screens/reminders_screen.dart'), contains("action: 'Undo'"));
    });
  });

  tearDown(() {
    LifeStageStore.instance.resetForTest();
  });
}
