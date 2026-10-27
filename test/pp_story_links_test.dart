// =============================================================================
//  Every link on a story page reaches the story (BEFORE-LAUNCH, 2026-10-27)
// -----------------------------------------------------------------------------
//  ⚠️ A CARDS PAGE OPENS AS THE STORY DECK, and the deck used to keep only the
//  first same-section page link, as a closing slide. Every link to another
//  door, a tool or a shelf was dropped: about fifty links on the story pages
//  across the parenting doors were never seen. The reader showed them; the
//  deck, which is the only thing that opens a CARDS page, did not.
//
//  The user chose option A after the prototype
//  (claude.ai/artifact/7U6dFgWt41Kfd6cqGfczbx): keep the stories, and make
//  every link a swipe-up. A link names the slide it belongs to (`slide:`), or
//  becomes a slide of its own where it is written. These tests hold both
//  halves over the data, every section at once, and the screen opening a
//  link to another door.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_story_screen.dart';

/// Every story page: a CARDS page the deck can hold.
Iterable<(String, PpPage, List<PpCarouselCard>)> _decks() sync* {
  for (final s in kPpSections) {
    for (final p in s.allPages) {
      if (p.format?.toUpperCase() != 'CARDS') continue;
      final slides = ppCardsAsSlides(p);
      if (slides != null) yield ('${s.id}/${p.id}', p, slides);
    }
  }
}

/// The links on a page that go somewhere.
List<PpLink> _links(PpPage p) => [
      for (final b in p.blocks)
        if (b is PpLink && (b.pageId != null || b.surfaceId != null)) b,
    ];

void main() {
  test('every link on a story page is on a slide', () {
    var links = 0;
    for (final (where, page, slides) in _decks()) {
      for (final l in _links(page)) {
        links++;
        final on = slides.where((s) =>
            s.isLinked && s.pageId == l.pageId && s.surfaceId == l.surfaceId);
        expect(on, isNotEmpty, reason: '$where: "${l.label}" is dropped by the story');
      }
    }
    // About fifty were dropped before; the count only guards the walk.
    expect(links, greaterThan(50));
  });

  test('a link that names its slide rides on that slide, one link a slide', () {
    var named = 0;
    for (final (where, page, slides) in _decks()) {
      final titles = [for (final s in slides) s.title];
      final claimed = <String>{};
      for (final l in _links(page)) {
        final slide = l.slide;
        if (slide == null) continue;
        named++;
        expect(titles, contains(slide),
            reason: '$where: "${l.label}" names a slide the page does not have: "$slide"');
        expect(claimed.add(slide), isTrue,
            reason: '$where: two links claim the slide "$slide"');
        final s = slides.firstWhere((s) => s.title == slide);
        expect(s.linkLabel, l.label,
            reason: '$where: "$slide" does not carry its link');
      }
    }
    expect(named, greaterThanOrEqualTo(16));
  });

  test('a link with no slide is a slide of its own, where it is written', () {
    // sick_or_head_bump: the falls link sits between two runs of cards, so its
    // slide sits between them too, not at the end.
    final (_, page, slides) =
        _decks().firstWhere((d) => d.$1 == 'parenting_sleep/sick_or_head_bump');
    final falls = slides.indexWhere((s) =>
        s.surfaceId == 'pp_page/parenting_safety/safety_falls');
    final later = slides.indexWhere((s) => s.title == 'Let your child sleep more');
    expect(falls, greaterThan(0));
    expect(falls, lessThan(later));
    expect(slides[falls].title, 'Falls from beds, stairs and balconies');
    expect(slides[falls].linkLabel, isNull, reason: 'the slide is the link');
    expect(page.blocks.whereType<PpLink>(), hasLength(3));
  });

  testWidgets('a swipe-up on a slide opens another door through the router', (tester) async {
    String? surface;
    await tester.pumpWidget(MaterialApp(
      home: PpStoryScreen(
        title: 'Test',
        hue: 188,
        cards: const [
          PpCarouselCard.linked('Papers', 'Passport, birth certificate.',
              surfaceId: 'pp_page/parenting_papers/pm_passport',
              linkLabel: "Your child's passport"),
        ],
        onPage: (_, _) {},
        onSurface: (_, id) => surface = id,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Swipe up: Your child's passport"));
    await tester.pumpAndSettle();
    expect(surface, 'pp_page/parenting_papers/pm_passport');
  });
}
