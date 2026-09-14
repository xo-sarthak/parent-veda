// =============================================================================
//  The parenting doors, all of them, one sanity gate
// -----------------------------------------------------------------------------
//  Written at the end of the eleven briefs (2026-09-14) as the check the
//  user asked for: every door's areas exist, every surface any parenting
//  page or door points at resolves to a screen, every in-section page link
//  lands, every coming-soon card is in the owed ledger, and the ten sections
//  with a door have the age rule on. The per-door tests hold each brief's
//  map; this one holds the wiring gate across all of them at once, so a
//  future edit that leaves a link pointing at nothing fails here by name.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('ten doors, one per library section; the shop is the one tile without', () {
    final doorIds = kPpDoors.map((d) => d.sectionId).toList();
    expect(doorIds.toSet(), hasLength(doorIds.length), reason: 'one door per section');
    expect(doorIds, containsAll([
      'parenting_sleep', 'parenting_feeding', 'parenting_health', 'parenting_development',
      'parenting_behaviour', 'parenting_potty', 'parenting_early_learning',
      'parenting_first_40', 'parenting_maternal', 'parenting_traditional',
    ]));
    for (final d in kPpDoors) {
      final s = ppSectionFor(d.sectionId);
      expect(s, isNotNull, reason: d.sectionId);
      expect(s!.autoScope, isTrue, reason: '${d.sectionId}: the age rule is app-wide');
      for (final t in d.tabs) {
        for (final id in t.areaIds) {
          expect(s.areas.any((a) => a.id == id), isTrue, reason: '${d.sectionId}/${t.id} names area "$id"');
        }
      }
      for (final id in d.hiddenAreaIds) {
        expect(s.areas.any((a) => a.id == id), isTrue, reason: '${d.sectionId} hides area "$id"');
      }
    }
  });

  test('every surface a door or a page points at resolves to a screen', () {
    final bad = <String>[];
    void check(String where, String? surface) {
      if (surface == null) return;
      if (ppScreenForSurface(surface) == null) bad.add('$where -> $surface');
    }
    for (final d in kPpDoors) {
      for (final t in d.tabs) {
        for (final tool in t.tools) {
          check('${d.sectionId}/${t.id}/tool', tool.surfaceId);
        }
      }
      check('${d.sectionId}/closing', d.closing?.surfaceId);
    }
    for (final s in kPpSections) {
      for (final p in s.allPages) {
        check('${s.id}/${p.id}/tool', p.toolSurfaceId);
        for (final b in p.blocks) {
          if (b is PpLink) check('${s.id}/${p.id}/link', b.surfaceId);
          if (b is PpConsult) check('${s.id}/${p.id}/consult', b.surfaceId);
        }
      }
      for (final t in s.tools) {
        check('${s.id}/tool', t.surfaceId);
      }
    }
    expect(bad, isEmpty, reason: 'dead surfaces:\n${bad.join('\n')}');
  });

  test('every in-section page link and every tool that follows a page lands', () {
    final bad = <String>[];
    for (final s in kPpSections) {
      for (final p in s.allPages) {
        for (final b in p.blocks) {
          if (b is PpLink && b.pageId != null && s.pageById(b.pageId!) == null) {
            bad.add('${s.id}/${p.id} -> page "${b.pageId}"');
          }
          if (b is PpInteractive && b.closingPageId != null && s.pageById(b.closingPageId!) == null) {
            bad.add('${s.id}/${p.id} -> closing page "${b.closingPageId}"');
          }
          if (b is PpCarousel) {
            for (final c in b.cards) {
              if (c.pageId != null && s.pageById(c.pageId!) == null) {
                bad.add('${s.id}/${p.id} -> slide page "${c.pageId}"');
              }
            }
          }
        }
      }
    }
    for (final d in kPpDoors) {
      final s = ppSectionFor(d.sectionId)!;
      for (final t in d.tabs) {
        for (final tool in t.tools) {
          if (tool.afterPageId != null && s.pageById(tool.afterPageId!) == null) {
            bad.add('${d.sectionId}/${t.id} tool after page "${tool.afterPageId}"');
          }
        }
        if (t.redFlagPageId != null && s.pageById(t.redFlagPageId!) == null) {
          bad.add('${d.sectionId}/${t.id} red flag "${t.redFlagPageId}"');
        }
        if (t.jumpToTabId != null && !d.tabs.any((x) => x.id == t.jumpToTabId)) {
          bad.add('${d.sectionId}/${t.id} jumps to "${t.jumpToTabId}"');
        }
      }
    }
    expect(bad, isEmpty, reason: 'dead page links:\n${bad.join('\n')}');
  });

  test('every coming-soon card, on every section, is in the owed ledger', () {
    final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
    final missing = <String>[];
    for (final s in kPpSections) {
      for (final p in s.allPages.where((p) => p.comingSoon)) {
        if (!ledger.contains(p.id)) missing.add('${s.id}/${p.id}');
      }
    }
    expect(missing, isEmpty, reason: 'coming-soon cards nobody owes:\n${missing.join('\n')}');
  });

  test('a page that opens a tool or another page carries no copy of its own', () {
    for (final s in kPpSections) {
      for (final p in s.allPages.where((p) => p.toolSurfaceId != null)) {
        expect(p.blocks, isEmpty, reason: '${s.id}/${p.id} opens ${p.toolSurfaceId} and also holds blocks');
      }
    }
  });
}
