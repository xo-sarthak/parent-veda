// =============================================================================
//  TtcBmiStore — her measurements, her units, and a plain history
// -----------------------------------------------------------------------------
//  Singleton `ChangeNotifier`, private constructor, lazy load,
//  `shared_preferences`. The house pattern.
//
//  ⚠️ A RECORD, NOT A PROGRESS TRACKER. §18 of the brief and it is right: no
//  streaks, no trophies, no "you lost 3 kg!", no celebration of a number going
//  down and no disappointment when it goes up. Weight moves for many reasons —
//  illness, medication, PCOS, thyroid, ordinary life — and an app that cheers
//  one direction is an app that has decided which direction is good.
//
//  So the history is a list of measurements with dates, and the only thing the
//  store ever says about a change is that it happened.
//
//  ⚠️ NO CLOUD SYNC. TTC takes no new tables while its UI is settling —
//  `docs/STILL-OPEN.md` §9.7, the same call attachments, vaccinations, the
//  PCOS checker and the checklist all made.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ttc_bmi_rules.dart';

@immutable
class BmiHistoryEntry {
  const BmiHistoryEntry({
    required this.at,
    required this.metres,
    required this.kilograms,
    required this.bmi,
  });

  final DateTime at;
  final double metres;
  final double kilograms;
  final double bmi;

  String encode() =>
      '${at.toIso8601String()}|$metres|$kilograms|$bmi';

  static BmiHistoryEntry? decode(String raw) {
    final p = raw.split('|');
    if (p.length < 4) return null;
    final at = DateTime.tryParse(p[0]);
    final m = double.tryParse(p[1]);
    final kg = double.tryParse(p[2]);
    final bmi = double.tryParse(p[3]);
    if (at == null || m == null || kg == null || bmi == null) return null;
    return BmiHistoryEntry(at: at, metres: m, kilograms: kg, bmi: bmi);
  }
}

class TtcBmiStore extends ChangeNotifier {
  TtcBmiStore._();
  static final TtcBmiStore instance = TtcBmiStore._();

  static const _kHistory = 'ttc_bmi_history';
  static const _kHeightUnit = 'ttc_bmi_height_unit';
  static const _kWeightUnit = 'ttc_bmi_weight_unit';
  static const _kOnChecklist = 'ttc_bmi_on_checklist';
  static const _kHeight = 'ttc_bmi_height_m';

  final List<BmiHistoryEntry> _history = [];
  BmiHeightUnit _heightUnit = BmiHeightUnit.cm;
  BmiWeightUnit _weightUnit = BmiWeightUnit.kg;
  bool _onChecklist = false;
  bool _loaded = false;

  /// ⚠️ HER HEIGHT, REMEMBERED ONCE (launch sanity T2, 2026-09-28). Height
  /// was only ever recovered from a SAVED result, so a woman who worked out
  /// her BMI and did not tap Save typed her height again next time. It is
  /// kept on its own the moment she works a number out, in metres (the unit
  /// is a display choice, as for the history).
  double? _heightM;

  /// Her height in metres: the one she last worked a BMI out with, else the
  /// latest saved measurement's. Null when she has never given it.
  double? get heightMetres => _heightM ?? latest?.metres;

  /// Oldest first.
  List<BmiHistoryEntry> get history => List.unmodifiable(_history);

  BmiHeightUnit get heightUnit => _heightUnit;
  BmiWeightUnit get weightUnit => _weightUnit;
  bool get onChecklist => _onChecklist;

  BmiHistoryEntry? get latest => _history.isEmpty ? null : _history.last;

  /// The entry before the latest — what a change note compares against.
  BmiHistoryEntry? get previous =>
      _history.length < 2 ? null : _history[_history.length - 2];

  bool get hasSavedMeasurements => _history.isNotEmpty;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final p = await SharedPreferences.getInstance();
    for (final row in p.getStringList(_kHistory) ?? const <String>[]) {
      final e = BmiHistoryEntry.decode(row);
      if (e != null) _history.add(e);
    }
    _history.sort((a, b) => a.at.compareTo(b.at));

    final h = p.getString(_kHeightUnit);
    _heightUnit = BmiHeightUnit.values
        .firstWhere((u) => u.name == h, orElse: () => BmiHeightUnit.cm);
    final w = p.getString(_kWeightUnit);
    _weightUnit = BmiWeightUnit.values
        .firstWhere((u) => u.name == w, orElse: () => BmiWeightUnit.kg);

    _onChecklist = p.getBool(_kOnChecklist) ?? false;
    _heightM = p.getDouble(_kHeight);
    notifyListeners();
  }

  /// Remember her height for next time (T2, 2026-09-28). Fire and forget.
  Future<void> rememberHeight(double metres) async {
    if (_heightM == metres) return;
    _heightM = metres;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setDouble(_kHeight, metres);
    } catch (_) {/* local-first: next time she types it again */}
  }

  @visibleForTesting
  void resetForTest() {
    _history.clear();
    _heightUnit = BmiHeightUnit.cm;
    _weightUnit = BmiWeightUnit.kg;
    _onChecklist = false;
    _heightM = null;
    _loaded = false;
  }

  Future<void> setUnits(
      {BmiHeightUnit? height, BmiWeightUnit? weight}) async {
    // ⚠️ THE UNIT IS A DISPLAY CHOICE AND THE STORED VALUE IS METRES AND
    // KILOGRAMS. Switching cm to feet must never alter the measurement — the
    // history would silently drift each time she toggled.
    if (height != null) _heightUnit = height;
    if (weight != null) _weightUnit = weight;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kHeightUnit, _heightUnit.name);
    await p.setString(_kWeightUnit, _weightUnit.name);
  }

  Future<void> save(BmiCalculation calc) async {
    _history.add(BmiHistoryEntry(
      at: DateTime.now(),
      metres: calc.metres,
      kilograms: calc.kilograms,
      bmi: calc.bmi,
    ));
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kHistory, [for (final e in _history) e.encode()]);
  }

  /// ⚠️ ADDS THE MEASUREMENT TO HER SNAPSHOT, AND DOES NOT TICK A MEDICAL ITEM.
  ///
  /// §17: "do not automatically treat the BMI category as a completed medical
  /// task." Knowing a number is not the same as having discussed it, and the
  /// checklist's `body` item is about a conversation.
  Future<void> setOnChecklist(bool value) async {
    _onChecklist = value;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kOnChecklist, value);
  }

  /// Take one measurement out of her history (tool rebuild, 2026-09-27).
  ///
  /// ⚠️ ADDITIVE. A saved measurement could never be removed, so a typo (a
  /// weight in pounds saved as kilograms) stayed in her history and fed the
  /// change note for ever. The screen offers Undo, which is [restoreEntry].
  Future<void> removeEntry(BmiHistoryEntry e) async {
    if (!_history.remove(e)) return;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kHistory, [for (final e in _history) e.encode()]);
  }

  /// Put a removed measurement back, in date order.
  Future<void> restoreEntry(BmiHistoryEntry e) async {
    if (_history.contains(e)) return;
    _history
      ..add(e)
      ..sort((a, b) => a.at.compareTo(b.at));
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kHistory, [for (final e in _history) e.encode()]);
  }

  Future<void> clearHistory() async {
    _history.clear();
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.remove(_kHistory);
  }
}
