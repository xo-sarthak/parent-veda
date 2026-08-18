// =============================================================================
//  The parenting section registry — bracketId -> its content
// -----------------------------------------------------------------------------
//  ⚠️ ONE LIST, SO "IS THIS SECTION REACHABLE?" IS A DATA QUESTION.
//
//  The failure this repo has actually hit, repeatedly, is correct-but-unreachable
//  code: content that compiles, reads well, and has no call site. Eleven sections
//  built in parallel is the ideal conditions for it — each author finishes a
//  perfectly good data file and nobody notices that two of them were never
//  wired.
//
//  So every section lands here, and `test/pp_section_test.dart` walks this list
//  rather than a list of filenames. A section that exists but is not registered
//  fails the test that counts them; a section registered under a bracketId that
//  no hub uses fails the test that matches them to `parenting_hubs.dart`. Neither
//  of those is findable by reading eleven files.
//
//  ⚠️ WHY THE REGISTRY RATHER THAN A SWITCH IN THE ROUTER. A `switch` would work
//  and would need editing in two places every time a section is added — the
//  router and whatever lists them for tests. A single list read by both means
//  adding a section is one line, and the wiring gate cannot be half-satisfied.
// =============================================================================

import 'pp_section_screen.dart';

import 'pp_behaviour_content.dart';
import 'pp_development_content.dart';
import 'pp_early_learning_content.dart';
import 'pp_feeding_content.dart';
import 'pp_health_content.dart';
import 'pp_first40_content.dart';
import 'pp_potty_content.dart';
import 'pp_sleep_content.dart';
import 'pp_traditions_content.dart';
import 'pp_you_maa_content.dart';

/// Every built parenting section.
///
/// ⚠️ THE ORDER HERE IS NOT THE DOOR ORDER. Doors are ordered by demand in
/// `parenting_hubs.dart`; this list is ordered by nothing in particular and must
/// not become load-bearing. If something starts depending on the order, it wants
/// its own explicit list.
final List<PpSection> kPpSections = [
  kPpSleepSection,
  kPpDevelopmentSection,
  kPpPottySection,
  kPpFirst40Section,
  kPpYouMaaSection,
  kPpBehaviourSection,
  kPpTraditionsSection,
  kPpFeedingSection,
  kPpHealthSection,
  kPpEarlyLearningSection,
  //
  // ⚠️ 'parenting_buying' IS ABSENT FOR A DIFFERENT REASON, AND THE TWO MUST NOT
  // BE CONFLATED.
  //
  // What to Buy was the one spec of the eleven that said "this is NOT a
  // ground-up build... do NOT restructure it". Its section is the existing
  // commerce IA — ProductsDiscoveryScreen and the screens around it — which is
  // richer than a content section and already reachable. Wrapping it in a
  // `PpSection` to make this list look complete would be filler of exactly the
  // kind the specs forbid, and it would put a second, worse front door on a shop
  // that already has one.
  //
  // `test/pp_section_test.dart` knows about this gap by name, so the count test
  // asserts ten rather than silently accepting any number.
];

/// The section behind a bracket, or null if that bracket has no content section.
PpSection? ppSectionFor(String bracketId) {
  for (final s in kPpSections) {
    if (s.id == bracketId) return s;
  }
  return null;
}

/// Brackets that intentionally have no `PpSection`. Named so the tests can tell
/// "deliberately elsewhere" apart from "forgotten", which is the same distinction
/// the bracket model's four-state enum exists to preserve.
const Set<String> kPpSectionlessBrackets = {'parenting_buying'};

/// ⚠️ BRACKETS WHOSE SECTION IS GENUINELY OWED, AS OPPOSED TO DELIBERATELY
/// ELSEWHERE.
///
/// The distinction matters more than it looks. `kPpSectionlessBrackets` means
/// "this will never have a PpSection and that is correct"; this set means "this
/// should have one and does not yet". Collapsing the two into a single absence
/// is exactly the loss the bracket model's four-state enum exists to prevent --
/// the first person to read a gap as a decision stops looking for the work.
///
/// Each of these keeps its CURRENT door behaviour until its section lands, so
/// nothing regresses: the doors still open what they opened before.
/// ⚠️ EMPTY, AND THAT IS THE POINT OF KEEPING IT.
///
/// All ten content sections are built and registered. The set stays because the
/// distinction it encodes is the one worth preserving: a bracket with no section
/// must be readable as "deliberately elsewhere" (`kPpSectionlessBrackets`) or as
/// "owed" (here), never as an unexplained gap. Deleting it would mean the next
/// bracket added has nowhere to say which it is.
const Set<String> kPpSectionsOwed = <String>{};
