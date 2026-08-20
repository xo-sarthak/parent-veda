// =============================================================================
//  ScanReportsStore — her reports, in one place
// -----------------------------------------------------------------------------
//  Scans & tests V2, door 2. The door exists because of the one sentence that
//  survives the "why would she open the app" test better than anything else in
//  this hub: *"where did I put that report?"*
//
//  It is also the only door that leaves something behind. A timeline is read;
//  a decoder is read; a stored report is a record that exists nowhere else and
//  is worth more at every later appointment.
//
//  ---------------------------------------------------------------------------
//  ⚠️ LOCAL-FIRST, AND NOW ACTUALLY DURABLE
//  ---------------------------------------------------------------------------
//  Metadata syncs through `CloudSyncedStore`; the FILES go to the private media
//  bucket via `uploadAttachments(picked, 'report')`. A failed upload keeps the
//  local path rather than dropping the reference — so a report is never lost to
//  a bad network, it is only "not durable yet", and [ScanReport.needsBackup]
//  says so.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THIS PARAGRAPH USED TO DESCRIBE A SECOND STEP THAT NOBODY EVER TOOK
//  ---------------------------------------------------------------------------
//  It read: "Uploading to storage is a SEPARATE, later step
//  (`uploadAttachments`)". `scan_reports_screen.dart` said the same thing at
//  its own head — "`uploadAttachments` already handles durability" — and
//  IMPORTED the file that defines it, for the picker. It never called it. Every
//  report ever added stored the raw camera path, and this store was the one
//  store of nineteen with no `CloudSyncedStore` at all.
//
//  ⚠️ WHY THIS ONE MATTERS MORE THAN THE OTHER WIRING GATES IN THIS REVIEW.
//  The paragraph below was already in this file and was already right:
//
//      this is a medical document a mother photographed once, in a clinic,
//      possibly of a printout she handed back. There may be no second copy
//      anywhere.
//
//  So the file that best explained the stakes was the file that failed to act
//  on them. Nothing looked wrong: reports listed, opened, and survived a
//  restart, because `shared_preferences` is enough for everything except the
//  case that matters — a new phone.
//
//  ⚠️ AND A COMMENT DESCRIBING FUTURE WORK IS THE COMMON THREAD. Mind & Mood's
//  booking said "wire this later". The diet chart download said "a clearly-named
//  stub". This said "a SEPARATE, later step". Each reads, to the next person, as
//  a decision somebody is tracking. Nobody was. A note about work that has not
//  happened should name what breaks until it does, or it functions as
//  reassurance.
//
//  ⚠️ THE APP GENERATES THE ID, so a local row and its cloud copy share one
//  identity and syncing is an idempotent merge rather than a duplicate.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_synced_store.dart';
import 'remote/storage_service.dart';

/// One file attached to a report.
class ReportFile {
  const ReportFile({required this.path, required this.name, this.isPdf = false});

  final String path;
  final String name;
  final bool isPdf;

  Map<String, dynamic> toJson() =>
      {'path': path, 'name': name, 'isPdf': isPdf};

