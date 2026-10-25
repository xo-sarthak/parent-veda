// =============================================================================
//  Parenting doors — the door shell over a parenting section
// -----------------------------------------------------------------------------
//  ⚠️ THE THIRD DOOR ENGINE, AND THE REASON IT IS NOT THE SECOND.
//
//  TTC has `ttc_focus_data.dart`; pregnancy has `pv_door_data.dart`, which its
//  own header describes as "the pregnancy-side twin of the TTC focus engine,
//  and the duplication is deliberate". Both are welded to their stage's
//  payloads and both are being worked on in parallel with this file, in other
//  terminals. Importing either from here would make a parenting screen break
//  when a pregnancy constructor changes. So parenting has its own shell, in
//  its own files, with the same SHAPE — and shares only what is already
//  stage-neutral: `V2Palette`, `V3HeroField`, `V3BracketArt`.
//
//  ⚠️ WHAT IS DIFFERENT, AND IT IS THE WHOLE DESIGN OF THIS FILE: A PARENTING
//  DOOR HOLDS NO CONTENT. The pregnancy door's tiles ARE its content — every
//  card is declared in the door file. A parenting section already has its
//  content in a `PpSection` (seven areas of `PpPage`s, age-banded, tested for
//  holes and dead links), and the door is only the SHELL she opens it through:
//  which areas sit on which of the five tabs, which tools sit above the rails,
//  which page is pinned as the tab's red flag. A door that copied page titles
//  into tiles would be a second list of the same things, drifting the first
//  time either was edited.
//
//  So: a tab names AREA IDS, and the screen reads the pages — for her band —
//  from the section at render time. The rail is the area. The card is the
//  page. The chip is `PpPage.format`, which the section already carries.
//
//  ⚠️ FIVE TABS, BECAUSE THAT IS WHAT THE SELECTOR DRAWS. The coverflow keeps
//  all five on screen and its geometry is written for five. A section with
//  seven areas groups them; that grouping is the one editorial decision a door
//  file makes, and it is why the file exists.
// =============================================================================

import 'package:flutter/material.dart' show IconData;

import 'pp_door_behaviour.dart';
import 'pp_door_development.dart';
import 'pp_door_early_learning.dart';
import 'pp_door_feeding.dart';
import 'pp_door_first40.dart';
import 'pp_door_health.dart';
import 'pp_door_potty.dart';
import 'pp_door_safety.dart';
import 'pp_door_papers.dart';
import 'pp_door_special_care.dart';
import 'pp_door_family.dart';
import 'pp_door_sleep.dart';
import 'pp_door_traditions.dart';
import 'pp_door_you_maa.dart';

export 'pp_door_behaviour.dart';
export 'pp_door_development.dart';
export 'pp_door_early_learning.dart';
export 'pp_door_feeding.dart';
export 'pp_door_first40.dart';
export 'pp_door_health.dart';
export 'pp_door_potty.dart';
export 'pp_door_safety.dart';
export 'pp_door_papers.dart';
export 'pp_door_special_care.dart';
export 'pp_door_family.dart';
export 'pp_door_sleep.dart';
export 'pp_door_traditions.dart';
export 'pp_door_you_maa.dart';

/// One parenting door: a shell over one section.
class PpDoor {
  const PpDoor({
    required this.sectionId,
    required this.tabs,
    this.heroImageUrl,
    this.aboutHer = false,
    this.hiddenAreaIds = const [],
    this.closing,
    this.closingLine,
    this.disclaimer,
    this.tabOrder = const {},
  });

  /// ⚠️ THE TAB ORDER FOR HIS AGE (step 0 · S1, 2026-10-25). Band id → tab
  /// ids, first one opens. Age used to only remove or lock tabs; it never
  /// picked where she lands, so a mother of a 2-month-old opened Family on
  /// "A second baby". A band with no entry here keeps the door's own order.
  /// Tabs the list leaves out keep the door's own order after the named ones. Each door's plan
  /// (`docs/pp-door-plans/`) gives its orders.
  final Map<String, List<String>> tabOrder;

  /// ⚠️ THE CLOSING AS ONE QUIET SENTENCE, NOT A CARD. The pregnancy door's
  /// `closingLine`: a line under whatever tab is open, tappable as a whole
  /// where `closing` gives it somewhere to go. Tried on Sleep first
  /// (2026-09-12) so the two representations can be compared on a phone —
  /// Feeding keeps the card until that is decided. When both are set, the
  /// line is drawn and the card is not. Decided 2026-09-13, on a phone: the
  /// card, on every door; no door sets this now.
  final String? closingLine;

  /// Areas of the section this door deliberately does not show — because a
  /// brief merged them into a tool and their pages are now that tool's data.
  /// Named, so `test/pp_<door>_door_test.dart` can require every area to be
  /// either on a tab or here, and a forgotten area still fails.
  final List<String> hiddenAreaIds;

