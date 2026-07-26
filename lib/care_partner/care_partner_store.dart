// =============================================================================
//  CarePartnerStore — who introduced this parent, held locally
// -----------------------------------------------------------------------------
//  Local-first like every other store, with one difference that matters: the
//  ATTRIBUTION ITSELF is written by the server and never by this class. What is
//  cached here is a copy, so the Care Circle renders instantly and offline.
//
//  The pending-token idea is the whole point of the module. A parent scans a QR
//  in a clinic corridor, installs the app, and only signs up ten minutes later.
//  The token has to survive that gap - across the install, the splash, the
//  onboarding - or the doctor loses the family. So a scanned token is held here
//  until there is an account to attach it to.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/supabase_repo.dart';
import 'care_partner_engine.dart';
import 'care_partner_models.dart';

class CarePartnerStore extends ChangeNotifier {
  CarePartnerStore._();
  static final CarePartnerStore instance = CarePartnerStore._();

  static const _key = 'care_partner_v1';

  Attribution? _attribution;
  CarePartner? _partner;

  /// A token seen before there was an account to bind it to.
  String? _pendingToken;
  ReferralChannel _pendingChannel = ReferralChannel.qr;
  DateTime? _pendingScannedAt;
  DateTime? _pendingInstalledAt;
  String? _pendingCampaign;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// Who introduced this parent. Null when she arrived organically.
  Attribution? get attribution => _attribution;
  CarePartner? get partner => _partner;
  bool get hasPartner => _attribution != null;

  bool get hasPending => (_pendingToken ?? '').isNotEmpty;
  String? get pendingToken => _pendingToken;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final d = jsonDecode(raw) as Map;
        if (d['attribution'] is Map) {
          _attribution = Attribution.fromMap(d['attribution'] as Map);
        }
        if (d['partner'] is Map) {
          _partner = CarePartner.fromMap(d['partner'] as Map);
        }
        // A token already held in memory WINS over the one on disk. A deep
        // link or an install referrer can land before this finishes - the app
        // was very likely launched BY one - and loading over it would silently
        // throw away the scan that started everything.
        if ((_pendingToken ?? '').isEmpty) {
          _pendingToken = d['pendingToken']?.toString();
          _pendingChannel =
              ReferralChannelX.parse(d['pendingChannel']?.toString());
          _pendingCampaign = d['pendingCampaign']?.toString();
          _pendingScannedAt = DateTime.tryParse('${d['pendingScannedAt']}');
          _pendingInstalledAt = DateTime.tryParse('${d['pendingInstalledAt']}');
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
  }

  /// A QR was scanned or a /care/ link opened. Held, not applied: binding needs
  /// an account, and she may not have one yet.
  void holdToken(
    String token, {
    ReferralChannel channel = ReferralChannel.qr,
    String? campaignId,
  }) {
    final t = CarePartnerEngine.normalise(token);
    if (!CarePartnerEngine.isWellFormed(t)) return;
    if (hasPartner) return; // first touch wins; do not overwrite
    _pendingToken = t;
    _pendingChannel = channel;
    _pendingCampaign = campaignId;
    // WHEN she scanned. The server cannot observe this - there is no account
    // yet - so it is recorded here and handed over at binding time, where it
    // is clamped (0039). Without it the funnel starts at signup and a printed
    // poster can never be measured.
    _pendingScannedAt ??= DateTime.now();
    _pendingInstalledAt ??= DateTime.now();
    _persist();
    notifyListeners();
  }

  void clearPending() {
    _pendingToken = null;
    _pendingCampaign = null;
    _pendingScannedAt = null;
    _pendingInstalledAt = null;
    _persist();
    notifyListeners();
  }

  /// Look up the partner behind a token so the welcome can say a real name
  /// BEFORE she signs up. Reads the public partner row only.
  Future<CarePartner?> lookup(String token) async {
    final t = CarePartnerEngine.normalise(token);
    if (!CarePartnerEngine.isWellFormed(t)) return null;
    try {
      final refs = await SupabaseRepo.selectAll('partner_referrals');
      final ref = refs
          .whereType<Map>()
          .where((r) => '${r['token']}' == t)
          .firstOrNull;
      if (ref == null) return null;
      final partners = await SupabaseRepo.selectAll('care_partners');
      final row = partners
          .whereType<Map>()
          .where((p) => '${p['id']}' == '${ref['partner_id']}')
          .firstOrNull;
      return row == null ? null : partnerFromRow(row);
    } catch (_) {
      return null;
    }
  }

