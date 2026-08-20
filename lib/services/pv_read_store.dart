// =============================================================================
//  PvReadStore — reading progress, bookmarks, and how she likes to read
// -----------------------------------------------------------------------------
//  Singleton `ChangeNotifier`, private constructor, lazy load, `shared_
//  preferences`. The house pattern; see CLAUDE.md.
//
//  ⚠️ TWO KINDS OF STATE LIVE HERE AND THEY HAVE DIFFERENT LIFETIMES.
//
//    · PER-READ  — progress, saved. Keyed by read id, grows with the library.
//    · PER-USER  — reading mode, font scale. One value each, forever.
//
//  They are in one store because they are written from one screen and a second
//  store would mean two listeners on every reader rebuild. They are kept in
//  separate prefs keys because the per-read map will one day sync to the cloud
//  and the per-user preferences are a device setting — a mother who reads in
//  dark mode on her phone has said nothing about her husband's tablet.
//
//  ⚠️ CLOUD SYNC IS DELIBERATELY NOT WIRED YET. `ReadingStore` (parenting) uses
//  the `CloudSyncedStore` mixin and that is the right end state, but TTC takes
//  no new tables while its UI is being finalised — see `docs/STILL-OPEN.md`
//  §9.7, the same call TTC attachments made. Local-first already behaves
//  correctly here: progress shows instantly and a cloud failure is never a
//  crash, because there is no cloud call to fail.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Light, sepia, dark. Persisted by NAME, not by index.
///
/// ⚠️ `.name`, NOT `.index` — an enum reordered later would silently reinterpret
/// every stored value, which is the same class of bug as `.now` where `.en` was
/// meant. The string is the identity.
enum PvReadMode { light, sepia, dark }

class PvReadStore extends ChangeNotifier {
  PvReadStore._();
  static final PvReadStore instance = PvReadStore._();

  static const _kProgress = 'pv_read_progress';
  static const _kSaved = 'pv_read_saved';
  static const _kMode = 'pv_read_mode';
  static const _kFont = 'pv_read_font';

  final Map<String, double> _progress = {};
  final Set<String> _saved = {};
  PvReadMode _mode = PvReadMode.light;
  double _fontScale = 1.0;

  bool _loaded = false;

  PvReadMode get mode => _mode;
  double get fontScale => _fontScale;
  Set<String> get saved => Set.unmodifiable(_saved);

  double progressOf(String id) => _progress[id] ?? 0;
  bool isSaved(String id) => _saved.contains(id);

  /// True once she is far enough in that "continue reading" is honest.
  bool isStarted(String id) {
    final p = progressOf(id);
    return p > 0.02 && p < 0.95;
  }

  bool isFinished(String id) => progressOf(id) >= 0.95;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final p = await SharedPreferences.getInstance();

    // Stored as `id:0.42` pairs rather than JSON — this map is a flat
    // string→double and a JSON codec round-trip would be more code for the same
    // result. A malformed pair is skipped rather than throwing: reading
    // progress is the least important thing in the app and must never be the
    // reason a screen fails to open.
    for (final row in p.getStringList(_kProgress) ?? const <String>[]) {
      final i = row.lastIndexOf(':');
      if (i <= 0) continue;
      final v = double.tryParse(row.substring(i + 1));
      if (v != null) _progress[row.substring(0, i)] = v;
    }
    _saved.addAll(p.getStringList(_kSaved) ?? const <String>[]);

    final modeName = p.getString(_kMode);
    _mode = PvReadMode.values.firstWhere((m) => m.name == modeName,
        orElse: () => PvReadMode.light);
    _fontScale = p.getDouble(_kFont) ?? 1.0;

    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
        _kProgress, [for (final e in _progress.entries) '${e.key}:${e.value}']);
  }

  /// ⚠️ ONLY EVER MOVES FORWARD, and this is not an optimisation.
  ///
  /// The reader writes progress on every scroll frame, including the frames
  /// where she scrolls back up to re-read a paragraph. Storing the live value
  /// would mean a read she finished shows as 40% done because she checked
  /// something near the top before leaving — and then `resume` would throw her
  /// back to the middle of a piece she had finished.
  void setProgress(String id, double v) {
    final next = v.clamp(0.0, 1.0);
    if (next <= (_progress[id] ?? 0)) return;
    _progress[id] = next;
    _saveProgress();
    // No notifyListeners() — the reader owns its own scroll state and rebuilding
    // it on every frame of every scroll is the one thing that would make this
    // screen feel cheap. Listeners elsewhere (a "continue reading" rail) pick
    // the new value up on their next natural rebuild, which is soon enough for
    // something that is true within a few percent.
  }

  Future<void> toggleSave(String id) async {
    _saved.contains(id) ? _saved.remove(id) : _saved.add(id);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kSaved, _saved.toList());
  }

  Future<void> setMode(PvReadMode m) async {
    if (m == _mode) return;
    _mode = m;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kMode, m.name);
  }

  /// Clamped to a range that still renders: below 0.85 the serif body loses its
  /// counters on a 360dp screen, above 1.4 a heading wraps to four lines.
  Future<void> setFontScale(double v) async {
    final next = v.clamp(0.85, 1.4);
    if (next == _fontScale) return;
    _fontScale = next;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kFont, next);
  }
}
