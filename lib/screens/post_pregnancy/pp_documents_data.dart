// =============================================================================
//  Baby documents - model + in-memory store
// -----------------------------------------------------------------------------
//  A calm home for the important papers of a child's early years: the birth
//  certificate, Aadhaar, passport, insurance, medical papers and anything else.
//  Each document is a title + category + date + optional image/PDF attachments.
//  A ChangeNotifier singleton like the app's other stores; a real backend slots
//  in behind these same methods later. Nothing here depends on the pregnancy app.
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/child_scoped_store.dart';
import '../../services/remote/supabase_repo.dart';
import '../../services/remote/sync_registry.dart';
import 'pp_attachments.dart';
import 'pp_child_profile.dart';

/// The small, fixed set of buckets a document can belong to.
const List<String> kBabyDocCategories = [
  'Birth certificate',
  'Aadhaar',
  'Passport',
  'Insurance',
  'Medical',
  'Other',
];

class BabyDocument {
  const BabyDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    this.attachments = const [],
    this.notes = '',
  });
  final String id;
  final String title;
  final String category; // one of kBabyDocCategories
  final String date; // display, e.g. "18 Mar 2026"
  final List<Attachment> attachments;
  final String notes;
}

// A couple of seeded examples so the screen never opens empty.
const List<BabyDocument> kBabyDocuments = [
  BabyDocument(
    id: 'doc_birth',
    title: 'Birth certificate',
    category: 'Birth certificate',
    date: '18 Mar 2026',
    notes: 'Municipal corporation copy. Original kept safe at home.',
  ),
  BabyDocument(
    id: 'doc_insurance',
    title: 'Health insurance (child add-on)',
    category: 'Insurance',
    date: '2 Apr 2026',
    notes: 'Added to the family floater policy.',
  ),
];

class BabyDocumentsStore extends ChangeNotifier {
  BabyDocumentsStore._();
  static final BabyDocumentsStore instance = BabyDocumentsStore._();

  // EMPTY, not seeded from kBabyDocuments: those are demo entries for a
  // fictional child and this store now syncs (BACKEND-PARENTING-BRIEF §5).
  final List<BabyDocument> _docs = [];

  bool _loaded = false;
  static const _prefsKey = 'pp_documents';
  static const _table = 'pp_documents';

  String? get _childId => ChildProfileStore.instance.activeChildId;

  List<BabyDocument> get documents => List.unmodifiable(_docs);

  // ---- persistence (local-first, then cloud) -------------------------------
  //  ⚠️ Flag #5 - HALF a fix. The ROW syncs; the FILES do not yet. The paths in
  //  `attachments` are image_picker / file_picker temp paths, which the OS reaps
  //  on its own schedule, so a photographed birth certificate is already rotting
  //  on-device today. Completing this means routing the bytes through
  //  StorageService (media bucket, 0013/0014) and storing the returned object
  //  path instead. Until then a restored document keeps its title and category
  //  but its attachment may point at a file that no longer exists.
  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _docs.add(_fromRow(Map<String, dynamic>.from(e)));
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
    try {
      await _syncFromCloud();
    } catch (_) {/* stay local */}
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    final childId = _childId;
    if (!SupabaseRepo.isLoggedIn || childId == null) return;
    try {
      final merged = await ChildSync.merge<BabyDocument>(
        table: _table,
        childId: childId,
        local: _docs,
        idOf: (d) => d.id,
        toRow: _toRow,
        fromRow: _fromRow,
      );
      _docs
        ..clear()
        ..addAll(merged);
      await _persist();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_docs.map(_toRow).toList()));
    } catch (_) {}
  }

  static Map<String, dynamic> _toRow(BabyDocument d) => {
        'id': d.id,
        'title': d.title,
        'category': d.category,
        'date': d.date,
        'notes': d.notes,
        'attachments': d.attachments
            .map((a) => {'kind': a.kind.name, 'path': a.path, 'name': a.name})
            .toList(),
      };

  static BabyDocument _fromRow(Map<String, dynamic> r) {
    final raw = r['attachments'];
    return BabyDocument(
      id: (r['id'] ?? '').toString(),
      title: (r['title'] ?? '').toString(),
      category: (r['category'] ?? '').toString(),
      date: (r['date'] ?? '').toString(),
      notes: (r['notes'] ?? '').toString(),
      attachments: raw is List
          ? raw.map((e) {
              final m = Map<String, dynamic>.from(e);
              return Attachment(
                AttachKind.values.firstWhere((k) => k.name == m['kind'],
                    orElse: () => AttachKind.image),
                (m['path'] ?? '').toString(),
                (m['name'] ?? '').toString(),
              );
            }).toList()
          : const <Attachment>[],
    );
  }

  void addDocument(BabyDocument d) {
    _docs.insert(0, d);
    notifyListeners();
    _persist();
    ChildSync.push(_table, _childId, d.id, _toRow(d));
  }

  void updateDocument(int i, BabyDocument d) {
    if (i < 0 || i >= _docs.length) return;
    _docs[i] = d;
    notifyListeners();
    _persist();
    ChildSync.push(_table, _childId, d.id, _toRow(d));
  }

  void removeDocument(int i) {
    if (i < 0 || i >= _docs.length) return;
    final row = _docs.removeAt(i);
    notifyListeners();
    _persist();
    ChildSync.remove(_table, row.id);
  }
}
