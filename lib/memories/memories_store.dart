// =============================================================================
//  MemoriesStore — the "My Memories" timeline
// -----------------------------------------------------------------------------
//  Every memory a parent makes is kept here, so the feature is a keepsake first:
//  even if they never share, their cards live in one place, newest first, and
//  can be re-opened, re-shared or made again. Stored locally (metadata only —
//  the template re-renders from the saved fields, so there is no image blob to
//  carry). The photo stays as the on-device path it was picked from.
//
//  IN THE CLOUD SINCE STEP 13 (2026-10-22, sync log, migration 0110). Memories
//  were kept only on this phone, so a sign-out or a new phone lost every
//  keepsake. Each memory is now a row in `memories` (own-only, soft delete,
//  newer wins, OwnRowLedger), its fields in `data`. The photo goes to Storage
//  (`media/<uid>/memory/...`) and the row carries that reference as
//  `photoRef`; the on-device `photoPath` stays this phone's own, and a phone
//  that lacks the file downloads it into its cache.
// =============================================================================

import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/own_row_ledger.dart';
import '../services/remote/storage_service.dart';
import '../services/remote/supabase_repo.dart';
import '../services/remote/sync_registry.dart';
import '../services/remote/sync_row_book.dart';
import 'memory_models.dart';

/// One saved memory: which milestone, which template, and the words + photo the
/// parent entered. Re-render the card any time from [templateId] + [data].
class SavedMemory {
  SavedMemory({
    required this.id,
    required this.templateId,
    required this.data,
    required this.createdUtc,
    this.photoRef,
  });

  final String id;
  final String templateId;
  final MemoryData data;
  final DateTime createdUtc;

  /// The photo's Storage reference once uploaded (step 13); null until then.
  String? photoRef;

  Map<String, Object?> toMap() => {
        'id': id,
        'templateId': templateId,
        'createdUtc': createdUtc.toUtc().toIso8601String(),
        'type': data.type.name,
        'coupleNames': data.coupleNames,
        'dueMonth': data.dueMonth,
        'babyName': data.babyName,
        'birthDate': data.birthDate,
        'birthTime': data.birthTime,
        'weight': data.weight,
        'length': data.length,
        'parentNames': data.parentNames,
        'message': data.message,
        'photoPath': data.photo?.path,
        'photoScale': data.photo?.scale,
        'photoDx': data.photo?.offset.dx,
        'photoDy': data.photo?.offset.dy,
        'photoRef': photoRef,
      };

  static SavedMemory fromMap(Map m) {
    final type = MemoryType.values
        .firstWhere((t) => t.name == m['type'], orElse: () => MemoryType.expecting);
    final data = MemoryData(type: type)
      ..coupleNames = (m['coupleNames'] ?? '').toString()
      ..dueMonth = (m['dueMonth'] ?? '').toString()
      ..babyName = (m['babyName'] ?? '').toString()
      ..birthDate = (m['birthDate'] ?? '').toString()
      ..birthTime = (m['birthTime'] ?? '').toString()
      ..weight = (m['weight'] ?? '').toString()
      ..length = (m['length'] ?? '').toString()
      ..parentNames = (m['parentNames'] ?? '').toString()
      ..message = (m['message'] ?? '').toString();
    final path = m['photoPath'];
    if (path != null) {
      data.photo = MemoryPhoto(
        path.toString(),
        scale: (m['photoScale'] as num?)?.toDouble() ?? 1.0,
        offset: Offset(
          (m['photoDx'] as num?)?.toDouble() ?? 0,
          (m['photoDy'] as num?)?.toDouble() ?? 0,
        ),
      );
    }
    return SavedMemory(
      id: (m['id'] ?? '').toString(),
      templateId: (m['templateId'] ?? '').toString(),
      data: data,
      createdUtc: DateTime.parse(
              (m['createdUtc'] ?? DateTime.now().toUtc().toIso8601String())
                  .toString())
          .toUtc(),
      photoRef: m['photoRef']?.toString(),
    );
  }
}

class MemoriesStore extends ChangeNotifier {
  MemoriesStore._() {
    SyncRegistry.registerReset(_resetForAccount);
  }
  static final MemoriesStore instance = MemoriesStore._();

  /// Newer-wins sync per memory (step 13, 0110).
  final OwnRowLedger _sync =
      OwnRowLedger('memories', 'memories_sync', keyColumn: 'key');

  /// Memories the cloud has not confirmed (the sign-out sheet reads this).
  bool get hasPending => _sync.hasPending;

