// =============================================================================
//  Parenting relevance, Step 3b (docs/door-relevance/PARENTING-GAP.md)
// -----------------------------------------------------------------------------
//  PP 4   What she told us in "Is my baby OK?" moves activities (a fixed list
//         of concern -> development area, never urgent, only with her yes),
//         and a page about it can join the home's reads.
//  PP 19  Found: change words matched inside other words ("hot" in "shots").
//  Fever  Fever check keeps a "see a doctor" answer with her yes (the user,
//         2026-10-28), never the reading, never asks under "Go now".
//  PP 20  Found: the home opened the old fever questions, not Fever check.
//  PP 9   One line under the grid when her answers moved a tile.
//  PP 8   Courses and groups ranked by the child's age; the reader's offer
//         never pitches a programme made for another age; 0124 carries it.
//
//  Source scans pin the wiring (CLAUDE.md, wiring gate).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/learn/pv_learn_view.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/screens/learn/pv_learn_catalog.dart';
import 'package:parentveda/screens/post_pregnancy/pp_changes_store.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_fever_check_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_grow_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_home_activities_store.dart';
import 'package:parentveda/screens/post_pregnancy/pp_home_today.dart';
import 'package:parentveda/screens/post_pregnancy/pp_learning_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_more_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_relevance.dart';
import 'package:parentveda/screens/post_pregnancy/pp_tile_order.dart';
import 'package:parentveda/screens/post_pregnancy/pp_what_changed_data.dart';
import 'package:parentveda/screens/reader/pv_read_offer.dart';
import 'package:parentveda/services/family_profile.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pp_use_consent.dart';
import 'package:parentveda/services/programme_store.dart';

String _src(String path) => File(path).readAsStringSync();

WcConcern _concern(String id) => kWcConcerns.firstWhere((c) => c.id == id);

