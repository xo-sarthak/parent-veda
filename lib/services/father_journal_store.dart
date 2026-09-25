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
import 'journal_sync.dart';
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';

class FatherJournalStore extends ChangeNotifier {
  FatherJournalStore._();
  static final FatherJournalStore instance = FatherJournalStore._();

  static const _key = 'father_journal_entries';

  // The same two sets the mother's journal keeps — see journal_sync.dart.
  static const _tombKey = 'father_journal_tombstones';
  static const _seenKey = 'father_journal_seen_ids';
  final Set<String> _tombstones = {};
  final Set<String> _seen = {};

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
      _tombstones.addAll(prefs.getStringList(_tombKey) ?? const []);
      _seen.addAll(prefs.getStringList(_seenKey) ?? const []);
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
      // A merge, not a replace (2026-09-23) — the mother's journal had the
      // same four holes; both now use `mergeJournal` (journal_sync.dart).
      final m = mergeJournal(
        local: _manual,
        cloud: [for (final r in rows) journalEntryFromRow(r)],
        tombstones: _tombstones,
        seen: _seen,
      );
      for (final id in m.deleteRemote) {
        await SupabaseRepo.delete('father_journal_entries', id);
        _tombstones.remove(id);
      }
      _tombstones.removeWhere((id) => !rows.any((r) => r['id'].toString() == id));
      for (final e in m.push) {
        await journalUpsert('father_journal_entries', e);
      }
      _seen
        ..clear()
        ..addAll(m.seen);
      _manual
        ..clear()
        ..addAll(m.keep);
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
          await journalUpsert('father_journal_entries', ne);
        } catch (_) {}
      }
    }
    if (changed) await _persist();
  }

  // Row mapping: `journalEntryRow` / `journalEntryFromRow` (journal_sync.dart)
  // since 2026-09-23. The previous pair, kept for revert:
  //   // camelCase model <-> snake_case columns (same shape as journal_entries).
  //   Map<String, dynamic> _toRow(JournalEntry e) => {
  //         'id': e.id,
  //         'type': e.type.name,
  //         'title': e.title,
  //         'description': e.description,
  //         'date': SupabaseRepo.dbTime(e.date),
  //         'week_number': e.weekNumber,
  //         'image_url': e.imageUrl,
  //         'audio_url': e.audioUrl,
  //         'image_urls': e.imageUrls,
  //         'audio_urls': e.audioUrls,
  //         'custom_tag': e.customTag,
  //         'tags': e.tags,
  //         'is_automatic': e.isAutomatic,
  //         'created_at': SupabaseRepo.dbTime(e.createdAt),
  //         'updated_at': SupabaseRepo.dbTime(e.updatedAt),
  //       };
  //
  //   JournalEntry _fromRow(Map<String, dynamic> r) {
  //     var t = JournalEntryType.memory;
  //     for (final e in JournalEntryType.values) {
  //       if (e.name == r['type']) {
  //         t = e;
  //         break;
  //       }
  //     }
  //     DateTime parse(Object? v) => SupabaseRepo.parseDbTime(v);
  //     List<String> strList(Object? v) =>
  //         (v as List?)?.map((e) => e.toString()).toList() ?? const [];
  //     return JournalEntry(
  //       id: (r['id'] ?? '').toString(),
  //       type: t,
  //       title: (r['title'] ?? '').toString(),
  //       description: (r['description'] ?? '').toString(),
  //       date: parse(r['date']),
  //       weekNumber: (r['week_number'] as num?)?.toInt() ?? 0,
  //       imageUrl: r['image_url']?.toString(),
  //       audioUrl: r['audio_url']?.toString(),
  //       imageUrls: r['image_urls'] == null ? null : strList(r['image_urls']),
  //       audioUrls: r['audio_urls'] == null ? null : strList(r['audio_urls']),
  //       customTag: (r['custom_tag'] ?? '').toString(),
  //       tags: strList(r['tags']),
  //       isAutomatic: r['is_automatic'] == true,
  //       createdAt: parse(r['created_at']),
  //       updatedAt: parse(r['updated_at']),
  //     );
  //   }

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
        await journalUpsert('father_journal_entries', e);
        _seen.add(e.id);
        await _persist();
      } catch (_) {/* offline — the next sync pushes it */}
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
        // The uploaded copy too — the mother's journal already did this; the
        // father's left his photos in Storage after the entry was gone.
        await StorageService.remove(p);
      }
    }
    _manual.removeWhere((x) => x.id == id);
    _tombstones.add(id);
    notifyListeners();
    await _persist();
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.delete('father_journal_entries', id);
        _tombstones.remove(id);
        _seen.remove(id);
        await _persist();
      } catch (_) {/* offline — the tombstone finishes it on the next sync */}
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(_manual.map((e) => e.toJson()).toList()));
      await prefs.setStringList(_tombKey, _tombstones.toList());
      await prefs.setStringList(_seenKey, _seen.toList());
    } catch (_) {/* best-effort */}
  }
}
