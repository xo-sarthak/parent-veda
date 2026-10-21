// =============================================================================
//  The phase screen (2026-10-21, Wave 5): the painting is the film's poster,
//  the Child snapshot draws each area's mark and opens its milestone page.
//  Since 2026-10-22 (Wave 6) the phase screen is a facade over the one phase
//  page (pp_phase_page.dart), so the same promises are checked on its keys:
//  was phase_detail_play / phase_detail_film_soon / phase_snapshot_<area>.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/pp_phase_docs.dart';
import 'package:parentveda/screens/post_pregnancy/phase_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_home_reads.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phases_data.dart';
import 'package:parentveda/screens/reader/pv_reader_screen.dart';
import 'package:parentveda/widgets/pv_placeholders.dart';

Future<void> _pump(WidgetTester t, AgePhase phase) async {
  t.view.physicalSize = const Size(360 * 3, 9000 * 3); // was 2800 tall: the phase page holds the whole doc (2026-10-22)
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: PhaseDetailScreen(phase: phase)));
  await t.pump(const Duration(milliseconds: 600));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the painting carries the film: play when there is one, a quiet line when not', (t) async {
    final phase = kPhases[6];
    await _pump(t, phase);
    final hasFilm = ppPhaseVideo(phase) != null;
    expect(find.byKey(const ValueKey('pp_phase_play')), hasFilm ? findsOneWidget : findsNothing);
    expect(find.byKey(const ValueKey('pp_phase_film_soon')), hasFilm ? findsNothing : findsOneWidget);
    expect(find.byType(PvVideoPlaceholder), findsNothing, reason: 'the separate placeholder card is gone');
    expect(t.takeException(), isNull);
  });

  testWidgets('every doc phase draws its five snapshot areas, each with its line', (t) async {
    for (final phase in [kPhases.first, kPhases[6], kPhases.last]) {
      final doc = ppPhaseDocFor(phase.number);
      if (doc == null) continue;
      await _pump(t, phase);
      for (final s in doc.snapshot) {
        expect(find.byKey(ValueKey('pp_doc_snapshot_${s.domain.name}')), findsOneWidget,
            reason: 'phase ${phase.number} ${s.domain.name}');
      }
      expect(t.takeException(), isNull, reason: 'phase ${phase.number}');
    }
  });

  testWidgets('a snapshot area opens its milestone page in the one reader', (t) async {
    final phase = kPhases[6];
    final doc = ppPhaseDocFor(phase.number)!;
    await _pump(t, phase);
    final first = doc.snapshot.firstWhere((s) => doc.milestoneFor(s.domain) != null);
    final row = find.byKey(ValueKey('pp_doc_snapshot_${first.domain.name}'));
    await t.ensureVisible(row);
    await t.pumpAndSettle();
    await t.tap(row);
    await t.pumpAndSettle();
    expect(find.byType(PvReaderScreen), findsOneWidget);
  });
}
