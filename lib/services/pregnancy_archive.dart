// =============================================================================
//  PregnancyArchive - what "a new pregnancy starts clean" moves, and what
//  deleting a pregnancy removes (R1, 2026-10-25)
// -----------------------------------------------------------------------------
//  Two kinds of pregnancy record, two rules (pregnancy_records.dart):
//
//   · DATED records (bump photos, symptoms, weights, kicks, contractions,
//     weekly notes, letters, the journal, appointments, garbh recordings)
//     belong to the pregnancy whose window holds their date. Nothing moves:
//     each store reads its own window. They are the [scoped] stores.
//   · UNDATED records (the hospital bag, the birth plan, the birth context,
//     the checklists, the journey dates, scan reports, scans ticked by
//     catalogue id, and the moods / missions / movement keyed by pregnancy
//     day) cannot be told apart by date. When the next pregnancy begins they
//     are COPIED into the old pregnancy's archive and the live stores start
//     clean, as her own edit, so her other phones follow. These are [_parts].
//
//  Her rituals, pins and favourites in Garbh Sanskar, her medicines and
//  reminders, kegels and calendar notes are hers, not a pregnancy's, and
//  carry on.
// =============================================================================

import '../data/garbh_rebuild_data.dart';
import 'birth_plan_store.dart';
import 'bump_store.dart';
import 'daily_store.dart';
import 'hospital_bag_store.dart';
import 'hospital_bag_v2_store.dart';
import 'journal_store.dart';
import 'journey_dates_store.dart';
import 'memory_store.dart';
import 'pregnancy_records.dart';
import 'pv_checklist_store.dart';
import 'ready_birth_context_store.dart';
import 'remote/cloud_merged_store.dart';
import 'scan_reports_store.dart';
import 'scans_store.dart';
import 'symptom_store.dart';
import 'tools_store.dart';

/// One undated store: how to load it, copy-and-clear it, and put a copy back.
class PregnancyArchivePart {
  const PregnancyArchivePart(this.key, this.label, this.take, this.restore);

  /// Its key in the record's archive.
  final String key;

  /// What the "Kept for you" page calls it.
  final String label;

  final Future<Object?> Function() take;
  final Future<void> Function(Object? copy) restore;
}

PregnancyArchivePart _merged(
  String label,
  CloudMergedStore Function() store,
  Future<void> Function() load,
) {
  final s = store();
  return PregnancyArchivePart(
    s.cloudKey,
    label,
    () async {
      await load();
      final st = store();
      final items = Map<String, Object?>.from(st.cloudItems());
      await st.replaceItemsAsEdit(const {});
      return items;
    },
    (copy) async {
      if (copy is! Map) return;
      await load();
      await store().replaceItemsAsEdit(Map<String, Object?>.from(copy));
    },
  );
}

class PregnancyArchive {
  PregnancyArchive._();

  /// The undated stores. ⚠️ A new store of this kind is added HERE, or the
  /// next pregnancy opens on the last one's (test/pregnancy_records_test.dart
  /// holds the list).
  static List<PregnancyArchivePart> get _parts => [
        _merged('Hospital bag', () => HospitalBagStore.instance,
            () => HospitalBagStore.instance.init()),
        _merged('Hospital bag', () => HospitalBagV2Store.instance,
            () => HospitalBagV2Store.instance.init()),
        _merged('Birth plan', () => BirthPlanStore.instance,
            () => BirthPlanStore.instance.init()),
        _merged('Ready for birth', () => ReadyBirthContextStore.instance,
            () => ReadyBirthContextStore.instance.init()),
        _merged('Checklists', () => PvChecklistStore.instance,
            () => PvChecklistStore.instance.init('scan_questions')),
        _merged('Journey dates', () => JourneyDatesStore.instance,
            () => JourneyDatesStore.instance.init()),
        _merged('Scan reports', () => ScanReportsStore.instance,
            () => ScanReportsStore.instance.load()),
        PregnancyArchivePart(
          'completed_scans',
          'Scans done',
          () async {
            await ScansStore.instance.init();
            return ScansStore.instance.takeCompletedForNewPregnancy();
          },
          (copy) async {
            await ScansStore.instance.init();
            await ScansStore.instance.restoreCompleted(copy);
          },
        ),
        PregnancyArchivePart(
          'days',
          'Moods and daily answers',
          () async {
            await DailyStore.instance.init();
            return DailyStore.instance.takeDaysForNewPregnancy();
          },
          (copy) async {
            await DailyStore.instance.init();
            await DailyStore.instance.restoreDays(copy);
          },
        ),
      ];

