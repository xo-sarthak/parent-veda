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
//  Tools tab. The hub draws every tool's glyph in that same tint, so the colour
//  she saw on the row she tapped is the colour of the page that opens. Four
//  groups, four colours:
//
//      Your body            172  (Body and cycle's hue)
//      Both of you          186  (his side's hue)
//      Care and medicines   206  (the clinic door's hue)
//      Plan and learn       104  (Getting ready's hue)
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

/// "Care and medicines": supplements, medication, tests, vaccinations,
/// records, appointments, experts.
const double kTtcToolHueCare = 206;

/// "Plan and learn": courses, food ideas, the journey map, Can I...?, the
/// pre-pregnancy checklist.
const double kTtcToolHuePlan = 104;
