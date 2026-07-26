// =============================================================================
//  InstallReferrerService — carrying a referral THROUGH the Play install
// -----------------------------------------------------------------------------
//  CORRECTION TO AN EARLIER ASSUMPTION IN THIS CODEBASE. Other files here said
//  no free mechanism could carry a referral through an app-store install, and
//  that manual code entry was the only honest fallback. That is true on iOS. It
//  is NOT true on Android: the Play Install Referrer API hands the app the
//  referrer string the Play Store link carried, and it is exactly what Firebase
//  Dynamic Links used underneath on Android.
//
//  THE CONTRACT with the website (parentveda.in), which must not drift:
//
//      share URL   https://parentveda.in/invite/<CODE>
//      Android     the page redirects to the Play listing with
//                  &referrer=<url-encoded>
//      we receive  utm_source=invite&utm_medium=referral&utm_content=ABCD234
//
//  utm_content carries the code. It is PARSED AS A QUERY STRING, never
//  substring-matched, because the website may add keys later and a
//  substring match would break the day it does.
//
//  Runs ONCE, ever. The value stays available from Play for 90 days after
//  install, but re-reading it on every launch risks re-applying a code to a
//  parent who has since been referred by someone else, so a flag records that
//  we have looked.
// =============================================================================

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'referral_analytics.dart';
import 'referral_engine.dart';
import 'referral_store.dart';

class InstallReferrerService {
  InstallReferrerService._();
  static final InstallReferrerService instance = InstallReferrerService._();

  static const _checkedKey = 'install_referrer_checked_v1';

  /// The key the website sends the code under.
  static const String codeParam = 'utm_content';

  /// Pull the code out of a Play referrer string.
  ///
  /// Parsed as a query string rather than matched, per the contract: today it
  /// is `utm_source=invite&utm_medium=referral&utm_content=ABCD234`, and more
  /// keys may be added.
  static String? codeFromReferrer(String? referrer) {
    if (referrer == null || referrer.trim().isEmpty) return null;
    try {
      // Uri.splitQueryString handles the percent-decoding the Play API has
      // already partly done, and copes with keys in any order.
      final params = Uri.splitQueryString(referrer.trim());
      final raw = params[codeParam];
      if (raw == null || raw.isEmpty) return null;
      final code = ReferralEngine.normalise(raw);
      return ReferralEngine.isWellFormed(code) ? code : null;
    } catch (_) {
      return null;
    }
  }

  /// Check Play for a referrer, once ever, and apply any code it carried.
  ///
  /// Returns the code applied, or null — which is the normal case for an
  /// organic install. Never throws: a referral must not be able to stop the
  /// app starting.
  Future<String?> checkOnce({String? dueMonth}) async {
    // Android only. iOS has no install-referrer equivalent at all, which is
    // exactly why manual code entry stays in the product rather than being a
    // stopgap.
    if (!Platform.isAndroid) return null;

    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_checkedKey) ?? false) return null;
    } catch (_) {
      // Without prefs we cannot record that we looked, and running again on
      // the next launch is worse than not running at all.
      return null;
    }

    String? code;
    try {
      final details = await PlayInstallReferrer.installReferrer;
      code = codeFromReferrer(details.installReferrer);
      if (kDebugMode) {
        debugPrint('[referral] install referrer: ${details.installReferrer}');
      }
    } catch (_) {
      // No Play Store, an OEM store that drops the referrer, a sideload, or
      // the service simply being unavailable. All ordinary; the manual code
      // entry covers every one of them.
      code = null;
    }

    // Mark as checked whatever happened. Retrying forever on a device that
    // will never have a referrer just burns a service connection per launch.
    try {
      await prefs.setBool(_checkedKey, true);
    } catch (_) {/* best effort */}

    if (code == null) return null;

    // A parent who already came in on someone else's code keeps that one. The
    // server enforces this too (referral_invites.invitee_id is unique); this
    // just avoids a pointless call and a confusing error.
    if (ReferralStore.instance.hasRedeemed) {
      if (kDebugMode) {
        debugPrint('[referral] referrer code ignored - already referred');
      }
      return null;
    }

    ReferralAnalytics.linkOpened();
    final problem =
        await ReferralStore.instance.redeem(code, dueMonth: dueMonth);
    if (problem != null) {
      ReferralAnalytics.codeRejected(problem);
      return null;
    }
    ReferralAnalytics.codeAccepted();
    return code;
  }

  /// Test seam — lets a test re-run the once-only check.
  @visibleForTesting
  static Future<void> resetChecked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_checkedKey);
    } catch (_) {/* ignore */}
  }
}
