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
import 'journal_sync.dart';
import 'tools_store.dart';

class JournalStore extends ChangeNotifier {
  JournalStore._();
  static final JournalStore instance = JournalStore._();

  static const _key = 'journal_entries';

  /// Ids deleted on this phone and not yet confirmed deleted in the cloud —
  /// see `journal_sync.dart` for why a delete has to be remembered.
  static const _tombKey = 'journal_tombstones';

  /// Ids this phone has seen in the cloud: tells "new here" from "deleted on
  /// another phone" when an entry is here and not there.
  static const _seenKey = 'journal_seen_ids';

  final Set<String> _tombstones = {};
  final Set<String> _seen = {};

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

  /// One-time, on read: an old "Note for baby" becomes an ordinary memory.
  ///
  /// ⚠️ THIS REWRITES SOMETHING SHE ALREADY WROTE, WHICH IS NORMALLY THE THING
  /// NOT TO DO — and it is done here because the product owner said the type
  /// was on trial and is being retired. Worth being precise about what is and
  /// is not touched:
  ///
  ///   · Her words, her photos, her date, her week and her id are untouched.
  ///     Only the `type` changes, which is the label above the card and the
  ///     colour of its chip.
  ///   · Nothing is deleted. An entry that was a note for her baby is still
  ///     the entry she wrote; it simply files under the one kind that remains.
  ///
  /// ⚠️ IT DOES NOT TOUCH THE FATHER'S. He still creates this type from his own
  /// screens, into `FatherJournalStore`, and the review did not ask to change
  /// his app. Two stores is what makes that separation free — a single shared
  /// store would have forced a choice between breaking his feature and leaving
  /// hers half-migrated.
  ///
  /// ⚠️ AND IT RUNS ON READ RATHER THAN AS A ONE-SHOT WITH A FLAG. A flag needs
  /// somewhere to live and a way to be correct after a reinstall or a restore
  /// from the cloud; converting on the way in is idempotent by construction —
  /// a converted entry has nothing left to convert — and it also catches an old
  /// entry arriving later from a cloud sync, which a startup-only pass would
  /// miss entirely.
  JournalEntry _migrated(JournalEntry e) =>
      e.type == JournalEntryType.noteForBaby
          ? e.retyped(JournalEntryType.memory)
          : e;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _manual.add(_migrated(
              JournalEntry.fromJson(Map<String, dynamic>.from(e))));
        }
      }
      _tombstones.addAll(prefs.getStringList(_tombKey) ?? const []);
      _seen.addAll(prefs.getStringList(_seenKey) ?? const []);
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
      // ⚠️ A MERGE, NOT A REPLACE (2026-09-23). This used to rebuild the
      // list from the cloud and upload only ids the cloud lacked: an offline
      // edit was overwritten, an offline delete came back, and a place never
      // survived a sync. `mergeJournal` keeps the newer copy, finishes
      // pending deletes, and tells new-here from deleted-elsewhere.
      final m = mergeJournal(
        local: _manual,
        cloud: [for (final r in rows) _migrated(journalEntryFromRow(r))],
        tombstones: _tombstones,
        seen: _seen,
      );
      for (final id in m.deleteRemote) {
        await SupabaseRepo.delete('journal_entries', id);
        _tombstones.remove(id);
      }
      // A tombstone for an id the cloud never had is simply done.
      _tombstones.removeWhere((id) => !rows.any((r) => r['id'].toString() == id));
      for (final e in m.push) {
        await journalUpsert('journal_entries', e);
      }
      _seen
        ..clear()
        ..addAll(m.seen);
      _manual
        ..clear()
        ..addAll(m.keep);

      // Merged view: also pull the paired partner's (father's) journal, marked
      // read-only. RLS on father_journal_entries allows the partner to read.
      _partner.clear();
      final partnerId = await SupabaseRepo.myPartnerId();
      if (partnerId != null) {
        final prows =
            await SupabaseRepo.fetchByUser('father_journal_entries', partnerId);
        _partner.addAll(
            prows.map((r) => journalEntryFromRow(r, isPartner: true)));
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
          await journalUpsert('journal_entries', ne);
        } catch (_) {}
      }
    }
    if (changed) await _persist();
  }

  // camelCase model <-> snake_case columns: `journalEntryRow` and
  // `journalEntryFromRow` in journal_sync.dart since 2026-09-23 — one shape for
  // both journals, and it carries `place`. The previous pair, kept for revert:
  //   // camelCase model <-> snake_case columns.
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
  //   JournalEntry _fromRow(Map<String, dynamic> r, {bool isPartner = false}) {
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
  //       isPartner: isPartner,
  //       createdAt: parse(r['created_at']),
  //       updatedAt: parse(r['updated_at']),
  //     );
  //   }

  List<JournalEntry> get manualEntries => List.unmodifiable(_manual);

  bool get hasManualEntries => _manual.isNotEmpty;

  Future<void> addEntry(JournalEntry e) async {
    _manual.add(e);
    notifyListeners();
    await _persist();
    if (SupabaseRepo.isLoggedIn) {
      try {
        await journalUpsert('journal_entries', e);
        _seen.add(e.id);
        await _persist();
      } catch (_) {/* offline — the next sync pushes it (never seen) */}
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
    // Remembered until the cloud confirms — else the next sync brings it back.
    _tombstones.add(id);
    notifyListeners();
    await _persist();
    if (SupabaseRepo.isLoggedIn) {
      try {
        await SupabaseRepo.delete('journal_entries', id);
        _tombstones.remove(id);
        _seen.remove(id);
        await _persist();
      } catch (_) {/* offline — the tombstone finishes it on the next sync */}
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
        await journalUpsert('journal_entries', e);
      } catch (_) {/* offline — newer here, so the next sync pushes it */}
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
