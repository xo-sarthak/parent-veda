// =============================================================================
//  PvReviewStore — parents' own reviews of a product (store Track A, 2026-10-28)
// -----------------------------------------------------------------------------
//  The launch store is affiliate only, so she buys on Amazon or Flipkart, not
//  here. After the buy sheet she is asked "Did you buy it?"; a yes lets her
//  rate it. Those ratings are ParentVeda's own voices, shown under "Ratings
//  from parents" and never mixed with the retailer's stars.
//
//  LOCAL-FIRST, like every store. Her own reviews live on the phone and show
//  the moment she saves; the cloud copy (`product_reviews`, migration 0119) is
//  sent after. The send uses the CONFIRMED upsert, not fire-and-forget: a
//  review the server never took is kept marked unsent and retried on the
//  next start, because a lost review is a voice that silently vanished.
//
//  OTHER PARENTS' reviews are read per product from the cloud. RLS returns
//  only approved ones (plus her own), so a review nobody has checked yet is
//  never shown to anyone else.
//
//  ⚠️ NEVER "VERIFIED PURCHASE". We cannot see an Amazon order, so the label
//  is "Bought on Amazon, says the parent" (pvReviewSourceLine).
// =============================================================================

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';

/// One parent's review of one product.
@immutable
class PvStoreReview {
  const PvStoreReview({
    required this.id,
    required this.productId,
    required this.rating,
    this.body = '',
    this.boughtAt = '',
    this.authorLabel = '',
    this.status = 'pending',
    required this.createdAt,
    this.sent = false,
  });

  final String id;
  final String productId;
  final int rating; // 1–5
  final String body;

  /// Where she says she bought it: 'Amazon', 'Flipkart', 'FirstCry' …
  final String boughtAt;
  final String authorLabel;

  /// 'pending' | 'approved' | 'rejected' — set by the server, never the phone.
  final String status;
  final DateTime createdAt;

  /// Whether the cloud has confirmed it (her own reviews only).
  final bool sent;

  bool get approved => status == 'approved';

  PvStoreReview copyWith({
    int? rating,
    String? body,
    String? status,
    bool? sent,
  }) => PvStoreReview(
    id: id,
    productId: productId,
    rating: rating ?? this.rating,
    body: body ?? this.body,
    boughtAt: boughtAt,
    authorLabel: authorLabel,
    status: status ?? this.status,
    createdAt: createdAt,
    sent: sent ?? this.sent,
  );

  /// The cloud row (0119). `user_id` is set by the column default; status
  /// and `verified` are forced by the trigger, so they are not sent.
  Map<String, dynamic> toRow() => {
    'id': id,
    'product_id': productId,
    'rating': rating,
    'body': body,
    'bought_at': boughtAt,
    'author_label': authorLabel,
  };

  Map<String, dynamic> toJson() => {
    ...toRow(),
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'sent': sent,
  };

  static PvStoreReview? fromJson(Map<String, dynamic> j) {
    final id = j['id'] as String?;
    final pid = j['product_id'] as String?;
    final r = (j['rating'] as num?)?.toInt();
    if (id == null || pid == null || r == null || r < 1 || r > 5) return null;
    return PvStoreReview(
      id: id,
      productId: pid,
      rating: r,
      body: (j['body'] as String?) ?? '',
      boughtAt: (j['bought_at'] as String?) ?? '',
      authorLabel: (j['author_label'] as String?) ?? '',
      status:
          (j['status'] as String?) ??
          (j['moderation_status'] as String?) ??
          'pending',
      createdAt:
          DateTime.tryParse((j['created_at'] as String?) ?? '') ??
          DateTime.now(),
      sent: (j['sent'] as bool?) ?? true,
    );
  }
}

/// Where her word says she bought it, in our voice. Never "Verified purchase":
/// an order on another site is one we cannot see.
String pvReviewSourceLine(PvStoreReview r) => r.boughtAt.isEmpty
    ? 'Bought it, says the parent'
    : 'Bought on ${r.boughtAt}, says the parent';

class PvReviewStore extends ChangeNotifier {
  PvReviewStore._() {
    SyncRegistry.registerReset(_resetForAccount);
  }
  static final PvReviewStore instance = PvReviewStore._();

  static const _key = 'pv_store_reviews_mine';

