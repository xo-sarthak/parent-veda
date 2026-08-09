// =============================================================================
//  LocalWipe — remove every trace of an account from this device.
// =============================================================================
//
//  THE BUG THIS CLOSES
//  -------------------
//  Deleting an account removed everything server-side, and left every store's
//  local cache sitting in shared_preferences. That is not merely untidy —
//  `cloud_synced_store.dart` resolves a first sync like this:
//
//      if (cloudData != null)  applyCloudData(...)          // cloud wins
//      else                    saveState(cloudKey, local)   // SEED FROM LOCAL
//
//  A freshly created account has no cloud data. So the `else` branch fires and
//  the PREVIOUS user's cache is uploaded into the new account:
//
//      Priya deletes her account  →  her sister signs up on the same phone
//                                 →  new account has no cloud rows
//                                 →  Priya's journal is seeded into it
//
//  "Delete everything" that quietly re-uploads the data is the opposite of what
//  it promises, and the person harmed never touched the button.
//
//  WHY ALLOWLIST-AND-CLEAR, NOT ENUMERATE-AND-DELETE
//  -------------------------------------------------
//  The obvious implementation is a list of the ~25 store keys to remove. That
//  list drifts the moment somebody adds a store — and it drifts in the
//  dangerous direction, because the symptom of a forgotten key is silent: data
//  survives a deletion and lands in a stranger's account.
//
//  Clearing everything and restoring a tiny known-safe set fails the other way.
//  Forget to allowlist something and it gets wiped — mildly annoying, and
//  immediately visible. When a mistake is inevitable, choose the design whose
//  mistakes are loud and harmless over the one whose mistakes are quiet and
//  severe.
//
//  WHY THE APP THEN CLOSES
//  -----------------------
//  Clearing storage does not empty the singleton stores already loaded in
//  memory. They would keep their data for the life of the process and re-persist
//  it on the next write — re-creating the exact bug one layer up. Resetting all
//  of them would mean a reset hook in every store, which is a lot of surface to
//  keep correct for one rare path. Ending the process is the guaranteed version:
//  next launch, empty storage and fresh singletons, with nothing to remember.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pregnancy_controller.dart';

class LocalWipe {
  LocalWipe._(); // static-only.

  /// Keys that survive, because they describe the DEVICE rather than the
  /// account. Deliberately tiny — everything not named here is account data
  /// until proven otherwise.
  ///
  /// Her reading language belongs to the phone: someone who reads Hindi still
  /// reads Hindi on the next account, and re-opening in English after a
  /// deletion would read as the app forgetting who she is.
  static const Set<String> keep = <String>{
    PregnancyController.kLanguageKey,
  };

  /// Erase all locally cached account data. Best-effort and never throws — by
  /// the time this runs the server row is already gone, so failing here must
  /// not be reported as "deletion failed".
  static Future<void> run() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Read the survivors BEFORE clearing.
      final saved = <String, Object>{};
      for (final k in keep) {
        final v = prefs.get(k);
        if (v != null) saved[k] = v;
      }

      await prefs.clear();

      // shared_preferences has no generic setter, so the type has to be
      // recovered by inspection. Anything unrecognised is simply not restored,
      // which is the safe direction.
      for (final entry in saved.entries) {
        final v = entry.value;
        if (v is String) {
          await prefs.setString(entry.key, v);
        } else if (v is bool) {
          await prefs.setBool(entry.key, v);
        } else if (v is int) {
          await prefs.setInt(entry.key, v);
        } else if (v is double) {
          await prefs.setDouble(entry.key, v);
        } else if (v is List<String>) {
          await prefs.setStringList(entry.key, v);
        } else {
          debugPrint('LocalWipe: not restoring ${entry.key} (${v.runtimeType})');
        }
      }
    } catch (e) {
      debugPrint('LocalWipe failed: $e');
    }
  }
}
