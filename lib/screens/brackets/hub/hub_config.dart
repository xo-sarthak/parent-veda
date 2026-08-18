// =============================================================================
//  HubConfig — a problem hub described as data
// -----------------------------------------------------------------------------
//  Implements the shared anatomy from PARENTVEDA-PROBLEM-HUB-SPEC.md §2, and the
//  content rule from §3.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY A CONFIG AND NOT JUST A SCREEN
//  ---------------------------------------------------------------------------
//
//  The brief is "build Scans, look at it, iterate, then do the rest" — so a
//  forty-bracket engine today would be building for a shape nobody has agreed
//  yet. But a bespoke screen has the opposite failure: by the time three hubs
//  exist they have drifted, and the shared anatomy the spec insists on is gone.
//
//  The split that serves both: **the RENDERER is generic, the CONFIG is data.**
//  Iterating on Scans means editing one data file. Agreeing the shape and
//  starting hub #2 also means adding one data file — not another screen.
//
//  Nothing here forces a hub to be config-only. A hub that genuinely needs
//  bespoke UI (After a loss, First 40 days) can render its own body; this is
//  the default, not a cage.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE RULE §3 EXISTS TO ENFORCE, ENCODED IN THE TYPE
//  ---------------------------------------------------------------------------
//
//  "Content is never 'show generic articles about this topic'. Every content
//  group answers a specific user question."
//
//  So [HubSlot.question] is REQUIRED and there is no constructor without it.
//  A slot cannot be added without stating what question it answers, which makes
//  the generic-articles failure impossible to express rather than merely
//  discouraged.
// =============================================================================

import '../../../localization/app_language.dart';
import 'hub_intent_art.dart';

/// Which of the spec's §5 templates a hub follows.
///
/// Recorded rather than executed: the ORDER lives in the config's section list,
/// because the spec's own per-bracket entries vary the order within a template.
/// This exists so a reader can see at a glance which family a hub belongs to,
/// and so a test can assert a stage's hubs are not all the same template.
enum HubTemplate {
  immediateAnswer,
  trackerLed,
  learnAndPlan,
  practiceLed,
  decisionCommerce,
  longTermDevelopment,
  afterALoss,
  firstFortyDays,
}

/// What a slot resolves to, and therefore how it renders.
///
/// ⚠️ THESE ARE THE SPEC'S §4 STATUS RULES, NOT NEW STATES. They map onto the
/// bracket model rather than replacing it — `reuse` is a LIVE cell, `newContent`
/// / `newTool` / `newSupply` are `notReady`, `elsewhere` is `notCore`. A cell
/// that is `notApplicable` cannot appear here at all: it has no slot.
enum SlotStatus {
  /// An existing surface. Do not rebuild. Renders as a real row.
  reuse,

  /// Missing owned content. Renders as a placeholder.
  newContent,

  /// Missing tool. Renders as a placeholder.
  newTool,

  /// Missing product / consult / course supply. Renders as a placeholder.
  newSupply,

  /// Exists on another surface. Renders only if a link genuinely helps.
  elsewhere,
}

// ⚠️ `HubSlot` AND `HubSection` HAVE BEEN REMOVED — FINAL SPEC §2.2.
//
// The earlier build rendered Understand / Check / Talk sections under the intent
// doors. The final spec deletes that architecture outright, and the reason is
// worth keeping: a hub that asks "what do you need right now?" and then answers
// with another set of categories has asked the same question twice. She already
// told us.
//
// Solution TYPES are still real — they are what a focused destination is built
// from (§5.4) — they are simply no longer visible headings on the hub. The
// classes are deleted rather than left unused, because an unused type is an
// invitation to put the old shape back.
//
// `SlotStatus` survives: the placeholder component still needs to know whether
// a missing thing is content, a tool or supply.

