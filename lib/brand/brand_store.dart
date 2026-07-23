// =============================================================================
//  BrandStudioStore — what this parent has already been shown
// -----------------------------------------------------------------------------
//  Frequency caps have to survive a restart, a reinstall and a device switch,
//  or "shown only once per campaign" is a slogan rather than a fact. The old
//  launch_promo guard was an in-memory bool that reset on every process start,
//  so a parent could be shown the same promo every single app open.
//
//  Persisted via shared_preferences + CloudSyncedStore, so the cap follows the
//  parent across devices.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/cloud_synced_store.dart';

class BrandStudioStore extends ChangeNotifier with CloudSyncedStore {
  BrandStudioStore._();
  static final BrandStudioStore instance = BrandStudioStore._();

  static const _key = 'brand_studio';

  /// campaignId -> times surfaced.
  final Map<String, int> _impressions = {};

  /// Campaigns the parent watched/read to the end.
  final Set<String> _completed = {};

  /// Campaigns the parent actively dismissed. A dismissal is a signal, not just
  /// an absence: we do not re-show something a parent closed.
  final Set<String> _dismissed = {};

  /// Demo mode — relaxes targeting + caps so every placement is visible.
  /// Persisted so it survives a restart while someone is evaluating the app.
  bool _demoMode = false;
  /// When the last sponsored NOTIFICATION was sent, across all campaigns. The
  /// global frequency gap keys off this — see BrandNotifications. Null = never.
  DateTime? _lastNotificationAt;
  bool get demoMode => _demoMode;
  set demoMode(bool v) {
    if (_demoMode == v) return;
    _demoMode = v;
    _save();
  }

  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) _apply(jsonDecode(raw) as Map);
    } catch (_) {/* start fresh */}
    _loaded = true;
    notifyListeners();
    // A cloud hiccup must never break startup (and keeps widget tests offline).
    try {
      await syncStateFromCloud();
    } catch (_) {/* stay local */}
  }

  // ---- reads ----------------------------------------------------------------
  int impressions(String campaignId) => _impressions[campaignId] ?? 0;
  bool completed(String campaignId) => _completed.contains(campaignId);
  bool dismissed(String campaignId) => _dismissed.contains(campaignId);
  DateTime? get lastNotificationAt => _lastNotificationAt;

  // ---- writes ---------------------------------------------------------------
  void recordImpression(String campaignId) {
    _impressions[campaignId] = impressions(campaignId) + 1;
    _save();
  }

  void markCompleted(String campaignId) {
    if (_completed.add(campaignId)) _save();
  }

  void markDismissed(String campaignId) {
    if (_dismissed.add(campaignId)) _save();
  }

  /// Stamp a sponsored notification as just sent — starts the global gap.
  void markNotificationSent(DateTime at) {
    _lastNotificationAt = at;
    _save();
  }

  /// Test/debug only — lets a QA build replay a campaign.
  @visibleForTesting
  void resetAll() {
    _impressions.clear();
    _completed.clear();
    _dismissed.clear();
    _demoMode = false;
    _lastNotificationAt = null;
    _save();
  }

  /// Replay every campaign from scratch, keeping demo mode as-is. The button
  /// the preview screen offers so a Premiere can actually be watched twice.
  void replayAll() {
    _impressions.clear();
    _completed.clear();
    _dismissed.clear();
    _save();
  }

  // ---- persistence ----------------------------------------------------------
  Map<String, Object?> _toMap() => {
        'impressions': _impressions,
        'completed': _completed.toList(),
        'dismissed': _dismissed.toList(),
        'demoMode': _demoMode,
        'lastNotificationAt': _lastNotificationAt?.toIso8601String(),
      };

  void _apply(Map j) {
    _impressions
      ..clear()
      ..addAll((j['impressions'] as Map?)?.map((k, v) => MapEntry('$k', (v as num).toInt())) ?? const {});
    _completed
      ..clear()
      ..addAll(((j['completed'] as List?) ?? const []).map((e) => '$e'));
    _dismissed
      ..clear()
      ..addAll(((j['dismissed'] as List?) ?? const []).map((e) => '$e'));
    _demoMode = (j['demoMode'] as bool?) ?? false;
    final ln = j['lastNotificationAt'] as String?;
    _lastNotificationAt = ln == null ? null : DateTime.tryParse(ln);
  }

  Future<void> _save() async {
    notifyListeners(); // CloudSyncedStore pushes on notify
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_toMap()));
    } catch (_) {/* best-effort */}
  }

  @override
  String get cloudKey => 'brand_studio';
  @override
  Object cloudData() => _toMap();
  @override
  void applyCloudData(Object data) => _apply(data as Map);
  @override
  Future<void> persistLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_toMap()));
    } catch (_) {/* best-effort */}
  }
}
