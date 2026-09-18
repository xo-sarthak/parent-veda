// =============================================================================
//  The crisis pathway — a stub, marked, and STOPPED
// -----------------------------------------------------------------------------
//  The Feelings brief, call 2: "If a child writes something that suggests
//  she is in danger, self-harm, abuse, being hurt, the door cannot simply
//  ignore it, and it also cannot responsibly be answered by a product
//  spec. Automated scanning of a child's private feelings is surveillance
//  and profiling of the most sensitive data there is, it is fraught under
//  DPDP, and it can endanger a child when the parent is the source of
//  harm. There is no clean product answer."
//
//  And its prompt: "do NOT build any automated distress/self-harm scanning
//  of the journal. The crisis pathway is a clinical + legal design task,
//  not a code task; leave a clearly-marked stub and STOP."
//
//  So this file is the stub. It does nothing, it reads nothing, and it is
//  not wired to the journal — `SkJournalStore` has no hook into it and
//  must not grow one from the code side. What IS built, and free, and
//  first-class, is the off-ramp (`sk_safety.dart`): a trusted adult and a
//  real helpline on every screen of the door, and asking for help as an
//  ordinary practised skill in the content.
//
//  ⚠️ WHAT A CHILD PSYCHOLOGIST AND A LAWYER DECIDE, BEFORE A LINE OF THIS
//  IS WRITTEN: whether anything a child writes is ever surfaced; to whom
//  (and never by default to a parent who may be the source of harm); the
//  mandatory-reporting questions under Indian law; what the app says to the
//  child at that moment; and whether any of it can be done without reading
//  her journal, which the brief says it should not. Until then the
//  interface has one implementation and it is `SkNoCrisisPathway`.
// =============================================================================

/// The seam. Nothing calls it today; the test holds that.
abstract class SkCrisisPathway {
  /// What the door does when help is asked for in the open (the off-ramp
  /// tap). Today: nothing is recorded, nothing is sent.
  Future<void> onHelpAsked();
}

/// The only implementation: no scanning, no record, no signal. The
/// deliberate default until the experts have designed the real one.
class SkNoCrisisPathway implements SkCrisisPathway {
  const SkNoCrisisPathway();

  @override
  Future<void> onHelpAsked() async {}
}

/// The one instance, for the day a real pathway is designed and swapped in.
const SkCrisisPathway kSkCrisisPathway = SkNoCrisisPathway();