  factory ReportFile.fromJson(Map<String, dynamic> j) => ReportFile(
        path: (j['path'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        isPdf: j['isPdf'] == true,
      );
}

/// A stored report — one visit's paperwork.
class ScanReport {
  const ScanReport({
    required this.id,
    required this.title,
    required this.dateIso,
    String? reportDateIso,
    this.scanId,
    this.note = '',
    this.files = const [],
  }) : reportDateOrNull = reportDateIso;

  final String id;

  /// What she calls it. Defaults to the scan's name when she picked one.
  final String title;

  /// When she ADDED it. An audit fact, never shown as "the date of the report".
  final String dateIso;

  /// When the report itself is from — the date printed on the paper.
  ///
  /// ⚠️ TWO DATES BECAUSE THERE ARE TWO FACTS, and collapsing them was a real
  /// defect rather than a tidiness question: the list sorted on [dateIso], so a
  /// mother photographing a stack of old reports filed all of them under today,
  /// in the order she happened to pick them up. The most useful ordering in a
  /// medical folder — oldest test to newest — was the one ordering the screen
  /// could not produce.
  ///
  /// ⚠️ NULL FALLS BACK TO [dateIso], WHICH IS WHAT MAKES THIS SAFE TO ADD.
  /// Every report already stored on a phone has no `reportDateIso` in its JSON,
  /// and reads back sorting exactly as it did before. No migration, no
  /// backfill, and nothing moves under her without her doing anything.
  ///
  /// ⚠️ AND SHE IS NEVER ASKED FOR IT. "Derive, never ask" — it defaults to
  /// today at capture, which is right for the common case (a report
  /// photographed the day it was handed over) and correctable in the editor
  /// that already exists for the case it is wrong.
  /// ⚠️ NAMED `reportDateOrNull` AND NOT `_reportDateIso`, WHICH IS NOT
  /// bikeshedding: the constructor takes `reportDateIso`, and a field whose
  /// name differs from its parameter only by an underscore trips
  /// `prefer_initializing_formals` — and an initializing formal cannot be used
  /// here, because a private named parameter is unusable from another library.
  /// The honest name also states the thing that matters at every read site:
  /// this can be null, and [reportDateIso] is the one to use.
  final String? reportDateOrNull;

  /// The report's own date, falling back to when she added it.
  String get reportDateIso => reportDateOrNull ?? dateIso;

  /// True while any file is still only on this phone.
  ///
  /// ⚠️ DERIVED FROM THE PATHS, NOT STORED AS A FLAG. Same argument as the diet
  /// charts' Hindi flag, reached independently: a stored "backed up" boolean is
  /// a claim, and a claim goes stale silently — she signs out, an upload fails,
  /// the flag keeps saying yes. `StorageService.upload` returns the STORAGE
  /// path on success and the ORIGINAL LOCAL PATH on failure, so the path itself
  /// already records the truth and nothing else needs to.
  ///
  /// A report with no files at all is metadata, which the cloud blob carries —
  /// so it is not "unbacked".
  bool get needsBackup =>
      files.any((f) => !StorageService.isRemoteRef(f.path));

  /// ⚠️ NULLABLE ON PURPOSE. A report does not have to belong to a scan we know
  /// about — she may photograph a blood panel, a referral, or something the
  /// library has never heard of. Forcing a scan id would mean the app refuses
  /// to hold a document it does not recognise, which is the opposite of what
  /// "one place for everything" promises.
  final String? scanId;

  final String note;
  final List<ReportFile> files;

  /// ⚠️ `clearScanId` EXISTS BECAUSE `scanId` IS NULLABLE, AND THAT MAKES
  /// `copyWith` AMBIGUOUS.
  ///
  /// With a nullable field there is no way for `copyWith` to tell "she unlinked
  /// this report from its scan" apart from "she did not mention the scan" —
  /// both arrive as `scanId: null`. Without the flag, unlinking is simply not
  /// expressible, and the editor would silently keep a link she just removed.
  ///
  /// The alternative is a sentinel object, which is shorter to call and worse
  /// to read: a reviewer has to know what the sentinel means. A named boolean
  /// says it at the call site.
  ScanReport copyWith({
    String? title,
    String? note,
    String? reportDateIso,
    List<ReportFile>? files,
    String? scanId,
    bool clearScanId = false,
  }) =>
      ScanReport(
        id: id,
        title: title ?? this.title,
        dateIso: dateIso,
        reportDateIso: reportDateIso ?? reportDateOrNull,
        scanId: clearScanId ? null : (scanId ?? this.scanId),
        note: note ?? this.note,
        files: files ?? this.files,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dateIso': dateIso,
        // Written only when set, so an untouched report keeps the exact JSON
        // it had before this field existed.
        if (reportDateOrNull != null) 'reportDateIso': reportDateOrNull,
        'scanId': scanId,
        'note': note,
        'files': files.map((f) => f.toJson()).toList(),
      };

  factory ScanReport.fromJson(Map<String, dynamic> j) => ScanReport(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        dateIso: (j['dateIso'] ?? '').toString(),
        reportDateIso: j['reportDateIso']?.toString(),
        scanId: j['scanId']?.toString(),
        note: (j['note'] ?? '').toString(),
        files: (j['files'] as List?)
                ?.whereType<Map>()
                .map((m) => ReportFile.fromJson(m.cast<String, dynamic>()))
                .toList() ??
            const [],
      );
}

class ScanReportsStore extends ChangeNotifier with CloudSyncedStore {
  ScanReportsStore._();
  static final ScanReportsStore instance = ScanReportsStore._();

  static const _key = 'scan_reports_v1';

  final List<ScanReport> _reports = [];
  bool _loaded = false;

  /// Newest first — the one she just added is the one she is looking for.
  List<ScanReport> get reports {
    final out = [..._reports];
    // ⚠️ SORTS ON THE REPORT DATE, NOT THE UPLOAD DATE. `reportDateIso` falls
    // back to `dateIso`, so a library recorded before that field existed keeps
    // exactly the order it had.
    //
    // Ties break on `dateIso` DESCENDING, which matters for the case that
    // motivated the field: photographing a stack of old reports gives several
    // rows the same report date, and within that day the most recently added
    // should sit on top — it is the one she is looking at.
    out.sort((a, b) {
      final byReport = b.reportDateIso.compareTo(a.reportDateIso);
      return byReport != 0 ? byReport : b.dateIso.compareTo(a.dateIso);
    });
    return List.unmodifiable(out);
  }

  bool get isEmpty => _reports.isEmpty;

  List<ScanReport> forScan(String scanId) =>
      reports.where((r) => r.scanId == scanId).toList();

  /// ⚠️ SHOWS CACHED DATA INSTANTLY, LOADS AFTER. Callers render whatever is in
  /// memory and rebuild on notify; nothing waits on disk.
  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return;
      final list = jsonDecode(raw);
      if (list is! List) return;
      _reports
        ..clear()
        ..addAll(list
            .whereType<Map>()
            .map((m) => ScanReport.fromJson(m.cast<String, dynamic>())));
      notifyListeners();
    } catch (_) {
      // A corrupt blob must not take the screen with it — she still gets an
      // empty list and can add a report, which is better than a crash on a
      // screen whose whole promise is "your things are safe here".
    }
    // ⚠️ AFTER THE LOCAL READ, AND ONLY THEN. `syncStateFromCloud` adopts with
    // "cloud wins", and it also flips the mixin's `_cloudReady` guard — which
    // exists so the notifyListeners() fired while loading the cache cannot push
    // an empty local list up and clobber a good cloud copy. Calling it first
    // would do exactly that on a fresh install, which for this store means
    // deleting her reports from the cloud on a new phone.
    try {
      await syncStateFromCloud();
    } catch (_) {/* offline — the local cache is still hers */}
  }

