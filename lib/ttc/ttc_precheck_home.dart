// =============================================================================
//  The Pre-pregnancy checklist, on the home (2026-10-01)
// -----------------------------------------------------------------------------
//  The user, asking what the checklist gives back: "when we collect this
//  information then the user might expect something… is that linked anywhere
//  or are we just collecting it?" It was only collected: nothing else in the
//  app read her answers. First change of five: the home's insight rail shows
//  "Your next step", the first open step of her own checklist, and opens the
//  checklist. It is the same step the checklist's own "Your next 3 steps"
//  leads with, so the two can never disagree.
//
//  Hers only (the user: it is for the woman; nothing for his side).
// =============================================================================

import 'ttc_precheck_rules.dart';
import 'ttc_precheck_store.dart';

/// The first step of her checklist that is still open, or null when there is
/// none (everything that matters is settled), so the home draws no card.
///
/// Also starts the store loading if it has not (the home never opens the
/// checklist itself); the home listens to the store and redraws when it lands.
PrecheckPriority? ttcPrecheckNextStep() {
  final store = TtcPrecheckStore.instance;
  store.load();
  final c = PrecheckContext.gather();
  final steps = precheckPriorities(c, (id) => store.statusOf(id, c));
  return steps.isEmpty ? null : steps.first;
}