  Map<String, dynamic> _toRow(SavedMemory m) =>
      {'key': m.id, 'data': m.toMap()};

  Map<String, Map<String, dynamic>> _live() =>
      {for (final m in _items) m.id: _toRow(m)};

  static const _key = 'memories_v1';
  final List<SavedMemory> _items = [];
  int _seq = 0;
  bool _loaded = false;

  /// Newest first.
  List<SavedMemory> get all => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _items.add(SavedMemory.fromMap(e as Map));
        }
        _items.sort((a, b) => b.createdUtc.compareTo(a.createdUtc));
      }
    } catch (_) {/* start empty */}
    await _sync.load();
    _loaded = true;
    notifyListeners();
    await syncFromCloud();
  }

  bool _registered = false;

  /// Push waiting memories (photos first), then take the cloud's newer ones.
  /// No-op when logged out; offline keeps everything waiting.
  Future<void> syncFromCloud() async {
    if (!_registered) {
      _registered = true;
      SyncRegistry.register(syncFromCloud);
      SyncRegistry.registerPending(() => hasPending);
    }
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      await _uploadPhotos();
      await _sync.push(_live,
          onRemovalConfirmed: (_, cols) {
            final data = cols['data'];
            final ref = data is Map ? data['photoRef']?.toString() : null;
            if (ref != null && ref.isNotEmpty) StorageService.remove(ref);
          });
      final taken = await _sync.pull(liveKeys: _items.map((m) => m.id));
      if (taken.isEmpty) return;
      final byId = {for (final m in _items) m.id: m};
      for (final r in taken) {
        final id = r['id'].toString();
        if (syncParseStamp(r['removed_at']) != null) {
          byId.remove(id);
          continue;
        }
        final data = r['data'];
        if (data is! Map) continue;
        final m = SavedMemory.fromMap({...data, 'id': id});
        await _fetchPhoto(m);
        byId[id] = m;
      }
      _items
        ..clear()
        ..addAll(byId.values)
        ..sort((a, b) => b.createdUtc.compareTo(a.createdUtc));
      await _persist();
      notifyListeners();
    } catch (_) {/* offline - keep local, still waiting */}
  }

  /// A photo still only on this phone goes to Storage, and the memory is
  /// marked changed so its row carries the reference.
  Future<void> _uploadPhotos() async {
    var changed = false;
    for (final m in _items) {
      final path = m.data.photo?.path;
      if (path == null || path.isEmpty || m.photoRef != null) continue;
      if (!File(path).existsSync()) continue;
      final ref = await StorageService.upload(path, 'memory');
      if (ref == path) continue; // offline or not set up: try next time
      m.photoRef = ref;
      _sync.touch(m.id);
      changed = true;
    }
    if (changed) await _persist();
  }

  /// A memory from another phone: its photo is fetched into this phone's
  /// cache, and the card points at that copy.
  Future<void> _fetchPhoto(SavedMemory m) async {
    final photo = m.data.photo;
    final ref = m.photoRef;
    if (photo == null || ref == null || ref.isEmpty) return;
    if (File(photo.path).existsSync()) return;
    final file = await StorageService.resolve(ref);
    if (file == null) return;
    m.data.photo =
        MemoryPhoto(file.path, scale: photo.scale, offset: photo.offset);
  }

  /// Save a newly made memory (or overwrite one with the same id).
  SavedMemory save({
    required String templateId,
    required MemoryData data,
    DateTime? at,
  }) {
    final now = (at ?? DateTime.now()).toUtc();
    final m = SavedMemory(
      id: 'mem_${now.microsecondsSinceEpoch}_${_seq++}',
      templateId: templateId,
      data: data.copy(),
      createdUtc: now,
    );
    _items.insert(0, m);
    _persist();
    notifyListeners();
    _sync.touch(m.id);
    syncFromCloud();
    return m;
  }

  void delete(String id) {
    for (final m in _items.where((m) => m.id == id).toList()) {
      _sync.remove(id, _toRow(m));
    }
    _items.removeWhere((m) => m.id == id);
    _persist();
    notifyListeners();
    syncFromCloud();
  }

  // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  // are wiped, the singleton was not.
  // resetAll() below also writes prefs, so this one touches memory only.
  void _resetForAccount() {
    _items.clear();
    _loaded = false;
    _sync
      ..clear()
      ..save();
    notifyListeners();
  }

  @visibleForTesting
  void resetAll() {
    _items.clear();
    _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(_items.map((m) => m.toMap()).toList()));
    } catch (_) {/* best-effort */}
  }
}
