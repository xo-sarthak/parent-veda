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

class ReminderStore extends ChangeNotifier {
  ReminderStore._();
  static final ReminderStore instance = ReminderStore._();

  static const _key = 'reminders';
  final List<Reminder> _items = [];
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
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
    // Make sure the OS has every enabled reminder scheduled on startup.
    await NotificationService.instance.init();
    await NotificationService.instance.syncAll(_items);
  }

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
  }

  void remove(String id) {
    final r = byId(id);
    _items.removeWhere((x) => x.id == id);
    if (r != null) NotificationService.instance.cancelReminder(r);
    _persistNotify();
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
