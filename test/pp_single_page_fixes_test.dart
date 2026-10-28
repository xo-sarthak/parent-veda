// =============================================================================
//  Single-page fixes from the final review (item 8, 2026-10-27)
// -----------------------------------------------------------------------------
//  Six small things, each a page that said something slightly wrong:
//    · Sukanya Samriddhi matures 21 years after opening, not at age 21;
//    · honey sat under "before six months", which read as fine after;
//    · a vitamin D dose in IU, where the dose is the paediatrician's;
//    · two tiles to one ceremony safety page on ear piercing and mundan;
//    · Tele-MANAS inside a doctor box on two You, Maa pages;
//    · Health typing 112, 108 and the poison line instead of the constants.
//  The helpline and the numbers are held across the doors, not page by page,
//  because both are rules a new page can break without anyone noticing.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/data/mind_mood_data.dart'
    show kCrisisHelplineNumber;
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';

PpPage _page(String section, String id) => ppSectionFor(section)!.pageById(id)!;

String _text(PpPage p) => [
      for (final b in p.blocks)
        if (b is PpIntro) b.text
        else if (b is PpArticle) ...b.paragraphs
        else if (b is PpCards) for (final c in b.cards) '${c.title} ${c.line}'
        else if (b is PpCallout) b.text
        else if (b is PpWhenLine) b.text,
    ].join(' ');

void main() {
  test('Tele-MANAS is never inside a doctor box, in any door', () {
    final inBox = [
      for (final s in kPpSections)
        for (final p in s.allPages)
          for (final c in p.blocks.whereType<PpCallout>())
            if (c.kind == PpCalloutKind.doctor &&
                (c.text.contains(kCrisisHelplineNumber) || c.text.contains('Tele-MANAS')))
              '${s.id}/${p.id}',
    ];
    expect(inBox, isEmpty, reason: 'the helpline is its own card, from the constant');
    for (final id in ['mind_birth_trauma', 'people_partner_low']) {
      final cards = _page('parenting_maternal', id).blocks.whereType<PpCallout>();
      expect(cards.where((c) => c.text.contains(kCrisisHelplineNumber)), hasLength(1), reason: id);
    }
  });

  test('Health types no emergency number; the constants carry them', () {
    final number = RegExp(r'\b(112|108|102)\b(?!\.\d|\d| ?F\b)|1800-116-117');
    for (final f in ['lib/screens/post_pregnancy/pp_health_content.dart', 'lib/data/doors/pp_door_health.dart']) {
      final src = File(f).readAsStringSync()
          .replaceAllMapped(RegExp(r'/\*[\s\S]*?\*/'), (m) => m[0]!.replaceAll(RegExp(r'[^\n]'), ' '));
      for (final (i, line) in src.split('\n').indexed) {
        if (line.trimLeft().startsWith('//')) continue;
        expect(number.hasMatch(line), isFalse, reason: '$f:${i + 1}: $line');
      }
    }
  });

  test('ear piercing and mundan each have one tile to the ceremony safety page', () {
    final s = ppSectionFor('parenting_traditional')!;
    for (final p in s.allPages) {
      final tiles = p.blocks.whereType<PpLink>().where((l) => l.pageId == 'ceremony_day_safety');
      expect(tiles.length, lessThanOrEqualTo(1), reason: p.id);
    }
  });

  test('the three copy fixes hold', () {
    final papers = ppSectionFor('parenting_papers')!;
    final sukanya = [for (final p in papers.allPages) _text(p)].join(' ');
    expect(sukanya, isNot(contains('matures when your daughter is 21')));
    expect(sukanya, contains('21 years after the account is opened'));

    final grand = _page('parenting_family', 'fam_grandparents_help');
    final firm = grand.blocks.whereType<PpCards>().firstWhere((c) => c.heading == 'Hold firm on');
    final six = firm.cards.firstWhere((c) => c.title == 'Nothing but milk before six months');
    expect(six.line, isNot(contains('honey')));
    expect(firm.cards.map((c) => c.title), contains('No honey before one year'));

    final feeding = ppSectionFor('parenting_feeding')!;
    for (final p in feeding.allPages) {
      expect(_text(p), isNot(contains(' IU')), reason: '${p.id}: the dose is the paediatrician\'s');
    }
  });
}
