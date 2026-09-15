// =============================================================================
//  Skilling doors — the door shell over a skill door's content
// -----------------------------------------------------------------------------
//  ⚠️ THE FOURTH DOOR ENGINE, AND THE REASON IT IS NOT THE THIRD.
//
//  Pregnancy has `pv_door_data.dart`; parenting has `pp_door_data.dart`,
//  whose header says of the pregnancy one: "importing either from here would
//  make a parenting screen break when a pregnancy constructor changes. So
//  parenting has its own shell, in its own files, with the same SHAPE." Both
//  are open in other terminals as this is written. Skilling takes the same
//  seam for the same reason: its own copy, value for value, sharing only
//  what is stage-neutral (`V2Palette`, `V3HeroField`, `V3SkillArt`).
//
//  ⚠️ WHAT IS SKILLING'S OWN. A parenting tab names AREA IDS and the screen
//  reads the pages from the section. A skill door's five tabs are the
//  brief's five child SURFACES — Today's thing to try · Things to do ·
//  Lessons · AI, explained · What I've made and tried — and every skill
//  brief lists the same five ("reuses the shell"). So a tab names a KIND,
//  and the screen draws that kind from the door's `SkDoorContent` for her
//  band: the today card, the activity rails by thinking skill, the lesson
//  sets, the cross-band set, the keepsake tool. A door file chooses labels,
//  icons and hues; it cannot invent a sixth surface without a brief naming
//  one (`SkTabKind.pages` is the escape hatch — a rail of named pages — for
//  the brief that does).
//
//  ⚠️ THE FOUR PARENT SURFACES ARE NOT TABS. Set up and consent, the course
//  shelf, the product shelf and the parent note are parent-side, behind the
//  grown-up gate, reached from the closing card under every tab. The user's
//  call (2026-09-14, question 4): the brief literally — child surfaces on
//  the selector, parent surfaces behind the gate.
// =============================================================================

import 'package:flutter/material.dart' show IconData;

import 'sk_door_coding.dart';
import 'sk_door_communication.dart';

export 'sk_door_coding.dart';
export 'sk_door_communication.dart';

/// Which of the brief's child surfaces a tab draws.
enum SkTabKind {
  /// One clear thing to do now, scoped to her band. One rail, the today
  /// card pinned first.
  today,

  /// The full set for her band: one rail per thinking skill.
  activities,

  /// The teaching spine: one rail per lesson set in her band.
  lessons,

  /// The cross-band set (Coding's AI literacy): one rail, her band's cards.
  crossBand,

  /// The no-score keepsake: a Tool card that opens it.
  keepsake,

  /// A rail of named pages, for a brief that asks for a surface the five
  /// kinds do not cover. Nothing uses it yet.
  pages,
}

/// One skill door: a shell over one `SkDoorContent`.
class SkDoor {
  const SkDoor({
    required this.doorId,
    required this.tabs,
    this.heroImageUrl,
    this.closing,
    this.disclaimer,
  });

  /// The bracket id — also the content id. The hero's eyebrow, title and
  /// blurb come from the bracket, so the door and the tile cannot drift.
  final String doorId;

  /// Five. See the header.
  final List<SkDoorTab> tabs;

  /// A photograph behind the hero. `images.unsplash.com` only, and it must
  /// not contradict the door's own content.
  final String? heroImageUrl;

  /// The closing card under every tab. For a skill door this is the way to
  /// the grown-up side; a Consult closing arrives when a brief un-holds one.
  final SkDoorClosing? closing;

  /// Null takes the skilling default.
  final String? disclaimer;

  SkDoorTab? tabById(String id) {
    for (final t in tabs) {
      if (t.id == id) return t;
    }
    return null;
  }
}

/// One card on the selector, and what the tab under it shows.
class SkDoorTab {
  const SkDoorTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.hue,
    required this.kind,
    this.tools = const [],
    this.pageIds = const [],
    this.bandId,
    this.note,
    this.footer,
  });

  /// ⚠️ A TAB PINNED TO ONE BAND. The Communication brief lists its three
  /// activity sets as three SURFACES — "Say it out loud (6 to 8)", "Tell it
  /// and explain it (8 to 11)", "Say what you think (11 to 14)" — so each
  /// is a card on the selector. Null (Coding's shape) means the tab draws
  /// her band. Set, the tab draws that band, and the age rule applies to
  /// the tab whole: a band ahead of hers is LOCKED ("From 8 years"), a
  /// band behind hers DROPS — the user's rule 3, made a picture. The
  /// user's call for Communication, 2026-09-15 (question 2, A).
  final String? bandId;

  final String id;

  /// Short — it sits on a 4a card and wraps at two lines.
  final String label;
  final IconData icon;
  final double hue;
  final SkTabKind kind;

  /// Tool cards that lead the tab's first rail (or follow a named page).
  final List<SkDoorTool> tools;

  /// For `SkTabKind.pages`: the pages, in order.
  final List<String> pageIds;

  /// A standing note for the tab. Quiet type.
  final String? note;

  /// One human line under the rails.
  final String? footer;
}

/// A tool card on a tab.
class SkDoorTool {
  const SkDoorTool({
    required this.label,
    required this.blurb,
    required this.surfaceId,
    required this.icon,
    this.chip = 'Tool',
    this.afterPageId,
  });
  final String label;
  final String blurb;
  final String surfaceId;
  final IconData icon;
  final String chip;

  /// A tool that follows its read (the parenting `afterPageId` rule). Null
  /// keeps the tool at the front of the first rail.
  final String? afterPageId;
}

/// The closing card.
class SkDoorClosing {
  const SkDoorClosing({
    required this.label,
    required this.blurb,
    required this.surfaceId,
    this.chip = 'Grown-ups',
    this.grownUp = true,
  });
  final String label;
  final String blurb;
  final String surfaceId;

  /// "Grown-ups" for the parent side; "Consult" when a brief un-holds one.
  final String chip;

  /// The parent side. Drawn with a lock; the screen it opens asks the
  /// grown-up gate itself, so the card does not ask twice.
  final bool grownUp;
}

/// Every skilling door. A bracket without one keeps its plan sheet; adding
/// a door is a data file and a line here.
final List<SkDoor> kSkDoors = [
  kSkCodingDoor,
  kSkCommunicationDoor,
];

SkDoor? skDoorFor(String doorId) {
  for (final d in kSkDoors) {
    if (d.doorId == doorId) return d;
  }
  return null;
}
