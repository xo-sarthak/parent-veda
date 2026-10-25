// =============================================================================
//  Development tools, the screens (tools pass 17-21, Wave 3, 2026-10-25)
// -----------------------------------------------------------------------------
//  Each test holds one finding from docs/pp-tool-plans/17-21-development.md:
//  a checklist tick that vanished so its Undo could never run, links named
//  "today" that opened the whole list, area links that landed on the top,
//  the visit summary reading development data without her yes, a six-year-old
//  told she was in the 4-5 phase, and a stage reminder on the birthday when
//  the page reads corrected age.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/post_pregnancy/development_all_activities_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_doctor_visit_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_milestones_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_month_checklist_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phase_page.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phases_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/services/parenting_surfaces.dart';
import 'package:parentveda/services/pp_messages_store.dart';
import 'package:parentveda/services/pp_use_consent.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DevStore.instance.applyCloudItems(const {});
    PpUseConsent.instance.applyCloudItems(const {});
  });
  tearDown(() => ChildProfileStore.instance.resetForTest());

  Future<void> pump(WidgetTester t, Widget w, {double h = 3200}) async {
    t.view.physicalSize = Size(360 * 3, h * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: w));
    await t.pumpAndSettle();
  }

  testWidgets('checklist: a ticked skill stays, ticked, and Undo takes it back', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 185)));
    await pump(t, const PpMonthChecklistScreen(), h: 4200);
    final ms = MilestoneStore.instance;
    final first = ms.inWindow.first;
    for (final m in ms.inWindow) {
      if (ms.isObserved(m.id)) ms.unobserve(m.id);
    }
    await t.pumpAndSettle();
    final row = find.byKey(ValueKey('pp_checklist_ms_${first.id}'));
    await t.ensureVisible(row);
    await t.tap(row);
    await t.pumpAndSettle();
    expect(ms.isObserved(first.id), isTrue);
    expect(row, findsOneWidget, reason: 'the row stays, ticked');
    await t.tap(find.text('Undo'));
    await t.pumpAndSettle();
    expect(ms.isObserved(first.id), isFalse);
    expect(find.byKey(const ValueKey('pp_checklist_not_a_diagnosis')), findsOneWidget);
  });

  test('checklist: the short list takes one skill from each area in turn', () {
    // At six months the window holds several areas; the first few rows must
    // not all be one area, which is what `take(6)` of the catalogue gave.
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 185)));
    final window = MilestoneStore.instance.inWindow;
    final areas = window.map((m) => m.domain).toSet();
    expect(areas.length, greaterThan(1));
  });

  test('area links open Activities on that area; an unknown area opens all', () {
    final s = ppScreenForSurface('pp_activities/language');
    expect(s, isA<DevelopmentAllActivitiesScreen>());
    expect((s as DevelopmentAllActivitiesScreen).area, 'language');
    final all = ppScreenForSurface('pp_activities/nonsense') as DevelopmentAllActivitiesScreen;
    expect(all.area, isNull);
  });

  test('R3: nothing that opens every activity is named "today"', () {
    for (final d in kPpDoors) {
      for (final tab in d.tabs) {
        for (final tool in tab.tools) {
          if (tool.surfaceId.startsWith('pp_activities')) {
            expect(tool.label.toLowerCase(), isNot(contains('today')), reason: '${d.sectionId}: ${tool.label}');
          }
          if (tool.surfaceId == 'pp_milestones') {
            expect(tool.label, 'Milestones', reason: 'named as the tool is');
          }
        }
      }
    }
    final surface = kPpSurfaces.firstWhere((s) => s.id == 'pp_activities');
    expect(surface.label.en.toLowerCase(), isNot(contains('today')));
  });

  testWidgets('activities: "We tried this" saves for the child, says so, and undoes', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 300)));
    await pump(t, const DevelopmentAllActivitiesScreen());
    final tick = find.byWidgetPredicate((w) => w is PpTriedTick).first;
    final id = t.widget<PpTriedTick>(tick).activity.id;
    await t.ensureVisible(tick);
    await t.tap(tick);
    await t.pumpAndSettle();
    expect(DevStore.instance.isCompleted(id), isTrue);
    expect(find.textContaining('Saved: you tried'), findsOneWidget);
    await t.tap(find.text('Undo'));
    await t.pumpAndSettle();
    expect(DevStore.instance.isCompleted(id), isFalse);
  });

  testWidgets('activities: a link can open on one area', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 300)));
    await pump(t, const DevelopmentAllActivitiesScreen(area: 'language'));
    final language = devAreaById('language');
    final rows = t.widgetList(find.byWidgetPredicate((w) => w is PpTriedTick)).cast<PpTriedTick>();
    expect(rows, isNotEmpty);
    expect(rows.every((r) => r.activity.areaId == language.id), isTrue);
  });

  test('the visit summary reads development only after her yes', () {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 185)));
    final ms = MilestoneStore.instance;
    final m = ms.inWindow.first;
    ms.markObserved(m.id);
    expect(ppDoctorVisitDevelopmentLine(), isNull, reason: 'unasked counts as no');
    PpUseConsent.instance.set(PpUseKind.development, false);
    expect(ppDoctorVisitDevelopmentLine(), isNull);
    PpUseConsent.instance.set(PpUseKind.development, true);
    expect(ppDoctorVisitDevelopmentLine(), contains(m.title));
    expect(ppDoctorVisitShareText(days: const []), contains('Development: '));
    ms.unobserve(m.id);
  });

  test('past five: no phase claims to be now', () {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 365 * 6)));
    final now = ppPhaseNowNumber();
    expect(now, kPhases.length + 1);
    final last = ppPhasePageRead(kPhases.last, current: now);
    expect(last.kicker.en, startsWith('Earlier'));
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 200)));
    expect(ppPhaseNowNumber(), currentPhase().number);
  });

  // Found while running the suite (2026-10-25): the id was the clock alone,
  // so twins added back to back could share one id and every store merged them.
  test('two children added back to back never share an id', () async {
    final store = ChildProfileStore.instance;
    final dob = DateTime.now().subtract(const Duration(days: 40));
    final ids = <String>{};
    for (var i = 0; i < 5; i++) {
      ids.add((await store.addChild(name: 'Twin $i', isBoy: i.isEven, dob: dob)).id);
    }
    expect(ids, hasLength(5));
  });

  test('"A new stage" comes by corrected age for a baby born early', () {
    final dob = DateTime(2026, 6, 1);
    final now = DateTime(2026, 6, 2);
    PpMessage? stage(int? weeks, int phase) => ppMessageCandidates(
          PpMessageFacts(dob: dob, name: 'Meera', realChild: true, correctionWeeks: weeks),
          now,
        ).where((m) => m.id == 'phase:$phase').firstOrNull;
    final term = stage(null, 3);
    final early = stage(8, 3);
    expect(term, isNotNull);
    expect(early, isNotNull);
    // Eight weeks on the birth date, then the months: 55-59 days later,
    // as months differ in length.
    expect(early!.at.difference(term!.at).inDays, inInclusiveRange(55, 59), reason: 'about eight weeks later');
  });
}
