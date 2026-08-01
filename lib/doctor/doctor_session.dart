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

  /// How long [resolveFromServer] waits for the server before deciding the
  /// answer is "no identity". See that method for why silence, not just
  /// failure, has to be handled.
  static const _resolveDeadline = Duration(seconds: 6);

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

  /// Ask the SERVER who this account is, and become them.
  ///
  /// THE DIFFERENCE FROM [enter]. `enter` is the testing affordance: a picker
  /// listing every doctor in the compiled catalogue, chosen by hand each time.
  /// That is fine on a developer's phone and wrong in a doctor's hands — an
  /// identity you select from a dropdown is not an identity, and the row it
  /// writes would let one account claim to be any expert.
  ///
  /// This is the real path. `expert_accounts` already maps user → expert (the
  /// row `enter` upserts); nothing read it back until now, which is why the
  /// picker survived. So a doctor signs in once and simply IS that doctor, on
  /// every launch, with the server as the authority.
  ///
  /// Falls back to `partner_accounts` (0068) for an organisation — a hospital,
  /// IVF centre or lab has no entry in the compiled expert catalogue and should
  /// not. Returns true when an identity was found.
  ///
  /// Note the ORDER: expert first. Someone who both consults and represents a
  /// clinic should land in their consulting view, because that is the one with
  /// patients waiting in it.
  ///
  /// EVERY CALL HERE IS DEADLINED. This runs on the boot path — main_doctor.dart
  /// shows a spinner until it answers — so a request that never returns is not a
  /// slow launch, it is an app that never launches. try/catch does not cover
  /// that case: it handles a call that FAILS, and says nothing about a call that
  /// simply never comes back, which is what an unreachable network looks like
  /// from Dart. The timeout is the other half of "a cloud failure degrades to
  /// local-only"; without it the rule holds for errors and breaks for silence.
  ///
  /// A timeout resolves to "no identity", the same answer as a refusal, so the
  /// doctor sees the sign-in screen and can act. Six seconds because this blocks
  /// a person looking at a spinner, not a background sync.
  Future<bool> resolveFromServer() async {
    if (!SupabaseRepo.isLoggedIn) return false;

    try {
      // expert_accounts is keyed on user_id and has no created_at, so order by
      // the column it does have — fetch() defaults to created_at and would 400.
      final rows = await SupabaseRepo.fetch('expert_accounts',
              orderBy: 'user_id')
          .timeout(_resolveDeadline);
      final expertId = rows.isEmpty ? null : rows.first['expert_id'] as String?;
      if (expertId != null && expertId.isNotEmpty) {
        _active = true;
        _expertId = expertId;
        _partnerId = null;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Named, not swallowed. "No expert record" and "could not reach the
      // server" produce the same screen, and telling them apart from the
      // outside is guesswork — which is exactly how this cost an evening.
      debugPrint('[doctor] expert_accounts lookup failed: $e');
    }

    try {
      final res = await SupabaseRepo.callFunction('my_care_partner')
          .timeout(_resolveDeadline);
      final first = res.isEmpty ? null : res.first;
      final id = (first is Map) ? first['id'] as String? : null;
      if (id != null && id.isNotEmpty) {
        _active = true;
        _expertId = null;
        _partnerId = id;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('[doctor] my_care_partner lookup failed: $e');
    }

    return false;
  }

  /// Leave doctor mode entirely. Used when the doctor app signs out, so the
  /// next person to sign in on that device does not inherit an identity.
  void clear() {
    if (!_active && _expertId == null && _partnerId == null) return;
    _active = false;
    _expertId = null;
    _partnerId = null;
    notifyListeners();
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