/// One of the 2–4 "What do you need right now?" doors.
///
/// ⚠️ THIS IS THE PRIMARY NAVIGATION OF THE HUB — FINAL SPEC §5.3 — and after
/// §2.2 it is very nearly the ONLY navigation. The spec removed the generic
/// Understand / Check / Talk sections: a hub that asks "what do you need?" and
/// then answers with another category menu has asked the question twice.
///
/// So a door leads straight to its focused destination (§5.4), and the hub's
/// whole job is to route.
///
/// ⚠️ THE LABEL DESCRIBES THE OUTCOME, NOT THE CONTENT TYPE. "Understand my
/// report", never "Articles". §2.1 lists the inventory words that are banned
/// here, and `test/problem_hub_test.dart` fails the build on them.
class HubNeed {
  const HubNeed({
    required this.label,
    required this.blurb,
    required this.mark,
    required this.hue,
    this.surfaceId,
    this.action,
  });

  final LocalizedText label;

  /// One line on what she gets. The door is a promise; this is the promise.
  final LocalizedText blurb;

  /// Drawn mark for the door's well — the V3 home's treatment, not an icon.
  final IntentMark mark;

  /// The door's hue on the controlled-pastel wheel.
  final double hue;

  final String? surfaceId;

  /// For destinations that are not a plain surface — the urgent path, a
  /// context-dependent scan page.
  final String? action;
}

/// The urgent strip, where a problem has red flags.
///
/// ⚠️ OPTIONAL AND DELIBERATELY SO — §2 says "only where red flags matter".
/// A hub that shows one where none exist trains people to ignore the ones that
/// do, which is the failure that makes every warning worthless.
class HubUrgent {
  const HubUrgent({required this.line, required this.action});
  final LocalizedText line;
  final String action;
}

/// A whole problem hub, as data.
class HubConfig {
  const HubConfig({
    required this.bracketId,
    required this.template,
    required this.coreQuestion,
    required this.hero,
    required this.heroSupport,
    required this.needsTitle,
    required this.needs,
    this.urgent,
    this.closing,
  });

  /// Must match a `Bracket.id`. The renderer looks the bracket up and asks the
  /// resolver before drawing anything — a hub cannot show a layer its bracket
  /// refuses, however the config is written.
  final String bracketId;

  final HubTemplate template;

  /// The spec's "core question" for this bracket. Not rendered — it is the
  /// editorial test every slot has to pass, kept next to the slots so the next
  /// person editing this file can apply it.
  final String coreQuestion;

  final LocalizedText hero;

  /// The line under the heading (§4). One sentence on what this problem area
  /// covers — it is what lets the four doors below be short.
  final LocalizedText heroSupport;

  final LocalizedText needsTitle;

  /// ⚠️ 2–4, PER §2. More than four is a menu, and a menu is the catalogue UX
  /// this restructure exists to replace. Asserted in the renderer.
  final List<HubNeed> needs;

  // ⚠️ NO `sections` FIELD, DELIBERATELY — FINAL SPEC §2.2 removed the generic
  // Understand / Check / Talk architecture from the hub. Solution types are
  // still real (they are what a DESTINATION is built from); they are no longer
  // visible headings on the hub itself.
  //
  // The field is absent rather than empty so the old shape cannot creep back:
  // an unused list is an invitation.
  final HubUrgent? urgent;

  /// ⚠️ WHAT WE OFFER WHEN THE APP COULD NOT FINISH THE JOB — and nothing else.
  ///
  /// This is NOT a fourth door. A door names a reason she opened the app;
  /// booking a consult is not one of those — it is what is left when reading
  /// has run out. So it sits at the foot, after the doors, quiet.
  ///
  /// Keeping it out of `needs` is the whole point: promoted to a door it would
  /// compete with the reasons she actually came, and every hub would grow a
  /// "talk to someone" tile whether or not there is anyone to talk to.
  final HubClosing? closing;
}

/// One offer at the foot of a hub — today, always a consult.
class HubClosing {
  const HubClosing({
    required this.label,
    required this.blurb,
    required this.action,
  });

  final LocalizedText label;
  final LocalizedText blurb;
  final String action;
}
