// =============================================================================
//  Twin pages link each other (final review item 7, 2026-10-27)
// -----------------------------------------------------------------------------
//  ⚠️ Two doors often answer one question from two sides: Family writes for
//  both parents, You, Maa writes for her; Development says when to check
//  speech, Early learning says how to grow it. You, Maa had no link into Family
//  at all, so a mother reading about her mother-in-law never learnt the Family
//  door had the same question, written for everyone. Each pair below links
//  both ways (or one way, where only one side has a next step), and this holds
//  it.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';

/// Each side is a section id and a page id, joined by a slash, as the
/// `pp_page/` surface names them.
const _pairs = [
  ('parenting_development/dev_help_talk', 'parenting_early_learning/skills_language'),
  ('parenting_family/fam_age_gap', 'parenting_maternal/people_spacing'),
  ('parenting_family/fam_choosing_childcare', 'parenting_maternal/work_childcare'),
  ('parenting_family/fam_dad_depression', 'parenting_maternal/people_partner_low'),
  ('parenting_family/fam_grandparents_help', 'parenting_maternal/people_mother_in_law'),
  ('parenting_family/fam_you_two', 'parenting_maternal/mind_relationship'),
  ('parenting_family/people_partner_anxiety', 'parenting_maternal/mind_anxiety'),
];

/// One way only: the second page is the next step, not a twin.
const _oneWay = [
  ('parenting_development/dev_speech_flags', 'pp_page/parenting_special_care/sc_therapies'),
  ('parenting_feeding/solids_when', 'pp_learn/co_weaning'),
  ('parenting_health/health_choking_response', 'pp_page/parenting_safety/safety_cpr'),
  ('parenting_traditional/first_festivals', 'pp_page/parenting_maternal/cani_fasting'),
];

PpPage _page(String path) {
  final [section, id] = path.split('/');
  return ppSectionFor(section)!.pageById(id)!;
}

Iterable<String?> _surfaces(PpPage p) =>
    p.blocks.whereType<PpLink>().map((l) => l.surfaceId);

void main() {
  test('each twin pair links both ways', () {
    for (final (a, b) in _pairs) {
      expect(_surfaces(_page(a)), contains('pp_page/$b'), reason: '$a -> $b');
      expect(_surfaces(_page(b)), contains('pp_page/$a'), reason: '$b -> $a');
    }
  });

  test('the one-way links land, and every target opens a screen', () {
    for (final (from, to) in _oneWay) {
      expect(_surfaces(_page(from)), contains(to), reason: from);
      expect(ppScreenForSurface(to), isNotNull, reason: to);
    }
    for (final (a, b) in _pairs) {
      expect(ppScreenForSurface('pp_page/$a'), isNotNull, reason: a);
      expect(ppScreenForSurface('pp_page/$b'), isNotNull, reason: b);
    }
  });
}