  /// A photograph behind the hero, as every pregnancy door has. Null keeps the
  /// V3 field and the bracket's mark, which is a finished hero and not a
  /// fallback: local-first is absolute, and on a dead connection the door
  /// looks exactly like this.
  ///
  /// ⚠️ THE PICTURE MUST NOT CONTRADICT THE DOOR. Sleep's own collection 5
  /// says "on her back, every sleep, nothing soft near her face", and most
  /// stock photographs of sleeping babies show precisely the opposite. A
  /// close face and a fist, position out of frame, is what passed.
  final String? heroImageUrl;

  /// ⚠️ THE ONE DOOR THAT IS ABOUT THE MOTHER. Every line the shell writes
  /// for itself — the hero's "FOR his-name · band", the locked tab's
  /// "This opens when he turns 1" — is in the baby's voice, and read wrong
  /// on You, Maa, where the bands are HER time since birth. Seen on a phone,
  /// 2026-09-14. True flips those lines to her.
  final bool aboutHer;

  /// The `PpSection` this door opens — also the bracket id, which is what the
  /// home tile carries. The hero's eyebrow, title and blurb come from that
  /// bracket and its hub config, so the door and the tile cannot drift.
  final String sectionId;

  /// Exactly five. See the header.
  final List<PpDoorTab> tabs;

  /// The closing offer under every tab — "Talk to a sleep expert". Shown once
  /// per page, whatever tab is open, for the reason the pregnancy door gives
  /// for its closing line: a row only under the last tab is a row most people
  /// never see.
  final PpDoorClosing? closing;

  /// The disclaimer at the foot. Null takes the parenting default.
  final String? disclaimer;

  PpDoorTab? tabFor(String areaId) {
    for (final t in tabs) {
      if (t.areaIds.contains(areaId)) return t;
    }
    return null;
  }
}

/// One card on the selector, and what the tab under it shows.
class PpDoorTab {
  const PpDoorTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.hue,
    required this.areaIds,
    this.tools = const [],
    this.redFlagPageId,
    this.jumpToTabId,
    this.jumpTitle,
    this.note,
    this.footer,
    this.toMonths,
    this.expert,
    this.extraPageIds = const [],
    this.ageRail = const {},
    this.closing,
    this.dueLine,
  });

  /// ⚠️ A FIRST RAIL PICKED FOR HIS AGE (Health plan H-M1 / H2, look approved
  /// 2026-10-24). Band id → the pages a parent of that age needs first. The
  /// area rails are grouped by body part, which is right for looking a thing
  /// up and wrong for a 3-week-old, whose fever, jaundice, skin and colic
  /// pages sat on four different rails. Drawn as the first rail, the tools
  /// leading it; the area rails below skip every page already on it, so
  /// nothing shows twice. Plain data, so a test holds it row by row.
  final Map<String, PpAgeRail> ageRail;

  /// ⚠️ THIS TAB'S OWN CLOSING, IN PLACE OF THE DOOR'S (Health H3). Get help
  /// now must not end on "Talk to a paediatrician": an emergency goes to 112,
  /// not a video call. Its foot is the first-aid class instead, after the
  /// footer, the one offer that makes the next emergency go better. Null
  /// keeps the door's closing.
  final PpDoorClosing? closing;

  /// ⚠️ THE TAB CARD'S SECOND LINE, WHEN SOMETHING IS DUE (Health H1). Null,
  /// or a function returning null, keeps the count. A top-level function, so
  /// the data stays const: Vaccines says "Due in 5 days" when a dose is near.
  final String? Function()? dueLine;

  /// ⚠️ THE EXPERT FOR THIS TAB, AFTER ITS FIRST RAIL (Feeding D2, approved
  /// 2026-10-23). The door's `closing` sits at the foot, under every tab, and
  /// a consult at the foot is one most parents never reach. This puts the
  /// right person on the first scroll: a lactation expert on Milk feeds, a
  /// child nutritionist on the food tabs. A tab that has one ends on the
  /// doctor sentence instead of the closing card, so one tab never pitches
  /// twice. Null keeps the door's closing as the only consult.
  final PpDoorClosing? expert;

  /// ⚠️ A PAGE FROM ANOTHER TAB, ON THIS ONE TOO. Feeding's gagging carousel
  /// lives in Keeping it safe, and a parent opening Starting solids at seven
  /// months meets the first gag before she ever reaches tab three. One page,
  /// two ways in, never a second copy: the id is resolved against the
  /// section and drawn in the first rail after the tools, for her band only.
  final List<String> extraPageIds;

  /// ⚠️ A TAB THAT DROPS AWAY WITH AGE. Development's "When will my baby..."
  /// is scoped to the first two years and the brief is explicit that it
  /// "drops away after 2, on purpose": a parent of a walking three-year-old
  /// never sees "when will my baby roll over". The age rule applied to a
  /// whole tab rather than a page. Null means every age.
  final int? toMonths;

  /// ⚠️ A PINNED CARD THAT SWITCHES TAB. Health's default tab pins "Is this
  /// an emergency?" which is a reference to the Get help now tab, not a
  /// page: in a 2am panic the red flags are one tap from wherever she
  /// landed. Drawn in the red-flag treatment, above everything.
  final String? jumpToTabId;
  final String? jumpTitle;

  /// One human line under the rails — Get help now's "If he seems wrong to
  /// you and a screen says otherwise, believe yourself."
  final String? footer;

  final String id;

  /// Short — it sits on a 4a card and wraps at two lines.
  final String label;
  final IconData icon;
  final double hue;

  /// The section's areas shown on this tab, in order. Each becomes a heading
  /// and a rail of that area's pages for her band.
  final List<String> areaIds;

  /// Full-width tool rows above the rails — the tracker, the sounds player.
  final List<PpDoorTool> tools;

  /// A page pinned above everything on this tab as the red flag, and removed
  /// from its rail so it is not shown twice. Same treatment as the pregnancy
  /// door's `pinnedRedFlag`: coral, above the content, never in an accordion.
  final String? redFlagPageId;

  /// A standing note for the tab. Quiet type.
  final String? note;
}

