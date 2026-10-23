// =============================================================================
//  An activity in the one reader, and the Development door as the one area page
// -----------------------------------------------------------------------------
//  2026-10-21, Wave 5b ("old screens still reachable from the home").
//
//  ONE READER (CLAUDE.md): an activity is a piece of writing, so it opens in
//  `PvReaderScreen` as a `PvRead`, like every page, look-up and milestone. Its
//  steps ride as a `PpSteps` custom block, drawn by `PpBlockView`, the same
//  numbered list every parenting page draws (Mobbin: Nike Training Club's
//  "Three tips" and Lifesum's instructions: a plain title, numbered steps, no
//  cards). `DevelopmentActivityScreen` is now a facade over [ppActivityReader],
//  so its ten callers move in one place.
//
//  ONE AREA PAGE: the old `DevelopmentAreaScreen` and `DevelopmentHomeScreen`
//  were a second, older Development section beside the Development door. Both
//  now open the door ([ppDevelopmentDoor]), on the tab that holds the area.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/doors/pp_door_data.dart' show ppDoorFor;
import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../reader/pv_reader_screen.dart';
import 'doors/pp_door_screen.dart' show PpDoorScreen;
import 'pp_content.dart' show PpBlock, PpBlockView, PpStep, PpSteps;
import 'pp_activity_paintings.dart' show ppActivityPainting;
import 'pp_development_data.dart' show DevActivity, devAreaById;
import 'pp_phases_data.dart' show ppFillChild;
import 'pp_search.dart' show ppOpenSurface;

LocalizedText _same(String s) => LocalizedText(en: s, hi: s);
LocalizedText _fill(String s) => _same(ppFillChild(s));

/// The Development door's tab for one of the eight development areas. The
/// door groups by what a parent wants to do, not by area: talking has its own
/// tab, every other area lives under "What to do".
String ppDevelopmentTabFor(String areaId) => areaId == 'language' ? 'talking' : 'what_to_do';

/// One activity as a read, in the order the activity page used: what it is,
/// what it builds and why, what you need, how to do it, things to remember,
/// keeping it safe, variations, the milestones it supports.
PvRead ppActivityAsRead(DevActivity a) {
  final area = devAreaById(a.areaId);
  return PvRead(
    id: 'pp_activity_${a.id}',
    kicker: _same('${area.name} · ${a.ageTag}'),
    title: _fill(a.title),
    teaser: _fill(a.intro ?? a.benefit),
    scaleSetter: _same(a.metaLine),
    author: _same('ParentVeda editorial'),
    authorRole: _same('Something to do together'),
    reviewed: false,
    hue: 268,
    // The activity's painting as the hero once it has one (Wave 8).
    imageUrl: ppActivityPainting(a.id),
    sections: [
      if (a.skills.isNotEmpty) PvReadSection(heading: _same('What it builds'), bullets: [for (final s in a.skills) _fill(s)]),
      // The intro already opened the page for a doc activity; the benefit is
      // the "why" for every activity.
      if (a.intro != null)
        PvReadSection(heading: _same('Why ParentVeda recommends it'), paragraphs: [_fill(a.benefit)]),
      if (a.materials.isNotEmpty)
        PvReadSection(heading: _same('What you’ll need'), bullets: [for (final m in a.materials) _fill(m)]),
      PvReadSection(
        heading: _same('How to do it'),
        custom: PpSteps([for (final s in a.steps) PpStep(ppFillChild(s))]),
      ),
      if (a.remember.isNotEmpty)
        PvReadSection(heading: _same('Things to remember'), bullets: [for (final r in a.remember) _fill(r)]),
      if (a.safety.isNotEmpty)
        PvReadSection(
          callout: PvCallout(
            tone: PvCalloutTone.note,
            title: _same('Keep it safe'),
            body: _fill(a.safety.join('\n')),
          ),
        ),
      if (a.variations case final v?) PvReadSection(heading: _same('Variations'), paragraphs: [_fill(v)]),
      if (a.linkedMilestones.isNotEmpty)
        PvReadSection(
          heading: _same(a.linkedMilestones.length == 1 ? 'The milestone it supports' : 'The milestones it supports'),
          bullets: [for (final m in a.linkedMilestones) _fill(m)],
        ),
    ],
    whenToSeeSomeone: kPvShortPieceCallout,
    faqs: const [],
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _same('More for ${area.name.toLowerCase()}'),
        value: _same('The Development pages for this area, by age.'),
        surfaceId: 'pp_section/parenting_development/${ppDevelopmentTabArea(a.areaId)}',
      ),
    ],
  );
}

/// The door area id that lands on [ppDevelopmentTabFor]'s tab through the
/// router's `pp_section/<door>/<area>` surface.
String ppDevelopmentTabArea(String areaId) => areaId == 'language' ? 'speech_language' : 'help_develop';

/// The reader for one activity, with parenting's renderer for the steps.
Widget ppActivityReader(DevActivity a) => PvReaderScreen(
      read: ppActivityAsRead(a),
      // Parenting authors in English (CLAUDE.md, "New work is English").
      lang: AppLanguage.english,
      customBlock: (context, block) => PpBlockView(block: block as PpBlock, onSurface: ppOpenSurface),
      openSurface: ppOpenSurface,
    );

/// The Development door, opened on the tab that holds [areaId] when given.
Widget ppDevelopmentDoor({String? areaId}) => PpDoorScreen(
      door: ppDoorFor('parenting_development')!,
      initialTabId: areaId == null ? null : ppDevelopmentTabFor(areaId),
      onSurface: ppOpenSurface,
    );
