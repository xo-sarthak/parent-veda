// Door card names that over-promised or drifted from their tool (the tools
// terminal's hand-over item 4, 2026-10-29; PREGNANCY-GAP 36, TTC-GAP 31).
// A door tool card carries the tool's one name, so the card and the screen
// it opens agree, and the old names stay gone.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/doors/pv_door_partner.dart' show kPartnerDoor;
import 'package:parentveda/screens/tools/ready_for_birth_screen.dart'
    show kHospitalBagTitle;
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';

Iterable<PvDoorToolTile> _tools(PvDoorPage d) =>
    d.allTiles.whereType<PvDoorToolTile>();

Iterable<TtcToolTile> _ttcTools() => [
  for (final p in kTtcFocusPages)
    for (final s in p.sections) ...s.tiles.whereType<TtcToolTile>(),
];

String _ttcToolName(String id) => ttcToolGroups
    .expand((g) => g.tools)
    .firstWhere((t) => t.id == id)
    .nameEn;

void main() {
  test('every hospital bag card says Hospital bag (twins keeps its line)', () {
    for (final d in [kGettingReadyDoor, kLabourDoor, kPartnerDoor]) {
      final names = {
        for (final t in _tools(d))
          if (t.surfaceId == kLabourSurfaceBag || t.surfaceId == kReadySurfaceBag)
            t.title,
      };
      expect(names, {kHospitalBagTitle}, reason: d.bracketId);
    }
  });

  test('both checklist cards carry the Product checklist name', () {
    final lang = File('lib/localization/app_language.dart').readAsStringSync();
    final tool = RegExp(r"pclTitle => _p\('([^']+)'").firstMatch(lang)![1]!;
    for (final d in [kGettingReadyDoor, kPartnerDoor]) {
      final t = _tools(d).firstWhere((t) => t.surfaceId == kReadySurfaceStore);
      expect(t.title.toLowerCase(), tool.toLowerCase(), reason: d.bracketId);
    }
  });

  test('TTC door tool cards take the Tools tab name', () {
    final byId = {for (final t in _ttcTools()) t.id: t};
    expect(byId['ttc_tile_plan_your_own_week']!.title, _ttcToolName('nutrition'));
    expect(byId['ttc_tile_track_what_you_re_working_on']!.title,
        _ttcToolName('habits'));
    expect(byId['ttc_tile_track_this_treatment_cycle']!.title,
        _ttcToolName('treatment'));
  });

  test('the PCOS report card promises one cycle, not months', () {
    final t = _ttcTools().firstWhere(
        (t) => t.id == 'ttc_tile_what_your_cycle_shows');
    expect(t.surfaceId, 'ttc_cycle_report');
    expect(t.blurb, isNot(contains('months')));
  });

  test('the old names are gone from live door cards and the reads', () {
    const old = [
      'Shop the list',
      'Ready for Birth',
      'The hospital bag',
      'What you really need for the baby',
      'Plan your own week of meals',
      'Your habit trackers',
      'four habit trackers',
      'Track this treatment cycle',
    ];
    final titles = [
      for (final d in [kGettingReadyDoor, kLabourDoor, kPartnerDoor])
        for (final t in d.allTiles) t.title,
      for (final t in _ttcTools()) t.title,
      for (final t in _ttcTools()) t.blurb,
    ];
    final reads = File('lib/data/reads/pregnancy_reads_ready.dart')
        .readAsLinesSync()
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');
    for (final o in old) {
      expect(titles.where((t) => t.contains(o)), isEmpty, reason: o);
      if (o == 'Shop the list' || o == 'Ready for Birth') {
        expect(reads, isNot(contains(o)), reason: 'a read still names $o');
      }
    }
  });
}
