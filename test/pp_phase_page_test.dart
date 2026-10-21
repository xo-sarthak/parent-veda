// =============================================================================
//  The one phase page (2026-10-22, Wave 6)
// -----------------------------------------------------------------------------
//  A tap on the phase opens one page: the painting and film on top, the phase
//  doc as the body in the one reader, "For this phase" inside it, and a swipe
//  to the phases either side. The map and the old phase screen are facades
//  over it. The home's hero is the painting, and its order is the approved one.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/phase_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/phase_map_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phase_page.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phases_data.dart';
import 'package:parentveda/screens/reader/pv_reader_screen.dart';

String _live(String path) =>
    File(path).readAsLinesSync().where((l) => !l.trimLeft().startsWith('//')).join('\n');

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(360 * 3, 1600 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pump(const Duration(milliseconds: 800));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 14)));
  });

  test('the map and the phase screen are facades over the phase page', () {
    expect(_live('lib/screens/post_pregnancy/phase_map_screen.dart'),
        contains('Widget build(BuildContext context) => const PpPhasePage();'));
    expect(_live('lib/screens/post_pregnancy/phase_detail_screen.dart'),
        contains('Widget build(BuildContext context) => PpPhasePage(initial: phase.number);'));
  });

  test('every phase reads with the doc, its offers, its questions and the next phase', () {
    final current = currentPhase().number;
    for (final ph in kPhases) {
      final r = ppPhasePageRead(ph, current: current);
      expect(r.title.en, isNotEmpty, reason: '${ph.number}');
      expect(r.sections.any((s) => s.custom is PpPhaseOffersBlock), isTrue, reason: '${ph.number}: no offers');
      if (ph.number < kPhases.length) {
        expect(r.nextSteps.single.surfaceId, '$kPpPhasePageSurface${ph.number + 1}');
      }
    }
  });

  test('the kicker says where the phase sits against the child', () {
    final ph = kPhases[3];
    expect(ppPhasePageRead(ph, current: 4).kicker.en, startsWith('This phase'));
    expect(ppPhasePageRead(ph, current: 1).kicker.en, startsWith('Coming up'));
    expect(ppPhasePageRead(ph, current: 9).kicker.en, startsWith('Earlier'));
  });

  test('offers follow the phase, not today', () {
    expect(ppPhaseExpertCategory(1), 'Lactation expert');
    expect(ppPhaseExpertCategory(5), 'Sleep expert');
    final early = ppPhaseProducts(kPhases.first, 6);
    for (final x in early) {
      expect(x.suitsAge(kPhases.first.startMonth.floor()), isTrue, reason: x.name);
    }
  });

  testWidgets('the map opens the phase page on the child\'s phase, in the one reader', (t) async {
    await _pump(t, const PhaseMapScreen());
    expect(find.byType(PpPhasePage), findsOneWidget);
    expect(find.byType(PvReaderScreen), findsWidgets);
    expect(find.text('The Settling In'), findsWidgets);
    expect(find.byKey(const ValueKey('pp_phase_back_to_now')), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('the next pill moves to phase 2, with a way back to now', (t) async {
    await _pump(t, PhaseDetailScreen(phase: kPhases.first));
    await t.tap(find.byKey(const ValueKey('pp_phase_pill_2')).first);
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('Awake and Unsettled'), findsWidgets);
    expect(find.byKey(const ValueKey('pp_phase_back_to_now')), findsWidgets);
    expect(t.takeException(), isNull);
  });

  test('the home: painted hero, Explore under Due now, no Looking ahead, rows not cards', () {
    final src = _live('lib/screens/post_pregnancy/pp_home_v3.dart');
    expect(src, contains('child: _PaintedHero('));
    expect(src, contains('onSpine: () => ppOpenPhasePage(context)'));
    // Order: the visit card, then Explore by topic, then the three activities.
    final visit = src.indexOf('ppVisitCardFor()');
    final explore = src.indexOf("title: 'Explore by topic'");
    final acts = src.indexOf('_ActivityRows(');
    final changes = src.indexOf("title: 'How \${child.nameMid} is growing'");
    expect(visit, greaterThan(0));
    expect(explore, greaterThan(visit));
    expect(acts, greaterThan(explore));
    expect(changes, greaterThan(acts));
    // Gone from the home, kept commented for revert.
    expect(src, isNot(contains("title: 'What comes next'")));
    expect(src, isNot(contains('_pad(_PhaseAtAGlance(')));
    expect(src, isNot(contains('_pad(PpAtThisAge(')));
    expect(src, isNot(contains("label: 'What changes next'")));
    // The eyebrows name the child.
    expect(src, contains("eyebrow: 'For \${child.nameMid}'"));
  });
}
