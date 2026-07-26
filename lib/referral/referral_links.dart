// =============================================================================
//  ReferralLinks — turning an opened link into a redeemed code
// -----------------------------------------------------------------------------
//  What this covers, and what it honestly cannot:
//
//  INSTALLED  -> an Android App Link / iOS Universal Link opens the app on
//                parentveda.in/invite/<CODE>. handleLink() below reads the
//                code and hands it to the store. Verified domain, no vendor,
//                no cost.
//
//  NOT INSTALLED -> the link goes to the web page, which sends the visitor to
//                the store. The referral CANNOT ride through that install for
//                free: carrying it is "deferred deep linking", which Firebase
//                Dynamic Links used to do and stopped doing on 25 August 2025.
//                The remaining options are paid attribution vendors (Branch,
//                AppsFlyer, Adjust) or fingerprinting, which is both unreliable
//                and a privacy trade we should not make for a referral.
//                So we ask: "Have an invite code?" - see enter_code_sheet.dart.
//
//  If deferred attribution ever becomes worth paying for, it plugs in behind
//  this same class and nothing else in the app changes.
// =============================================================================

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import 'referral_analytics.dart';
import 'referral_engine.dart';
import 'referral_store.dart';

class ReferralLinks {
  ReferralLinks._();

  static const String host = 'parentveda.in';

  /// A code held from a cold start, so onboarding can apply it at the right
  /// moment rather than mid-splash.
  static String? _pending;
  static String? get pending => _pending;

  /// True when a link brought a code in and it has not been consumed yet.
  static bool get hasPending => (_pending ?? '').isNotEmpty;

  /// Parse an incoming link. Returns the code, or null when it is not one of
  /// ours. Tolerant of both shapes the spec named:
  ///     parentveda.in/invite/ABCD234
  ///     parentveda.in?r=ABCD234
  static String? codeFromUri(Uri uri) {
    if (uri.host.isNotEmpty && !uri.host.endsWith(host)) return null;
    final q = uri.queryParameters['r'];
    if (q != null && q.isNotEmpty) {
      final c = ReferralEngine.normalise(q);
      return ReferralEngine.isWellFormed(c) ? c : null;
    }
    final segs = uri.pathSegments;
    final i = segs.indexOf('invite');
    if (i >= 0 && i + 1 < segs.length) {
      final c = ReferralEngine.normalise(segs[i + 1]);
      return ReferralEngine.isWellFormed(c) ? c : null;
    }
    return null;
  }

  /// Called when the OS hands us a link. Stores the code for onboarding to
  /// apply; does NOT redeem immediately, because redeeming needs an account and
  /// the friend may not have signed in yet.
  static void handleLink(Uri uri) {
    final code = codeFromUri(uri);
    if (code == null) return;
    _pending = code;
    ReferralAnalytics.linkOpened();
    if (kDebugMode) debugPrint('[referral] link carried code $code');
  }

  /// Apply a pending code once an account exists. Returns null on success, a
  /// message on refusal, or null when there was nothing pending.
  static Future<String?> applyPending({String? dueMonth}) async {
    final code = _pending;
    if (code == null || code.isEmpty) return null;
    final problem =
        await ReferralStore.instance.redeem(code, dueMonth: dueMonth);
    // Clear either way: a bad code should not be retried forever on every
    // launch, and a good one is now recorded.
    _pending = null;
    if (problem == null) {
      ReferralAnalytics.codeAccepted();
    } else {
      ReferralAnalytics.codeRejected(problem);
    }
    return problem;
  }

  static AppLinks? _appLinks;
  static StreamSubscription<Uri>? _sub;

  /// Start listening for links from the OS. Two cases, both needed:
  ///   * COLD START - the app was launched BY the link, so the initial link has
  ///     already happened and no stream event will ever fire for it;
  ///   * WARM - the app is already running and Android/iOS hands it a new URI.
  /// Missing the first is the classic bug: tapping an invite while the app is
  /// closed silently loses the code.
  ///
  /// Never throws: a referral link must not be able to stop the app starting.
  static Future<void> startListening() async {
    if (_appLinks != null) return; // idempotent - safe on every app start
    try {
      final links = AppLinks();
      _appLinks = links;
      final initial = await links.getInitialLink();
      if (initial != null) handleLink(initial);
      _sub = links.uriLinkStream.listen(handleLink, onError: (_) {});
    } catch (_) {
      _appLinks = null; // deep links simply do not work; the code entry does
    }
  }

  static Future<void> stopListening() async {
    await _sub?.cancel();
    _sub = null;
    _appLinks = null;
  }

  @visibleForTesting
  static void clearPending() => _pending = null;
}
