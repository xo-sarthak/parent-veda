// =============================================================================
//  TtcAuthor - who wrote or owns a couple-shared TTC row
// -----------------------------------------------------------------------------
//  Moved here from ttc_journal_store.dart on 2026-09-28, when the journal was
//  commented out of Trying to Conceive. The enum was never about the journal:
//  the supplements list ("mine" or "his") and the questions for the doctor
//  both use it. Leaving it inside the journal's file would have kept two live
//  features importing a file whose feature is gone, which is the same coupling
//  that nearly took the doctor questions down with the journal
//  (docs/BACKEND-PATTERNS.md, section 16r).
// =============================================================================

/// Who wrote it. Rows are attributed, never hidden from each other: in a
/// couple-shared list, seeing what your partner added is the feature.
enum TtcAuthor { me, partner }
