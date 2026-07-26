// =============================================================================
//  CarePartnerEngine — tokens, links, and the rules about who gets credited
// -----------------------------------------------------------------------------
//  Pure Dart. Every rule that decides whether a parent is attributed to a
//  partner lives here so it can be tested exhaustively, and so there is one
//  place to look when a doctor asks "why was this family not credited to me?".
//
//  As with the parent referral engine, this is the CLIENT's copy. It exists to
//  fail fast and to give a decent message; the server re-runs everything before
//  writing an attribution, because attribution is money.
//
//  TWO THINGS DELIBERATELY SEPARATE FROM lib/referral/:
//
//  * A DIFFERENT URL PATH. Parent invites are /invite/<CODE>; partner referrals
//    are /care/<TOKEN>. One path per system means a link can never be resolved
//    by the wrong engine, and either can change without touching the other.
//
//  * A DIFFERENT TOKEN SHAPE. Partner tokens are 10 characters, parent codes 7.
//    A parent code is meant to be read aloud and retyped by a friend; a partner
//    token is printed on a poster and scanned, so it trades memorability for a
//    much larger space (31^10 ~= 8x10^14) - which is what makes guessing
//    someone else's QR pointless.
// =============================================================================

import 'care_partner_models.dart';

/// Why an attribution attempt was refused. Kept as a type rather than a string
/// so the UI, the analytics label and the support message cannot drift apart.
enum AttributionRefusal {
  malformedToken,
  unknownPartner,
  partnerNotActive,
  expired,
  alreadyAttributed,
  selfReferral,
}

extension AttributionRefusalX on AttributionRefusal {
  /// Said to the PARENT. Never blames them, never exposes partner internals.
  String get parentMessage => switch (this) {
        AttributionRefusal.malformedToken =>
          'That link does not look right. Ask for it again?',
        AttributionRefusal.unknownPartner =>
          'We could not find that care partner.',
        AttributionRefusal.partnerNotActive =>
          'This care partner is not active on ParentVeda yet.',
        AttributionRefusal.expired => 'This invitation has expired.',
        AttributionRefusal.alreadyAttributed =>
          'You are already connected to a care partner.',
        AttributionRefusal.selfReferral =>
          'You cannot connect yourself as your own care partner.',
      };

  /// Short, fixed label for analytics. Never free text.
  String get analyticsLabel => name;
}

class CarePartnerEngine {
  CarePartnerEngine._();

  /// Same unambiguous alphabet as the parent codes: no I, L, O, 0 or 1. A
  /// partner token gets read off a printed poster in a clinic corridor, and a
  /// misread character is a family credited to nobody.
  static const String alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const int tokenLength = 10;

  /// The path partner referrals live on. NOT /invite/ - see the file header.
  static const String path = 'care';
  static const String host = 'parentveda.in';

  /// A token for a partner, optionally per campaign so the same doctor can run
  /// several (a poster campaign and a prescription campaign) and tell them
  /// apart in analytics.
  ///
  /// NOT THE SOURCE OF TRUTH. Kept for tests and for reasoning about the token
  /// shape; nothing in the product prints what this returns.
  ///
  /// It used to be what the referral kit rendered, and that was a defect: the
  /// website resolves a scan against partner_referrals, so a derived token with
  /// no matching row produced a QR that scanned, looked correct, and credited
  /// nobody — on something printed and stuck to a wall. Tokens are now minted
  /// by the database (0040) and only ever READ by the app.
  ///
  /// Deterministic from (partnerId, campaignId, rotation).
  static String tokenFor(String partnerId,
      {String? campaignId, int rotation = 0}) {
    if (partnerId.isEmpty) return '';
    final seed = '$partnerId|${campaignId ?? ''}|$rotation';
    var h = 0x811c9dc5;
    for (final unit in seed.codeUnits) {
      h ^= unit;
      h = (h * 0x01000193) & 0xffffffff;
    }
    // A second, differently-seeded pass: one 32-bit hash does not have enough
    // entropy to fill 10 characters without visible structure, and structure in
    // a token is what makes neighbouring tokens guessable.
    var g = 0x2545f491;
    for (final unit in seed.codeUnits.reversed) {
      g ^= unit;
      g = (g * 0x85ebca6b) & 0xffffffff;
    }
    final out = StringBuffer();
    var a = h, b = g;
    for (var i = 0; i < tokenLength; i++) {
      final v = (i.isEven ? a : b) ^ (i * 0x9e3779b9);
      out.write(alphabet[v.abs() % alphabet.length]);
      a = ((a << 5) ^ (a >> 3) ^ b) & 0xffffffff;
      b = ((b << 7) ^ (b >> 1) ^ h) & 0xffffffff;
      if (a == 0) a = h + i + 1;
      if (b == 0) b = g + i + 1;
    }
    return out.toString();
  }

