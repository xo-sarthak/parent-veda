// =============================================================================
//  OfferQuote — what the SERVER says a purchase costs her, with her partner
//  offers (Partner Editions A4, migration 0149 `my_offer_quote`)
// -----------------------------------------------------------------------------
//  THE PHONE NEVER COMPUTES A DISCOUNT. It asks `my_offer_quote(offering)`,
//  which runs the same `_offers_for` the order runs (`open_payment_order`) and
//  the stub preview runs (`record_stub_purchase`). So the struck-through price
//  on the checkout sheet and the amount Razorpay opens with come from one
//  function, and cannot disagree. The phone holds the answer and shows it.
//
//  HER PICK IS A PREFERENCE. The best offer applies by default (the server's
//  `best_code`). "Apply offer" lets her choose another; the chosen code is sent
//  with the order and the server uses it only if it still applies to her,
//  otherwise its best. Sending a code buys nothing the server would not give.
//
//  MEMORY ONLY, and cleared on sign-out or a change of account
//  (`SyncRegistry.registerReset`), as PartnerOfferStore is (A3): a quote names
//  her coupon codes, and one family's pick must never ride into the next
//  family's checkout. A quote is fetched when a checkout opens, never at launch.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../services/remote/supabase_repo.dart';
import '../services/remote/sync_registry.dart';

/// One of her offers for one purchase, priced by the server.
@immutable
class QuotedOffer {
  const QuotedOffer({
    required this.code,
    required this.kind,
    required this.value,
    required this.savingMinor,
    required this.priceMinor,
    this.label,
    this.endsAt,
  });

  final String code;

  /// 'percent' or 'flat' (paise).
  final String kind;
  final int value;

  /// What comes off, and what she pays: the server's figures.
  final int savingMinor;
  final int priceMinor;
  final String? label;
  final DateTime? endsAt;

  /// "15% off", "₹100 off".
  String get off =>
      kind == 'flat' ? '${offerRupees(value)} off' : '$value% off';

  static QuotedOffer? fromRow(Map<String, dynamic> m) {
    final code = (m['code'] ?? '').toString();
    final saving = (m['saving_paise'] as num?)?.toInt() ?? 0;
    final price = (m['price_paise'] as num?)?.toInt() ?? 0;
    // A row with nothing off, or nothing left to pay, is not an offer the
    // server would apply (0149 skips both); never draw one.
    if (code.isEmpty || saving <= 0 || price < 100) return null;
    final ends = m['ends_at'];
    return QuotedOffer(
      code: code,
      kind: m['kind'] == 'flat' ? 'flat' : 'percent',
      value: (m['value'] as num?)?.toInt() ?? 0,
      savingMinor: saving,
      priceMinor: price,
      label: (m['label'] as String?)?.trim(),
      endsAt: ends == null
          ? null
          : DateTime.tryParse(ends.toString())?.toLocal(),
    );
  }
}

/// The server's answer for one offering.
@immutable
class OfferQuote {
  const OfferQuote({
    required this.offeringId,
    required this.listMinor,
    required this.offers,
    this.bestCode,
  });

  final String offeringId;
  final int listMinor;

  /// Best first, as the server ordered them.
  final List<QuotedOffer> offers;
  final String? bestCode;

  bool get hasOffer => offers.isNotEmpty;

  /// The offer that applies: her pick if the server listed it, else the best.
  /// Mirrors 0149's `_offer_pick`, for display only; the order re-decides.
  QuotedOffer? applied(String? pick) {
    if (offers.isEmpty) return null;
    if (pick != null) {
      for (final o in offers) {
        if (o.code == pick) return o;
      }
    }
    for (final o in offers) {
      if (o.code == bestCode) return o;
    }
    return offers.first;
  }

  /// Null for an unknown offering, or one not for her (the server says
  /// `known: false` for both).
  static OfferQuote? fromJson(Object? res) {
    if (res is! Map || res['known'] != true) return null;
    final rows = res['offers'];
    return OfferQuote(
      offeringId: (res['offering_id'] ?? '').toString(),
      listMinor: (res['list_paise'] as num?)?.toInt() ?? 0,
      offers: [
        if (rows is List)
          for (final r in rows)
            if (r is Map) ?QuotedOffer.fromRow(r.cast<String, dynamic>()),
      ],
      bestCode: res['best_code'] as String?,
    );
  }
}

/// "₹1,499", "₹425", "₹74.99": Indian grouping, paise only when there are some.
String offerRupees(int minor) {
  final whole = (minor ~/ 100).toString();
  final paise = minor % 100;
  var s = whole;
  if (whole.length > 3) {
    final last3 = whole.substring(whole.length - 3);
    var rest = whole.substring(0, whole.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    s = '${parts.join(',')},$last3';
  }
  return paise == 0 ? '₹$s' : '₹$s.${paise.toString().padLeft(2, '0')}';
}

class OfferQuoteStore extends ChangeNotifier {
  OfferQuoteStore._() {
    SyncRegistry.registerReset(_resetForAccount);
  }
  static final OfferQuoteStore instance = OfferQuoteStore._();

  final Map<String, OfferQuote> _quotes = {};
  final Map<String, String> _picks = {};

  /// Bumped on every reset, so a quote that lands after a sign-out is dropped.
  int _generation = 0;

  OfferQuote? quoteFor(String offeringId) => _quotes[offeringId];

  /// The code she chose in "Apply offer", or null for "the best".
  String? pickFor(String offeringId) => _picks[offeringId];

  /// The offer the sheet shows as applied.
  QuotedOffer? appliedFor(String offeringId) =>
      _quotes[offeringId]?.applied(_picks[offeringId]);

  /// What the pay button says she pays: the applied offer's price, else null
  /// (the caller keeps its own list-price label).
  int? payMinorFor(String offeringId) => appliedFor(offeringId)?.priceMinor;

  void pick(String offeringId, String code) {
    if (_picks[offeringId] == code) return;
    _picks[offeringId] = code;
    notifyListeners();
  }

  /// Ask the server. Null when signed out, offline, or 0149 has not run: the
  /// same as no offer, so checkout looks exactly as it did before A4.
  Future<OfferQuote?> load(String offeringId) async {
    final gen = _generation;
    try {
      final res = await SupabaseRepo.rpcJson('my_offer_quote', {
        'p_offering_id': offeringId,
      });
      if (gen != _generation) return null;
      // No answer (signed out, uninitialised, offline): keep what we had.
      // Only the server saying `known: false` forgets a quote.
      if (res == null) return _quotes[offeringId];
      final q = OfferQuote.fromJson(res);
      if (q == null) {
        if (_quotes.remove(offeringId) != null) notifyListeners();
        return null;
      }
      _quotes[offeringId] = q;
      // A pick the server no longer lists falls back to the best.
      final p = _picks[offeringId];
      if (p != null && !q.offers.any((o) => o.code == p)) {
        _picks.remove(offeringId);
      }
      notifyListeners();
      return q;
    } catch (_) {
      return null;
    }
  }

  void _resetForAccount() {
    _generation++;
    if (_quotes.isEmpty && _picks.isEmpty) return;
    _quotes.clear();
    _picks.clear();
    notifyListeners();
  }

  @visibleForTesting
  void debugSet(OfferQuote q) {
    _quotes[q.offeringId] = q;
    notifyListeners();
  }

  @visibleForTesting
  void debugReset() => _resetForAccount();
}
