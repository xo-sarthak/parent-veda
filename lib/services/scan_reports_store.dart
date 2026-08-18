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
//  ⚠️ LOCAL-FIRST, AND THE FILE NEVER LEAVES THE PHONE UNTIL IT HAS TO
//  ---------------------------------------------------------------------------
//  Metadata lives in `shared_preferences`; the file itself stays wherever the
//  picker put it. Uploading to storage is a SEPARATE, later step
//  (`uploadAttachments`), and a failed upload keeps the local path rather than
//  dropping the reference — so a report is never lost to a bad network, it is
//  only "not durable yet".
//
//  That ordering matters more here than in most stores: this is a medical
//  document a mother photographed once, in a clinic, possibly of a printout she
//  handed back. There may be no second copy anywhere.
//
//  ⚠️ THE APP GENERATES THE ID, so a local row and its cloud copy share one
//  identity and syncing is an idempotent merge rather than a duplicate.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    this.scanId,
    this.note = '',
    this.files = const [],
  });

  final String id;

  /// What she calls it. Defaults to the scan's name when she picked one.
  final String title;

  final String dateIso;

  /// ⚠️ NULLABLE ON PURPOSE. A report does not have to belong to a scan we know
  /// about — she may photograph a blood panel, a referral, or something the
  /// library has never heard of. Forcing a scan id would mean the app refuses
  /// to hold a document it does not recognise, which is the opposite of what
  /// "one place for everything" promises.
  final String? scanId;

  final String note;
  final List<ReportFile> files;

  ScanReport copyWith({String? title, String? note, List<ReportFile>? files}) =>
      ScanReport(
        id: id,
        title: title ?? this.title,
        dateIso: dateIso,
        scanId: scanId,
        note: note ?? this.note,
        files: files ?? this.files,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dateIso': dateIso,
        'scanId': scanId,
        'note': note,
        'files': files.map((f) => f.toJson()).toList(),
      };

  factory ScanReport.fromJson(Map<String, dynamic> j) => ScanReport(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        dateIso: (j['dateIso'] ?? '').toString(),
        scanId: j['scanId']?.toString(),
        note: (j['note'] ?? '').toString(),
        files: (j['files'] as List?)
                ?.whereType<Map>()
                .map((m) => ReportFile.fromJson(m.cast<String, dynamic>()))
                .toList() ??
            const [],
      );
}

class ScanReportsStore extends ChangeNotifier {
  ScanReportsStore._();
  static final ScanReportsStore instance = ScanReportsStore._();

  static const _key = 'scan_reports_v1';

  final List<ScanReport> _reports = [];
  bool _loaded = false;

  /// Newest first — the one she just added is the one she is looking for.
  List<ScanReport> get reports {
    final out = [..._reports];
    out.sort((a, b) => b.dateIso.compareTo(a.dateIso));
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

  /// Test seam. Never called by the app.
  @visibleForTesting
  void resetForTest() {
    _reports.clear();
    _loaded = false;
  }
}
