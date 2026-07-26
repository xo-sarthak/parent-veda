// =============================================================================
//  CareConfig — the admin-editable rules, with the compiled ones as the floor
// -----------------------------------------------------------------------------
//  Reads care_visibility_rules and care_partner_config (0038). Follows the same
//  contract as the referral config before it:
//
//    the table is seeded to match the compiled defaults, so a device that has
//    never reached the server behaves identically to one that has.
//
//  That is not a nicety. A parent scanning a QR in a clinic basement with no
//  signal must still see "Invited by Dr Rao"; a placement that only works
//  online is a placement that fails in exactly the room it was printed for.
//
//  MOST-SPECIFIC WINS: a rule naming one partner beats a rule naming their
//  type, which beats the compiled default. Nothing here can make a partner
//  appear somewhere the code does not already allow — CareVisibility still
//  decides, and this only supplies the rule it decides against.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../services/remote/supabase_repo.dart';
import 'care_partner_models.dart';
import 'care_visibility.dart';

class CareConfig extends ChangeNotifier {
  CareConfig._();
  static final CareConfig instance = CareConfig._();

  final Map<String, CareVisibilityRule> _byType = {};
  final Map<String, CareVisibilityRule> _byPartner = {};
  final Map<String, Object?> _knobs = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// The rule to use for [partner]: their own row, then their type's row, then
  /// what is compiled in.
  CareVisibilityRule ruleFor(CarePartner partner) =>
      _byPartner[partner.id] ??
      _byType[partner.type] ??
      CareVisibilityRule.defaultsFor(partner.type);

  /// Days after a scan during which a signup still credits the partner.
  int get attributionWindowDays =>
      (_knobs['attribution_window_days'] as num?)?.toInt() ?? 90;

  /// 'first_touch' | 'last_touch'. See the OPEN POINT in 0038: multi-partner
  /// ownership is undecided, and first-touch is the conservative reading —
  /// changing it later rewrites who introduced whom.
  String get attributionModel =>
      (_knobs['attribution_model'] as String?) ?? 'first_touch';

  bool get welcomeMomentEnabled =>
      _knobs['welcome_moment_enabled'] as bool? ?? true;

  /// Bumped centrally to invalidate every printed QR at once.
  int get tokenRotation => (_knobs['token_rotation'] as num?)?.toInt() ?? 0;

  /// Best-effort. A failure leaves the compiled defaults in place, which is a
  /// working app rather than an empty one.
  Future<void> load() async {
    try {
      final rules = await SupabaseRepo.selectAll('care_visibility_rules');
      for (final r in rules.whereType<Map>()) {
        final rule = _ruleFromRow(r);
        final pid = r['partner_id']?.toString();
        final type = r['partner_type']?.toString();
        if (pid != null && pid.isNotEmpty) {
          _byPartner[pid] = rule;
        } else if (type != null && type.isNotEmpty) {
          _byType[type] = rule;
        }
      }
    } catch (_) {/* compiled defaults stand */}

    try {
      final cfg = await SupabaseRepo.selectAll('care_partner_config');
      for (final r in cfg.whereType<Map>()) {
        final k = r['key']?.toString();
        if (k != null && k.isNotEmpty) _knobs[k] = r['value'];
      }
    } catch (_) {/* likewise */}

    _loaded = true;
    notifyListeners();
  }

  /// Column names are snake_case in Postgres and camelCase in the model, so the
  /// row is translated rather than passed straight to fromMap.
  static CareVisibilityRule _ruleFromRow(Map r) =>
      CareVisibilityRule.fromMap({
        'topics': (r['topics'] as List?) ?? const [],
        // Postgres carries 'care_circle'; the enum is careCircle.
        'surfaces': ((r['surfaces'] as List?) ?? const [])
            .map((s) => _surfaceName(s.toString()))
            .toList(),
        'priority': r['priority'],
        'frequency': r['frequency'],
        'dismissible': r['dismissible'],
        'expiresAt': r['expires_at'],
      });

  static String _surfaceName(String s) =>
      s == 'care_circle' ? CareSurface.careCircle.name : s;

  @visibleForTesting
  static CareVisibilityRule debugRuleFromRow(Map r) => _ruleFromRow(r);

  @visibleForTesting
  void debugSeed({
    Map<String, CareVisibilityRule>? byType,
    Map<String, CareVisibilityRule>? byPartner,
    Map<String, Object?>? knobs,
  }) {
    _byType
      ..clear()
      ..addAll(byType ?? const {});
    _byPartner
      ..clear()
      ..addAll(byPartner ?? const {});
    _knobs
      ..clear()
      ..addAll(knobs ?? const {});
    _loaded = true;
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    _byType.clear();
    _byPartner.clear();
    _knobs.clear();
    _loaded = false;
  }
}
