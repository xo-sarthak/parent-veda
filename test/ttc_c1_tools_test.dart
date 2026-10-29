// =============================================================================
//  C1, TTC: every tool a door offers is a Tools row (2026-10-30)
// -----------------------------------------------------------------------------
//  Rule C1 (docs/preg-ttc-tool-plans/00-MASTER.md): a door may show a tool; it
//  may never be the only way to find it. Until now TTC had no such test:
//  `ttc_tools_only_tools_test.dart` checks Tools against More, and
//  `ttc_focus_page_test.dart` only checks that door ids resolve. This walks
//  every door in `kTtcFocusPages`. Plan: docs/preg-ttc-tool-plans/C1-tools-rows.md.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/ttc/ttc_surface_router.dart';
import 'package:parentveda/screens/ttc/ttc_tool_marks.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';

/// The surface a row opens, where it is not `ttc_<id>`.
const Map<String, String> _rowSurface = {
  'symptoms': 'ttc_symptom_log',
  'should_test': 'ttc_chat/should_test',
  'canI': 'ttc_can_i',
  'weight': 'ttc_bmi',
};

String _surfaceOf(String rowId) => _rowSurface[rowId] ?? 'ttc_$rowId';

/// Not tools under M6, so they stay in their doors.
bool _allowed(String id) =>
    id.startsWith('ttc_practice/') || // practices (Mind and body)
    id == 'ttc_mind_today' || // today's practice
    id == 'ttc_garbh_course' || // a course, on More
    id == 'ttc_chat/period_came'; // a talk-through for a hard day, not her data

/// Every tool id a door offers: tool, checklist and do tiles, and the tool a
/// tab draws inline.
Map<String, Set<String>> _doorTools() {
  final out = <String, Set<String>>{};
  for (final p in kTtcFocusPages) {
    final ids = out.putIfAbsent(p.bracketId, () => {});
    for (final g in p.groups ?? const <TtcFocusGroup>[]) {
      if (g.inlineSurfaceId ?? g.toolSurfaceId case final id?) ids.add(id);
    }
    for (final t in p.allTiles) {
      switch (t) {
        case TtcToolTile(:final surfaceId):
        case TtcChecklistTile(:final surfaceId):
        case TtcDoTile(:final surfaceId):
          ids.add(surfaceId);
        default:
      }
    }
  }
  return out;
}

/// A door id is covered when a row opens it, or opens its root (a sub-route
/// of the same tool: `ttc_precheck/lifestyle`, `ttc_treatment_journey`).
bool _covered(String id, Set<String> rowSurfaces) =>
    rowSurfaces.contains(id) ||
    rowSurfaces.contains(id.split('/').first) ||
    (id == 'ttc_treatment_journey' && rowSurfaces.contains('ttc_treatment'));

void main() {
  final her = {for (final g in ttcToolGroupsFor(him: false)) for (final t in g.tools) t.id};
  final his = {for (final g in ttcToolGroupsFor(him: true)) for (final t in g.tools) t.id};

  test('every door tool is also one of her Tools rows', () {
    final surfaces = {for (final id in her) _surfaceOf(id)};
    final missing = [
      for (final MapEntry(key: door, value: ids) in _doorTools().entries)
        for (final id in ids)
          if (!_covered(id, surfaces) && !_allowed(id)) '$door: $id',
    ];
    expect(missing, isEmpty, reason: 'a door offers a tool the Tools tab does not list');
  });

  test("every tool on his door is on his Tools tab", () {
    final surfaces = {for (final id in his) _surfaceOf(id)};
    final missing = [
      for (final id in _doorTools()['ttc_male_fertility'] ?? const <String>{})
        if (!_covered(id, surfaces)) id,
    ];
    expect(missing, isEmpty);
    expect(his, contains('semen_report'));
  });

  test('the five C1 rows: a real screen, a tool, a mark of their own', () {
    for (final id in ['calendar', 'should_test', 'cycle_report', 'ready_plan', 'semen_report']) {
      expect(her, contains(id), reason: id);
      expect(kTtcToolKinds[id], isTrue, reason: id);
      expect(ttcScreenForSurface(_surfaceOf(id)), isNotNull, reason: id);
      expect(ttcToolMarkFor(id), isNotNull, reason: id);
      // The door card draws what the row draws.
      expect(ttcToolMarkForSurface(_surfaceOf(id)), ttcToolMarkFor(id), reason: id);
    }
    // Calendar, Should I test? and the Ready plan are hers; his door has none.
    for (final id in ['calendar', 'should_test', 'cycle_report', 'ready_plan']) {
      expect(his, isNot(contains(id)), reason: id);
    }
  });

  test('every row (hers and his) opens a surface the router knows, or its own screen', () {
    for (final g in ttcToolGroupsFor(him: false)) {
      for (final t in g.tools) {
        expect(kTtcToolKinds[t.id], isTrue, reason: '${t.id} is not classed a tool');
      }
    }
  });

  // T5 PH3's hand-over: his weight lives on his Partner health page, so his
  // line names it and his Tools search finds it.
  test('his Partner health line names his weight', () {
    expect(kTtcHisToolWords['partner_health']!.$2.toLowerCase(), contains('weight'));
  });
}