  /// Her own, by product id.
  final Map<String, PvStoreReview> _mine = {};

  /// Other parents' approved reviews, by product id, as last read.
  final Map<String, List<PvStoreReview>> _others = {};
  final Set<String> _asked = {};
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          final r = PvStoreReview.fromJson(Map<String, dynamic>.from(e as Map));
          if (r != null) _mine[r.productId] = r;
        }
      }
    } catch (_) {
      /* start empty */
    }
    _loaded = true;
    notifyListeners();
    _sendUnsent();
  }

  // ---- queries -------------------------------------------------------------

  PvStoreReview? mineFor(String productId) => _mine[productId];

  /// What the product page shows: hers first (whatever its status, because
  /// it is hers), then other parents' approved ones.
  List<PvStoreReview> shownFor(String productId) => [
    ?_mine[productId],
    for (final r in _others[productId] ?? const <PvStoreReview>[])
      if (r.id != _mine[productId]?.id) r,
  ];

  /// Reads other parents' approved reviews of [productId] once per session.
  Future<void> loadFor(String productId) async {
    if (!_asked.add(productId)) return;
    final rows = await SupabaseRepo.selectWhere(
      'product_reviews',
      'product_id',
      productId,
    );
    final mineId = SupabaseRepo.userId;
    final list = <PvStoreReview>[
      for (final row in rows)
        if (row['user_id'] != mineId && row['moderation_status'] == 'approved')
          ?PvStoreReview.fromJson(row),
    ];
    // Her own row tells the phone what the server decided about it.
    for (final row in rows) {
      if (row['user_id'] != mineId) continue;
      final cur = _mine[productId];
      final status = row['moderation_status'] as String?;
      if (cur != null && status != null && cur.id == row['id']) {
        _mine[productId] = cur.copyWith(status: status, sent: true);
        _persist();
      }
    }
    _others[productId] = list;
    notifyListeners();
  }

  // ---- mutations -----------------------------------------------------------

  /// Saves (or edits) her review of [productId]. An edit keeps the id, so
  /// the cloud row is the same row, and goes back to `pending`.
  Future<void> save({
    required String productId,
    required int rating,
    String body = '',
    String boughtAt = '',
  }) async {
    final cur = _mine[productId];
    final r = PvStoreReview(
      id: cur?.id ?? _newId(),
      productId: productId,
      rating: rating.clamp(1, 5),
      body: body.trim(),
      boughtAt: boughtAt,
      createdAt: cur?.createdAt ?? DateTime.now(),
    );
    _mine[productId] = r;
    notifyListeners();
    await _persist();
    await _send(r);
  }

  Future<void> remove(String productId) async {
    final cur = _mine.remove(productId);
    if (cur == null) return;
    notifyListeners();
    await _persist();
    SupabaseRepo.delete('product_reviews', cur.id).catchError((_) {});
  }

  Future<void> _send(PvStoreReview r) async {
    final ok = await SupabaseRepo.upsertRowConfirmed(
      'product_reviews',
      r.toRow(),
      onConflict: 'id',
    );
    if (!ok) return; // stays unsent, retried on the next start
    final now = _mine[r.productId];
    if (now?.id != r.id) return;
    _mine[r.productId] = now!.copyWith(sent: true);
    await _persist();
  }

  void _sendUnsent() {
    for (final r in _mine.values.toList()) {
      if (!r.sent) _send(r);
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode([for (final r in _mine.values) r.toJson()]),
      );
    } catch (_) {
      /* best-effort */
    }
  }

  static final _rand = Random.secure();
  static String _newId() {
    final t = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final n = List.generate(
      8,
      (_) => _rand.nextInt(36).toRadixString(36),
    ).join();
    return 'rv_${t}_$n';
  }

  /// A sign-out, or another account signing in (sync log step 12): her own
  /// reviews (and the unsent marks on them) are hers, so memory forgets them
  /// with the wiped prefs. Cloud copies stay; the next sign-in's init() reads
  /// whatever that account's phone cache holds.
  void _resetForAccount() {
    _mine.clear();
    _others.clear();
    _asked.clear();
    _loaded = false;
    notifyListeners();
  }

  /// Tests only: forget everything.
  @visibleForTesting
  void resetForTest() {
    _mine.clear();
    _others.clear();
    _asked.clear();
    _loaded = false;
  }
}
