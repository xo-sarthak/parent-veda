// =============================================================================
//  FatherJournalStore - the father's own simple journal (manual entries only)
// -----------------------------------------------------------------------------
//  A deliberately small, SEPARATE store from the mother's JournalStore: it holds
//  only the father's manual entries (a memory, a note for baby, a photo, a voice
//  note) under its own prefs key - no auto milestones / health / scans. Photos +
//  voice clips reuse JournalStore's static saveImage / saveAudio helpers and the
//  shared JournalEntry model. (Mother + father journals stay separate for now;
//  merging into one shared source can come later.)
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';
import 'remote/storage_service.dart';
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';

class FatherJournalStore extends ChangeNotifier {
  FatherJournalStore._();
  static final FatherJournalStore instance = FatherJournalStore._();

  static const _key = 'father_journal_entries';

  final List<JournalEntry> _manual = [];
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _manual.add(JournalEntry.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();

    // Then sync with the cloud (no-op if logged out). Files → Phase 3.
    await _syncFromCloud();
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      final rows = await SupabaseRepo.fetch('father_journal_entries');
      final byId = {for (final r in rows) r['id'].toString(): _fromRow(r)};
      for (final e in _manual) {
        if (!byId.containsKey(e.id)) {
          byId[e.id] = e;
          await SupabaseRepo.insert('father_journal_entries', _toRow(e));
        }
      }
      _manual
        ..clear()
        ..addAll(byId.values);
      await _persist();
      await _backfillMedia();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  // Upload any media still stored as local paths; rewrite to the cloud path.
  Future<void> _backfillMedia() async {
    var changed = false;
    for (var i = 0; i < _manual.length; i++) {
      final e = _manual[i];
      final imgs = await StorageService.backfillAll(e.imageUrls, 'journal');
      final auds = await StorageService.backfillAll(e.audioUrls, 'voice');
      if (!listEquals(imgs, e.imageUrls) || !listEquals(auds, e.audioUrls)) {
        final ne = e.copyWith(imageUrls: imgs, audioUrls: auds);
        _manual[i] = ne;
        changed = true;
        try {
          await SupabaseRepo.upsert('father_journal_entries', _toRow(ne),
              onConflict: 'id');
        } catch (_) {}
      }
    }
    if (changed) await _persist();
  }

  // camelCase model <-> snake_case columns (same shape as journal_entries).
  Map<String, dynamic> _toRow(JournalEntry e) => {
        'id': e.id,
        'type': e.type.name,
        'title': e.title,
        'description': e.description,
        'date': SupabaseRepo.dbTime(e.date),
        'week_number': e.weekNumber,
        'image_url': e.imageUrl,
        'audio_url': e.audioUrl,
        'image_urls': e.imageUrls,
        'audio_urls': e.audioUrls,
        'custom_tag': e.customTag,
        'tags': e.tags,
        'is_automatic': e.isAutomatic,
        'created_at': SupabaseRepo.dbTime(e.createdAt),
        'updated_at': SupabaseRepo.dbTime(e.updatedAt),
      };

  JournalEntry _fromRow(Map<String, dynamic> r) {
    var t = JournalEntryType.memory;
    for (final e in JournalEntryType.values) {
      if (e.name == r['type']) {
        t = e;
        break;
      }
    }
    DateTime parse(Object? v) => SupabaseRepo.parseDbTime(v);
    List<String> strList(Object? v) =>
        (v as List?)?.map((e) => e.toString()).toList() ?? const [];
    return JournalEntry(
      id: (r['id'] ?? '').toString(),
      type: t,
      title: (r['title'] ?? '').toString(),
      description: (r['description'] ?? '').toString(),
      date: parse(r['date']),
      weekNumber: (r['week_number'] as num?)?.toInt() ?? 0,
      imageUrl: r['image_url']?.toString(),
      audioUrl: r['audio_url']?.toString(),
      imageUrls: r['image_urls'] == null ? null : strList(r['image_urls']),
      audioUrls: r['audio_urls'] == null ? null : strList(r['audio_urls']),
      customTag: (r['custom_tag'] ?? '').toString(),
      tags: strList(r['tags']),
      isAutomatic: r['is_automatic'] == true,
      createdAt: parse(r['created_at']),
      updatedAt: parse(r['updated_at']),
    );
  }

  bool get hasEntries => _manual.isNotEmpty;

  /// All entries, newest first.
  List<JournalEntry> get entries {
    final list = [..._manual];
    list.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  Future<void> addEntry(JournalEntry e) async {
    _manual.add(e);
    notifyListeners();
    await _persist();
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.insert('father_journal_entries', _toRow(e));
      } catch (_) {}
    }
  }

  Future<void> deleteEntry(String id) async {
    for (final x in _manual.where((x) => x.id == id)) {
      for (final p in [...x.images, ...x.audios]) {
        if (p.isEmpty) continue;
        try {
          final f = File(p);
          if (f.existsSync()) f.deleteSync();
        } catch (_) {}
      }
    }
    _manual.removeWhere((x) => x.id == id);
    notifyListeners();
    await _persist();
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.delete('father_journal_entries', id);
      } catch (_) {}
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(_manual.map((e) => e.toJson()).toList()));
    } catch (_) {/* best-effort */}
  }
}
