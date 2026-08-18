// =============================================================================
//  LifeStageStore - which chapter of ParentVeda a family is living in
// -----------------------------------------------------------------------------
//  The first piece of the Family Journey layer described in Part 4 of the TTC
//  master document. Deliberately ADDITIVE: it records which stage the family is
//  in and nothing else. Pregnancy and Parenting keep their own controllers and
//  their own tables exactly as they are - this store does not replace them, it
//  sits beside them so a stage can be asked about without any module importing
//  another module.
//
//      "Life stages change. Architecture does not."   - TTC master, Principle 2
//
//  This is what the auth screen's long-dormant "I AM CURRENTLY: Trying /
//  Pregnant / New parent" selector finally writes into, and what the Transition
//  Engine (Phase 7) will flip when a positive test is recorded.
//
//  Lives in lib/services/ rather than lib/ttc/ on purpose: it is an app-wide
//  concern, not a TTC one. TTC is simply the first stage to read it.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ttc/ttc_sync.dart';
import 'remote/supabase_repo.dart';

/// The stages of the ParentVeda journey, in order.
///
/// `planning` and the stages beyond `parenting` named in the master document
/// (Birth & Recovery, School Years) are deliberately NOT declared yet - an enum
/// value with nothing behind it is a promise the product has not kept. They get
/// added the day something reads them.
enum LifeStage {
  /// Trying to conceive - the first built chapter.
  tryingToConceive,

  /// Week 4 to birth.
  pregnancy,

  /// Day one to age five.
  parenting,

  /// ⚠️ NOT A SELECTABLE STAGE — a fourth VALUE, not a fourth destination.
  ///
  /// Skilling exists here so its bracket table can name a stage without lying
  /// about which one. Nothing sets it: `LifeStageStore` never writes it, the
  /// splash never routes to it, and `JourneyState` refuses to infer anything
  /// from it. It is reachable only from the design preview.
  ///
  /// It gets a persisted id anyway, because `id` is exhaustive and a stage with
  /// no id would be one `switch` away from a crash the day someone does wire it.
  /// A value that can be persisted but never is costs nothing; a missing case
  /// costs a runtime error.
  skilling,
}

extension LifeStageCopy on LifeStage {
  /// The value persisted and sent to the backend. Stable - never rename these
  /// without a migration, because they outlive any UI wording.
  String get id {
    switch (this) {
      case LifeStage.tryingToConceive:
        return 'trying';
      case LifeStage.pregnancy:
        return 'pregnancy';
      case LifeStage.parenting:
        return 'parenting';
      case LifeStage.skilling:
        return 'skilling';
    }
  }

  String label(bool hinglish) {
    switch (this) {
      case LifeStage.tryingToConceive:
        return hinglish ? 'Family planning' : 'Trying to conceive';
      case LifeStage.pregnancy:
        return hinglish ? 'Pregnancy' : 'Pregnancy';
      case LifeStage.parenting:
        return hinglish ? 'Parenting' : 'Parenting';
      case LifeStage.skilling:
        return hinglish ? 'Skilling' : 'Skilling';
    }
  }

  static LifeStage? fromId(String? id) {
    switch (id) {
      case 'trying':
        return LifeStage.tryingToConceive;
      case 'pregnancy':
        return LifeStage.pregnancy;
      // The auth screen has always used 'new' for the new-parent card.
      case 'parenting':
      case 'new':
        return LifeStage.parenting;
      default:
        return null;
    }
  }
}

class LifeStageStore extends ChangeNotifier with TtcSyncedStore {
  LifeStageStore._() {
    _load();
  }
  static final LifeStageStore instance = LifeStageStore._();

  /// Public because the splash reads it directly, alongside the auth flag and
  /// role, to decide which stage to boot into. It cannot use the store itself
  /// there: `_load()` is async and fired from the constructor, so at splash time
  /// `stage` may still be null and the user would be sent to the wrong home.
  static const String kLifeStageKey = 'pv_life_stage';
  static const _enteredKey = 'pv_life_stage_entered';

  LifeStage? _stage;
  DateTime? _enteredAt;
  bool _loaded = false;

  /// Null until the family tells us - which is a real state, not a bug. A user
  /// who signed up before this existed simply has not declared one, and every
  /// caller must handle that rather than assuming pregnancy.
  LifeStage? get stage => _stage;

  /// When they entered the current stage. Doubles as the TTC journey start.
  DateTime? get enteredAt => _enteredAt;

  bool get isLoaded => _loaded;
  bool get isTrying => _stage == LifeStage.tryingToConceive;

  /// Declares the stage. Re-declaring the SAME stage keeps the original entry
  /// date - otherwise re-opening onboarding would silently reset a journey the
  /// family has been on for months.
  void setStage(LifeStage stage, {DateTime? at}) {
    if (_stage == stage) return;
    _stage = stage;
    _enteredAt = at ?? DateTime.now();
    _persist();
    notifyListeners();
  }

  /// Accepts the raw id the auth screen carries ('trying' | 'pregnant' | 'new').
  /// Unknown or empty values are ignored rather than guessed at.
  void setStageId(String? id) {
    // The auth screen says 'pregnant'; the persisted id is 'pregnancy'.
    final normalised = id == 'pregnant' ? 'pregnancy' : id;
    final s = LifeStageCopy.fromId(normalised);
    if (s != null) setStage(s);
  }

  @visibleForTesting
  void resetForTest() {
    _stage = null;
    _enteredAt = null;
    _loaded = true;
    notifyListeners();
  }

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      _stage = LifeStageCopy.fromId(p.getString(kLifeStageKey));
      final raw = p.getString(_enteredKey);
      _enteredAt = raw == null ? null : DateTime.tryParse(raw);
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
    await syncFromCloud();
  }

  // ---- cloud ----------------------------------------------------------------
  //  Lives on the profile row rather than a table of its own - it is one fact
  //  about a person, and 0041 adds the column beside the ones already there.
  //
  //  Cloud-wins here, unlike the row stores: this is a single declared value,
  //  and the newest declaration on any device is the one that is true.

  @override
  Future<void> pullFromCloud() async {
    final row = await SupabaseRepo.fetchMyProfile('life_stage, life_stage_at');
    if (row == null) return;
    final stage = LifeStageCopy.fromId(row['life_stage'] as String?);
    if (stage == null) return; // never declared in the cloud - keep local
    _stage = stage;
    _enteredAt = DateTime.tryParse(row['life_stage_at']?.toString() ?? '') ??
        _enteredAt;
  }

  @override
  Future<void> pushToCloud() async {
    final s = _stage;
    if (s == null) return; // nothing declared - do not write a null over a value
    await SupabaseRepo.updateMyProfile({
      'life_stage': s.id,
      'life_stage_at': _enteredAt?.toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> persistLocalCache() => _persist();

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      final s = _stage;
      if (s == null) {
        await p.remove(kLifeStageKey);
      } else {
        await p.setString(kLifeStageKey, s.id);
      }
      final e = _enteredAt;
      if (e == null) {
        await p.remove(_enteredKey);
      } else {
        await p.setString(_enteredKey, e.toIso8601String());
      }
    } catch (_) {/* best-effort */}
  }
}