PpChange _change(String id, {WcTone tone = WcTone.caution}) =>
    PpChange(childId: 'child_test', concernId: id, at: DateTime(2026, 10, 27), tone: tone);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final kids = ChildProfileStore.instance;
  final changes = PpChangesStore.instance;
  final consent = PpUseConsent.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    kids.resetForTest();
    changes.debugReset();
    consent.debugReset();
  });

  // ==========================================================================
  //  PP 19: whole words
  // ==========================================================================
  group('PP 19: change words match whole words', () {
    test('fever does not match vaccine shots; ears do not match the year', () {
      expect(_change('low_fever').matches('Vaccine shots at 6 weeks'), isFalse);
      expect(_change('low_fever').matches('A fever under three months'), isTrue);
      expect(_change('pulling_ears').matches('Your baby\'s first year'), isFalse);
      expect(_change('pulling_ears').matches('Early words'), isFalse);
      expect(_change('pulling_ears').matches('Ear infections'), isTrue);
      expect(_change('new_rash').matches('A bored toddler'), isFalse);
    });

    test('an area stem still matches the start of a word', () {
      expect(_change('wake_2h').matches('Settling a baby who wakes'), isTrue, reason: 'settl, wak');
      expect(_change('gassy').matches('Window and balcony safety'), isFalse, reason: 'wind is a keyword only');
      expect(_change('gassy').matches('Trapped wind'), isTrue);
    });

    test('lifting INTO the reads uses the concern keywords, not the area stems', () {
      // "Babbling less" is in Development, whose stems include "walk".
      expect(_change('gone_quiet').matches('First steps and walking'), isTrue, reason: 'ordering may');
      expect(_change('gone_quiet').matchesKeyword('First steps and walking'), isFalse);
      expect(_change('gone_quiet').matchesKeyword('Speech at this age'), isTrue);
    });

    test('a fever is "a fever" on a card, not "warm / low-grade fever"', () {
      expect(_change('low_fever').name, 'a fever');
      expect(_change('low_fever').why, 'Because you said: a fever');
      expect(_change('extra_clingy').why, 'Because you said: suddenly very clingy');
    });
  });

  // ==========================================================================
  //  PP 4: activities follow what she told us
  // ==========================================================================
  group('PP 4: what she told us moves activities', () {
    final today = DateTime(2026, 10, 28, 9);
    const months = 10;
    late PpHomeActivitiesStore store;

    // The emotional and social cards that fit 10 months exactly.
    Set<String> fitting(Set<String> areas) => {
          for (final a in growActivitiesForAge(months))
            if (areas.contains(a.areaId) && growSuitsAge(a, months)) a.id,
        };

    setUp(() async {
      kids.debugSetDob(today.subtract(const Duration(days: 305)));
      store = PpHomeActivitiesStore.instance;
      store.resetForTest();
      store.now = () => today;
      await store.ensureLoaded();
    });

    test('the pool has emotional or social cards at 10 months to lift', () {
      expect(fitting({'emotional', 'social'}), isNotEmpty);
    });

    test('with her yes, "suddenly very clingy" puts one first, and it says why', () {
      consent.set(PpUseKind.changes, true);
      changes.note(_concern('extra_clingy'), WcTone.caution, at: today);
      final three = store.todays(months, childId: kids.activeChildId);
      expect(fitting({'emotional', 'social'}), contains(three.first.id));
      expect(ppActivityWhy(three.first, changes.active(now: today)), 'Because you said: suddenly very clingy');
    });

    test('without her yes nothing moves', () {
      final before = store.todays(months, childId: kids.activeChildId).map((a) => a.id).toList();
      changes.note(_concern('extra_clingy'), WcTone.caution, at: today);
      expect(store.todays(months, childId: kids.activeChildId).map((a) => a.id).toList(), before);
    });

    test('an urgent answer moves no activity', () {
      expect(ppActivityChanges([_change('extra_clingy', tone: WcTone.urgent)]), isEmpty);
      expect(ppActivityChanges([_change('extra_clingy')]), hasLength(1));
    });

    test('a sleep worry moves pages only: no activity fits it', () {
      expect(ppActivityChanges([_change('wake_2h')]), isEmpty);
    });

    test('a new answer re-picks an untouched three, never a ticked one', () async {
      consent.set(PpUseKind.changes, true);
      final first = store.todays(months, childId: kids.activeChildId).map((a) => a.id).toList();
      await store.markDone(first.first);
      changes.note(_concern('extra_clingy'), WcTone.caution, at: today);
      expect(store.todays(months, childId: kids.activeChildId).map((a) => a.id).toList(), first,
          reason: 'she ticked one: it shows tomorrow');
    });

    test('every mapped concern and area exists', () {
      final concerns = {for (final c in kWcConcerns) c.id};
      final areas = {for (final a in kDevActivities) a.areaId, for (final a in kGrowActivities) a.areaId};
      for (final e in kPpChangeActivityAreas.entries) {
        expect(concerns, contains(e.key));
        for (final area in e.value) {
          expect(areas, contains(area), reason: e.key);
        }
      }
    });
  });

  // ==========================================================================
  //  The Fever check save
  // ==========================================================================
  group('Fever check keeps "see a doctor" with her yes', () {
    final now = DateTime(2026, 10, 28, 9);

    Future<void> pump(WidgetTester t) async {
      t.view.physicalSize = const Size(1200, 6000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(home: PpFeverCheckScreen(now: now)));
      await t.pumpAndSettle();
    }

    Future<void> tap(WidgetTester t, String text) async {
      await t.tap(find.text(text));
      await t.pumpAndSettle();
    }

    setUp(() => kids.debugSetDob(now.subtract(const Duration(days: 300))));

    testWidgets('asked under "see a doctor today"; a yes brings the home follow-up', (t) async {
      await pump(t);
      await tap(t, 'None of these');
      await tap(t, 'Above 39 C  (above 102.2 F)');
      expect(find.text('Worth a doctor today'), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_use_ask_changes')), findsOneWidget);
      expect(ppUrgentFollowUp(now: now), isNull, reason: 'nothing kept before her yes');
      await t.tap(find.byKey(const ValueKey('pp_use_yes_changes')));
      await t.pumpAndSettle();
      expect(ppUrgentFollowUp(now: now)?.concernId, 'low_fever');
      expect(find.byKey(const ValueKey('pp_fever_kept')), findsOneWidget);
    });

    testWidgets('never asked under "Go now"', (t) async {
      await pump(t);
      await tap(t, 'Yes, one of these');
      expect(find.text('Go now'), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_use_ask_changes')), findsNothing);
      expect(ppUrgentFollowUp(now: now), isNull);
    });

    testWidgets('with a yes given before, "Go now" keeps it quietly', (t) async {
      consent.set(PpUseKind.changes, true);
      await pump(t);
      await tap(t, 'Yes, one of these');
      expect(ppUrgentFollowUp(now: now)?.concernId, 'low_fever');
      expect(find.byKey(const ValueKey('pp_fever_kept')), findsOneWidget);
    });

    testWidgets('a corrected reading clears what this visit kept', (t) async {
      consent.set(PpUseKind.changes, true);
      await pump(t);
      await tap(t, 'None of these');
      await tap(t, 'Above 39 C  (above 102.2 F)');
      expect(ppUrgentFollowUp(now: now)?.concernId, 'low_fever');
      await tap(t, '36.5 to 38 C  (97.7 to 100.4 F)');
      expect(ppUrgentFollowUp(now: now), isNull);
    });

    testWidgets('another age group may be another child: nothing kept', (t) async {
      consent.set(PpUseKind.changes, true);
      await pump(t);
      await tap(t, 'None of these');
      await tap(t, '3 to 6 months'); // the child on screen is 9 months
      await tap(t, 'Above 39 C  (above 102.2 F)');
      expect(find.text('Get him seen today'), findsOneWidget);
      expect(ppUrgentFollowUp(now: now), isNull);
    });

    test('the intro says it is kept only with her yes, and never the reading', () {
      final src = _src('lib/screens/post_pregnancy/pp_fever_check_screen.dart');
      expect(src, contains('Nothing is kept without your yes'));
      // The old words stay only as a kept-for-revert comment, not as the intro.
      expect(src, isNot(contains("intro: ppFillChild('His age and his temperature. Nothing is saved")));
    });
  });

  // ==========================================================================
  //  PP 20: the home opens the fever judge
  // ==========================================================================
  test('PP 20: both home cards open what she told us through the hand-off', () {
    final src = _src('lib/screens/post_pregnancy/pp_home_v3.dart');
    expect(RegExp(r'_openChange\(context, [uc]\)').allMatches(src), hasLength(2));
    expect(src, contains('kWcHandOff[c.concernId]'));
    expect(kWcHandOff['low_fever'], 'pp_fever_check');
  });

  test('PP 4: the promise matches what happens', () {
    expect(_src('lib/screens/post_pregnancy/what_changed_screen.dart'),
        contains('activities too when one fits'));
    expect(PpUseKind.changes.why, contains('activities too when one fits'));
    expect(PpUseKind.changes.label, contains('Fever check'));
  });

  test('PP 4: the reads can lift a page about what she told us', () {
    expect(_src('lib/screens/post_pregnancy/pp_home_reads.dart'), contains('c.matchesKeyword(r.page.title)'));
  });

  // ==========================================================================
  //  PP 9: the tile line
  // ==========================================================================
  group('PP 9: one line when her answers moved a tile', () {
    final ids = [
      'parenting_sleep', 'parenting_feeding', 'parenting_health', 'parenting_development',
      'parenting_potty', 'parenting_behaviour', 'parenting_early_learning', 'parenting_safety',
      'parenting_maternal', 'parenting_first_40', 'parenting_buying',
    ];
    String label(String id) => id.replaceFirst('parenting_', '');

    test('age alone: no line', () {
      expect(ppTileWhy(ids, ageInDays: 400, label: label), isNull);
    });

    test('a priority that lifts a tile says so', () {
      final why = ppTileWhy(ids, ageInDays: 900, label: label, priorities: {Priority.behaviour});
      expect(why, contains('because you chose behaviour in your family setup'));
    });

    test('born early names Development', () {
      final why = ppTileWhy(ids, ageInDays: 900, label: label, signals: {PpSignal.bornEarly});
      // At 2.5 years born early puts Development first of all.
      expect(why, 'development is first here, because your baby was born early.');
      // A priority that lifts a tile without making it first says "moved up".
      final up = ppTileWhy(ids, ageInDays: 20, label: label, priorities: {Priority.health});
      expect(up, 'health moved up, because you chose health in your family setup.');
    });

    test('the home shows it under the grid', () {
      final src = _src('lib/screens/post_pregnancy/pp_home_v3.dart');
      expect(src, contains("ValueKey('pp_home_tiles_why')"));
      expect(src, contains('ppTileWhy('));
      expect(src, isNot(contains('// ⚠️ OFF BY DEFAULT: the user decided')), reason: 'PP 14, stale comment');
    });
  });

  // ==========================================================================
  //  PP 8: courses and groups by the child's age
  // ==========================================================================
  group('PP 8: offerings by the child\'s age', () {
    PvOfferingView view(String id, {int? from, int? to}) => PvOfferingView(
          id: id,
          stage: LifeStage.parenting,
          kind: PvLearnKind.masterclass,
          title: id,
          subtitle: '',
          about: '',
          expert: const PvLearnExpert(id: 'x', name: 'X', role: ''),
          hue: 0,
          ageFromMonths: from,
          ageToMonths: to,
        );

    test('made for her age first, then every age, then the rest; nothing dropped', () {
      final all = [view('newborn', from: 0, to: 2), view('any'), view('toddler', from: 12, to: 36)];
      expect(ppRankByAge(all, 24).map((v) => v.id), ['toddler', 'any', 'newborn']);
      expect(ppRankByAge(all, 1).map((v) => v.id), ['newborn', 'any', 'toddler']);
    });

    test('the line says why only when one is made for her age', () {
      expect(ppAgeFirstLine([view('any')], 24, 'Aarav'), isNull);
      expect(ppAgeFirstLine([view('toddler', from: 12, to: 36)], 24, 'Aarav'),
          "Those made for Aarav's age come first.");
    });

    test('The First 40 Days is for the first weeks; the special needs course for every age', () {
      final first40 = kLearningPrograms.firstWhere((p) => p.id == 'mc_first40');
      expect(first40.fitsAge(1), isTrue);
      expect(first40.fitsAge(36), isFalse);
      expect(kLearningPrograms.firstWhere((p) => p.id == 'rc_specialneeds').fitsAge(60), isTrue);
      expect(PvLearnCatalog.instance.byId('mc_first40')?.hasAgeWindow, isTrue, reason: 'carried into the view');
    });

    test('a toddler\'s read never offers a newborn programme', () {
      LocalizedText l(String s) => LocalizedText(en: s, hi: s);
      final read = PvRead(
        id: 'pp_page_x_y',
        kicker: l(''),
        title: l('Newborn sleep basics'),
        teaser: l(''),
        scaleSetter: l(''),
        author: l('ParentVeda team'),
        authorRole: l(''),
        hue: 0,
        sections: [PvReadSection(heading: l('One'), paragraphs: [l('Text.')])],
        whenToSeeSomeone: kPvShortPieceCallout,
        faqs: const [],
      );
      final catalog = [view('First 40 Days newborn', from: 0, to: 2)];
      expect(pvReadOfferFor(read, catalog: catalog)?.id, 'First 40 Days newborn');
      expect(pvReadOfferFor(read, catalog: catalog, childMonths: 30), isNull);
    });

    test('a published row carries its window, and the cache keeps it', () {
      final store = ProgrammeStore.instance;
      final p = store.fromMap({'id': 'live1', 'kind': 'masterclass', 'title': 'T', 'age_from_months': 6, 'age_to_months': 12});
      expect((p.ageFromMonths, p.ageToMonths), (6, 12));
      final back = store.fromMap(store.toCacheMap(p));
      expect((back.ageFromMonths, back.ageToMonths), (6, 12));
      expect(store.fromMap({'id': 'live2', 'kind': 'masterclass', 'title': 'T'}).fitsAge(60), isTrue,
          reason: 'before 0124 is run: every age');
    });

    test('0124 adds the columns, checks them and rebuilds the view with them last', () {
      final sql = _src('supabase/migrations/0124_programme_age_window.sql');
      expect(sql, contains('add column if not exists age_from_months integer'));
      expect(sql, contains('programmes_age_window_ok'));
      final view = sql.substring(sql.indexOf('create or replace view public.programmes_published'));
      expect(view.indexOf('as seats_left'), lessThan(view.indexOf('p.age_from_months')));
      // Every bundled window is mirrored in the migration.
      for (final p in kLearningPrograms.where((p) => p.ageFromMonths != null)) {
        expect(sql, contains("('${p.id}', ${p.ageFromMonths}, ${p.ageToMonths})"), reason: p.id);
      }
    });

    test('More and the reader are wired to the age', () {
      final more = _src('lib/screens/post_pregnancy/pp_more_screen.dart');
      expect(more, contains('ppRankByAge('));
      expect(more, contains('ChildProfileStore.instance, programmeListenable'));
      expect(_src('lib/screens/reader/pv_reader_screen.dart'), contains('childMonths: widget.read.id.startsWith'));
    });
  });
}
