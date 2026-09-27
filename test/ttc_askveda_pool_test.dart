// Ask Veda and the new TTC content pool (2026-09-27, TTC gap plan B11).
//
// Three things are held here, each of which fails silently if it drifts:
//
// 1. THE TREATMENT STEP REACHES THE SERVICE. The wire body is a contract
//    across two repos (CLAUDE.md). The app sends `treatment_step` from the
//    same resolver its home uses, never from the partner's device, and the
//    service knows every value the app can send.
// 2. EVERY EXPORTED ID OPENS SOMETHING. The export names reads `ttcread_<id>`
//    and door tiles `ttcdoor_<bracket>__<slug>`; the screen's deep link must
//    resolve exactly those, and no id may end in `_hi` (the screen strips
//    that suffix as the Hinglish twin's).
// 3. HER "HIDE INTIMACY" CHOICE HOLDS IN ASK VEDA TOO.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';
import 'package:parentveda/ttc/ttc_treatment_round.dart';

void main() {
  final screen =
      File('lib/screens/ttc/ttc_askveda_screen.dart').readAsStringSync();
  final service =
      File('lib/services/remote/ask_veda_service.dart').readAsStringSync();

  group('the treatment step on the wire', () {
    test('the request body carries treatment_step', () {
      expect(service, contains("'treatment_step': treatmentStep"));
    });

    test('it comes from the home resolver, and never from the partner', () {
      expect(screen, contains('ttcHomeRoundPhaseOn(DateTime.now())?.name'));
      expect(
        RegExp(r'treatmentStep: widget\.partnerMode\s*\?\s*null')
            .hasMatch(screen),
        isTrue,
        reason: 'her round must not leave the partner device',
      );
    });

    test('the service knows every step the app can send', () {
      // Cross-repo, so only where both checkouts sit side by side.
      final prompt = File('../parentveda-askveda/app/prompt.py');
      if (!prompt.existsSync()) {
        markTestSkipped('Ask Veda repo not checked out beside this one');
        return;
      }
      final src = prompt.readAsStringSync();
      // ttcHomeRoundPhaseOn returns a running step, a result or between
      // rounds; never own cycle or planned.
      final sent = TtcRoundPhase.values.where((p) =>
          p.isRunning ||
          p == TtcRoundPhase.result ||
          p == TtcRoundPhase.betweenRounds);
      for (final p in sent) {
        expect(src, contains('"${p.name.toLowerCase()}": ('),
            reason: '${p.name} would fall back to "not pregnant"');
      }
    });
  });

  group('exported ids open something', () {
    test('every door tile slug finds its tile again', () {
      for (final page in kTtcFocusPages) {
        for (final s in page.sections) {
          for (final t in s.tiles) {
            final slug = ttcTileSlug(t);
            if (slug.isEmpty) continue;
            expect(slug.endsWith('_hi'), isFalse, reason: slug);
            expect(slug.contains('__'), isFalse, reason: slug);
            final hit = ttcTileBySlug(page, slug);
            expect(hit, isNotNull, reason: '${page.bracketId} $slug');
            expect(ttcTileSlug(hit!.$1), slug);
          }
        }
      }
    });

    test('no bracket id holds the tile separator', () {
      for (final page in kTtcFocusPages) {
        expect(page.bracketId.contains('__'), isFalse, reason: page.bracketId);
      }
    });

    test('no read id ends like a Hinglish twin', () {
      for (final r in kTtcReads) {
        expect(r.id.endsWith('_hi'), isFalse, reason: r.id);
      }
    });

    test('the screen opens reads, door tiles and every card set', () {
      expect(screen, contains("id.startsWith('ttcread_')"));
      expect(screen, contains("id.startsWith('ttcdoor_')"));
      expect(screen, contains('kTtcTreatmentInsights.values'));
      expect(screen, contains('ttcAllInsights'));
    });

    test('the export and the screen agree on the prefixes', () {
      final tool = File('tool/export_ttc_corpus.dart').readAsStringSync();
      expect(tool, contains("'ttcread_\${r.id}'"));
      expect(tool, contains("'ttcdoor_\${page.bracketId}__\$slug'"));
      // 'read' would be skipped by the editor-owned ratchet.
      expect(tool, contains("kind: 'ttcread'"));
    });
  });

  group('her hide-intimacy choice', () {
    test('the service cards and the offline reads both honour it', () {
      expect(screen, contains('for (final it in _shownContent(f))'));
      expect(screen, contains('for (final r in _matchingReads())'));
      expect(screen, contains('kTtcIntimateReadIds'));
      expect(screen, contains('kTtcIntimateInsightIds'));
      expect(screen, contains('kTtcIntimateGroupId'));
    });
  });
}
