// =============================================================================
//  Parenting relevance, Batch 1 (docs/door-relevance/PARENTING-GAP.md)
// -----------------------------------------------------------------------------
//  PP 1. Today's three activities belong to ONE child at ONE age. They were
//  keyed by the date alone, so a switch from a 3-week-old to a 3-year-old
//  kept the baby's three until midnight. The store takes a clock, so these
//  tests can move time instead of waiting for it.
//
//  PP 10. Parenting needs a real child. With none saved, the home opens the
//  add-child form (required outside developer builds), after the children
//  and the first cloud pull have loaded, and never for him.
//
//  Both are also pinned against the home's SOURCE: a correct store the home
//  never calls is the failure this repo has hit (the wiring gate).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/multichild_sheet.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_home_activities_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final homeSrc =
      File('lib/screens/post_pregnancy/pp_home_v3.dart').readAsStringSync();

  // ==========================================================================
  //  PP 1. One three per child, per age
  // ==========================================================================
  group('PP 1: activities follow the child', () {
    late PpHomeActivitiesStore store;
    var today = DateTime(2026, 10, 28, 10);
    Set<String> ids(int age, String? child) =>
        store.todays(age, childId: child).map((a) => a.id).toSet();

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = PpHomeActivitiesStore.instance;
      store.resetForTest();
      today = DateTime(2026, 10, 28, 10);
      store.now = () => today;
      await store.ensureLoaded();
    });

    test('a switch to an older sibling brings that child\'s own three', () {
      final baby = ids(0, 'child_baby');
      final toddler = ids(36, 'child_toddler');
      expect(toddler.length, kPpHomeActivityCount);
      expect(toddler.intersection(baby), isEmpty,
          reason: 'a 3-year-old must not get the newborn\'s three');
    });

    test('switching back the same day finds the same three, still ticked',
        () async {
      final first = store.todays(4, childId: 'child_a');
      await store.markDone(first[0].id);
      ids(36, 'child_b');
      expect(store.isDone(first[0].id), isFalse,
          reason: 'the tick belongs to child A, not to whoever is on screen');
      final again = store.todays(4, childId: 'child_a');
      expect(again.map((a) => a.id), first.map((a) => a.id));
      expect(store.isDone(first[0].id), isTrue);
    });

    test('a real birthday saved after the stand-in child gets fresh picks',
        () {
      // The stand-in is born today (age 0, no id); her real baby is 9 months.
      final standIn = ids(0, null);
      final real = ids(9, 'child_real');
      expect(real, isNot(standIn));
    });

    test('a month birthday refreshes the three, because the pool changed', () {
      final before = ids(5, 'child_a');
      final after = ids(6, 'child_a');
      expect(after, isNot(before));
    });

    test('a swap stays with the child it was made for', () {
      final a = store.todays(4, childId: 'child_a');
      store.swap(a[1].id, 4, childId: 'child_a');
      final swappedIn = store.todays(4, childId: 'child_a')[1].id;
      expect(store.wasSwappedIn(swappedIn), isTrue);
      ids(36, 'child_b');
      expect(store.wasSwappedIn(swappedIn), isFalse);
    });

    test('tomorrow every child starts fresh', () async {
      final a = ids(4, 'child_a');
      today = today.add(const Duration(days: 1));
      expect(ids(4, 'child_a').intersection(a), isEmpty);
    });

    test('the home passes the child on screen and the corrected age', () {
      expect(
          homeSrc.contains('.todays(child.devAgeInMonths, '
              'childId: child.activeChildId)'),
          isTrue,
          reason: 'PP 1 + PP 2: keyed by the child, by corrected age');
      expect(homeSrc.contains('childId: child.activeChildId),'), isTrue,
          reason: 'the swap is for the same child');
    });
  });

  // ==========================================================================
  //  PP 10. A real child is required
  // ==========================================================================
  group('PP 10: Parenting asks for a child', () {
    final kids = ChildProfileStore.instance;

    setUp(() {
      kids.resetForTest();
      kids.debugLoaded = false;
    });
    tearDown(() {
      kids.resetForTest();
      kids.debugLoaded = false;
    });

    test('not before the children and the cloud pull have loaded', () {
      expect(kids.needsChild(), isFalse,
          reason: 'a new phone must not be asked before her account lands');
    });

    test('asked once loaded with no child', () {
      kids.debugLoaded = true;
      expect(kids.needsChild(), isTrue);
    });

    test('never asked of him', () {
      kids.debugLoaded = true;
      expect(kids.needsChild(father: true), isFalse);
    });

    test('not asked once a child is saved', () {
      kids.debugLoaded = true;
      kids.debugSetDob(DateTime(2026, 6, 1));
      expect(kids.needsChild(), isFalse);
    });

    test('the home asks, required outside developer builds', () {
      expect(homeSrc.contains('child.needsChild(father: FatherPreview.instance.on)'),
          isTrue);
      expect(
          homeSrc.contains(
              'showAddChildForm(context, required: !(kDebugMode || kPvDevBuild))'),
          isTrue);
    });

    testWidgets('the required form says what the answer unlocks',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showAddChildForm(context, required: true),
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Tell us about your child'), findsOneWidget);
      expect(find.textContaining('Everything here follows their age'),
          findsOneWidget);

      // Tapping outside does not close it.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Tell us about your child'), findsOneWidget);
    });
  });
}
