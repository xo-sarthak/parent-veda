// =============================================================================
//  A TTC read shows "Reviewed by" and a tick only when the expert signed it off
// -----------------------------------------------------------------------------
//  Launch sanity H14 (2026-09-28): every TTC read said "REVIEWED BY Dr Ruchika
//  Sood" with a verified tick while docs/TTC-EXPERT-SIGNOFF.md said nothing
//  had been sent. The rule now lives in lib/ttc/ttc_expert_signoff.dart: the
//  tick needs the read's id in its expert's signed-off set, and one id added
//  there flips that read back.
//
//  H14's follow-up (2026-09-28): the same rule for door carousels, stories
//  and infographics (`kTtcSignedOffStories`, keyed by tile title), and for
//  the Trying to conceive courses, groups and classes, whose first trust row
//  said "Reviewed by our clinical panel" with a seal and tick.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/learn/pv_learn_view.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/learn/pv_learn_art.dart';
import 'package:parentveda/screens/learn/pv_offering_content.dart';
import 'package:parentveda/screens/reader/pv_reader_screen.dart';
import 'package:parentveda/screens/ttc/ttc_infographic_screen.dart';
import 'package:parentveda/screens/ttc/ttc_story_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/ttc_expert_signoff.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

class _NoNet extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setUpAll(() => HttpOverrides.global = _NoNet());

  test('no TTC read claims a review its expert has not signed off', () {
    for (final r in kTtcReads) {
      if (!r.reviewed) continue;
      expect(kTtcSignedOffReads[r.author.en] ?? const <String>{},
          contains(r.id),
          reason: '"${r.id}" shows "Reviewed by ${r.author.en}" with a tick, '
              'but its id is not in kTtcSignedOffReads');
    }
  });

  test('an unsigned read keeps its words and wears the desk byline', () {
    final written = kTtcReadsAsWritten
        .firstWhere((r) => r.reviewed && r.author.en == 'Dr Ruchika Sood');
    final shown = kTtcReads.firstWhere((r) => r.id == written.id);
    expect(shown.reviewed, isFalse);
    expect(shown.author.en, 'ParentVeda team');
    expect(shown.title.en, written.title.en);
    expect(shown.sections.length, written.sections.length);
    expect(shown.evidence, same(written.evidence));
    // The planned reviewer is kept on the read as written.
    expect(written.author.en, 'Dr Ruchika Sood');
  });

  test('adding the id to the signed-off set flips it back', () {
    final written = kTtcReadsAsWritten
        .firstWhere((r) => r.reviewed && r.author.en == 'Dr Surbhi Sharma');
    final signed = ttcApplySignoff(written, signedOff: {
      'Dr Surbhi Sharma': {written.id},
    });
    expect(signed.reviewed, isTrue);
    expect(signed.author.en, 'Dr Surbhi Sharma');
    // Another expert's sign-off does not count for her read.
    final wrong = ttcApplySignoff(written, signedOff: {
      'Dr Ruchika Sood': {written.id},
    });
    expect(wrong.reviewed, isFalse);
  });

  testWidgets('the reader draws no REVIEWED BY and no tick on a TTC read',
      (tester) async {
    tester.view.physicalSize = const Size(360, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final read = kTtcReads.firstWhere((r) =>
        kTtcReadsAsWritten.any((w) => w.id == r.id && w.reviewed));
    await tester.pumpWidget(MaterialApp(
        home: PvReaderScreen(read: read, lang: AppLanguage.english)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.text('REVIEWED BY'), findsNothing);
    expect(find.text('ParentVeda team'), findsWidgets);
  });

  // ===========================================================================
  //  Door carousels, stories and infographics
  // ===========================================================================
  group('door stories and infographics', () {
    final tiles = [
      for (final page in kTtcFocusPages)
        for (final s in page.sections) ...s.tiles,
    ];
    String? writtenBy(TtcTile t) => switch (t) {
          TtcCarouselTile(:final reviewedBy) => reviewedBy,
          TtcInfographicTile(:final reviewedBy) => reviewedBy,
          _ => null,
        };

    test('no door story names a reviewer who has not signed it off', () {
      var named = 0;
      for (final t in tiles) {
        final raw = writtenBy(t);
        if (raw == null || raw.toLowerCase().contains('parentveda')) continue;
        named++;
        final shown = ttcStoryReviewer(raw, t.title);
        final signed = kTtcSignedOffStories.entries
            .any((e) => raw.contains(e.key) && e.value.contains(t.title));
        expect(ttcStoryBylineIsPerson(shown), signed,
            reason: '"${t.title}" shows "$shown"');
      }
      // The PCOS and IVF doors name experts in their data today.
      expect(named, greaterThan(0));
    });

    test('every signed-off title is a real tile', () {
      final titles = tiles.map((t) => t.title).toSet();
      for (final set in kTtcSignedOffStories.values) {
        for (final title in set) {
          expect(titles, contains(title),
              reason: 'a sign-off for "$title" matches no door tile');
        }
      }
    });

    test('a sign-off by that expert, for that title, flips it back', () {
      const raw = 'Reviewed by Dr Ruchika Sood, IVF gynaecologist';
      expect(
          ttcStoryReviewer(raw, 'Hair changes, explained'), 'ParentVeda team');
      expect(
          ttcStoryReviewer(raw, 'Hair changes, explained', signedOff: {
            'Dr Ruchika Sood': {'Hair changes, explained'},
          }),
          raw);
      // Another expert's sign-off, or another title, does not count.
      expect(
          ttcStoryReviewer(raw, 'Hair changes, explained', signedOff: {
            'Dr Surbhi Sharma': {'Hair changes, explained'},
          }),
          'ParentVeda team');
      expect(ttcStoryReviewer(null, 'x'), isNull);
      expect(ttcStoryReviewer('ParentVeda team', 'x'), 'ParentVeda team');
    });

    testWidgets('a door carousel opens with BY · ParentVeda team',
        (tester) async {
      final tile = tiles.whereType<TtcCarouselTile>().firstWhere((t) =>
          t.reviewedBy != null && t.reviewedBy!.contains('Dr Ruchika Sood'));
      await tester.pumpWidget(MaterialApp(
        home: TtcStoryScreen(
          title: tile.title,
          cards: tile.cards,
          hue: 268,
          reviewedBy: tile.reviewedBy,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.textContaining('REVIEWED BY'), findsNothing);
      expect(find.textContaining('Ruchika'), findsNothing);
      expect(find.text('BY  ·  ParentVeda team'), findsWidgets);
    });

    testWidgets('an infographic shows the team, with no tick',
        (tester) async {
      tester.view.physicalSize = const Size(400, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final tile = tiles
          .whereType<TtcInfographicTile>()
          .firstWhere((t) => t.reviewedBy != null);
      await tester.pumpWidget(
          MaterialApp(home: TtcInfographicScreen(tile: tile, hue: 268)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      final line = tester
          .widget<Text>(find.byKey(const ValueKey('ttc_infographic_byline')));
      expect(line.data, 'By ParentVeda team');
      expect(find.byIcon(Icons.verified_outlined), findsNothing);
      expect(find.textContaining('Reviewed by'), findsNothing);
    });
  });

  // ===========================================================================
  //  Courses, groups and classes on Trying to conceive
  // ===========================================================================
  group('TTC courses claim no review', () {
    PvOfferingView v(PvLearnKind kind, String name,
            {LifeStage stage = LifeStage.tryingToConceive}) =>
        PvOfferingView(
          id: '${kind.name}$name',
          stage: stage,
          kind: kind,
          title: 't',
          subtitle: 's',
          about: 'a',
          expert: PvLearnExpert(id: name, name: name, role: 'r'),
          hue: 1,
          facts: const [],
        );

    test('no "Reviewed by" and no seal on a TTC course or class', () {
      for (final kind in [
        PvLearnKind.course,
        PvLearnKind.masterclass,
        PvLearnKind.cohort,
        PvLearnKind.classPack,
      ]) {
        for (final who in ['Dr Surbhi Sharma', 'An andrologist', 'ParentVeda']) {
          final rows = pvTrustRowsFor(v(kind, who));
          for (final r in rows) {
            expect(r.title.toLowerCase(), isNot(contains('reviewed')),
                reason: '${kind.name} $who: "${r.title}"');
            expect(r.title.toLowerCase(), isNot(contains('panel')),
                reason: '${kind.name} $who: "${r.title}"');
            expect(r.mark, isNot(PvLearnMark.reviewed),
                reason: '${kind.name} $who draws the seal and tick');
          }
          expect(rows.length, 3);
        }
      }
      expect(pvTrustRowsFor(v(PvLearnKind.course, 'ParentVeda')).first.title,
          'Written by the ParentVeda team');
      expect(
          pvTrustRowsFor(v(PvLearnKind.masterclass, 'An andrologist'))
              .first
              .title,
          'Taught by an andrologist');
    });

    test('other stages are unchanged', () {
      final rows = pvTrustRowsFor(
          v(PvLearnKind.course, 'X', stage: LifeStage.pregnancy));
      expect(rows.first.mark, PvLearnMark.reviewed);
    });
  });
}