  /// The archive keys, for the test that holds the list.
  static List<String> get partKeys => [for (final p in _parts) p.key];

  /// Copies every undated store and clears it: the pregnancy before a new one
  /// is sealed. One part that fails does not stop the others; the archive
  /// says when it was made, so even an all-empty one marks the record sealed.
  static Future<Map<String, Object?>> seal() async {
    final out = <String, Object?>{
      'sealed_at': DateTime.now().toUtc().toIso8601String(),
    };
    for (final p in _parts) {
      try {
        out[p.key] = await p.take();
      } catch (_) {/* this part stays live; the others still seal */}
    }
    return out;
  }

  /// Puts an archive back into the live stores (the undo of a new pregnancy).
  static Future<void> restore(Map<String, Object?> archive) async {
    for (final p in _parts) {
      if (!archive.containsKey(p.key)) continue;
      try {
        await p.restore(archive[p.key]);
      } catch (_) {}
    }
  }

  // ---- reading and deleting a pregnancy (the "Kept for you" page) ----------

  /// The dated stores.
  static List<PregnancyScopedStore> get scoped => [
        BumpStore.instance,
        SymptomStore.instance,
        ToolsStore.instance,
        MemoryStore.instance,
        DailyStore.instance,
        JournalStore.instance,
        ScansStore.instance,
        GarbhJournalStore.instance,
      ];

  /// Loads every store the page reads (each init is idempotent).
  static Future<void> loadAll() async {
    await Future.wait([
      BumpStore.instance.init(),
      SymptomStore.instance.init(),
      ToolsStore.instance.init(),
      MemoryStore.instance.init(),
      DailyStore.instance.init(),
      JournalStore.instance.init(),
      ScansStore.instance.init(),
      GarbhJournalStore.instance.init(),
    ].map((f) => f.catchError((_) {})));
  }

  /// How many undated things [r] holds, by label, for the page's "also kept"
  /// line. A sealed pregnancy counts its archive; the latest counts nothing
  /// here (its undated things are the live stores', opened as usual).
  static Map<String, int> archiveCounts(PregnancyRecord r) {
    final out = <String, int>{};
    for (final p in _parts) {
      final v = r.archive[p.key];
      final n = v is Map
          ? (p.key == 'days'
              ? ((v['moods'] as Map?)?.length ?? 0)
              : v.length)
          : v is List
              ? v.length
              : 0;
      if (n > 0) out[p.label] = (out[p.label] ?? 0) + n;
    }
    return out;
  }

  /// ⚠️ DELETES A PREGNANCY, AT HER ASKING ONLY (the user, 2026-10-25: "let
  /// them take control of it and delete it permanently if they want").
  /// Every dated record in its window goes through its store's own delete,
  /// so each removal syncs and Storage files go the usual way; the archive
  /// goes with the record. The house soft delete: gone from her phones now,
  /// purged from the cloud after 90 days (0109). The latest pregnancy's
  /// undated things are the live stores', so they are cleared too.
  static Future<int> deletePregnancy(PregnancyRecord r) async {
    final recs = PregnancyRecords.instance;
    await loadAll();
    final w = recs.windowOf(r);
    var n = 0;
    for (final s in scoped) {
      try {
        n += await s.removeIn(w);
      } catch (_) {}
    }
    final isLatest = recs.latest?.id == r.id;
    if (isLatest && !r.sealed) {
      await seal(); // the copy is dropped: she asked for it gone
    }
    await recs.remove(r);
    return n;
  }
}
