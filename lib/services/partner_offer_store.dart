// =============================================================================
//  PartnerOfferStore — the offers only her employer's, school's, doctor's or
//  clinic's families get
// -----------------------------------------------------------------------------
//  Partner Editions A3 (docs/partner-editions/MASTER.md). The app's half of
//  migration 0148: `my_partner_offers()` returns the CALLER's own audience
//  coupons, and nothing else. Who may see an offer is the database's decision
//  (0142's `_audience_ok`); this store only holds the answer.
//
//  MEMORY ONLY, ON PURPOSE. Most stores here show a cached copy at launch and
//  refresh after (local-first). This one keeps no disk copy, and the trade is
//  deliberate: on a cold start the offer card arrives a moment after the rest
//  of the rail, and in return a coupon code never sits in shared preferences,
//  under a key that sign-out would have to remember to wipe. An offer is an
//  extra on a screen, never something she needs offline.
//
//  FOLLOWS THE ACCOUNT, as ProgrammeStore and CreditsStore do since A2:
//  `SyncRegistry.register` fetches on every sign-in and resync, and
//  `registerReset` empties it on sign-out or a change of account, so one
//  family's offers can never show on the next family's phone.
//
//  Kept for revert (A3): "⚠️ NOTHING APPLIES AN OFFER YET. Checkout (0126's
//  price_offering) ignores coupons, so the phone says what an offer is and
//  until when, never 'Auto-applied'."
//  A4 (2026-10-31): checkout applies them now, on the server (0149). This
//  store still only LISTS offers; what one is worth on a given purchase is
//  OfferQuoteStore's (`my_offer_quote`), never computed here.
// =============================================================================

import 'package:flutter/foundation.dart';

import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';

/// One audience offer, as `my_partner_offers()` returns it.
@immutable
class PartnerOffer {
  const PartnerOffer({
    required this.code,
    required this.kind,
    required this.value,
    required this.audience,
    required this.audienceId,
    this.label,
    this.programmeId,
    this.endsAt,
  });

  final String code;

  /// 'percent' or 'flat' (paise).
  final String kind;
  final int value;

  /// 'sponsor' or 'partner'.
  final String audience;
  final String audienceId;

  /// What it is for ("the back-to-work masterclass"); null means any session.
  final String? label;
  final String? programmeId;
  final DateTime? endsAt;

  bool get isSponsor => audience == 'sponsor';

  /// "15% off the back-to-work masterclass", "₹100 off any session".
  String get headline {
    final off = kind == 'flat'
        ? '₹${(value / 100).round()} off'
        : '$value% off';
    final what = (label ?? '').trim();
    return '$off ${what.isEmpty ? 'any ParentVeda session' : what}';
  }

  /// "Until 30 Nov", or "No end date".
  String get until =>
      endsAt == null ? 'No end date' : 'Until ${_short(endsAt!)}';

  static PartnerOffer? fromRow(Map<String, dynamic> m) {
    final code = (m['code'] ?? '').toString();
    final audience = (m['audience'] ?? '').toString();
    final id = (m['audience_id'] ?? '').toString();
    final value = (m['value'] as num?)?.toInt() ?? 0;
    if (code.isEmpty || id.isEmpty || value <= 0) return null;
    if (audience != 'sponsor' && audience != 'partner') return null;
    final ends = m['ends_at'];
    return PartnerOffer(
      code: code,
      kind: m['kind'] == 'flat' ? 'flat' : 'percent',
      value: value,
      audience: audience,
      audienceId: id,
      label: m['label'] as String?,
      programmeId: m['programme_id'] as String?,
      endsAt: ends == null
          ? null
          : DateTime.tryParse(ends.toString())?.toLocal(),
    );
  }
}

String _short(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${months[d.month - 1]}';
}

class PartnerOfferStore extends ChangeNotifier {
  PartnerOfferStore._() {
    SyncRegistry.registerReset(_resetForAccount);
    SyncRegistry.register(refresh);
  }
  static final PartnerOfferStore instance = PartnerOfferStore._();

  List<PartnerOffer> _all = const [];
  bool _loaded = false;

  /// Bumped on every reset, so a fetch that lands after a sign-out is dropped
  /// (the same guard ContentStore uses since A2).
  int _generation = 0;

  /// Live offers. One that ended since the last fetch drops here, on the
  /// phone, so a page never advertises an offer past its date between
  /// sign-in resyncs (the server filters it on the next fetch anyway).
  List<PartnerOffer> get all {
    final now = DateTime.now();
    return [
      for (final o in _all)
        if (o.endsAt == null || o.endsAt!.isAfter(now)) o,
    ];
  }

  /// Offers for one sponsor or one care partner.
  List<PartnerOffer> forSponsor(String? id) => id == null
      ? const []
      : [
          for (final o in all)
            if (o.isSponsor && o.audienceId == id) o,
        ];
  List<PartnerOffer> forPartner(String? id) => id == null
      ? const []
      : [
          for (final o in all)
            if (!o.isSponsor && o.audienceId == id) o,
        ];

  void ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    refresh();
  }

  void _resetForAccount() {
    _generation++;
    _loaded = false;
    if (_all.isEmpty) return;
    _all = const [];
    notifyListeners();
  }

  Future<void> refresh() async {
    final gen = _generation;
    try {
      // Null when logged out or the backend is uninitialised: the same as
      // having no offers.
      final res = await SupabaseRepo.rpcJson('my_partner_offers');
      if (gen != _generation) return;
      _all = [
        if (res is List)
          for (final r in res)
            if (r is Map) ?PartnerOffer.fromRow(r.cast<String, dynamic>()),
      ];
      notifyListeners();
    } catch (_) {
      // Offline, or 0148 has not run. Keep what we had; never a crash.
    }
  }

  @visibleForTesting
  void debugSet(List<PartnerOffer> offers) {
    _all = offers;
    _loaded = true;
    notifyListeners();
  }
}