/// A tool row on a tab.
class PpDoorTool {
  const PpDoorTool({
    required this.label,
    required this.blurb,
    required this.surfaceId,
    required this.icon,
    this.chip = 'Tool',
    this.afterPageId,
    this.atEnd = false,
    this.bands,
  });
  final String label;

  /// ⚠️ THE AGES A TOOL IS FOR (Feeding plan §2c, 2026-10-23). Band ids of
  /// the door's section; null means every band. A tool had no age, so a
  /// toddler's parent met the newborn feed timer, nappies and pumping before
  /// any help. Outside its bands a tool leaves the first rail and sits in
  /// the band block it fits at the foot of the tab: still reachable, never
  /// deleted.
  final List<String>? bands;

  bool inBand(String band) => bands == null || bands!.contains(band);

  /// Drawn after every page on the first rail instead of before them. For a
  /// shop card that should never come before the free things (gap analysis
  /// P2, Early learning, 2026-10-07). Read by the door screen's rail.
  final bool atEnd;
  final String blurb;
  final String surfaceId;
  final IconData icon;

  /// ⚠️ A TOOL THAT FOLLOWS ITS READ. Tools lead the first rail; this puts
  /// one after a named page instead, so a rail can go read, then the tool
  /// for it: "The normal range is much wider than you think", then Where he
  /// is right now; "When something is worth checking", then A
  /// gentle check-in. The user's call on Development (2026-09-13): educate,
  /// then hand over the tool, per pair. Null keeps the tool at the front.
  final String? afterPageId;

  /// "Tool", "Audio" — the badge the brief marks the landing item with.
  final String chip;
}

/// The closing offer.
class PpDoorClosing {
  const PpDoorClosing({
    required this.label,
    required this.blurb,
    required this.surfaceId,
    this.note,
  });
  final String label;
  final String blurb;
  final String surfaceId;

  /// A quiet line under the label. Health's safety line on a consult that
  /// shares a tab with the emergency row: "Not for an emergency. For that,
  /// Get help now." (plan §3a).
  final String? note;
}

/// A tab's first rail for one age (`PpDoorTab.ageRail`).
class PpAgeRail {
  const PpAgeRail(this.title, this.pageIds);

  /// "In the first three months". The rail's heading; the screen adds the
  /// line under it ("Picked for Aarav, 3 weeks").
  final String title;

  /// Pages of the section, in order. A page outside the band is skipped.
  final List<String> pageIds;
}

/// Every parenting door. A section without one keeps its hub and library
/// screens exactly as before; adding a door is a data file and a line here.
final List<PpDoor> kPpDoors = [
  kPpSleepDoor,
  kPpFeedingDoor,
  kPpHealthDoor,
  kPpDevelopmentDoor,
  kPpBehaviourDoor,
  kPpPottyDoor,
  kPpEarlyLearningDoor,
  kPpFirst40Door,
  kPpYouMaaDoor,
  kPpTraditionsDoor,
  kPpSafetyDoor,
  kPpPapersDoor,
  kPpSpecialCareDoor,
  kPpFamilyDoor,
];

PpDoor? ppDoorFor(String sectionId) {
  for (final d in kPpDoors) {
    if (d.sectionId == sectionId) return d;
  }
  return null;
}
