// =============================================================================
//  A parenting page, as an article — the adapter, not a rewrite
// -----------------------------------------------------------------------------
//  Every parenting door page (`PpPage`, eleven sections, hundreds of pages)
//  rendered through `PpContentPage`: its own back button, its own title
//  size, its own spacing, no picture, no byline, no foot. The user's rule
//  (2026-09-17): one article format for the whole app — `PvReaderScreen`,
//  the piece he confirmed in TTC — and "new additions in future get under
//  the same template". So:
//
//  ⚠️ THE PAGE DATA DOES NOT MOVE. `PpPage` and its blocks stay exactly as
//  authored — tables, chart cards, scripts, consult offers, audio, all of it —
//  and this file turns one page into a `PvRead` at the moment it opens. The
//  blocks the reader models (an article's paragraphs, a callout, the doctor
//  line, a link) become the reader's own sections, callout and next steps;
//  the blocks it does not model ride along as `PvReadSection.custom` and
//  render through `PpBlockView` — the same widget, the same look, inside the
//  article's frame. Nothing is lost and nothing is rewritten as prose.
//
//  ⚠️ WHY THIS IS THE UNIFICATION AND NOT ANOTHER FORMAT. A parenting page
//  now has the picture frame, the title at 24, the teaser, the byline, the
//  lede rule, the body type, the when-to-ask line, "Was this helpful?" and
//  the foot tiles — because it IS a PvRead on the one screen. A new page
//  written tomorrow in `pp_door_*.dart` gets all of that without being told,
//  and `test/reader_unification_test.dart` fails the build if any screen
//  pushes the old page renderer again.
//
//  What the adapter decides:
//    · teaser  = the page subtitle, else the intro block, else nothing.
//    · lede    = the intro when the subtitle took the teaser slot; else the
//                first paragraph of the first article block (lifted out of
//                it); else the teaser again is NOT repeated — the lede is
//                simply omitted by handing the reader an empty string, which
//                it renders as nothing.
//    · sections, in `orderedBlocks` order (video hoisted, as the page rule
//                says): article → section; callout → section with a callout;
//                everything else → custom.
//    · whenToSeeSomeone = the first `PpWhenLine` (urgent tone — that is
//                exactly what it is), else the shared short-piece line.
//                Further when-lines become note callouts in place.
//    · nextSteps = the page's links. A surface link is a tool tile; a page
//                link opens the sibling page through `openAction`.
//    · byline  = the desk, no verified mark (`reviewed: false`) — no named
//                clinician stands behind a parenting page yet. The role line
//                names the section, so the piece says where it belongs.
//    · hue     = the area's hue, so the picture frame and the foot tiles
//                carry the door's colour.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../reader/pv_reader_screen.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

/// The id a page carries as a read: `pp_page_<section>_<page>`.
const String kPpPageReadPrefix = 'pp_page_';

/// The action a page-to-page link carries on its next-step tile; the reader
/// hands it back through `openAction`, and `openPpPageRead` resolves it.
const String kPpPageLinkAction = 'pp_page:';

LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

PvCallout _callout(PpCallout c) {
  final tone = switch (c.kind) {
    PpCalloutKind.doctor => PvCalloutTone.urgent,
    PpCalloutKind.key ||
    PpCalloutKind.myth ||
    PpCalloutKind.safety =>
      PvCalloutTone.note,
  };
  final title = c.title ??
      switch (c.kind) {
        PpCalloutKind.key => 'Worth remembering',
        PpCalloutKind.doctor => 'Worth raising with a doctor',
        PpCalloutKind.myth => 'A common belief, checked',
        PpCalloutKind.safety => 'For safety',
      };
  return PvCallout(tone: tone, title: _same(title), body: _same(c.text));
}

