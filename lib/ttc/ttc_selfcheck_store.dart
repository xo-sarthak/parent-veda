// =============================================================================
//  TtcSelfCheckStore — the answers she gave on the two self-checks, kept
// -----------------------------------------------------------------------------
//  Added 2026-09-27 (tool rebuild). "PCOS symptom check" and "See a
//  specialist?" wrote what they could into the shipped stores
//  (`TtcPcosCheckStore`, `TtcFertilityHelpStore`) and then forgot the form.
//  Opening either tool again showed eight (or six) blank questions, so the
//  only way to look at her result a second time was to answer everything
//  again, and a single changed answer meant redoing the lot.
//
//  ⚠️ WHY A SMALL STORE OF ITS OWN, AND NOT A READ-BACK FROM THE SHIPPED ONES.
//  Both write-throughs are lossy on purpose (see `PcosStandAnswers.writeThrough`
//  and `IvfReadinessAnswers.writeThrough`): hair areas become a count, family
//  history is not stored, "not sure" on the conditions is left unanswered and
//  "not done" on his test is not written. Rebuilding the form from those would
//  put answers in front of her that she never gave, which on a screen that
//  decides whether she is told to see a doctor is the one thing it must not do.
//  So the form is kept whole, beside them, and the shipped stores stay exactly
//  as they were for the five other screens that read them.
//
//  Shape from Flo's Symptom Checker ("Updated Aug 29 · Review conditions", the
//  gap analysis, Appendix B) and Mobbin: Lifesum Life Score (the last result on
//  the entry, "Retake the test"), Tempo's dated report with "Start a new scan",
//  Equinox+ "Your results · Retake".
//
//  Singleton `ChangeNotifier`, private constructor, lazy load,
//  `shared_preferences`. No cloud sync: TTC takes no new tables while its UI is
//  settling (`docs/STILL-OPEN.md` §9.7), the same call the BMI, checklist and
//  PCOS stores made.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/cloud_merged_store.dart';
// import '../services/remote/sync_registry.dart'; // kept for revert (step 13: the mixin registers)

import 'ttc_fertility_help_rules.dart';
import 'ttc_ivf_readiness.dart';
import 'ttc_pcos_stand.dart';

T? _enum<T extends Enum>(List<T> values, String? name) =>
    name == null ? null : values.where((v) => v.name == name).firstOrNull;

Map<String, String> _decode(List<String>? rows) => {
      for (final r in rows ?? const <String>[])
        if (r.contains(':'))
          r.substring(0, r.indexOf(':')): r.substring(r.indexOf(':') + 1),
    };

List<String> _encode(Map<String, String?> m) => [
      for (final e in m.entries)
        if (e.value != null) '${e.key}:${e.value}',
    ];

/// One saved form as an item value: a JSON string with sorted keys, so the
/// same form always encodes the same way. A map value would come back from
/// Postgres `jsonb` with its keys reordered and read as an edit.
String _formItem(Map<String, String> m) =>
    jsonEncode({for (final k in m.keys.toList()..sort()) k: m[k]});

Map<String, String> _formOf(Object? v) {
  if (v is! String) return {};
  try {
    final m = jsonDecode(v);
    if (m is! Map) return {};
    return {for (final e in m.entries) e.key.toString(): e.value.toString()};
  } catch (_) {
    return {};
  }
}

// ⚠️ IN THE CLOUD SINCE STEP 13 (2026-10-22, sync log). It was phone-only, so
// a sign-out or a new phone lost both saved forms. Items: `pcos` and `ivf`,
// each one whole saved form. ONE ITEM PER FORM, NOT PER QUESTION, on purpose:
// a form is saved whole, and merging two saves question by question could
// build a form she never filled in (the header's reason, one layer down).
class TtcSelfCheckStore extends ChangeNotifier with CloudMergedStore {
  TtcSelfCheckStore._();
  // Kept for revert (step 13): the reset now comes from the mixin.
  //   TtcSelfCheckStore._() {
  //     SyncRegistry.registerReset(_resetForAccount);
  //   }
  static final TtcSelfCheckStore instance = TtcSelfCheckStore._();

  static const _kPcos = 'ttc_selfcheck_pcos_stand';
  static const _kIvf = 'ttc_selfcheck_ivf_readiness';

