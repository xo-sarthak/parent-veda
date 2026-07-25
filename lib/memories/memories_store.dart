// =============================================================================
//  MemoriesStore — the "My Memories" timeline
// -----------------------------------------------------------------------------
//  Every memory a parent makes is kept here, so the feature is a keepsake first:
//  even if they never share, their cards live in one place, newest first, and
//  can be re-opened, re-shared or made again. Stored locally (metadata only —
//  the template re-renders from the saved fields, so there is no image blob to
//  carry). The photo stays as the on-device path it was picked from.
// =============================================================================

import 'dart:convert';
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'memory_models.dart';

/// One saved memory: which milestone, which template, and the words + photo the
/// parent entered. Re-render the card any time from [templateId] + [data].
class SavedMemory {
  SavedMemory({
    required this.id,
    required this.templateId,
    required this.data,
    required this.createdUtc,
  });

  final String id;
  final String templateId;
  final MemoryData data;
  final DateTime createdUtc;

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
    );
  }
}

class MemoriesStore extends ChangeNotifier {
  MemoriesStore._();
  static final MemoriesStore instance = MemoriesStore._();

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
    _loaded = true;
    notifyListeners();
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
    return m;
  }

  void delete(String id) {
    _items.removeWhere((m) => m.id == id);
    _persist();
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
