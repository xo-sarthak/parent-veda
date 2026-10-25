// =============================================================================
//  Parenting tools 25-28, the You, Maa family: the backend, held
//  (docs/pp-tool-plans/25-28-you-maa.md, 2026-10-25).
//
//  · Kegel Care: her clock is her youngest child's birth, not the child on
//    screen; a custom routine is capped after birth; a breathing session never
//    moves the squeeze routine; a record saved before `kind` existed reads as a
//    squeeze session (the lenient read is the migration for a JSON blob).
//  · Yoga: no seeded saves; the cloud items keep their shape; a priced
//    recorded class is bought once and has no slots, a free one plays; the
//    six-week gate runs at every way into a class; her rails follow her band;
//    no seeded rating on a class page; no lavender ground.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/booking/booking_catalog.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/screens/learn/pv_learn_catalog.dart';
import 'package:parentveda/screens/post_pregnancy/pp_age_bands.dart';
import 'package:parentveda/screens/post_pregnancy/pp_yoga_data.dart';
import 'package:parentveda/screens/post_pregnancy/yoga_home_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/tools/kegel_care_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/tools_store.dart';

String _src(String p) => File(p).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final tools = ToolsStore.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ChildProfileStore.instance.resetForTest();
    await tools.init();
    await tools.clearKegelCustomRoutine();
  });
  tearDown(() => ChildProfileStore.instance.resetForTest());

  group('Kegel Care after birth', () {
    Future<void> pumpPp(WidgetTester t) async {
      LifeStageStore.instance.setStage(LifeStage.parenting);
      t.view.physicalSize = const Size(900, 3200);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: KegelCareScreen()));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
    }

    Future<void> done(WidgetTester t) async {
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 5));
    }

    testWidgets('three weeks after a new birth is breathe-first, toddler on screen',
        (t) async {
      final kids = ChildProfileStore.instance;
      kids.debugSetDob(DateTime.now().subtract(const Duration(days: 3 * 365)));
      final older = kids.activeChildId!;
      await t.runAsync(() => kids.addChild(
          name: 'Baby',
          isBoy: false,
          dob: DateTime.now().subtract(const Duration(days: 21))));
      await t.runAsync(() => kids.switchTo(older));
      expect(ppDaysSinceBirth, greaterThan(1000), reason: 'the toddler is on screen');
      expect(ppMotherDaysSinceBirth, inInclusiveRange(20, 22));
      await pumpPp(t);
      expect(find.text('Breathe first'), findsOneWidget);
      expect(find.text('Kegels, done properly'), findsNothing);
      await done(t);
    });

    testWidgets('a custom routine from pregnancy is capped at 5 s x 10 after birth',
        (t) async {
      ChildProfileStore.instance
          .debugSetDob(DateTime.now().subtract(const Duration(days: 200)));
      await tools.setKegelCustomRoutine(hold: 10, relax: 10, reps: 15);
      await pumpPp(t);
      final nums = t
          .widgetList<Text>(find.descendant(
            of: find.byKey(const ValueKey('kg_routine_numbers')),
            matching: find.byType(Text),
          ))
          .map((w) => int.tryParse(w.data ?? ''))
          .whereType<int>()
          .toList();
      expect(nums, hasLength(3));
      expect(nums[0], lessThanOrEqualTo(5), reason: 'hold');
      expect(nums[2], lessThanOrEqualTo(10), reason: 'reps');
      await done(t);
    });

    testWidgets('the breathe-first "how" is the breath, and links her page', (t) async {
      ChildProfileStore.instance
          .debugSetDob(DateTime.now().subtract(const Duration(days: 20)));
      await pumpPp(t);
      await t.ensureVisible(find.byKey(const ValueKey('kg_fold_toggle_how')));
      await t.tap(find.byKey(const ValueKey('kg_fold_toggle_how')));
      await t.pumpAndSettle();
      final how = t.widget<Text>(find.byKey(const ValueKey('kg_how_body'),
          skipOffstage: false));
      expect(how.data, isNot(contains('Squeeze')));
      expect(how.data, contains('No squeezing'));
      expect(find.byKey(const ValueKey('kg_how_page'), skipOffstage: false),
          findsOneWidget);
      expect(find.byKey(const ValueKey('kg_pp_physio_pill')), findsOneWidget);
      await done(t);
    });
  });

  group('Kegel history', () {
    test('a breathing session never moves the squeeze routine', () async {
      final hold = tools.kegelHoldAdjust;
      final reps = tools.kegelRepAdjust;
      for (var i = 0; i < 5; i++) {
        await tools.recordKegelSession(
            holdSeconds: 4,
            relaxSeconds: 6,
            repetitions: 10,
            feedback: 'easy',
            kind: kKegelKindBreath);
      }
      expect(tools.kegelHoldAdjust, hold);
      expect(tools.kegelRepAdjust, reps);
      // A squeeze session still does.
      await tools.recordKegelSession(
          holdSeconds: 3, relaxSeconds: 6, repetitions: 8, feedback: 'easy');
      expect(tools.kegelHoldAdjust, isNot(hold));
    });

    test('a record saved before `kind` existed reads as a squeeze session', () {
      final old = KegelRecord.fromJson({
        'dateIso': '2026-09-01T10:00:00.000',
        'holdSeconds': 5,
        'relaxSeconds': 5,
        'repetitions': 10,
        'feedback': 'comfortable',
      });
      expect(old.kind, kKegelKindSqueeze);
      expect(old.isBreath, isFalse);
    });

    test('kind and a feeling of none round-trip', () {
      const r = KegelRecord(
          dateIso: '2026-10-25T09:00:00.000',
          holdSeconds: 4,
          relaxSeconds: 6,
          repetitions: 10,
          feedback: 'none',
          kind: kKegelKindBreath);
      final back = KegelRecord.fromJson(r.toJson());
      expect(back.kind, kKegelKindBreath);
      expect(back.feedback, 'none');
    });

    test('leaving a finished session saves it (the live code)', () {
      final src = _src('lib/screens/tools/kegel_care_screen.dart');
      expect(src, contains('onPopInvokedWithResult'));
      expect(src, contains("_record('none')"));
      expect(src, contains('kind: widget.breathe ? kKegelKindBreath : kKegelKindSqueeze'));
    });
  });

  group('Yoga', () {
    test('a new mother starts with nothing saved', () {
      final src = _src('lib/screens/post_pregnancy/pp_yoga_data.dart');
      expect(src, contains('  final Set<String> _saved = {};'));
      expect(src, isNot(contains("\n  final Set<String> _saved = {'pn_group'")));
    });

    test('the cloud items keep their shape: saved|<id>, booked|<id>', () {
      final y = YogaStore.instance;
      final had = y.isSaved('po_gentle_rec');
      if (!had) y.toggleSave('po_gentle_rec');
      final items = y.cloudItems();
      expect(items['saved|po_gentle_rec'], isTrue);
      for (final k in items.keys) {
        expect(k.startsWith('saved|') || k.startsWith('booked|'), isTrue, reason: k);
      }
      if (!had) y.toggleSave('po_gentle_rec');
    });

    test('a priced recorded class is bought once, with no slots; a free one plays', () {
      final cat = BookingCatalog.instance;
      final recorded = kYogaClasses.where((c) => c.mode == YogaMode.recorded);
      var priced = 0;
      for (final c in recorded) {
        final o = cat.offeringForCatalog(c.id);
        final free = !RegExp(r'\d').hasMatch(c.price);
        if (free) {
          expect(o, isNull, reason: '${c.id} is free and plays');
        } else {
          priced++;
          expect(o, isNotNull, reason: '${c.id} shows ${c.price}');
          expect(o!.kind, OfferingKind.masterclass);
          expect(o.format, SessionFormat.recorded);
          expect(o.grant.recordingAccess, isTrue);
          expect(o.priceMinor, greaterThan(0));
          expect(cat.slotsFor(o.id), isEmpty, reason: 'nothing to reserve');
        }
      }
      expect(priced, greaterThanOrEqualTo(5));
    });

    test('every way into a class asks the six-week gate', () {
      for (final f in [
        'lib/screens/post_pregnancy/yoga_home_screen.dart',
        'lib/screens/post_pregnancy/provider_profile_screen.dart',
        'lib/screens/move/pv_move_today_screen.dart',
        'lib/screens/prepare/prenatal_yoga_screen.dart',
      ]) {
        final live = _src(f)
            .split('\n')
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        expect(live, contains('openYogaClass('), reason: f);
        expect(live, isNot(contains('builder: (_) => YogaClassScreen(cls: c)')), reason: f);
      }
      final helper = _src('lib/screens/post_pregnancy/yoga_class_screen.dart');
      expect(helper, contains("ppSurfaceUnavailable(id) != null"));
    });

    test('her rails follow her band', () {
      expect(ppYogaRailOrder('pp_0_6w').first, 'breathing');
      expect(ppYogaRailOrder('pp_6w_3m').first, 'core');
      expect(ppYogaRailOrder('pp_3_6m').first, 'core');
      expect(ppYogaRailOrder('pp_6m').first, 'postnatal');
      for (final b in ['pp_0_6w', 'pp_6w_3m', 'pp_3_6m', 'pp_6m']) {
        expect(ppYogaRailOrder(b).toSet(), {'breathing', 'core', 'postnatal'},
            reason: 'nothing hidden in $b');
      }
    });

    test('no seeded rating on a class page, and the stop signs are there', () {
      for (final c in kYogaClasses) {
        final v = PvLearnCatalog.instance.byId(c.id);
        if (v == null) continue;
        expect(v.rating, isNull, reason: c.id);
        expect(v.reviews, isEmpty, reason: c.id);
        expect(v.faqs.any((f) => f.q == 'When should I stop?'), isTrue, reason: c.id);
        expect(v.faqs.first.a, contains(kYogaClassDisclaimer));
      }
    });

    test('no lavender ground on a class card', () {
      expect(yogaHueIsLavender(250), isTrue);
      expect(yogaHueIsLavender(280), isTrue);
      expect(yogaHueIsLavender(20), isFalse);
      expect(yogaHueIsLavender(330), isFalse);
    });
  });
}
