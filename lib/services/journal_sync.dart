// =============================================================================
//  Journal sync — the one merge both journals use (2026-09-23)
// -----------------------------------------------------------------------------
//  The user: *"the whole record is maintained not locally but wherever she
//  logs in, on whichever device."* An audit of `JournalStore` (and the
//  father's copy of it) found four ways the record was not:
//
//    1. PLACE NEVER LEFT THE PHONE. The compose screen stamps "where was
//       this?", the model carries it, the row sent to Supabase did not — and
//       the table had no column. Worse, a sync REPLACED the local list with the
//       cloud's, so the place vanished from her own phone on the next sync.
//    2. CLOUD ALWAYS WON. An edit made offline failed to upload, and the next
//       sync overwrote it with the older cloud copy.
//    3. A DELETE MADE OFFLINE CAME BACK. The row was still in the cloud, so the
//       next sync pulled it down again.
//    4. A DELETE ON ONE PHONE WAS UNDONE BY ANOTHER. Phone B still held the
//       entry; to B it looked like "mine, not in the cloud yet" and B uploaded
//       it again.
//
//  The general facts, because they are why each fix has the shape it does:
//
//    · "LAST WRITE WINS" NEEDS A CLOCK ON EVERY ROW. Each entry carries
//      `updatedAt`, moved on every edit (`copyWith`). The merge keeps the newer
//      copy and pushes it if it is the local one — so an offline edit is not a
//      lost edit.
//    · A DELETE HAS TO BE REMEMBERED, NOT JUST DONE. Removing a row locally
//      leaves no trace; a TOMBSTONE (the id, kept until the cloud confirms) is
//      what stops the next sync from resurrecting it.
//    · "ONLY HERE" MEANS TWO DIFFERENT THINGS. An entry on this phone and not
//      in the cloud is either new (never uploaded) or deleted elsewhere (was
//      uploaded, since removed). Without knowing which, a sync must either
//      lose new work or resurrect deletions. The phone keeps the set of ids it
//      has SEEN in the cloud: seen-then-gone is a deletion elsewhere; never-
//      seen is new.
//
//  Pure functions, no Supabase — `test/journal_sync_test.dart` walks every
//  case without a network.
// =============================================================================

import '../models/journal_entry.dart';
import 'remote/supabase_repo.dart';

/// What a sync decided.
class JournalMerge {
  const JournalMerge({
    required this.keep,
    required this.push,
    required this.deleteRemote,
    required this.seen,
  });

  /// The entries this phone should hold after the sync.
  final List<JournalEntry> keep;

  /// Local entries the cloud lacks, or holds an older copy of — upload these.
  final List<JournalEntry> push;

  /// Ids deleted on this phone that the cloud still has — delete these there.
  final List<String> deleteRemote;

  /// Every id known to be in the cloud once this sync's writes land.
  final Set<String> seen;
}

/// Merge this phone's entries with the cloud's.
///
/// [tombstones] are ids deleted here and not yet confirmed deleted there;
/// [seen] are ids this phone has seen in the cloud before.
JournalMerge mergeJournal({
  required List<JournalEntry> local,
  required List<JournalEntry> cloud,
  required Set<String> tombstones,
  required Set<String> seen,
}) {
  final cloudById = {for (final e in cloud) e.id: e};
  final localById = {for (final e in local) e.id: e};
  final keep = <String, JournalEntry>{};
  final push = <JournalEntry>[];
  final deleteRemote = <String>[];

  for (final c in cloud) {
    if (tombstones.contains(c.id)) {
      deleteRemote.add(c.id); // deleted here; finish the job there
      continue;
    }
    final l = localById[c.id];
    if (l != null && l.updatedAt.isAfter(c.updatedAt)) {
      keep[c.id] = l; // edited here, later than the cloud's copy
      push.add(l);
    } else {
      // The cloud's copy — but a column the cloud may not have yet (`place`,
      // before its migration runs) must not be wiped by it.
      keep[c.id] = (l != null && c.place == null && l.place != null &&
              !l.updatedAt.isBefore(c.updatedAt))
          ? l
          : c;
    }
  }

  for (final l in local) {
    if (cloudById.containsKey(l.id) || tombstones.contains(l.id)) continue;
    if (seen.contains(l.id)) continue; // was in the cloud, deleted elsewhere
    keep[l.id] = l; // new here, never uploaded
    push.add(l);
  }

  final nowSeen = {
    ...cloudById.keys.where((id) => !tombstones.contains(id)),
    ...push.map((e) => e.id),
  };
  return JournalMerge(
    keep: keep.values.toList(),
    push: push,
    deleteRemote: deleteRemote,
    seen: nowSeen,
  );
}

/// An entry as a row, for either journal's table. One shape for both, so a
/// column added to one cannot be forgotten on the other.
/// `test/journal_sync_test.dart` pins every key against the migrations.
Map<String, dynamic> journalEntryRow(JournalEntry e) => {
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
      'place': e.place,
      'tags': e.tags,
      'is_automatic': e.isAutomatic,
      'created_at': SupabaseRepo.dbTime(e.createdAt),
      'updated_at': SupabaseRepo.dbTime(e.updatedAt),
    };

/// A row back into an entry.
JournalEntry journalEntryFromRow(Map<String, dynamic> r,
    {bool isPartner = false}) {
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
  final place = r['place']?.toString().trim();
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
    place: (place == null || place.isEmpty) ? null : place,
    tags: strList(r['tags']),
    isAutomatic: r['is_automatic'] == true,
    isPartner: isPartner,
    createdAt: parse(r['created_at']),
    updatedAt: parse(r['updated_at']),
  );
}

/// ⚠️ THE APP CAN SHIP BEFORE THE MIGRATION RUNS. Until `place` exists in the
/// table, PostgREST refuses the WHOLE row ("Could not find the 'place'
/// column"), and because cloud writes are fire-and-forget, every journal
/// write would fail silently. So a write that is refused for that column is
/// retried once without it, and the rest of the session stops sending it.
/// Expand-then-contract, from the client's side: tolerate the schema you
/// might be ahead of.
bool _placeMissing = false;

Future<void> journalUpsert(String table, JournalEntry e) async {
  final row = journalEntryRow(e);
  if (_placeMissing) row.remove('place');
  try {
    await SupabaseRepo.upsert(table, row, onConflict: 'id');
  } catch (err) {
    if (!_placeMissing && err.toString().contains('place')) {
      _placeMissing = true;
      row.remove('place');
      await SupabaseRepo.upsert(table, row, onConflict: 'id');
    } else {
      rethrow;
    }
  }
}
