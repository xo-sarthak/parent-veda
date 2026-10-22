// =============================================================================
//  ReadyBirthContextStore - the personalisation inputs for "Ready for Birth"
// -----------------------------------------------------------------------------
//  The redesign personalises by delivery type, twins, season and what the
//  hospital already provides. Only "delivery type" existed before (scoped inside
//  the bag store); the rest had no home. This small ChangeNotifier singleton owns
//  them, persists locally and syncs to the cloud like the other stores. Season is
//  derived from the date unless the mother overrides it. Kept separate from the
//  bag data so the retained old bag store is left completely untouched.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/ready_for_birth_data.dart';
import 'hospital_bag_store.dart' show DeliveryType;
import 'remote/cloud_merged_store.dart';
// import 'remote/cloud_synced_store.dart'; // kept for revert (step 13)

// Per-item since step 13 (2026-10-22, sync log). It synced as one whole blob,
// so a twins answer on one phone and a hospital tick on the other erased each
// other. Items: `delivery`, `twins`, `season` (each only when set away from
// its default) and `provides|<token>` (true) per thing the hospital provides.
class ReadyBirthContextStore extends ChangeNotifier with CloudMergedStore {
  ReadyBirthContextStore._();
  static final ReadyBirthContextStore instance = ReadyBirthContextStore._();

  static const _key = 'rfb_context';

  DeliveryType _delivery = DeliveryType.unsure;
  bool _twins = false;
  final Set<String> _hospitalProvides = {};
  Season? _seasonOverride;
  bool _loaded = false;

  // ---- getters --------------------------------------------------------------
  DeliveryType get delivery => _delivery;
  bool get twins => _twins;
  Set<String> get hospitalProvides => Set.unmodifiable(_hospitalProvides);
  Season? get seasonOverride => _seasonOverride;

  /// The effective season: the mother's override, else derived from the month.
  Season get season => _seasonOverride ?? seasonForMonth(DateTime.now().month);

  bool providesFor(String token) => _hospitalProvides.contains(token);

  /// True once the mother has told us anything beyond the defaults.
  bool get personalised =>
      _delivery != DeliveryType.unsure ||
      _twins ||
      _hospitalProvides.isNotEmpty ||
      _seasonOverride != null;

  // ---- load -----------------------------------------------------------------
  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) _apply(jsonDecode(raw) as Map);
    } catch (_) {/* start with defaults */}
    _loaded = true;
    notifyListeners();
    // await syncStateFromCloud(); // kept for revert (step 13)
    await syncMergedFromCloud();
  }

  void _apply(Map m) {
    _delivery = DeliveryType.values.firstWhere(
        (d) => d.name == (m['delivery'] ?? 'unsure'),
        orElse: () => DeliveryType.unsure);
    _twins = m['twins'] == true;
    _hospitalProvides
      ..clear()
      ..addAll(((m['provides'] as List?) ?? const []).map((e) => e.toString()));
    final so = m['season']?.toString();
    Season? parsedSeason;
    if (so != null) {
      for (final s in Season.values) {
        if (s.name == so) {
          parsedSeason = s;
          break;
        }
      }
    }
    _seasonOverride = parsedSeason;
  }

  // ---- mutations ------------------------------------------------------------
  Future<void> setDelivery(DeliveryType d) async {
    if (_delivery == d) return;
    _delivery = d;
    await _save();
  }

  Future<void> setTwins(bool v) async {
    if (_twins == v) return;
    _twins = v;
    await _save();
  }

  Future<void> toggleProvides(String token) async {
    if (!_hospitalProvides.add(token)) _hospitalProvides.remove(token);
    await _save();
  }

  Future<void> setSeasonOverride(Season? s) async {
    _seasonOverride = s;
    await _save();
  }

  // ---- cloud sync -----------------------------------------------------------
  @override
  String get cloudKey => 'rfb_ctx';
  @override
  String? get legacyBlobKey => cloudKey;

  // Kept for revert (step 13): applyCloudItems({}) is the empty state now.
  //   /// What a sign-out resets this store to (2026-10-17): the blob of a store nobody has used.
  //   @override
  //   Object get cloudEmptyData => const <String, Object?>{};
  //
  //   @override
  //   Object cloudData() => _toMap();

  @override
  void applyLegacyBlob(Object blob) => _apply(blob as Map);

  @override
  Map<String, Object?> cloudItems() => {
        if (_delivery != DeliveryType.unsure) 'delivery': _delivery.name,
        if (_twins) 'twins': true,
        if (_seasonOverride != null) 'season': _seasonOverride!.name,
        for (final t in _hospitalProvides) 'provides|$t': true,
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    // The same reading as the blob: absent fields are the defaults.
    _apply({
      'delivery': items['delivery'],
      'twins': items['twins'],
      'season': items['season'],
      'provides': [
        for (final k in items.keys)
          if (k.startsWith('provides|')) k.substring('provides|'.length),
      ],
    });
    _loaded = true;
  }
  @override
  Future<void> persistLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_toMap()));
  }

  Map<String, dynamic> _toMap() => {
        'delivery': _delivery.name,
        'twins': _twins,
        'provides': _hospitalProvides.toList(),
        'season': _seasonOverride?.name,
      };

  Future<void> _save() async {
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_toMap()));
    } catch (_) {/* best-effort */}
  }
}
