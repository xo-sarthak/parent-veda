// =============================================================================
//  JournalStore - persistence + timeline assembly for "My Journal"
// -----------------------------------------------------------------------------
//  Manual entries (memory / note-for-baby / photo / voice) are persisted in
//  shared_preferences; photo files live in the app documents dir. The full
//  timeline merges those manual entries with AUTO entries derived from the
//  mother's existing data - pregnancy milestones, weight logs, kick sessions -
//  so the journal feels alive without her logging anything twice.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/journey_milestones.dart';
import '../localization/app_language.dart';
import '../models/journal_entry.dart';
import '../models/journey_node.dart';
import 'pregnancy_controller.dart';
import 'remote/storage_service.dart';
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';
import 'tools_store.dart';

class JournalStore extends ChangeNotifier {
  JournalStore._();
  static final JournalStore instance = JournalStore._();

  static const _key = 'journal_entries';

  final List<JournalEntry> _manual = [];

  /// The paired partner's (father's) entries, pulled read-only for the merged
  /// view. Never persisted locally; refreshed from the cloud on each sync.
  final List<JournalEntry> _partner = [];

  /// Whether the merged timeline includes the partner's entries (the mother can
  /// toggle this in the journal screen). Defaults on when a partner is paired.
  bool showPartnerEntries = true;

  bool _loaded = false;

  bool get hasPartnerEntries => _partner.isNotEmpty;

  void setShowPartnerEntries(bool v) {
    showPartnerEntries = v;
    notifyListeners();
  }

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

    // Then sync with the cloud (no-op if logged out). Only MANUAL entries are
    // persisted/synced (auto entries are derived at runtime). NOTE: the image/
    // audio columns hold local file PATHS for now - the actual files move to
    // Supabase Storage in Phase 3.
    await _syncFromCloud();
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      final rows = await SupabaseRepo.fetch('journal_entries');
      final byId = {for (final r in rows) r['id'].toString(): _fromRow(r)};
      for (final e in _manual) {
        if (!byId.containsKey(e.id)) {
          byId[e.id] = e;
          await SupabaseRepo.insert('journal_entries', _toRow(e));
        }
      }
      _manual
        ..clear()
        ..addAll(byId.values);

      // Merged view: also pull the paired partner's (father's) journal, marked
      // read-only. RLS on father_journal_entries allows the partner to read.
      _partner.clear();
      final partnerId = await SupabaseRepo.myPartnerId();
      if (partnerId != null) {
        final prows =
            await SupabaseRepo.fetchByUser('father_journal_entries', partnerId);
        _partner.addAll(prows.map((r) => _fromRow(r, isPartner: true)));
      }

