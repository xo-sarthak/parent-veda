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
//  A CARE PARTNER poster goes through the SAME Play install, and must not be
//  lost there — a QR on a clinic wall is scanned by a phone that does not have
//  the app yet, which is the entire point of it. Same mechanism, different
//  source:
//
//      share URL   https://parentveda.in/care/<TOKEN>?ch=qr
//      we receive  utm_source=care&utm_medium=partner&utm_content=<TOKEN>
//                  [&utm_campaign=<CAMPAIGN>&utm_term=<CHANNEL>]
//
//  The two are told apart by utm_source, NOT by guessing from the code length.
//  A 7-character parent code and a 10-character partner token would be
//  distinguishable today and would stop being so the moment either length
//  changes, and the failure mode — crediting the wrong person — is silent.
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

import '../care_partner/care_partner_engine.dart';
import '../care_partner/care_partner_models.dart';
import '../care_partner/care_partner_store.dart';
import 'referral_analytics.dart';
import 'referral_engine.dart';
import 'referral_store.dart';

class InstallReferrerService {
  InstallReferrerService._();
  static final InstallReferrerService instance = InstallReferrerService._();

  static const _checkedKey = 'install_referrer_checked_v1';

  /// The key the website sends the code under — the same for both systems.
  static const String codeParam = 'utm_content';

  /// utm_source values. This is the ONLY thing that decides which system a
  /// referrer belongs to.
  static const String parentSource = 'invite';
  static const String partnerSource = 'care';

  /// Pull the code out of a Play referrer string.
  ///
  /// Parsed as a query string rather than matched, per the contract: today it
  /// is `utm_source=invite&utm_medium=referral&utm_content=ABCD234`, and more
  /// keys may be added.
  static String? codeFromReferrer(String? referrer) {
    final p = _params(referrer);
    if (p == null) return null;
    // A partner poster is not a parent invite. Refuse rather than fall
    // through, so a care token can never be redeemed as a friend's code.
    if (p['utm_source'] == partnerSource) return null;
    final raw = p[codeParam];
    if (raw == null || raw.isEmpty) return null;
    final code = ReferralEngine.normalise(raw);
    return ReferralEngine.isWellFormed(code) ? code : null;
  }

  /// The Care Partner token a Play referrer carried, or null.
  ///
  /// Requires utm_source=care. A referrer with no source is treated as the
  /// parent system, because that is what the website sent before partners
  /// existed and old links are still in circulation.
  static String? partnerTokenFromReferrer(String? referrer) {
    final p = _params(referrer);
    if (p == null) return null;
    if (p['utm_source'] != partnerSource) return null;
    final raw = p[codeParam];
    if (raw == null || raw.isEmpty) return null;
    final token = CarePartnerEngine.normalise(raw);
    return CarePartnerEngine.isWellFormed(token) ? token : null;
  }

  /// Which surface the partner link was used on, for the channel analytics the
  /// spec asks for.
  ///
  /// The website is expected to forward the link's `?ch=` into `utm_term`. When
  /// it has not, QR is the default rather than the generic `link`: a referrer
  /// that survived a Play install came from a phone that did not have the app,
  /// and the channel built for exactly that case is the printed poster.
  /// A wrong-but-plausible default is a real cost — it is a REQUIREMENT on the
  /// website, noted in docs/ADMIN-PANEL.md, not something to paper over here.
  static ReferralChannel partnerChannelFromReferrer(String? referrer) {
    final term = _params(referrer)?['utm_term'];
    if (term == null || term.isEmpty) return ReferralChannel.qr;
    return ReferralChannelX.parse(term);
  }

  static String? partnerCampaignFromReferrer(String? referrer) {
    final c = _params(referrer)?['utm_campaign'];
    return (c == null || c.isEmpty) ? null : c;
  }

  static Map<String, String>? _params(String? referrer) {
    if (referrer == null || referrer.trim().isEmpty) return null;
    try {
      // Uri.splitQueryString handles the percent-decoding the Play API has
      // already partly done, and copes with keys in any order.
      return Uri.splitQueryString(referrer.trim());
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
    String? raw;
    try {
      final details = await PlayInstallReferrer.installReferrer;
      raw = details.installReferrer;
      code = codeFromReferrer(raw);
      if (kDebugMode) {
        debugPrint('[referral] install referrer: $raw');
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

    // A CARE PARTNER token is held, not redeemed: binding needs an account and
    // she has just installed the app. holdToken persists it, so it survives
    // until she finishes onboarding — which is the whole reason a poster in a
    // clinic works at all.
    final partnerToken = partnerTokenFromReferrer(raw);
    if (partnerToken != null) {
      CarePartnerStore.instance.holdToken(
        partnerToken,
        channel: partnerChannelFromReferrer(raw),
        campaignId: partnerCampaignFromReferrer(raw),
      );
      if (kDebugMode) {
        debugPrint('[care] install referrer carried token $partnerToken');
      }
      // A referrer carries one or the other, never both.
      return null;
    }

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
