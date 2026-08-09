// =============================================================================
//  DeleteAccount — the app half of erasing an account.
// -----------------------------------------------------------------------------
//  WHY IT EXISTS AT ALL: Google Play requires that any app offering account
//  creation also offers account DELETION, both in-app and via a web route. It
//  is a store-review blocker, not a nice-to-have. It is also simply right — an
//  app holding a pregnancy history should be leaveable.
//
//  The destructive half runs in the `delete-account` edge function, because
//  removing an `auth.users` row needs the service_role key and that key must
//  never ship inside an APK. This side asks, then cleans up locally.
//
//  ORDER MATTERS, AND NOT IN THE OBVIOUS DIRECTION.
//  Cloud first, local second. The temptation is to wipe the device immediately
//  so it feels instant — but if the server call then fails, her account still
//  exists with all its data, on a phone that has forgotten it. She would be
//  locked out of an account she asked to delete and could no longer reach to
//  try again. Deleting the server row first means the worst case is the
//  opposite: the account is gone and some stale cache lingers, which the next
//  launch discards anyway because there is no session to load it against.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../remote/supabase_repo.dart';
import 'local_wipe.dart';
import 'social_auth.dart';

/// The word she must type to confirm deletion.
///
/// NOT a localized string, on purpose. This value is COMPARED against what she
/// typed, never merely shown — and the repo has been bitten eight times by
/// exactly this shape, a value that looks like copy, gets translated, and then
/// silently stops matching. Translating it would mean the confirm button never
/// enables in Hindi. The dialog renders it as a hint so she is told what to
/// type; only this constant decides whether it matched.
const String kDeleteAccountKeyword = 'DELETE';

class DeleteAccount {
  DeleteAccount._(); // static-only.

  /// Delete the signed-in account for good.
  ///
  /// Returns true only when the server confirmed the deletion. Never throws —
  /// a failure here must leave her exactly where she was, still signed in, free
  /// to try again.
  static Future<bool> run() async {
    if (!SupabaseRepo.isLoggedIn) return false;

    // 1. THE SERVER FIRST. The function reads the user id from our JWT, so
    // there is nothing to pass — and deliberately no way for this call to name
    // a different account.
    final res = await SupabaseRepo.invokeEdge('delete-account', const {});
    if (res == null || res['deleted'] != true) {
      debugPrint('[delete-account] refused or unreachable: $res');
      return false;
    }

    // 2. THEN THE DEVICE. Best-effort from here on: the account is already
    // gone, so nothing below can fail in a way that should be reported as
    // "deletion failed" — that would be untrue and would invite a retry that
    // can only 401.

    // Sign out FIRST, so the stores stop believing they have a cloud to talk
    // to before their caches disappear underneath them.
    try {
      await SocialAuth.signOutGoogle();
    } catch (_) {/* Play Services cache; see social_auth.dart */}

    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // The session is server-side dead already — the user row it belonged to
      // no longer exists. Failing to clear it locally is not worth surfacing.
    }

    // EVERY local cache, not just the ones this file happens to know about.
    // Leaving them would mean the next account created on this phone gets
    // seeded with the deleted user's data — see local_wipe.dart. This also
    // subsumes the pending profile and the auth flag, which is why neither is
    // cleared separately any more.
    await LocalWipe.run();

    return true;
  }
}