      await _persist();
      await _backfillMedia();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  // Upload any media still stored as local paths (captured offline/logged-out,
  // or from before Storage existed) and rewrite the entry to the cloud path.
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
          await SupabaseRepo.upsert('journal_entries', _toRow(ne),
              onConflict: 'id');
        } catch (_) {}
      }
    }
    if (changed) await _persist();
  }

  // camelCase model <-> snake_case columns.
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

  JournalEntry _fromRow(Map<String, dynamic> r, {bool isPartner = false}) {
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
      isPartner: isPartner,
      createdAt: parse(r['created_at']),
      updatedAt: parse(r['updated_at']),
    );
  }

  List<JournalEntry> get manualEntries => List.unmodifiable(_manual);

  bool get hasManualEntries => _manual.isNotEmpty;

  Future<void> addEntry(JournalEntry e) async {
    _manual.add(e);
    notifyListeners();
    await _persist();
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.insert('journal_entries', _toRow(e));
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
        await StorageService.remove(p);
      }
    }
    _manual.removeWhere((x) => x.id == id);
    notifyListeners();
    await _persist();
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.delete('journal_entries', id);
      } catch (_) {}
    }
  }

  /// Replace a manual entry (same id) with an edited copy.
  Future<void> updateEntry(JournalEntry e) async {
    final i = _manual.indexWhere((x) => x.id == e.id);
    if (i < 0) return;
    _manual[i] = e;
    notifyListeners();
    await _persist();
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.upsert('journal_entries', _toRow(e), onConflict: 'id');
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

  /// Copy a picked image into the app documents dir; returns the stored path
  /// (falls back to the source path if copying fails).
  static Future<String> saveImage(String sourcePath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final jdir = Directory('${dir.path}/journal');
      if (!jdir.existsSync()) jdir.createSync(recursive: true);
      final ext = sourcePath.contains('.') ? sourcePath.split('.').last : 'jpg';
      final dest =
          '${jdir.path}/jr_${DateTime.now().microsecondsSinceEpoch}.$ext';
      await File(sourcePath).copy(dest);
      // Upload the bytes to Storage; returns the storage path (or the local
      // path as an offline fallback) to persist on the entry.
      return StorageService.upload(dest, 'journal');
    } catch (_) {
      return sourcePath;
    }
  }

  /// Copy a recorded audio clip into the app documents dir; returns the stored
  /// path (falls back to the source path if copying fails).
  static Future<String> saveAudio(String sourcePath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final jdir = Directory('${dir.path}/journal');
      if (!jdir.existsSync()) jdir.createSync(recursive: true);
      final ext = sourcePath.contains('.') ? sourcePath.split('.').last : 'm4a';
      final dest =
          '${jdir.path}/jr_${DateTime.now().microsecondsSinceEpoch}.$ext';
      await File(sourcePath).copy(dest);
      return StorageService.upload(dest, 'voice');
    } catch (_) {
      return sourcePath;
    }
  }

  // ---- Timeline (manual + auto), newest first --------------------------------

  List<JournalEntry> timeline(PregnancyController p) {
    final s = S(p.language);
    final list = <JournalEntry>[..._manual];
    if (showPartnerEntries) list.addAll(_partner);
    list.addAll(_autoMilestones(p));
    list.addAll(_autoHealth(p, s));
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  // Kept for the (commented-out) kick auto-entries above.
  // ignore: unused_element
  int _weekAt(PregnancyController p, DateTime d) {
    final days = p.dueDate.difference(DateTime(d.year, d.month, d.day)).inDays;
    final raw = 40 - (days / 7).floor();
    return raw.clamp(4, 40);
  }

  // Milestones reached so far, sourced from the shared Journey milestone library
  // (achievements + baby development + "days together" + mother experiences) so
  // the journal and the Pregnancy Map stay in sync. Medical scans and
  // feature-unlock nodes are intentionally excluded (scans fill from real logs
  // later; the spec forbids feature/product achievements in the journal).
  List<JournalEntry> _autoMilestones(PregnancyController p) {
    final lang = p.language;
    final currentDay = p.currentDay;
    final now = DateTime.now();
    const included = {
      JourneyNodeType.achievement,
      JourneyNodeType.babyDev,
      JourneyNodeType.pvJourney,
      JourneyNodeType.mother,
    };
    final out = <JournalEntry>[];
    for (final m in kJourneyMilestones) {
      if (!included.contains(m.type)) continue;
      if (m.posDay > currentDay) continue;
      var date = p.dueDate.subtract(
          Duration(days: (PregnancyController.termDays - m.posDay).round()));
      if (date.isAfter(now)) date = now;
      var desc = '';
      for (final sec in m.sections) {
        final b = sec.body.of(lang).trim();
        if (b.isNotEmpty) {
          desc = b;
          break;
        }
      }
      out.add(JournalEntry(
        id: 'jm_${m.id}',
        type: JournalEntryType.milestone,
        title: '${m.emoji}  ${m.title.of(lang)}',
        description: desc,
        date: date,
        weekNumber: m.anchorWeek,
        isAutomatic: true,
      ));
    }
    return out;
  }

  List<JournalEntry> _autoHealth(PregnancyController p, S s) {
    final out = <JournalEntry>[];
    final t = ToolsStore.instance;

    for (final w in t.weightEntries) {
      final d = DateTime.tryParse(w.timeIso) ??
          DateTime.tryParse(w.dateIso) ??
          p.dueDate;
      out.add(JournalEntry(
        id: 'wt_${w.id}',
        type: JournalEntryType.weight,
        title: s.jrWeightLogged,
        description: '${w.weight.toStringAsFixed(1)} ${s.kgUnit}',
        date: d,
        weekNumber: w.week,
        isAutomatic: true,
      ));
    }

    // Kick sessions are intentionally NOT shown in the journal - they live in
    // the Baby Movement tool. Kept commented for an easy revert.
    /*
    var first = true;
    for (final ms in t.movementSessionHistory.reversed) {
      out.add(JournalEntry(
        id: 'kick_${ms.id}',
        type: JournalEntryType.kick,
        title: first ? s.jrFirstKick : s.jrKickSession,
        description: s.jrMovementsCount(ms.times.length),
        date: ms.start,
        weekNumber: _weekAt(p, ms.start),
        isAutomatic: true,
      ));
      first = false;
    }
    */
    return out;
  }
}
