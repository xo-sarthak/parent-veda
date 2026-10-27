// =============================================================================
//  ppFillPage — a door page, about this child (final review, 2026-10-27)
// -----------------------------------------------------------------------------
//  ⚠️ THE DOOR PAGES ARE WRITTEN WITH "HE" FOR THE CHILD, and until now they
//  reached the screen exactly as written: about 340 strings across the doors,
//  the emergency steps included ("Lay him on his side"). A girl's parent read
//  every instruction about a boy. The phase pages never had the problem,
//  because they pass through `ppFillChildFor` (pp_phases_data.dart): she and
//  her for a girl, the child's name when the parent did not say.
//
//  This is the same fill, applied to a whole page once, where every page is
//  opened (`_ppPageScreenAndKind`), so the reader, the story deck and the
//  blocks the stage draws itself all get the filled words. The trade-off:
//  filling at display keeps one authored copy (the data, the tests that read
//  it and the Ask Veda corpus stay as written), at the cost of a copy of the
//  page per open. A page is a few dozen strings, so the copy is cheap; a
//  second authored copy per child would not be.
//
//  ⚠️ TWO KINDS OF PAGE KEEP THEIR WORDS:
//    · a story (`format: 'STORY'`): "he" is the monkey, the king, Birbal;
//    · a page about an adult (`PpPage.aboutAdult`): "he" is her husband.
//  `test/pp_page_fill_test.dart` holds both, and that no "he" is left for a
//  girl anywhere else.
// =============================================================================

import 'pp_child_profile.dart' show ChildProfileStore;
import 'pp_content.dart';
import 'pp_phases_data.dart' show ppFillChildFor;

/// Whether [page] keeps its authored he/him/his.
bool ppPageKeepsPronouns(PpPage page) =>
    page.aboutAdult || page.format?.toUpperCase() == 'STORY';

/// The words-filler for the active child: he/him/his to she/her or the
/// child's name. Null for a boy's parent, whose pages are written for him.
String Function(String)? ppChildFiller([ChildProfileStore? child]) {
  final c = child ?? ChildProfileStore.instance;
  if (c.sexGiven && c.isBoy) return null;
  // No name given: "your baby" until one, then "your child". A page about a
  // four-year-old that says "your baby" reads as written for someone else.
  final name = c.active.nameMid == 'your baby' && c.ageInMonths >= 12
      ? 'your child'
      : c.active.nameMid;
  return (s) => ppFillChildFor(s, sexGiven: c.sexGiven, isBoy: c.isBoy, name: name);
}

/// A page's title as a list, a rail or the home shows it: filled like the
/// page it opens, so the row and the page agree.
String ppPageTitle(PpPage page, [ChildProfileStore? child]) {
  if (ppPageKeepsPronouns(page)) return page.title;
  final f = ppChildFiller(child);
  return f == null ? page.title : f(page.title);
}

/// [page] with every child pronoun filled for the active child. A boy's
/// parent gets the page itself, untouched.
PpPage ppFillPage(PpPage page, [ChildProfileStore? child]) {
  if (ppPageKeepsPronouns(page)) return page;
  final f = ppChildFiller(child);
  if (f == null) return page;
  return PpPage(
    id: page.id,
    title: f(page.title),
    subtitle: page.subtitle == null ? null : f(page.subtitle!),
    blocks: [for (final b in page.blocks) ppFillBlock(b, f)],
    bands: page.bands,
    format: page.format,
    toolSurfaceId: page.toolSurfaceId,
    linkedOnly: page.linkedOnly,
    pinned: page.pinned,
    comingSoon: page.comingSoon,
    ageLead: page.ageLead,
    aboutAdult: page.aboutAdult,
  );
}

/// [b] with [f] applied to every string a parent reads. Ids, surface ids,
/// kinds and numbers are untouched. A block with no words comes back as it
/// was.
PpBlock ppFillBlock(PpBlock b, String Function(String) f) {
  String? o(String? s) => s == null ? null : f(s);
  return switch (b) {
    PpIntro() => PpIntro(f(b.text)),
    PpArticle() => PpArticle([for (final p in b.paragraphs) f(p)], heading: o(b.heading)),
    PpSteps() => PpSteps([for (final s in b.steps) PpStep(f(s.title), o(s.detail))],
        heading: o(b.heading)),
    PpCards() => PpCards([for (final c in b.cards) PpCard(f(c.title), f(c.line))],
        heading: o(b.heading), hue: b.hue),
    PpTable() => PpTable(
        columns: [for (final c in b.columns) f(c)],
        rows: [
          for (final r in b.rows) [for (final c in r) f(c)],
        ],
        heading: o(b.heading),
        rowMonths: b.rowMonths,
      ),
    PpChartCard() => PpChartCard(
        title: f(b.title),
        rows: [for (final (a, v) in b.rows) (f(a), f(v))],
        subtitle: o(b.subtitle),
        note: o(b.note),
        hue: b.hue,
        rowMonths: b.rowMonths,
      ),
    PpCallout() => PpCallout(f(b.text), kind: b.kind, title: o(b.title)),
    PpScript() => PpScript([
        for (final l in b.lines)
          PpScriptLine(say: f(l.say), notThis: o(l.notThis), why: o(l.why)),
      ], heading: o(b.heading)),
    PpWhenLine(doctor: true) => PpWhenLine.doctor(f(b.text)),
    PpWhenLine() => PpWhenLine(f(b.text)),
    PpIndiaNote() => PpIndiaNote(f(b.text)),
    // The slide name is a card title, so it is filled the same way, or a
    // link that names "His first word" would no longer find "Her first word".
    PpLink() => PpLink(f(b.label),
        surfaceId: b.surfaceId, pageId: b.pageId, blurb: o(b.blurb), slide: o(b.slide)),
    PpConsult() => PpConsult(
        title: f(b.title), whoFor: f(b.whoFor), surfaceId: b.surfaceId, role: b.role),
    PpCarousel() => PpCarousel(
        cards: [for (final c in b.cards) ppFillSlide(c, f)],
        coverTitle: o(b.coverTitle),
        coverBlurb: o(b.coverBlurb),
        hue: b.hue,
        eyebrow: o(b.eyebrow),
      ),
    PpInteractive() => PpInteractive(
        kind: b.kind,
        title: f(b.title),
        items: [
          for (final it in b.items) PpInteractiveItem(f(it.title), o(it.detail), o(it.group)),
        ],
        blurb: o(b.blurb),
        closing: o(b.closing),
        closingPageId: b.closingPageId,
        closingLabel: o(b.closingLabel),
        hue: b.hue,
      ),
    PpAnimation() => PpAnimation(kind: b.kind, title: f(b.title), caption: o(b.caption)),
    PpIllustration() => PpIllustration(
        kind: b.kind,
        title: f(b.title),
        labels: [for (final l in b.labels) PpIllustrationLabel(f(l.title), o(l.detail))],
        caption: o(b.caption),
        asset: b.asset,
      ),
    // Film and sound slots, the Aadhaar reminder: titles of things that are
    // made or recorded, kept as they are.
    _ => b,
  };
}

/// One story slide with [f] applied to its words.
PpCarouselCard ppFillSlide(PpCarouselCard c, String Function(String) f) =>
    PpCarouselCard.all(
      title: f(c.title),
      body: f(c.body),
      pageId: c.pageId,
      surfaceId: c.surfaceId,
      linkLabel: c.linkLabel == null ? null : f(c.linkLabel!),
      myth: c.myth,
      fromMonths: c.fromMonths,
      toMonths: c.toMonths,
    );
