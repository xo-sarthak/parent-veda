// =============================================================================
//  PpJournalStore - the parenting journal's real memories
// -----------------------------------------------------------------------------
//  Added 2026-10-02 in the fork (CognihabRepo/parent-veda-fork 57020be), taken
//  into main 2026-10-07 with one change. The gap analysis found the home's
//  "Record a memory" said "Memory saved to the story" and kept nothing, then
//  the journal showed another family ("Priya", a two-year-old, "Puppy
//  Kisses!"). The capture screens now write here, and PpJournalScreen reads
//  from here.
//
//  ⚠️ THE CHANGE: THIS IS AN ADAPTER, NOT A SECOND STORE.
//  The fork kept these memories in their own shared_preferences key, on the
//  phone only ("a new phone starts with an empty journal"). The user has
//  already ruled on that for the pregnancy journal (STILL-OPEN §77: "the whole
//  record is maintained not locally but wherever she logs in"), and the app
//  already has a journal that does it: `JournalStore`, the person's journal,
//  synced to `journal_entries` with photo upload, tombstones and newest-wins
//  merge (BACKEND-PATTERNS §16l). docs/FAMILY-MODEL.md puts the journal on
//  the PERSON, one continuous story from trying to parenting.
//
//  So a parenting memory is a `JournalEntry` in that same store, carrying two
//  tags: `pp_child:<child id>` (whose memory it is, so a second child does not
//  see the first one's) and `pp_kind:<moment|guided|story|letter>` (which
//  capture screen made it). No new table, no migration: `tags` and
//  `image_urls` are columns the journal already syncs.
//
//  The trade-off, named: tags are a softer link than a `child_id` column (a
//  typo in a tag is not caught by a foreign key). It buys sync today with
//  zero backend change. If child-scoped journal queries are ever needed on the
//  server, a `child_id` column can be backfilled from the tag.
//
//  The pregnancy journal's timeline leaves these out (`isChildMemory` in
//  journal_store.dart), so a baby's first smile is not filed under "Week 40".
// =============================================================================

import 'package:flutter/foundation.dart';

import '../../../models/journal_entry.dart';
import '../../../services/journal_store.dart';
import '../pp_child_profile.dart';
import 'jv2_data.dart' show JvKind;

/// Ties a journal memory to the milestone it keeps (R10).
const String kPpMilestoneTag = 'pp_milestone:';

class PpJournalEntry {
  PpJournalEntry({
    required this.id,
    required this.childId,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.photoPath,
    this.fromPartner = false,
  });

  /// Written by the paired partner: shown, never editable here (2026-10-07).
  final bool fromPartner;

  final String id;
  final String childId;
  final JvKind kind;
  final String title;
  final String body;
  final DateTime createdAt;

  /// A local path or a storage path, whichever the journal holds.
  final String? photoPath;

  static PpJournalEntry? fromJournal(JournalEntry e) {
    String? tag(String prefix) {
      for (final t in e.tags) {
        if (t.startsWith(prefix)) return t.substring(prefix.length);
      }
      return null;
    }

    final child = tag(kPpChildTag);
    if (child == null) return null;
    final k = tag(kPpKindTag);
    return PpJournalEntry(
      id: e.id,
      childId: child,
      kind: JvKind.values.firstWhere((v) => v.name == k, orElse: () => JvKind.moment),
      title: e.title,
      body: e.description,
      createdAt: e.date,
      photoPath: e.images.isEmpty ? null : e.images.first,
      fromPartner: e.isPartner,
    );
  }
}

class PpJournalStore extends ChangeNotifier {
  PpJournalStore._() {
    _journal.addListener(notifyListeners);
  }
  static final PpJournalStore instance = PpJournalStore._();

  JournalStore get _journal => JournalStore.instance;
  int _seq = 0;

  String get _childId => ChildProfileStore.instance.activeChildId ?? 'local';

  Future<void> init() => _journal.init();