/// The page as a read. Pure — the same page always yields the same read.
PvRead ppPageAsRead(PpSection section, PpPage page) {
  final blocks = List<PpBlock>.of(page.orderedBlocks);

  // ---- the head: teaser and lede ------------------------------------------
  PpIntro? intro;
  for (final b in blocks) {
    if (b is PpIntro) {
      intro = b;
      break;
    }
  }
  if (intro != null) blocks.remove(intro);

  final String teaser;
  String lede;
  if (page.subtitle case final sub?) {
    teaser = sub;
    lede = intro?.text ?? '';
  } else {
    teaser = intro?.text ?? '';
    lede = '';
  }
  if (lede.isEmpty) {
    // Lift the first paragraph of the first article block into the lede, so
    // the page opens the way every other article does — on its scale-setter.
    for (var i = 0; i < blocks.length; i++) {
      final b = blocks[i];
      if (b is PpArticle && b.heading == null && b.paragraphs.isNotEmpty) {
        lede = b.paragraphs.first;
        final rest = b.paragraphs.sublist(1);
        if (rest.isEmpty) {
          blocks.removeAt(i);
        } else {
          blocks[i] = PpArticle(rest);
        }
        break;
      }
      if (b is PpArticle) break; // a headed article is not an opening
    }
  }

  // ---- the doctor line ------------------------------------------------------
  PvCallout? when;
  final sections = <PvReadSection>[];
  final next = <PvReadNextStep>[];

  for (final b in blocks) {
    switch (b) {
      case PpArticle(:final heading, :final paragraphs):
        sections.add(PvReadSection(
          heading: heading == null ? null : _same(heading),
          paragraphs: [for (final p in paragraphs) _same(p)],
        ));
      case PpCallout():
        sections.add(PvReadSection(callout: _callout(b)));
      case PpWhenLine(:final text):
        if (when == null) {
          when = PvCallout(
            tone: PvCalloutTone.urgent,
            title: _same('When to see a doctor'),
            body: _same(text),
          );
        } else {
          sections.add(PvReadSection(
            callout: PvCallout(
                tone: PvCalloutTone.note,
                title: _same('Also worth a call'),
                body: _same(text)),
          ));
        }
      case PpLink(:final label, :final blurb, :final surfaceId, :final pageId):
        if (surfaceId != null) {
          next.add(PvReadNextStep(
            kind: PvNextKind.tool,
            title: _same(label),
            value: _same(blurb ?? ''),
            surfaceId: surfaceId,
          ));
        } else if (pageId != null) {
          next.add(PvReadNextStep(
            kind: PvNextKind.read,
            title: _same(label),
            value: _same(blurb ?? ''),
            action: '$kPpPageLinkAction$pageId',
          ));
        }
      default:
        // Tables, steps, cards, charts, scripts, India notes, video and audio
        // slots, carousels, animations, illustrations, consults — the
        // parenting renderer draws them inside the article's frame.
        sections.add(PvReadSection(custom: b));
    }
  }

  // The area the page sits in, for its hue and its name.
  PpArea? area;
  for (final a in section.areas) {
    if (a.pages.any((p) => p.id == page.id)) {
      area = a;
      break;
    }
  }

  return PvRead(
    id: '$kPpPageReadPrefix${section.id}_${page.id}',
    kicker: _same(area?.title ?? section.title),
    title: _same(page.title),
    teaser: _same(teaser),
    scaleSetter: _same(lede),
    author: _same('ParentVeda editorial'),
    authorRole: _same(section.title),
    reviewed: false,
    hue: area?.hue ?? 268,
    sections: sections,
    whenToSeeSomeone: when ?? kPvShortPieceCallout,
    faqs: const [],
    nextSteps: next,
  );
}

/// The reader for a page: the read above, with the parenting renderer for
/// its custom blocks and the section's own page-to-page navigation.
Widget ppPageReader(
  PpSection section,
  PpPage page, {
  void Function(BuildContext context, String surfaceId)? onSurface,
  void Function(BuildContext context, String pageId)? onPage,
}) {
  final read = ppPageAsRead(section, page);
  return PvReaderScreen(
    read: read,
    // Parenting authors in English (CLAUDE.md, "New work is English"); the
    // strings are `_same` in both slots, so the flag changes nothing here.
    lang: AppLanguage.english,
    customBlock: (context, block) => PpBlockView(
      block: block as PpBlock,
      onSurface: onSurface,
      onPage: onPage,
    ),
    openSurface: onSurface,
    openAction: (context, action) {
      if (action.startsWith(kPpPageLinkAction)) {
        onPage?.call(context, action.substring(kPpPageLinkAction.length));
      }
    },
  );
}