  Future<void> add(ScanReport r) async {
    _reports.add(r);
    notifyListeners();
    await _save();
  }

  Future<void> update(ScanReport r) async {
    final i = _reports.indexWhere((x) => x.id == r.id);
    if (i < 0) return;
    _reports[i] = r;
    notifyListeners();
    await _save();
  }

  Future<void> remove(String id) async {
    _reports.removeWhere((r) => r.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(_reports.map((r) => r.toJson()).toList()));
    } catch (_) {
      // Fire-and-forget, like every other store here. The cost is a silent
      // failure; the benefit is that a full disk never breaks the UI.
    }
  }

  // ---------------------------------------------------------------------------
  //  CloudSyncedStore — the metadata half of durability
  // ---------------------------------------------------------------------------
  //  ⚠️ THIS STORE WAS THE ONLY ONE OF NINETEEN WITHOUT IT, and it held the
  //  documents a mother is least able to replace.
  //
  //  ⚠️ WHY A `user_state` BLOB RATHER THAN A TABLE, given that the parenting
  //  side gave its reports one (`pp_reports`, migration 0022). A dedicated
  //  table earns its cost when something QUERIES the rows server-side —
  //  filtering, joining, an Edge Function reading them. Nothing does here:
  //  reports are read by exactly one device, the one signed in. A blob through
  //  the existing mixin therefore needs no migration, no RLS policy and no
  //  schema to keep in step with the Dart model, which is also the failure mode
  //  CLAUDE.md warns about — a column-name mismatch fails silently because
  //  cloud writes are fire-and-forget.
  //
  //  If reports ever need to be readable by a partner or a doctor, that is the
  //  moment for a table, and the id is already app-generated so the move is a
  //  copy rather than a reconciliation.
  //
  //  ⚠️ THE BLOB CARRIES FILE REFERENCES, NEVER FILE BYTES. The bytes go to the
  //  private media bucket. Putting a photographed report inside a JSON blob
  //  would be both enormous and the wrong place for a medical image.
  @override
  String get cloudKey => 'scan_reports';

  @override
  Object cloudData() => _reports.map((r) => r.toJson()).toList();

  @override
  void applyCloudData(Object data) {
    if (data is! List) return;
    // ⚠️ REPLACE, NOT MERGE, AND THAT IS THE MIXIN'S CONTRACT RATHER THAN A
    // CHOICE MADE HERE: `applyCloudData` runs once at sync, before local edits
    // are allowed to push. Merging would also need a per-row timestamp this
    // model does not carry, and inventing one to guess at conflicts is worse
    // than the mixin's rule that the cloud is the truth at sync time.
    _reports
      ..clear()
      ..addAll(data
          .whereType<Map>()
          .map((m) => ScanReport.fromJson(m.cast<String, dynamic>())));
  }

  @override
  Future<void> persistLocalCache() => _save();

  /// Test seam. Never called by the app.
  @visibleForTesting
  void resetForTest() {
    _reports.clear();
    _loaded = false;
  }
}