  /// This child's memories, newest first.
  List<PpJournalEntry> get entries {
    final id = _childId;
    final list = [
      for (final e in _journal.manualEntries)
        if (PpJournalEntry.fromJournal(e) case final p? when p.childId == id) p,
      // The partner's memories of the same child, read-only (2026-10-07).
      for (final e in _journal.partnerChildEntries)
        if (PpJournalEntry.fromJournal(e) case final p? when p.childId == id) p,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(list);
  }

  /// Saves one memory. Returns false, and saves nothing, when there are no
  /// words and no photo: an empty card in a keepsake is worse than none.
  Future<bool> add({required JvKind kind, String title = '', String body = '', String? pickedPhotoPath}) async {
    final t = title.trim();
    final b = body.trim();
    if (t.isEmpty && b.isEmpty && pickedPhotoPath == null) return false;
    final now = DateTime.now();
    // The app generates the id, so the local row and its cloud copy are one
    // identity and sync is an idempotent merge (CLAUDE.md conventions).
    final id = 'jv_${now.microsecondsSinceEpoch}_${_seq++}';
    final photo = pickedPhotoPath == null ? null : await JournalStore.saveImage(pickedPhotoPath);
    await _journal.addEntry(JournalEntry(
      id: id,
      type: photo != null && t.isEmpty && b.isEmpty ? JournalEntryType.photo : JournalEntryType.memory,
      title: t,
      description: b,
      date: now,
      imageUrls: photo == null ? null : [photo],
      tags: ['$kPpChildTag$_childId', '$kPpKindTag${kind.name}'],
    ));
    return true;
  }

  /// A saved milestone's one journal memory (R10, 2026-10-26).
  ///
  /// Milestones are the one save; with "Also keep it in the journal" on,
  /// this keeps the memory. The tag `pp_milestone:<id>` ties the memory to
  /// its milestone, so saving the milestone again (a new photo, a date
  /// fixed) updates its memory instead of adding a second one.
  ///
  /// ⚠️ THE PHOTO IS A SEPARATE COPY OF THE ONE MILESTONES KEEPS.
  /// `JournalStore.deleteEntry` deletes an entry's images from Storage, so if
  /// both pointed at one object, deleting the memory would erase the
  /// milestone's photo too. Two files cost storage; they buy two records
  /// that can each be deleted without touching the other.
  Future<void> keepMilestone({
    required String milestoneId,
    required String title,
    required DateTime date,
    String body = '',
    String? pickedPhotoPath,
  }) async {
    final tag = '$kPpMilestoneTag$milestoneId';
    final child = '$kPpChildTag$_childId';
    JournalEntry? had;
    for (final e in _journal.manualEntries) {
      if (e.tags.contains(tag) && e.tags.contains(child)) had = e;
    }
    final photo = pickedPhotoPath == null
        ? null
        : await JournalStore.saveImage(pickedPhotoPath);
    final images = photo != null ? [photo] : (had?.images ?? const <String>[]);
    final entry = JournalEntry(
      id: had?.id ?? 'jv_${DateTime.now().microsecondsSinceEpoch}_${_seq++}',
      type: JournalEntryType.memory,
      title: title.trim(),
      description: body.trim(),
      date: date,
      imageUrls: images.isEmpty ? null : images,
      tags: [child, '$kPpKindTag${JvKind.guided.name}', tag],
      createdAt: had?.createdAt,
    );
    if (had == null) {
      await _journal.addEntry(entry);
    } else {
      await _journal.updateEntry(entry);
    }
  }

  /// True when this child's milestone already has its journal memory.
  bool hasMilestone(String milestoneId) {
    final tag = '$kPpMilestoneTag$milestoneId';
    final child = '$kPpChildTag$_childId';
    return _journal.manualEntries
        .any((e) => e.tags.contains(tag) && e.tags.contains(child));
  }

  Future<void> remove(String id) => _journal.deleteEntry(id);

  @visibleForTesting
  // A test hook calling a test hook; both are test-only.
  // ignore: invalid_use_of_visible_for_testing_member
  void debugReset() => _journal.debugClearForTest();
}
