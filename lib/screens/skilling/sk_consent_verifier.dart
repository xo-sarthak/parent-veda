// =============================================================================
//  SkConsentVerifier — verified parental consent, as an interface with a stub
// -----------------------------------------------------------------------------
//  ⚠️ FLAGGED FOR LEGAL REVIEW. NOT A PROVIDER, ON PURPOSE.
//
//  The Coding v2 brief: "In India a child is anyone under eighteen, and the
//  law needs verified parental consent before you touch a child's data ...
//  Leave the verification adapter (DigiLocker or equivalent) an interface
//  with a stub, flagged for legal review, do not hard-wire a provider."
//
//  So this file is the SEAM and nothing behind it. The gate calls
//  [SkConsentVerifier.verify] and records what came back; which provider
//  answers — DigiLocker, an OTP to a verified number, a card check — is a
//  legal and product decision that has not been made, and a provider wired
//  in now would be a provider somebody has to unwire. The general fact: an
//  interface with one stub implementation costs nothing today and makes the
//  real adapter a one-file change that touches no screen.
//
//  ⚠️ THE STUB PASSES, AND SAYS SO. It has to pass or the door cannot be
//  walked on a phone; it says "stub" on the settings screen so nobody
//  mistakes a walk-through for a lawful consent. `SkVerification.stub` is a
//  distinct state from `verified` for exactly that reason — the two must
//  never be collapsed into a boolean.
// =============================================================================

/// What the verifier said. Persisted by name on the child record.
enum SkVerification {
  /// The gate has not run.
  none,

  /// The stub answered. Legally nothing; honest on screen.
  stub,

  /// A real adapter verified the parent. None exists yet.
  verified,

  /// A real adapter refused. None exists yet.
  refused,
}

/// The seam. One method: given what the parent typed, say whether they are
/// a verified adult with authority over this child.
abstract class SkConsentVerifier {
  Future<SkVerification> verify({
    required String parentName,
    required String childName,
    required DateTime childDob,
  });

  /// One line the settings screen shows beside the result.
  String get label;

  /// The adapter in use. Swap here, nowhere else.
  static SkConsentVerifier current = const SkStubConsentVerifier();
}

/// The stub. Passes, labelled as a stub.
class SkStubConsentVerifier implements SkConsentVerifier {
  const SkStubConsentVerifier();

  @override
  Future<SkVerification> verify({
    required String parentName,
    required String childName,
    required DateTime childDob,
  }) async =>
      SkVerification.stub;

  @override
  String get label => 'Not verified yet (stub, pending legal review)';
}
