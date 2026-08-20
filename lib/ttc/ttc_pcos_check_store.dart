// =============================================================================
//  TtcPcosCheckStore — answers, resume, and what the app already knows
// -----------------------------------------------------------------------------
//  Singleton `ChangeNotifier`, private constructor, lazy load,
//  `shared_preferences`. The house pattern — see CLAUDE.md. The brief asked for
//  Riverpod and GoRouter; both are on this repo's do-not-propose list with
//  stated reasons, so the separation the brief actually wanted (content, rules,
//  UI and persistence in different files) is honoured with the stack that is
//  already here.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE PART THAT MAKES THIS A COMPANION RATHER THAN A QUIZ
//  ---------------------------------------------------------------------------
//
//  ParentVeda already knows her cycles. `CycleStore` holds every period start
//  she has logged, the completed cycle lengths derived from them, and any
//  positive LH strips per cycle. Asking her to type all of that again is what
//  makes an internet symptom quiz feel like an internet symptom quiz.
//
//  So `prefill()` answers the cycle questions FROM HER OWN DATA and the flow
//  skips them, showing what it concluded and letting her correct it. Two
//  questions removed from a fifteen-question check, and — much more
//  importantly — the answers are measured rather than remembered.
//
//  ⚠️ IT ONLY SPEAKS WHEN IT HAS ENOUGH TO BE RIGHT. Two completed cycles is
//  the floor, and it is deliberately conservative: one cycle is a single
//  interval and says nothing about regularity, and a tool that confidently
//  described a pattern from one data point would be doing the thing this whole
//  feature exists to avoid.
//
//  ⚠️ AND SHE CAN ALWAYS OVERRIDE IT. A derived answer is a suggestion with
//  provenance, never a fact she is stuck with. Her own sense of her cycle
//  outranks our arithmetic — that is the truth hierarchy the rest of the app
//  already follows, where "her own observation" sits above "ParentVeda's
//  calculation".
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cycle_store.dart';
import 'ttc_pcos_check_data.dart';
import 'ttc_pcos_check_rules.dart';

/// How an answer got there. Drives the "we filled this in" treatment and
/// nothing else.
enum PcosAnswerSource { hers, derived }

class TtcPcosCheckStore extends ChangeNotifier {
  TtcPcosCheckStore._();
  static final TtcPcosCheckStore instance = TtcPcosCheckStore._();

  static const _kAnswers = 'ttc_pcos_answers';
  static const _kDone = 'ttc_pcos_completed_at';

  final Map<String, String> _answers = {};
  final Map<String, PcosAnswerSource> _sources = {};
  DateTime? _completedAt;
  bool _loaded = false;

  Map<String, String> get answers => Map.unmodifiable(_answers);
  DateTime? get completedAt => _completedAt;
  bool get hasStarted => _answers.isNotEmpty;
  bool get hasCompleted => _completedAt != null;

  PcosAnswerSource sourceOf(String qid) =>
      _sources[qid] ?? PcosAnswerSource.hers;

  String? answerFor(String qid) => _answers[qid];

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final p = await SharedPreferences.getInstance();
    for (final row in p.getStringList(_kAnswers) ?? const <String>[]) {
      final i = row.indexOf(':');
      if (i <= 0) continue;
      _answers[row.substring(0, i)] = row.substring(i + 1);
    }
    final done = p.getString(_kDone);
    if (done != null) _completedAt = DateTime.tryParse(done);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  //  Answering
  // ---------------------------------------------------------------------------

  Future<void> answer(String qid, String optionId) async {
    _answers[qid] = optionId;
    // Touching a derived answer makes it hers. Provenance follows the last
    // person to set it, which is the only reading that stays true.
    _sources[qid] = PcosAnswerSource.hers;
    notifyListeners();
    await _persist();
  }