  /// Bind the held token to this account. Called once she has signed up.
  ///
  /// The SERVER decides — this only asks. Returns null on success, or a
  /// sentence to show her.
  Future<String?> applyPending() async {
    final token = _pendingToken;
    if (token == null || token.isEmpty) return null;
    if (!SupabaseRepo.isLoggedIn) return null; // still no account; keep holding

    try {
      final res = await SupabaseRepo.callFunction('attribute_to_partner', {
        'p_token': token,
        'p_channel': _pendingChannel.name,
        'p_campaign': _pendingCampaign,
        'p_scanned_at': _pendingScannedAt?.toUtc().toIso8601String(),
        'p_installed_at': _pendingInstalledAt?.toUtc().toIso8601String(),
      });
      final status = res.isEmpty ? 'ok' : '${res.first}';
      // Clear either way: a token that will never bind should not be retried on
      // every launch forever.
      clearPending();
      if (status == 'ok') {
        await refreshFromServer();
        return null;
      }
      return switch (status) {
        'unknown_token' => AttributionRefusal.malformedToken.parentMessage,
        'unknown_partner' => AttributionRefusal.unknownPartner.parentMessage,
        'partner_not_active' => AttributionRefusal.partnerNotActive.parentMessage,
        'expired' => AttributionRefusal.expired.parentMessage,
        'self_referral' => AttributionRefusal.selfReferral.parentMessage,
        'already_attributed' =>
          AttributionRefusal.alreadyAttributed.parentMessage,
        _ => null, // not signed in, or a transient failure - stay quiet
      };
    } catch (_) {
      return null; // offline: keep the token and try again next launch
    }
  }

  /// Pull this parent's own attribution and the partner behind it.
  Future<void> refreshFromServer() async {
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      final rows = await SupabaseRepo.selectAll('partner_attributions');
      final mine = rows.whereType<Map>().firstOrNull;
      if (mine == null) return;
      _attribution = Attribution.fromMap(mine);

      final partners = await SupabaseRepo.selectAll('care_partners');
      final row = partners
          .whereType<Map>()
          .where((p) => '${p['id']}' == _attribution!.partnerId)
          .firstOrNull;
      if (row != null) _partner = partnerFromRow(row);

      _persist();
      notifyListeners();
    } catch (_) {/* keep the cached view */}
  }

  /// Build a partner from a care_partners row. Public because the doctor-side
  /// dashboard reads the same table from the other end of the relationship.
  static CarePartner partnerFromRow(Map r) => CarePartner(
        id: '${r['id']}',
        name: (r['name'] ?? '').toString(),
        type: (r['type'] ?? CarePartnerType.doctor).toString(),
        status: PartnerStatus.values.firstWhere(
            (s) => s.name == r['status'],
            orElse: () => PartnerStatus.pending),
        speciality: (r['speciality'] ?? '').toString(),
        organisation: (r['organisation'] ?? '').toString(),
        department: (r['department'] ?? '').toString(),
        city: (r['city'] ?? '').toString(),
        logoUrl: r['logo_url']?.toString(),
        photoUrl: r['photo_url']?.toString(),
        trust: r['trust'] is Map
            ? TrustMessage.fromMap(r['trust'] as Map)
            : const TrustMessage(),
        expertId: r['expert_id']?.toString(),
        verifiedAt: r['verified_at'] == null
            ? null
            : DateTime.tryParse('${r['verified_at']}'),
      );

  /// Record a journey event. Append-only; the partner sees only counts.
  void recordEvent(String event, {String? detail}) {
    if (!SupabaseRepo.isLoggedIn) return;
    SupabaseRepo.fireEvent('parent_timeline', {
      'user_id': SupabaseRepo.userId,
      'partner_id': _attribution?.partnerId,
      'event': event,
      'detail': detail,
      'at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode({
          'attribution': _attribution?.toMap(),
          'partner': _partner?.toMap(),
          'pendingToken': _pendingToken,
          'pendingChannel': _pendingChannel.name,
          'pendingCampaign': _pendingCampaign,
          'pendingScannedAt': _pendingScannedAt?.toIso8601String(),
          'pendingInstalledAt': _pendingInstalledAt?.toIso8601String(),
        }),
      );
    } catch (_) {/* in-memory stands */}
  }

  @visibleForTesting
  void resetAll() {
    _pendingScannedAt = null;
    _pendingInstalledAt = null;
    _attribution = null;
    _partner = null;
    _pendingToken = null;
    _pendingCampaign = null;
    _loaded = false;
    notifyListeners();
  }

  @visibleForTesting
  void debugSeed({Attribution? attribution, CarePartner? partner}) {
    _attribution = attribution;
    _partner = partner;
    _loaded = true;
    notifyListeners();
  }
}
