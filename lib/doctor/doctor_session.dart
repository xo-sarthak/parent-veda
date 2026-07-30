// =============================================================================
//  DoctorSession — is the app currently in DOCTOR (expert) mode?
// -----------------------------------------------------------------------------
//  ParentVeda is one app with two audiences. A parent sees the mother/father
//  experience; a doctor who logs in sees a different app entirely — their
//  dashboard, their calls, their availability. This singleton is the switch:
//  when [active] is true the app root renders the DoctorScaffold instead of the
//  parent MainScaffold, exactly the way FatherPreview flips mother/father.
//
//  [expertId] ties the logged-in doctor to one entry in kExperts — that's whose
//  profile, calls and sessions they see. For now it's chosen at a testing entry
//  (a "log in as doctor" affordance); later it comes from the backend (an
//  expert-accounts mapping), and the testing entry is removed.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../services/remote/supabase_repo.dart';

class DoctorSession extends ChangeNotifier {
  DoctorSession._();
  static final DoctorSession instance = DoctorSession._();

  bool _active = false;
  String? _expertId;
  String? _partnerId;

  /// True while the app should show the doctor experience.
  bool get active => _active;

  /// Which expert (kExperts id) this partner is, when they also consult inside
  /// the app. NULL for a partner that only refers — a hospital, IVF centre or
  /// lab has no entry in the compiled kExperts catalogue and should not.
  String? get expertId => _expertId;

  /// Which care_partners row is signed in, when the session was opened as a
  /// partner rather than as a consulting expert.
  String? get partnerId => _partnerId;

  /// Whether this session has a consulting identity at all.
  ///
  /// False for a referral-only partner. Nothing is HIDDEN from them — the
  /// availability, appointments and earnings screens are all still there and
  /// simply render empty, which is the house rule and also the honest answer:
  /// a hospital that does not consult has no slots, not a missing feature.
  bool get consults => (_expertId ?? '').isNotEmpty;

  /// One key for "who is signed in", whichever route they came by. Used only to
  /// de-duplicate loads — the SERVER decides which partner this account is, via
  /// my_care_partner() (0068).
  String? get sessionKey =>
      (_expertId ?? '').isNotEmpty ? _expertId : _partnerId;

  /// Enter doctor mode as [expertId]. The app root swaps to the DoctorScaffold.
  /// Also registers the user<->expert mapping on the server (best-effort) so the
  /// roster and the expert-join token know who this account is.
  void enter(String expertId) {
    _active = true;
    _expertId = expertId;
    _partnerId = null;
    notifyListeners();
    if (SupabaseRepo.isLoggedIn) {
      SupabaseRepo.upsert('expert_accounts', {'expert_id': expertId})
          .catchError((_) => null);
    }
  }

  /// Enter the partner view as a care_partners row that has NO expert record —
  /// a hospital, IVF centre, diagnostic lab, corporate.
  ///
  /// The view is identical to a doctor's. Which partner this is remains the
  /// server's answer: the account has to be linked with link_partner_account()
  /// (0068, service_role), so entering here without that link produces a view
  /// that correctly finds nothing rather than one that invents an identity.
  void enterAsPartner(String partnerId) {
    _active = true;
    _expertId = null;
    _partnerId = partnerId;
    notifyListeners();
  }

  /// Leave the partner view — back to the parent experience.
  void exit() {
    if (!_active) return;
    _active = false;
    _expertId = null;
    _partnerId = null;
    notifyListeners();
  }
}