  Future<void> complete() async {
    _completedAt = DateTime.now();
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kDone, _completedAt!.toIso8601String());
  }

  /// Starts again. Keeps nothing — a half-remembered previous answer showing up
  /// in a fresh check is worse than typing it again.
  Future<void> reset() async {
    _answers.clear();
    _sources.clear();
    _completedAt = null;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.remove(_kAnswers);
    await p.remove(_kDone);
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
        _kAnswers, [for (final e in _answers.entries) '${e.key}:${e.value}']);
  }

  // ---------------------------------------------------------------------------
  //  What the app already knows
  // ---------------------------------------------------------------------------

  /// Minimum completed cycles before we will describe a pattern. See the header.
  static const int minCyclesToDerive = 2;

  /// A read-only view of what her logged cycles say, or null when there is not
  /// enough to say anything honest.
  PcosCycleFacts? get cycleFacts {
    final cycles = CycleStore.instance.cycleLengths;
    if (cycles.length < minCyclesToDerive) return null;

    final sorted = [...cycles]..sort();
    final shortest = sorted.first;
    final longest = sorted.last;
    final spread = longest - shortest;

    return PcosCycleFacts(
      count: cycles.length,
      shortest: shortest,
      longest: longest,
      spread: spread,
      median: sorted[sorted.length ~/ 2],
    );
  }

  /// Fills the cycle questions from her own logs.
  ///
  /// ⚠️ ONLY FILLS WHAT IT CAN DEFEND, and only where she has not already
  /// answered. It sets regularity and typical length — both directly derivable
  /// — and deliberately does NOT set `q_gap`, because a three-month gap in the
  /// data could equally be three months she did not open the app.
  void prefill() {
    final f = cycleFacts;
    if (f == null) return;

    void put(String qid, String optionId) {
      if (_answers.containsKey(qid)) return;
      _answers[qid] = optionId;
      _sources[qid] = PcosAnswerSource.derived;
    }

    // Regularity from the spread between her shortest and longest cycle.
    // Thresholds live in the rules file's spirit but are cycle-arithmetic
    // rather than clinical judgement, so they sit here beside the data.
    put(
        'q_predictable',
        f.spread <= 3
            ? 'very_regular'
            : f.spread <= 7
                ? 'usually'
                : f.spread <= 14
                    ? 'sometimes'
                    : f.spread <= 21
                        ? 'often'
                        : 'very_unpredictable');

    put(
        'q_length',
        f.spread > 14
            ? 'varies'
            : f.median < 21
                ? 'short'
                : f.median <= 35
                    ? 'normal'
                    : f.median <= 45
                        ? 'long'
                        : 'very_long');

    notifyListeners();
  }

  // ---------------------------------------------------------------------------

  /// The questions actually shown, after dependencies and prefill.
  List<PcosCheckerQuestion> get visibleQuestions => [
        for (final q in kPcosQuestions)
          if (_isVisible(q)) q,
      ];

  bool _isVisible(PcosCheckerQuestion q) {
    final dep = q.dependsOn;
    if (dep == null) return true;
    final i = dep.indexOf(':');
    return _answers[dep.substring(0, i)] == dep.substring(i + 1);
  }

  /// The first unanswered visible question, or null when the check is done.
  ///
  /// ⚠️ RESUME LANDS HERE RATHER THAN AT THE START. Someone who left after nine
  /// questions and comes back to question one will not finish.
  PcosCheckerQuestion? get nextUnanswered {
    for (final q in visibleQuestions) {
      if (!_answers.containsKey(q.id)) return q;
    }
    return null;
  }

  /// ⚠️ NOT A PERCENTAGE SHOWN AS A RESULT — this is flow progress only, and
  /// the result screen must never render a number of any kind. See the rules
  /// file.
  double get progress {
    final visible = visibleQuestions;
    if (visible.isEmpty) return 0;
    final done = visible.where((q) => _answers.containsKey(q.id)).length;
    return done / visible.length;
  }

  PcosInterpretation get result => interpretPcos(_answers);
}

/// What her logged cycles say, derived rather than asked.
@immutable
class PcosCycleFacts {
  const PcosCycleFacts({
    required this.count,
    required this.shortest,
    required this.longest,
    required this.spread,
    required this.median,
  });

  final int count;
  final int shortest;
  final int longest;

  /// Longest minus shortest. The single most useful number for regularity, and
  /// the one an average hides completely — 28 and 44 average to a reassuring 36.
  final int spread;

  final int median;
}
