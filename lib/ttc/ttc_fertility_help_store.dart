// =============================================================================
//  TtcFertilityHelpStore — the few answers the app could not already know
// -----------------------------------------------------------------------------
//  Singleton `ChangeNotifier`, private constructor, lazy load,
//  `shared_preferences`. The house pattern.
//
//  ⚠️ THIS STORE IS DELIBERATELY SMALL, AND THAT IS THE FEATURE.
//
//  Most of what the readiness check needs is already somewhere: `TtcStore`
//  knows how long she has been trying, `CycleStore` knows what her cycles look
//  like, `TtcPcosCheckStore` knows what her PCOS check found. Asking any of it
//  again would make this the fourth questionnaire in a stage that already has
//  three, and §8 of the brief makes it a hard requirement rather than a
//  preference.
//
//  So this holds only what nothing else can answer: her age band, her history,
//  and whether she is already in someone's care. Five or six facts, not
//  fifteen.
//
//  ⚠️ NO CLOUD SYNC. TTC takes no new tables while its UI settles —
//  `docs/STILL-OPEN.md` §9.7.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cycle_store.dart';
import 'ttc_fertility_help_rules.dart';
import 'ttc_pcos_check_rules.dart';
import 'ttc_pcos_check_store.dart';
import 'ttc_store.dart';

class TtcFertilityHelpStore extends ChangeNotifier {
  TtcFertilityHelpStore._();
  static final TtcFertilityHelpStore instance = TtcFertilityHelpStore._();

  static const _kAnswers = 'ttc_fhelp_answers';
  static const _kDone = 'ttc_fhelp_completed_at';

  final Map<String, String> _answers = {};
  DateTime? _completedAt;
  bool _loaded = false;

  Map<String, String> get answers => Map.unmodifiable(_answers);
  DateTime? get completedAt => _completedAt;
  bool get hasCompleted => _completedAt != null;

  String? answerFor(String id) => _answers[id];

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final p = await SharedPreferences.getInstance();
    for (final row in p.getStringList(_kAnswers) ?? const <String>[]) {
      final i = row.indexOf(':');
      if (i <= 0) continue;
      _answers[row.substring(0, i)] = row.substring(i + 1);
    }
    final d = p.getString(_kDone);
    if (d != null) _completedAt = DateTime.tryParse(d);
    notifyListeners();
  }

  Future<void> answer(String id, String value) async {
    _answers[id] = value;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
        _kAnswers, [for (final e in _answers.entries) '${e.key}:${e.value}']);
  }

  /// Multi-select conditions, stored as one comma-joined value.
  Future<void> toggleCondition(String id) async {
    final current = (_answers['conditions'] ?? '')
        .split(',')
        .where((s) => s.isNotEmpty)
        .toSet();
    // "None" is exclusive — selecting it clears everything else, and selecting
    // anything else clears it. A list saying both "none" and "endometriosis"
    // is a list nobody can act on.
    if (id == 'none') {
      current
        ..clear()
        ..add('none');
    } else {
      current.remove('none');
      current.contains(id) ? current.remove(id) : current.add(id);
    }
    await answer('conditions', current.join(','));
  }

  Set<String> get selectedConditions => (_answers['conditions'] ?? '')
      .split(',')
      .where((s) => s.isNotEmpty && s != 'none')
      .toSet();

  Future<void> complete() async {
    _completedAt = DateTime.now();
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kDone, _completedAt!.toIso8601String());
  }

  Future<void> reset() async {
    _answers.clear();
    _completedAt = null;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.remove(_kAnswers);
    await p.remove(_kDone);
  }

  // ---------------------------------------------------------------------------
  //  The context
  // ---------------------------------------------------------------------------

  /// Assembles what the engine reads — stores first, her answers second.
  FertilityHelpContext get context {
    final cycles = CycleStore.instance.cycleLengths;
    final shortest =
        cycles.isEmpty ? null : cycles.reduce((a, b) => a < b ? a : b);
    final longest =
        cycles.isEmpty ? null : cycles.reduce((a, b) => a > b ? a : b);

    final pcos = TtcPcosCheckStore.instance;
    final pcosResult = pcos.hasCompleted ? pcos.result : null;

    return FertilityHelpContext(
      daysTrying: TtcStore.instance.daysTrying,
      ageBand: FertilityAgeBand.values
          .where((b) => b.name == _answers['age'])
          .firstOrNull,
      cyclesLogged: cycles.length,
      cycleShortest: shortest,
      cycleLongest: longest,
      // ⚠️ TWO CYCLES IS THE FLOOR, matching the PCOS checker and the
      // checklist. One interval is not a pattern, and calling it one here
      // would fire the strongest rule in the set on a single data point.
      cyclesIrregular: cycles.length >= 2 &&
          longest != null &&
          shortest != null &&
          (longest - shortest) > 7,
      pcosCheckDone: pcos.hasCompleted,
      pcosPatternFound: pcosResult != null &&
          !pcosResult.stopped &&
          (pcosResult.level == PcosLevel.discuss ||
              pcosResult.level == PcosLevel.soon),
      pathway: switch (_answers['pathway']) {
        'current' => FertilityCarePathway.currentlyInCare,
        'done' => FertilityCarePathway.evaluated,
        _ => FertilityCarePathway.notStarted,
      },
      knownConditions: selectedConditions,
      priorMiscarriages: int.tryParse(_answers['miscarriages'] ?? '') ?? 0,
      partnerConcern: _answers['partner'] == 'yes',
      cancerTreatmentPlanned: _answers['cancer'] == 'yes',
      painfulOrHeavyPeriods: _answers['pain'] == 'yes',
      pelvicSurgeryOrInfection: _answers['pelvic'] == 'yes',
    );
  }

  FertilityHelpResult get result => evaluateFertilityHelp(context);

  /// Which questions still need asking. Everything else comes from the stores.
  ///
  /// ⚠️ THE LIST SHRINKS AS THE APP LEARNS HER. Someone who has logged cycles
  /// and run the PCOS check answers meaningfully fewer questions than someone
  /// arriving cold — which is the entire argument for this living inside
  /// ParentVeda rather than on a website.
  List<String> get missingQuestionIds {
    final c = context;
    final out = <String>[];
    if (_answers['age'] == null) out.add('age');
    if (_answers['pathway'] == null) out.add('pathway');
    // Already in care — nothing else changes the answer.
    if (_answers['pathway'] == 'current') return out;

    // ⚠️ SKIPPED WHEN THE STRONGEST RULE HAS ALREADY FIRED. Once irregular
    // cycles are established from her own logs, asking six more history
    // questions cannot change the result — and asking anyway is the
    // questionnaire-for-its-own-sake this tool exists to avoid.
    final alreadyDecisive = c.cyclesIrregular || c.pcosPatternFound;

    if (_answers['conditions'] == null) out.add('conditions');
    if (!alreadyDecisive) {
      if (_answers['miscarriages'] == null) out.add('miscarriages');
      if (_answers['pain'] == null) out.add('pain');
      if (_answers['pelvic'] == null) out.add('pelvic');
    }
    if (_answers['partner'] == null) out.add('partner');
    if (_answers['cancer'] == null) out.add('cancer');
    return out;
  }
}