  static bool isWellFormed(String token) {
    final t = token.trim().toUpperCase();
    if (t.length != tokenLength) return false;
    return t.split('').every(alphabet.contains);
  }

  /// Tolerates what a scanner or a person actually produces: a full URL, extra
  /// query parameters, spaces, dashes, lower case.
  static String normalise(String raw) {
    var s = raw.trim();
    final m = RegExp('(?:/$path/|[?&]c=)([A-Za-z0-9]+)').firstMatch(s);
    if (m != null) s = m.group(1)!;
    return s.replaceAll(RegExp(r'[\s\-_]'), '').toUpperCase();
  }

  /// The URL printed on a QR, poster or prescription.
  ///
  /// [channel] rides along so the same token can be told apart by where it was
  /// used — a poster scan and a WhatsApp tap are the same partner but very
  /// different acquisition costs, and the spec asks for channel analytics.
  static String linkFor(
    String token, {
    ReferralChannel channel = ReferralChannel.qr,
    String? campaignId,
  }) {
    final q = <String>[
      'ch=${channel.name}',
      if (campaignId != null && campaignId.isNotEmpty) 'cm=$campaignId',
    ].join('&');
    return 'https://$host/$path/${token.toUpperCase()}?$q';
  }

  /// Pull the token out of an incoming URL. Null when it is not one of ours —
  /// including when it is a PARENT invite link, which must never resolve here.
  static String? tokenFromUri(Uri uri) {
    if (uri.host.isNotEmpty && !uri.host.endsWith(host)) return null;
    final segs = uri.pathSegments;
    // Explicitly reject the parent-referral path even though it is our domain.
    if (segs.contains('invite')) return null;
    final i = segs.indexOf(path);
    if (i >= 0 && i + 1 < segs.length) {
      final t = normalise(segs[i + 1]);
      return isWellFormed(t) ? t : null;
    }
    final q = uri.queryParameters['c'];
    if (q != null && q.isNotEmpty) {
      final t = normalise(q);
      return isWellFormed(t) ? t : null;
    }
    return null;
  }

  static ReferralChannel channelFromUri(Uri uri) =>
      ReferralChannelX.parse(uri.queryParameters['ch']);

  static String? campaignFromUri(Uri uri) {
    final c = uri.queryParameters['cm'];
    return (c == null || c.isEmpty) ? null : c;
  }

  // ---- the rules ------------------------------------------------------------

  /// Whether this parent may be attributed to this partner right now.
  ///
  /// Returns null when it is fine. Order matters: the cheapest and least
  /// revealing checks run first, so a guessed token is refused as "malformed"
  /// long before anything confirms whether a partner exists.
  static AttributionRefusal? refusal({
    required String token,
    required CarePartner? partner,
    required bool alreadyAttributed,
    DateTime? expiresAt,
    String? viewerExpertId,
    DateTime? now,
  }) {
    if (!isWellFormed(normalise(token))) {
      return AttributionRefusal.malformedToken;
    }
    if (partner == null) return AttributionRefusal.unknownPartner;
    if (!partner.canAcquire) return AttributionRefusal.partnerNotActive;

    if (expiresAt != null && (now ?? DateTime.now()).isAfter(expiresAt)) {
      return AttributionRefusal.expired;
    }

    // A doctor scanning their own QR while signed in as that expert. Cheap to
    // catch here; the server checks it too, because this one directly creates
    // commission out of nothing.
    if (viewerExpertId != null &&
        viewerExpertId.isNotEmpty &&
        viewerExpertId == partner.expertId) {
      return AttributionRefusal.selfReferral;
    }

    // FIRST TOUCH WINS. A parent already bound to a partner is not re-bound by
    // a later scan — attribution is permanent by design.
    //
    // OPEN POINT (parked with the user): what SHOULD happen when a family
    // meets a second partner months later. Today the second partner simply
    // does not take the attribution; whether they should join the Care Circle
    // without commission, or share it, is undecided. Nothing here forecloses
    // either answer.
    if (alreadyAttributed) return AttributionRefusal.alreadyAttributed;

    return null;
  }

  /// Whether a partner may currently hand out referrals at all. Separate from
  /// [refusal] because this is about the PARTNER's state, not a parent's
  /// attempt — the doctor app uses it to explain why their QR is not live.
  static String? partnerBlocked(CarePartner p) {
    switch (p.status) {
      case PartnerStatus.pending:
        return 'Your ParentVeda partnership is still being verified. Your QR '
            'goes live as soon as that is done.';
      case PartnerStatus.inactive:
        return 'Your partnership is paused. Families you already referred are '
            'unaffected.';
      case PartnerStatus.rejected:
        return 'This partnership was not approved.';
      case PartnerStatus.active:
        return null;
    }
  }
}
