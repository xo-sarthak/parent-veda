// =============================================================================
//  TTC tool header colours - ONE RULE A USER CAN SEE
// -----------------------------------------------------------------------------
//  ⚠️ LAUNCH SANITY T6 (2026-09-28). Tool headers wore a hue picked screen by
//  screen: blue-grey on Ovulation tests and Weight, green on Weight and
//  fertility, lilac on Supplements, Records and the specialist check, and the
//  PCOS check in the PCOS door's violet. Nothing on screen explained any of
//  it, so it read as leftovers.
//
//  THE RULE: a tool's header wears the colour of the group it sits in on the
//  Tools tab. The hub draws every tool's mark in that same tint (a drawn
//  object on a disc since 2026-09-29, `ttc_tool_marks.dart`; a Material
//  glyph in a well before), so the colour
//  she saw on the row she tapped is the colour of the page that opens. Four
//  groups, four colours:
//
//      Your body            172  (Body and cycle's hue)
//      Both of you          186  (his side's hue)
//      Care and medicines   206  (the clinic door's hue)
//      Plan and check       104  (Getting ready's hue; "Plan and learn"
//                                 until 2026-09-28, when the courses left)
//
//  ⚠️ RE-CHECKED 2026-09-28, WHEN TOOLS BECAME TOOLS ONLY. The rule still
//  maps group to colour: the four groups keep their four hues. The treatment
//  cycle came into "Care and medicines" and its header already wore 206
//  (`kIvfHue`), so row and header agree. The journey map and its family
//  timeline LEFT Tools for More's "Your journey" tile; they are not tools,
//  so this rule no longer speaks for them, and they keep 104 unchanged
//  rather than being recoloured in passing (a decision left to the user).
//
//  `ttcToolGroups` in ttc_tools_screen.dart reads these constants for its
//  wells, and each tool screen passes the one for its group, so the hub and
//  the headers cannot drift apart. A tool opened from a door still wears its
//  Tools colour: one tool, one colour, wherever she opens it.
//
//  ONE STATED EXCEPTION: Cycle companion and Fertile window draw in the cycle
//  palette (ttc_cycle_palette.dart), because on those two the colour is the
//  information: violet means the fertile days on every cycle view, the home
//  hero and the calendar included. Recolouring them to the group's teal would
//  break that meaning to satisfy this one.
//
//  Kept here, in a file with no imports, so a tool screen can take its colour
//  without importing the hub (which imports every tool screen).
// =============================================================================

/// "Your body": her cycle, her logs, her checks.
const double kTtcToolHueBody = 172;

/// "Both of you": his health and the shared journal.
const double kTtcToolHueBoth = 186;

/// "Care and medicines": the specialist check, supplements, medication,
/// tests, vaccinations, records, appointments, the treatment cycle.
/// (Experts left for More on 2026-09-28.)
const double kTtcToolHueCare = 206;

/// "Plan and check": food ideas, Can I...?, the pre-pregnancy checklist.
/// (Courses and the journey map left for More on 2026-09-28; the map and
/// timeline screens still read this hue.)
const double kTtcToolHuePlan = 104;
