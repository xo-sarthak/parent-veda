// =============================================================================
//  PendingProfile — onboarding answers that outlive a missing session.
// =============================================================================
//
//  WHY THIS EXISTS
//  ---------------
//  With Supabase's "Confirm email" turned OFF, `auth.signUp` returns a session
//  immediately, so the onboarding screens can write straight into `profiles`.
//  That is how the flow has always worked — and it is why the setting has had
//  to stay off, which in turn means anyone can register with an address they do
//  not own. Not something to ship.
//
//  With it ON, `signUp` creates the user but NO session: there is no session
//  until she clicks the link in her email. Everything after that point in
//  onboarding — her name, role, due date, WhatsApp opt-in — is collected while
//  logged out, and `.update().eq('id', uid)` has no `uid` to aim at. RLS would
//  refuse it even if it did.
//
//  The old code noticed and gave up, toasting 'turn OFF "Confirm email"'. That
//  is a developer's note wearing a user's clothes.
//
//  THE FIX IS THE HOUSE PATTERN, NOT A NEW ONE
//  -------------------------------------------
//  Every store here already works this way: write locally, sync when the cloud
//  is reachable, and treat "logged out" as a normal state rather than an error.
//  An unconfirmed account is just another flavour of not-yet-reachable. So the
//  answers are kept on the device and replayed the moment a session appears.
//
//  WHAT IS STORED: the exact map `_saveProfile` would have sent — not a parsed
//  model. If a future column is added to that write it rides along here for
//  free, with no second place to remember to update. The cost is that this file
//  cannot validate what it holds; the benefit is that it can never drift from
//  what the write actually sends. For a payload written in one place and read
//  in one place, that trade is worth making.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../remote/supabase_repo.dart';

class PendingProfile {
  PendingProfile._(); // static-only.

  static const String _key = 'pending_profile_json';

  /// Hold onto the onboarding answers until there is somebody to attach them to.
  static Future<void> save(Map<String, dynamic> fields) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(fields));
    } catch (e) {
      debugPrint('PendingProfile.save failed: $e');
    }
  }

  /// What is waiting, or null if nothing is.
  static Future<Map<String, dynamic>?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (e) {
      // Corrupt JSON must not wedge every future login behind a failed decode.
      debugPrint('PendingProfile.load failed: $e');
      return null;
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      debugPrint('PendingProfile.clear failed: $e');
    }
  }

  /// Write anything pending into `profiles`, then forget it.
  ///
  /// Call after ANY route that establishes a session. Safe to call when there
  /// is nothing pending and safe to call when logged out — both are no-ops, so
  /// callers never need to check first.
  ///
  /// Returns true only if a row was actually written.
  ///
  /// ONLY CLEARED ON CONFIRMED SUCCESS. `.select()` makes the update return the
  /// rows it changed, and we require a non-empty result before forgetting the
  /// local copy. Clearing on a fire-and-forget write would mean an RLS refusal
  /// or a dropped connection silently discards her due date — the one answer
  /// the whole pregnancy stage is built on. Retrying next login is free;
  /// re-asking her is not.
  static Future<bool> flush() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return false; // logged out — nothing to attach to yet

    final fields = await load();
    if (fields == null || fields.isEmpty) return false;

    final wrote = await SupabaseRepo.updateMyProfileConfirmed(fields);
    if (!wrote) {
      debugPrint('PendingProfile.flush did not land — keeping it for next time');
      return false;
    }
    await clear();
    return true;
  }
}
