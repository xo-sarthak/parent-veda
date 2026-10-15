// =============================================================================
//  DearBabyVaultStore — when the Dear Baby letters open
// -----------------------------------------------------------------------------
//  The vault's row has always promised "Letters that open when your baby is
//  born" (pv_you_content.dart). This is the one place that knows whether that
//  day has come, and whether she has opened them yet. STILL-OPEN §83.2.
//
//  ⚠️ A STORED EVENT, WITH A DERIVED FALLBACK. Two ways to answer "is the
//  baby born?":
//    * derive it from the stage (parenting = born). Free, always agrees with
//      the rest of the app, but it cannot tell WHICH child, and a family who
//      had a child before this pregnancy is in neither stage cleanly;
//    * store the moment the arrival sheet saves (`markBorn`). That knows the
//      child's id, name and birthday, which the opening screen and the book
//      both print.
//  So the arrival sheet stores the event, and the stage is the fallback for
//  the paths that never pass through that sheet (onboarding straight into
//  parenting, the dev stage switch). BACKEND-PATTERNS has the general form.
//
//  ⚠️ THE LOSS PATH NEVER OPENS ANYTHING. "My pregnancy ended" does not call
//  `markBorn` and does not move to parenting, so no birth moment can fire
//  for a mother who has lost her baby. Her letters stay exactly where they
//  were.
//
//  Local-first: shared_preferences only. Nothing here goes to the cloud.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/post_pregnancy/pp_child_profile.dart';
import 'life_stage_store.dart';

class DearBabyVaultStore extends ChangeNotifier {
  DearBabyVaultStore._();
  static final DearBabyVaultStore instance = DearBabyVaultStore._();

  static const _kBornOn = 'dear_baby_born_on';
  static const _kChildId = 'dear_baby_child_id';
  static const _kChildName = 'dear_baby_child_name';
  static const _kOpenedAt = 'dear_baby_opened_at';

  bool _loaded = false;
  DateTime? _bornOn;
  String? _childId;
  String? _childName;
  DateTime? _openedAt;

  DateTime? get bornOn => _bornOn;
  DateTime? get openedAt => _openedAt;

  /// The letters open on the birth: the arrival sheet's record, or, for a
  /// family that reached parenting another way, the stage itself.
  bool get unlocked =>
      _bornOn != null || LifeStageStore.instance.stage == LifeStage.parenting;

  bool get opened => _openedAt != null;

  /// The name the letters are addressed to. The child's current name when
  /// the record still exists (a rename shows), else the name given at birth,
  /// else null (the copy then says "your baby").
  String? get childName {
    if (_childId != null) {
      for (final c in ChildProfileStore.instance.children) {
        if (c.id == _childId) {
          return c.name.trim().isEmpty || c.name == Child.placeholder
              ? null
              : c.name.trim();
        }
      }
    }
    final n = _childName?.trim();
    return (n == null || n.isEmpty) ? null : n;
  }

  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final sp = await SharedPreferences.getInstance();
      _bornOn = DateTime.tryParse(sp.getString(_kBornOn) ?? '');
      _childId = sp.getString(_kChildId);
      _childName = sp.getString(_kChildName);
      _openedAt = DateTime.tryParse(sp.getString(_kOpenedAt) ?? '');
    } catch (_) {/* local-first: an unreadable store is an unopened vault */}
    notifyListeners();
  }

  /// Called once, by the arrival sheet, when she says the baby is here.
  Future<void> markBorn({
    required DateTime dob,
    String? childId,
    String? name,
  }) async {
    await init();
    _bornOn = dob;
    _childId = childId;
    _childName = name;
    notifyListeners();
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kBornOn, dob.toIso8601String());
      if (childId != null) await sp.setString(_kChildId, childId);
      if (name != null) await sp.setString(_kChildName, name);
    } catch (_) {}
  }

  /// She opened the envelope. Once only: the opening never plays twice.
  Future<void> markOpened() async {
    await init();
    if (_openedAt != null) return;
    _openedAt = DateTime.now();
    notifyListeners();
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kOpenedAt, _openedAt!.toIso8601String());
    } catch (_) {}
  }

  @visibleForTesting
  void resetForTest() {
    _loaded = false;
    _bornOn = null;
    _childId = null;
    _childName = null;
    _openedAt = null;
  }
}
