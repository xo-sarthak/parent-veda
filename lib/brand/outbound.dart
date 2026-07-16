// =============================================================================
//  Outbound — the single door out of ParentVeda
// -----------------------------------------------------------------------------
//  Every link that leaves the app should go through here. Today `url_launcher`
//  is called ad-hoc from ~10 places and every "affiliate" URL is a bare
//  retailer SEARCH url (amazon.in/s?k=…) with no partner tag on it — which
//  means the app has been sending real purchase traffic to retailers and
//  earning nothing from any of it. There was nowhere to put a tag.
//
//  This is that place. One function:
//    · appends the partner tag for that retailer (when we have one)
//    · fires purchaseClicked so campaign ROI is measurable
//    · fails safely — a bad url is a no-op, never a crash
//
//  Deliberately NOT a redirect through our own server. A parent tapping "Buy on
//  Amazon" should land on Amazon, not on a tracker that forwards them there.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'brand_analytics.dart';
import 'brand_models.dart';

/// Partner tags per retailer, added to outbound links.
///
/// EMPTY UNTIL REAL AFFILIATE ACCOUNTS EXIST. An empty map means links go out
/// clean — exactly today's behaviour — so wiring this up costs nothing and
/// changes nothing until there is a real tag to add. Filling in one entry
/// switches on attribution for that retailer everywhere in the app at once.
const Map<String, Map<String, String>> kPartnerTags = {
  // 'amazon.in': {'tag': 'parentveda-21'},
  // 'firstcry.com': {'aff': 'parentveda'},
};

/// The retailer key for a url, e.g. 'amazon.in'. Null when we do not know it.
String? retailerOf(Uri uri) {
  final host = uri.host.toLowerCase().replaceFirst('www.', '');
  for (final key in kPartnerTags.keys) {
    if (host == key || host.endsWith('.$key')) return key;
  }
  return null;
}

/// Add our partner tag to an outbound url, if we have one for that retailer.
///
/// Never overwrites a param the url already carries: if a brand handed us a
/// deep link with its own tracking on it, that is theirs and we leave it alone.
Uri tagged(Uri uri) {
  final key = retailerOf(uri);
  if (key == null) return uri;
  final tags = kPartnerTags[key]!;
  final params = Map<String, String>.from(uri.queryParameters);
  for (final e in tags.entries) {
    params.putIfAbsent(e.key, () => e.value);
  }
  return uri.replace(queryParameters: params);
}

/// Send a parent out of the app.
///
/// [campaign] attributes the click to a campaign when the journey started from
/// brand content. Organic taps pass null and are simply untracked — we do not
/// invent an attribution to make a number look better.
Future<bool> openOutbound(
  String url, {
  BrandCampaign? campaign,
  String? productId,
}) async {
  if (url.trim().isEmpty) return false;
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasScheme) return false;

  final out = tagged(uri);

  if (campaign != null) {
    final meta = <String, Object?>{'retailer': retailerOf(out) ?? out.host};
    if (productId != null) meta['productId'] = productId;
    BrandAnalytics.instance.event(campaign, BrandEvent.purchaseClicked, meta: meta);
  }

  try {
    return await launchUrl(out, mode: LaunchMode.externalApplication);
  } catch (e) {
    if (kDebugMode) debugPrint('outbound failed: $e');
    return false;
  }
}
