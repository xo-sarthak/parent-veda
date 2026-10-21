// =============================================================================
//  LocalOwner: whose data is on this phone (2026-10-17)
// -----------------------------------------------------------------------------
//  Nothing used to record which account the phone's local cache belonged to.
//  So when a second person signed in on the same phone (a shared family
//  phone, a phone handed on, a test account), the first person's cycles,
//  logs and saved things were merged into the second person's account by the
//  first sync, and shown to them.
//
//  The fix is the usual one for an offline-first app (Perplexity on Mobbin:
//  "Signing out will clear your query history from this device. Synced
//  queries are available upon signing back in"):
//
//    · the phone remembers the user id its data belongs to;
//    · signing out wipes the phone and empties every store; the account in
//      the cloud keeps everything;
//    · if a DIFFERENT account is ever found signed in (a sign-out that never
//      ran, an expired session), the same wipe runs BEFORE any sync merges
//      or uploads.
//
//  An install from before this release has no owner yet: the signed-in user
//  adopts it, so nobody loses anything on update.
//  See docs/BACKEND-PATTERNS.md, section 16ii.
// =============================================================================

import 'package:shared_preferences/shared_preferences.dart';

import '../notification_service.dart';
import '../remote/supabase_repo.dart';
import '../remote/sync_registry.dart';
import 'local_wipe.dart';

class LocalOwner {
  LocalOwner._();

  static const String kKey = 'pv_local_owner_uid';

  static Future<String?> read() async {
    try {
      return (await SharedPreferences.getInstance()).getString(kKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> claim(String uid) async {
    try {
      await (await SharedPreferences.getInstance()).setString(kKey, uid);
    } catch (_) {/* best-effort */}
  }

  /// The phone's data now belongs to whoever is signed in. When that is a
  /// different account from the one that owns it, wipe and empty everything
  /// first. Returns true when a wipe ran. Silent and harmless when logged out.
  static Future<bool> ensureCurrent() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return false;
    final owner = await read();
    if (owner == null) {
      await claim(uid);
      return false;
    }
    if (owner == uid) return false;
    await wipeThisPhone();
    await claim(uid);
    return true;
  }

  /// Sign-out and account switch: the local cache goes, every store forgets,
  /// and the phone belongs to nobody until the next sign-in claims it.
  static Future<void> wipeThisPhone() async {
    await LocalWipe.run(); // clears every key but the device's own (language)
    SyncRegistry.resetAll();
    // ⚠️ THE LAST PERSON'S ALARMS USED TO KEEP RINGING (found 2026-10-21, sync
    // log step 12). The wipe emptied the stores but never touched what was
    // already scheduled with the OS, so after a delete, or another account
    // signing in, her medicine and appointment reminders still went off.
    // Sign-out muted them, but see `pvSignOut`: the wipe then deleted the mute.
    try {
      await NotificationService.instance.cancelAllScheduled();
    } catch (_) {/* best-effort */}
  }
}