  Map<String, String> _pcos = {};
  Map<String, String> _ivf = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final p = await SharedPreferences.getInstance();
    _pcos = _decode(p.getStringList(_kPcos));
    _ivf = _decode(p.getStringList(_kIvf));
    notifyListeners();
    await syncMergedFromCloud();
  }

  // ---- the cloud (step 13) --------------------------------------------------

  @override
  String get cloudKey => 'ttc_selfcheck';

  @override
  Map<String, Object?> cloudItems() => {
        if (_pcos.isNotEmpty) 'pcos': _formItem(_pcos),
        if (_ivf.isNotEmpty) 'ivf': _formItem(_ivf),
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _pcos = _formOf(items['pcos']);
    _ivf = _formOf(items['ivf']);
    _loaded = true;
  }

  @override
  Future<void> persistLocalCache() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (_pcos.isEmpty) {
        await p.remove(_kPcos);
      } else {
        await p.setStringList(_kPcos, _encode(_pcos));
      }
      if (_ivf.isEmpty) {
        await p.remove(_kIvf);
      } else {
        await p.setStringList(_kIvf, _encode(_ivf));
      }
    } catch (_) {/* best effort */}
  }

  // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  // are wiped, the singleton was not.
  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   void _resetForAccount() {
  //     resetForTest();
  //     notifyListeners();
  //   }

  @visibleForTesting
  void resetForTest() {
    _pcos = {};
    _ivf = {};
    _loaded = false;
  }

  // ---------------------------------------------------------------------------
  //  PCOS symptom check
  // ---------------------------------------------------------------------------

  /// When she last asked to see her pattern, or null if she never has.
  DateTime? get pcosAt => DateTime.tryParse(_pcos['at'] ?? '');

  /// Her saved answers, or null if there are none.
  PcosStandAnswers? get pcosAnswers {
    if (pcosAt == null) return null;
    final m = _pcos;
    return PcosStandAnswers()
      ..cycleLength = _enum(PcosCycleLength.values, m['cycle'])
      ..longGaps = _enum(PcosYesNo.values, m['gaps'])
      ..hairChecked = m['hairChecked'] == '1'
      ..hairAreas = {
        for (final n in (m['hair'] ?? '').split(','))
          ?_enum(PcosHairArea.values, n),
      }
      ..thinning = _enum(PcosDegree.values, m['thinning'])
      ..acne = _enum(PcosDegree.values, m['acne'])
      ..skinDarkening = _enum(PcosYesNo.values, m['skin'])
      ..trying = _enum(PcosTrying.values, m['trying'])
      ..family = _enum(PcosFamily.values, m['family']);
  }

  Future<void> savePcos(PcosStandAnswers a, {DateTime? at}) async {
    _pcos = {
      for (final e in <String, String?>{
        'at': (at ?? DateTime.now()).toIso8601String(),
        'cycle': a.cycleLength?.name,
        'gaps': a.longGaps?.name,
        'hairChecked': a.hairChecked ? '1' : null,
        'hair': a.hairAreas.isEmpty
            ? null
            : a.hairAreas.map((h) => h.name).join(','),
        'thinning': a.thinning?.name,
        'acne': a.acne?.name,
        'skin': a.skinDarkening?.name,
        'trying': a.trying?.name,
        'family': a.family?.name,
      }.entries)
        if (e.value != null) e.key: e.value!,
    };
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kPcos, _encode(_pcos));
  }

  /// Forget the saved form. Returns what was there so an Undo can put it back.
  Future<Map<String, String>> clearPcos() async {
    final was = Map<String, String>.from(_pcos);
    _pcos = {};
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.remove(_kPcos);
    return was;
  }

  Future<void> restorePcos(Map<String, String> raw) async {
    _pcos = Map.of(raw);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kPcos, _encode(_pcos));
  }

  // ---------------------------------------------------------------------------
  //  See a specialist?
  // ---------------------------------------------------------------------------

  DateTime? get ivfAt => DateTime.tryParse(_ivf['at'] ?? '');

  IvfReadinessAnswers? get ivfAnswers {
    if (ivfAt == null) return null;
    final m = _ivf;
    return IvfReadinessAnswers()
      ..age = _enum(FertilityAgeBand.values, m['age'])
      ..trying = _enum(IvfTrying.values, m['trying'])
      ..cycles = _enum(IvfCycles.values, m['cycles'])
      ..conditions = {
        for (final id in (m['conditions'] ?? '').split(','))
          if (id.isNotEmpty) id,
      }
      ..conditionsChecked = m['conditionsChecked'] == '1'
      ..conditionsUnsure = m['conditionsUnsure'] == '1'
      ..semen = _enum(IvfSemen.values, m['semen'])
      ..check = _enum(IvfCheck.values, m['check']);
  }

  Future<void> saveIvf(IvfReadinessAnswers a, {DateTime? at}) async {
    _ivf = {
      for (final e in <String, String?>{
        'at': (at ?? DateTime.now()).toIso8601String(),
        'age': a.age?.name,
        'trying': a.trying?.name,
        'cycles': a.cycles?.name,
        'conditions': a.conditions.isEmpty ? null : a.conditions.join(','),
        'conditionsChecked': a.conditionsChecked ? '1' : null,
        'conditionsUnsure': a.conditionsUnsure ? '1' : null,
        'semen': a.semen?.name,
        'check': a.check?.name,
      }.entries)
        if (e.value != null) e.key: e.value!,
    };
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kIvf, _encode(_ivf));
  }

  Future<Map<String, String>> clearIvf() async {
    final was = Map<String, String>.from(_ivf);
    _ivf = {};
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.remove(_kIvf);
    return was;
  }

  Future<void> restoreIvf(Map<String, String> raw) async {
    _ivf = Map.of(raw);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kIvf, _encode(_ivf));
  }
}
