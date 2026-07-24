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

  /// True while the app should show the doctor experience.
  bool get active => _active;

  /// Which expert (kExperts id) this doctor is. Null when not in doctor mode.
  String? get expertId => _expertId;

  /// Enter doctor mode as [expertId]. The app root swaps to the DoctorScaffold.
  /// Also registers the user<->expert mapping on the server (best-effort) so the
  /// roster and the expert-join token know who this account is.
  void enter(String expertId) {
    _active = true;
    _expertId = expertId;
    notifyListeners();
    if (SupabaseRepo.isLoggedIn) {
      SupabaseRepo.upsert('expert_accounts', {'expert_id': expertId})
          .catchError((_) => null);
    }
  }

  /// Leave doctor mode — back to the parent experience.
  void exit() {
    if (!_active) return;
    _active = false;
    _expertId = null;
    notifyListeners();
  }
}
