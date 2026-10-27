// =============================================================================
//  No link opens a whole door, or the whole expert roster (final review
//  item 6, 2026-10-27)
// -----------------------------------------------------------------------------
//  ⚠️ A link that opens a whole door ("Health, the whole section", "Papers and
//  money") hands her a door's home screen and asks her to find the answer
//  again. Ten links in seven doors did that, and one opened every expert
//  instead of the kind she needed. Each now names the page, or the expert
//  kind, that answers the next step.
//
//  Safety's door test held this for Safety alone (SF7). This holds it for
//  every door. A link to one area or tab of a door (`pp_section/<door>/<area>`)
//  is allowed: it lands on a narrow list, not the door's front. So are the
//  libraries (`pp_read`, `pp_courses`, `pp_find_help`, `pp_watch`,
//  `pp_recos`): each is a deliberate "see all", reviewed in item 10.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';

void main() {
  test('no link in any door opens a whole door or the bare expert roster', () {
    final wholeDoor = RegExp(r'^pp_section/[^/]+$');
    final bad = <String>[];
    for (final s in kPpSections) {
      for (final p in s.allPages) {
        for (final l in p.blocks.whereType<PpLink>()) {
          final id = l.surfaceId;
          if (id == null) continue;
          if (wholeDoor.hasMatch(id) || id == 'pp_experts') {
            bad.add('${s.id}/${p.id}: "${l.label}" -> $id');
          }
        }
      }
    }
    expect(bad, isEmpty,
        reason: 'Name the page that answers the next step, or the expert kind '
            '(pp_experts/<category>).');
  });

  test('the ten links name their pages', () {
    PpPage page(String section, String id) =>
        ppSectionFor(section)!.pageById(id)!;
    Iterable<String?> surfaces(PpPage p) =>
        p.blocks.whereType<PpLink>().map((l) => l.surfaceId);
    const exact = [
      ('parenting_first_40', 'f40_days_8_15', 'pp_page/parenting_papers/pm_birth_certificate'),
      ('parenting_first_40', 'f40_rest_and_food', 'pp_page/parenting_papers/pm_schemes'),
      ('parenting_first_40', 'f40_red_flags', 'pp_experts/Lactation expert'),
      ('parenting_maternal', 'work_schemes', 'pp_page/parenting_papers/pm_schemes'),
      ('parenting_maternal', 'body_rest', 'pp_page/parenting_first_40/f40_rest_and_food'),
      ('parenting_health', 'rec_abha', 'pp_page/parenting_papers/pm_health_insurance'),
      ('parenting_health', 'growth_flags', 'pp_page/parenting_development/dev_worth_checking'),
      ('parenting_feeding', 'solids_constipation', 'pp_page/parenting_health/tummy_constipation'),
      ('parenting_feeding', 'recipes_sick_days', 'pp_page/parenting_health/tummy_dehydration'),
      ('parenting_early_learning', 'school_admission', 'pp_page/parenting_papers/pm_birth_certificate'),
    ];
    for (final (section, id, target) in exact) {
      expect(surfaces(page(section, id)), contains(target), reason: '$section/$id');
    }
  });
}
