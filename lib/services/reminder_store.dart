// =============================================================================
//  ReminderStore — the mother's customizable reminders (persisted)
// -----------------------------------------------------------------------------
//  Holds every reminder she's created and persists them via shared_preferences.
//  On any change it (Phase 2) asks NotificationService to (re)schedule or cancel
//  the underlying OS notification — that hook is marked below and wired once
//  flutter_local_notifications is installed.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reminder.dart';
import 'notification_service.dart';
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';

class ReminderStore extends ChangeNotifier {
  ReminderStore._();
  static final ReminderStore instance = ReminderStore._();

  static const _key = 'reminders';
  final List<Reminder> _items = [];
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    // 1) Local cache first.
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _items
          ..clear()
          ..addAll(list.map(
              (e) => Reminder.fromJson(Map<String, dynamic>.from(e as Map))));
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();

    // 2) Sync with the cloud, THEN schedule notifications for the full merged
    //    set (so reminders synced from the cloud also get OS notifications).
    await _syncFromCloud();
    await NotificationService.instance.init();
    await NotificationService.instance.syncAll(_items);
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      final rows = await SupabaseRepo.fetch('reminders', orderBy: 'created_at');
      final byId = {for (final r in rows) r['id'].toString(): _fromRow(r)};
      for (final r in _items) {
        if (!byId.containsKey(r.id)) {
          byId[r.id] = r;
          await SupabaseRepo.insert('reminders', _toRow(r)); // push local-only up
        }
      }
      _items
        ..clear()
        ..addAll(byId.values);
      await _persist();
      notifyListeners();
    } catch (_) {/* offline — keep local */}
  }

  // Fire-and-forget cloud writes (like _persist) — best-effort.
  Future<void> _cloudPush(Reminder r) async {
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      await SupabaseRepo.upsert('reminders', _toRow(r), onConflict: 'id');
    } catch (_) {/* offline — syncs up on next init */}
  }

  Future<void> _cloudDelete(String id) async {
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      await SupabaseRepo.delete('reminders', id);
    } catch (_) {/* offline — best-effort */}
  }

  // camelCase model <-> snake_case columns. `dayOfMonth` -> `day_of_month`;
  // `repeat` is an enum (stored as .name); `times`/`weekdays` are jsonb lists.
  Map<String, dynamic> _toRow(Reminder r) => {
        'id': r.id,
        'title': r.title,
        'body': r.body,
        'hour': r.hour,
        'minute': r.minute,
        'repeat': r.repeat.name,
        'weekday': r.weekday,
        'enabled': r.enabled,
        'category': r.category,
        'times': r.times,
        'day_of_month': r.dayOfMonth,
        'weekdays': r.weekdays,
      };

  Reminder _fromRow(Map<String, dynamic> r) => Reminder(
        id: r['id'].toString(),
        title: (r['title'] ?? '').toString(),
        body: (r['body'] ?? '').toString(),
        hour: (r['hour'] as num?)?.toInt() ?? 9,
        minute: (r['minute'] as num?)?.toInt() ?? 0,
        repeat: ReminderRepeat.values
            .firstWhere((x) => x.name == r['repeat'], orElse: () => ReminderRepeat.daily),
        weekday: (r['weekday'] as num?)?.toInt() ?? DateTime.monday,
        enabled: r['enabled'] as bool? ?? true,
        category: (r['category'] ?? 'custom').toString(),
        times: ((r['times'] as List?) ?? const [])
            .map((e) => (e as num).toInt())
            .toList(),
        dayOfMonth: (r['day_of_month'] as num?)?.toInt() ?? 1,
        weekdays: ((r['weekdays'] as List?) ?? const [])
            .map((e) => (e as num).toInt())
            .toList(),
      );

  /// All reminders, newest first (created order is preserved as insert order).
  List<Reminder> get all => List.unmodifiable(_items);
  List<Reminder> get active => _items.where((r) => r.enabled).toList();
  bool get isEmpty => _items.isEmpty;

  /// Just the medication reminders (shown on the Daily Medication card). These
  /// are never tied to a specific medicine — they're free self-reminders.
  List<Reminder> get medication =>
      _items.where((r) => r.category == 'medication').toList();

  Reminder? byId(String id) {
    for (final r in _items) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Add a new reminder or replace an existing one (matched by id).
  void upsert(Reminder r) {
    final i = _items.indexWhere((x) => x.id == r.id);
    if (i >= 0) {
      _items[i] = r;
    } else {
      _items.insert(0, r);
    }
    if (r.enabled) {
      NotificationService.instance.schedule(r);
    } else {
      NotificationService.instance.cancelReminder(r);
    }
    _persistNotify();
    _cloudPush(r); // sync to cloud (fire-and-forget, like _persist)
  }

  void remove(String id) {
    final r = byId(id);
    _items.removeWhere((x) => x.id == id);
    if (r != null) NotificationService.instance.cancelReminder(r);
    _persistNotify();
    _cloudDelete(id); // remove from cloud too
  }

  void toggle(String id) {
    final i = _items.indexWhere((r) => r.id == id);
    if (i < 0) return;
    final updated = _items[i].copyWith(enabled: !_items[i].enabled);
    _items[i] = updated;
    if (updated.enabled) {
      NotificationService.instance.schedule(updated);
    } else {
      NotificationService.instance.cancelReminder(updated);
    }
    _persistNotify();
    _cloudPush(updated); // sync the toggled state to cloud
  }

  void _persistNotify() {
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(_items.map((r) => r.toJson()).toList()));
    } catch (_) {/* best-effort */}
  }
}
