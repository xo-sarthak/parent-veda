// =============================================================================
//  Contraction Tracker
// -----------------------------------------------------------------------------
//  A calm, non-alarmist decision-support tool: effortless tap-to-time, automatic
//  pattern insights (never a diagnosis), and a doctor-ready summary. No emergency
//  language, predictions, risk scores or red warning screens. Per the spec.
//
//  ⚠️ ONE PARENTVEDA (2026-09-30, the pregnancy restyle). Surfaces only; the
//  two-layer assessment engine below is untouched. White cards with the
//  hairline instead of tinted blocks, the one ink for the big start/stop
//  button and every other control, neutral tags, serif titles. The timer keeps
//  its app bar title: it is an instrument whose body changes by phase (home,
//  active, rest), so the name stays put above all three.
//
//  ⚠️ RED STAYS WHERE IT MEANS "NOW". The emergency and preterm readings keep
//  their red and orange (icon, title and a red edge on the card), and the
//  safety check's shield still turns red in the app bar during an emergency.
//  Red is for the urgent and the irreversible, not a brand colour, so nothing
//  else on the page is coloured. Every clinical line is the same line in the
//  same place.
// =============================================================================

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/tools_store.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../doors/pv_list_row.dart' show PvMarkWell;
import '../pregnancy/preg_chrome.dart';
import '../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;

// Kept for revert: the phase colours before the one ink.
// const Color _activeColor = Color(0xFFE8833A); // orange - active contraction
// const Color _restColor = Color(0xFF3B82C4); // blue - rest interval

/// The urgent colours. Only the emergency and preterm readings use them.
const Color _kUrgentRed = Color(0xFFC62828);
const Color _kUrgentOrange = Color(0xFFD9822B);

/// The Tools tab's "Get ready" hue, so the marks here match the row she tapped.
const double _kContractionHue = 28;

enum _Phase { home, active, rest }

// ---- shared pieces (private: the stages stay code-isolated) -----------------

/// The page title on a pushed page, announced as a heading.
Widget _pageTitle(String text) =>
    Semantics(header: true, child: Text(text, style: pregPageTitleStyle()));

/// A card's own title: the serif, smaller than a section heading.
TextStyle _cardTitleStyle() => pvFraunces(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.3,
    color: pvStorePalette.ink1);

/// A tag: a neutral pill with grey words (a tint is allowed on a tag).
Widget _tag(String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: pvStorePalette.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: pvManrope(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: pvStorePalette.ink2)),
    );

/// A column label inside a table (a group label, allowed inside a card).
TextStyle _columnStyle() => pvManrope(
    fontSize: 11.5, fontWeight: FontWeight.w700, color: pvStorePalette.ink3);

TextStyle _cellStyle() => pvManrope(fontSize: 13.5, color: pvStorePalette.ink1);

class ContractionTrackerScreen extends StatefulWidget {
  const ContractionTrackerScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<ContractionTrackerScreen> createState() =>
      _ContractionTrackerScreenState();
}

class _ContractionTrackerScreenState extends State<ContractionTrackerScreen> {
  _Phase _phase = _Phase.home;
  final List<Contraction> _current = [];
  Timer? _tick;
  String? _sessionId;
  DateTime? _activeStart;
  DateTime? _lastStart;
  DateTime? _lastEnd;
  int _pendingInterval = 0;

  /// The mother's answer to the gentle labour prompt this session ('yes'/'no').
  String? _laborResponse;
  bool _askedLabor = false;

  /// Layer-2 medical symptoms (defaults = all clear).
  ContractionSymptoms _symptoms = const ContractionSymptoms();

  // ---- Voice guidance (Section 11) ------------------------------------------
  //  Speaks the tracker's current interpretation aloud in a neutral voice so a
  //  labouring mother needn't stare at the screen. Own FlutterTts (pitch 1.0)
  //  rather than the baby voice, mirroring the setup in baby_voice_service.dart.
  //  Default state is ON; a speaker toggle in the app bar mutes it.
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;
  // Voice guidance is ON by default (so `_voiceMuted` starts false).
  // TODO(persist): this screen keeps no simple prefs (only sessions via
  //  ToolsStore), so the mute choice is in-memory for the session only.
  bool _voiceMuted = false;
  // The last interpretation we spoke - so we never repeat an unchanged sentence.
  String? _lastSpoken;

  @override
  void initState() {
    super.initState();
    ToolsStore.instance.init();
    _initTts();
  }

  @override
  void dispose() {
    _tick?.cancel();
    // Stop any in-flight speech as the screen goes away.
    unawaited(_tts.stop());
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.42);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      try {
        await _tts.setLanguage(
            widget.controller.language.isHinglish ? 'hi-IN' : 'en-IN');
      } catch (_) {
        await _tts.setLanguage('en-IN');
      }
    } catch (_) {
      // TTS is an enhancement - never fatal.
    }
    _ttsReady = true;
  }

  /// Derive the current interpretation and speak it - but ONLY when it differs
  /// from the last sentence we spoke (so a steady reading is never repeated).
  Future<void> _speakInterpretation() async {
    if (_voiceMuted) return;
    final level = assessContractions(
        _current, widget.controller.currentWeek, _symptoms);
    final key = _levelKey(level);
    final text = '${_s.assessTitle(key)}. ${_s.assessSummary(key)}';
    if (text.trim().isEmpty || text == _lastSpoken) return;
    _lastSpoken = text;
    if (!_ttsReady) await _initTts();
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // Ignore - speech is best-effort.
    }
  }

  void _toggleVoice() {
    setState(() => _voiceMuted = !_voiceMuted);
    if (_voiceMuted) {
      unawaited(_tts.stop());
    } else {
      // On unmute, forget the last line so the current reading is spoken now.
      _lastSpoken = null;
      _speakInterpretation();
    }
  }

  S get _s => S(widget.controller.language);

  void _ensureTick() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _startContraction() {
    final now = DateTime.now();
    _sessionId ??= now.microsecondsSinceEpoch.toString();
    _pendingInterval =
        _lastStart == null ? 0 : now.difference(_lastStart!).inSeconds;
    _activeStart = now;
    HapticFeedback.lightImpact();
    setState(() => _phase = _Phase.active);
    _ensureTick();
  }

  void _endContraction() {
    final now = DateTime.now();
    final start = _activeStart!;
    _current.add(Contraction(
      startIso: start.toIso8601String(),
      endIso: now.toIso8601String(),
      durationSeconds: now.difference(start).inSeconds,
      intervalSeconds: _pendingInterval,
    ));
    _lastStart = start;
    _lastEnd = now;
    HapticFeedback.lightImpact();
    setState(() => _phase = _Phase.rest);
    _ensureTick();
    _save();
    // A new contraction may have shifted the interpretation - speak it if so.
    _speakInterpretation();
    _maybePromptLabor();
  }

  Future<void> _save() async {
    if (_current.isEmpty || _sessionId == null) return;
    final first = DateTime.tryParse(_current.first.startIso) ?? DateTime.now();
    await ToolsStore.instance.saveContractionSession(ContractionSession(
      id: _sessionId!,
      dateIso: first.toIso8601String(),
      contractions: List.of(_current),
      laborResponse: _laborResponse,
    ));
  }

  /// Once per session, if the pattern looks like active labour, gently ask the
  /// mother how she feels and remember her answer.
  void _maybePromptLabor() {
    if (_askedLabor) return;
    // Don't stack the gentle "feels like labour?" ask on top of an emergency.
    if (_symptoms.isEmergency) return;
    if (classifyContractions(_current) != LaborState.activeLabor) return;
    _askedLabor = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showLaborPrompt();
    });
  }

  Future<void> _showLaborPrompt() async {
    final s = _s;
    final p = pvStorePalette;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(s.laborPromptTitle,
              style: pvFraunces(
                  fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.laborPromptBody,
                    style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1)),
                const SizedBox(height: 12),
                Text(s.consultProvider,
                    style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
              ]),
          actions: [
            TextButton(
                style: TextButton.styleFrom(foregroundColor: p.ink1),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _setLabor('no');
                },
                child: Text(s.laborNo)),
            FilledButton(
                style: pregFilledStyle(),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _setLabor('yes');
                },
                child: Text(s.laborYes)),
          ],
        );
      },
    );
  }

  void _setLabor(String response) {
    setState(() => _laborResponse = response);
    _save();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_s.laborSavedNote)));
    }
  }

  Future<void> _endSession() async {
    await _save();
    _tick?.cancel();
    if (mounted) Navigator.of(context).pop();
  }

  // ---- stats ----------------------------------------------------------------

  double get _avgDuration {
    if (_current.isEmpty) return 0;
    final sum = _current.fold<int>(0, (a, c) => a + c.durationSeconds);
    return sum / _current.length;
  }

  double get _avgIntervalSec {
    final intervals =
        _current.where((c) => c.intervalSeconds > 0).map((c) => c.intervalSeconds);
    if (intervals.isEmpty) return 0;
    return intervals.reduce((a, b) => a + b) / intervals.length;
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) => _save(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.contractionToolTitle),
          actions: [
            IconButton(
              tooltip: widget.controller.language.isHinglish
                  ? (_voiceMuted ? 'Awaaz on karein' : 'Awaaz band karein')
                  : (_voiceMuted ? 'Turn voice guidance on' : 'Mute voice guidance'),
              icon: Icon(_voiceMuted
                  ? Icons.volume_off_rounded
                  : Icons.volume_up_rounded),
              onPressed: _toggleVoice,
            ),
            // ⚠️ KEPT, THOUGH THE SAFETY CARD OPENS THE SAME SHEET: during a
            // contraction (the active phase) this is the only way to it, and
            // it turns red in an emergency. A clinical entry point is not
            // trimmed for tidiness.
            IconButton(
              tooltip: s.safetyCheckTitle,
              icon: Icon(
                Icons.health_and_safety_outlined,
                color: _symptoms.isEmergency ? _kUrgentRed : null,
              ),
              onPressed: _showSafetySheet,
            ),
            IconButton(
              tooltip: s.historyLabel,
              icon: const Icon(Icons.history_rounded),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    _ContractionHistoryScreen(controller: widget.controller),
              )),
            ),
          ],
        ),
        body: SafeArea(
          child: switch (_phase) {
            _Phase.home => _homeView(context),
            _Phase.active => _activeView(context),
            _Phase.rest => _restView(context),
          },
        ),
      ),
    );
  }

  // ---- Home -----------------------------------------------------------------

  Widget _homeView(BuildContext context) {
    final s = _s;
    final p = pvStorePalette;
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
          children: [
            if (_symptoms.isEmergency) ...[
              _assessBanner(s),
              const SizedBox(height: 16),
            ],
            // What contractions are + true vs false (Braxton Hicks) + how to time.
            _aboutCard(s),
            const SizedBox(height: 12),
            // Clear "we're a timer, not a medical app" disclaimer.
            _disclaimerCard(s),
            const SizedBox(height: 12),
            _safetyCard(s),
            const SizedBox(height: 30),
            // Kept for revert: const Text('🤍', style: TextStyle(fontSize: 56)).
            // No decorative emoji; the drawn mark in the tool's tint.
            Center(
              child: PvMarkWell(
                  p: p,
                  hue: _kContractionHue,
                  size: 64,
                  mark: IntentMark.cuppedHands),
            ),
            const SizedBox(height: 16),
            Text(s.contractionEmpty,
                textAlign: TextAlign.center,
                style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink2)),
          ],
        ),
      ),
      _bottomButton(context, s.contractionStartedCta, _startContraction),
    ]);
  }

  // ---- Active ---------------------------------------------------------------

  Widget _activeView(BuildContext context) {
    final s = _s;
    final p = pvStorePalette;
    final elapsed =
        _activeStart == null ? 0 : DateTime.now().difference(_activeStart!).inSeconds;
    return Column(children: [
      Expanded(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(s.currentContraction, style: _cardTitleStyle()),
            const SizedBox(height: 4),
            Text(s.contractionNumber(_current.length + 1),
                style: pvManrope(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink3)),
            const SizedBox(height: 22),
            _timerCircle(s.formatStopwatch(elapsed), active: true),
            const SizedBox(height: 24),
            Text(s.tapWhenEnds,
                style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2)),
          ]),
        ),
      ),
      _bottomButton(context, s.contractionEndedCta, _endContraction),
    ]);
  }

  // ---- Rest -----------------------------------------------------------------

  Widget _restView(BuildContext context) {
    final s = _s;
    final p = pvStorePalette;
    final rest =
        _lastEnd == null ? 0 : DateTime.now().difference(_lastEnd!).inSeconds;
    final last = _current.isNotEmpty ? _current.last : null;
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
          children: [
            _assessBanner(s),
            const SizedBox(height: 12),
            _safetyCard(s),
            const SizedBox(height: 22),
            Center(child: Text(s.timeSinceLast, style: _cardTitleStyle())),
            const SizedBox(height: 14),
            Center(child: _timerCircle(s.formatStopwatch(rest), active: false)),
            const SizedBox(height: 20),
            Row(children: [
              if (last != null)
                Expanded(
                    child: _stat(s.lastContractionLabel,
                        s.minSecLabel(last.durationSeconds))),
              Expanded(
                  child: _stat(
                      s.avgDurationLabel, s.minSecLabel(_avgDuration.round()))),
              Expanded(
                  child: _stat(s.avgIntervalLabel,
                      s.minSecLabel(_avgIntervalSec.round()))),
            ]),
            const SizedBox(height: 22),
            // The session, building live in front of the mother.
            _sessionList(s),
            const SizedBox(height: 16),
            if (_current.length >= 3)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPvInk,
                  side: const BorderSide(color: kPvLine, width: 1.5),
                  shape: const StadiumBorder(),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _SummaryScreen(
                    controller: widget.controller,
                    contractions: List.of(_current),
                  ),
                )),
                icon: const Icon(Icons.insights_rounded, size: 18),
                label: Text(s.viewSummaryCta,
                    style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            const SizedBox(height: 10),
            TextButton(
                style: TextButton.styleFrom(foregroundColor: p.ink2),
                onPressed: _endSession,
                child: Text(s.endSessionCta,
                    style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700))),
          ],
        ),
      ),
      _bottomButton(context, s.contractionStartedCta, _startContraction),
    ]);
  }

  /// A reading's glyph and colour. The emergency and preterm readings keep
  /// their red and orange; every calm reading draws in the ink. Kept for
  /// revert: activeLabor was _activeColor (orange), laborLikely 0xFFE6A817,
  /// earlyLabor and noPattern _restColor (blue), insufficient neutral500.
  ({Color color, IconData icon}) _levelStyle(AssessLevel l) {
    final p = pvStorePalette;
    switch (l) {
      case AssessLevel.emergency:
        return (color: _kUrgentRed, icon: Icons.warning_amber_rounded);
      case AssessLevel.preterm:
        return (color: _kUrgentOrange, icon: Icons.priority_high_rounded);
      case AssessLevel.activeLabor:
        return (color: p.ink1, icon: Icons.favorite_border_rounded);
      case AssessLevel.laborLikely:
        return (color: p.ink1, icon: Icons.trending_up_rounded);
      case AssessLevel.earlyLabor:
        return (color: p.ink1, icon: Icons.water_drop_outlined);
      case AssessLevel.noPattern:
        return (color: p.ink2, icon: Icons.timelapse_rounded);
      case AssessLevel.insufficient:
        return (color: p.ink3, icon: Icons.timelapse_rounded);
    }
  }

  /// The final assessment banner (Layer 2 override applied over Layer 1).
  ///
  /// Kept for revert: the whole banner sat on its level's colour at 10-14%
  /// with a matching edge. A white card now; an urgent reading keeps a red (or
  /// orange) edge, glyph and title, so it still stands out from a calm one.
  Widget _assessBanner(S s) {
    final p = pvStorePalette;
    final level = assessContractions(
        _current, widget.controller.currentWeek, _symptoms);
    final style = _levelStyle(level);
    final key = _levelKey(level);
    final urgent =
        level == AssessLevel.emergency || level == AssessLevel.preterm;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: urgent ? style.color : kPvLine, width: urgent ? 1.5 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(style.icon, color: style.color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(s.assessTitle(key),
                style: pvManrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: urgent ? style.color : p.ink1)),
          ),
          if (_laborResponse != null) _tag(s.feltInLabour(_laborResponse == 'yes')),
        ]),
        const SizedBox(height: 6),
        Text(s.assessSummary(key),
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1)),
        // ALWAYS point to the doctor - even on a calm "no pattern" reading, since
        // timing can't rule labour in or out. (Emergency/preterm already carry
        // their own urgent contact message, so skip the softer line there.)
        if (!urgent) ...[
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.local_hospital_outlined, size: 15, color: p.ink3),
            const SizedBox(width: 6),
            Expanded(
              child: Text(s.ctAlwaysConsult,
                  style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
            ),
          ]),
        ],
      ]),
    );
  }

  /// "Understanding contractions" - what they are, true vs false (Braxton
  /// Hicks), and how to time one. Helps a first-time user know what this is.
  /// Kept for revert: a grey block (surfaceContainer) with a blue info glyph.
  Widget _aboutCard(S s) => SizedBox(
        width: double.infinity,
        child: PregCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.ctAboutTitle, style: _cardTitleStyle()),
            const SizedBox(height: 8),
            Text(s.ctAboutBody,
                style: pvManrope(
                    fontSize: 13.5, height: 1.5, color: pvStorePalette.ink2)),
          ]),
        ),
      );

  /// The "this is a timer, not a diagnosis / not a medical app" disclaimer -
  /// kept clearly visible so the tool never reads as medical advice.
  /// Kept for revert: an amber block (0xFFFFF6E9, edge 0x33D9822B) with the
  /// title in 0xFFB36B12. A white card, the same two lines, still on the page.
  Widget _disclaimerCard(S s) {
    final p = pvStorePalette;
    return PregCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.health_and_safety_outlined, size: 20, color: p.ink1),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.ctDisclaimerTitle,
                style: pvManrope(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                    color: p.ink1)),
            const SizedBox(height: 4),
            Text(s.ctDisclaimerBody,
                style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
          ]),
        ),
      ]),
    );
  }

  /// The Layer-2 symptom "safety check" entry - shows current state + Update.
  /// Kept for revert: a grey block (surfaceContainer); the all-clear shield was
  /// tertiary500. The shield keeps red (emergency) and orange (reported).
  Widget _safetyCard(S s) {
    final p = pvStorePalette;
    final reported = _symptoms.anyReported;
    final emergency = _symptoms.isEmergency;
    final color = emergency
        ? _kUrgentRed
        : (reported ? _kUrgentOrange : p.ink2);
    return PregCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(children: [
        Icon(Icons.health_and_safety_outlined, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.safetyCheckTitle,
                style: pvManrope(
                    fontSize: 14.5, fontWeight: FontWeight.w800, color: p.ink1)),
            const SizedBox(height: 2),
            Text(reported ? s.safetyReported : s.safetyAllClear,
                style: pvManrope(fontSize: 12.5, color: p.ink2)),
          ]),
        ),
        TextButton(
            style: TextButton.styleFrom(foregroundColor: kPvInk),
            onPressed: _showSafetySheet,
            child: Text(s.safetyUpdate,
                style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800))),
      ]),
    );
  }

  Future<void> _showSafetySheet() async {
    final s = _s;
    final p = pvStorePalette;
    var sym = _symptoms;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          Widget q(String title, List<(String, String)> opts, String current,
              void Function(String) onPick) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink1)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    // Kept for revert: a Material ChoiceChip. The one pill:
                    // white with the hairline, the ink when chosen.
                    for (final (label, value) in opts)
                      _ChoicePill(
                        label: label,
                        selected: current == value,
                        onTap: () => setSheet(() => onPick(value)),
                      ),
                  ]),
                  const SizedBox(height: 18),
                ]);
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 4, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.safetyCheckTitle,
                        style: pvFraunces(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                            color: p.ink1)),
                    const SizedBox(height: 6),
                    Text(s.safetyCheckSub,
                        style: pvManrope(
                            fontSize: 12.5, height: 1.45, color: p.ink2)),
                    const SizedBox(height: 18),
                    q(s.qWaterBroken, [
                      (s.optNo, 'no'),
                      (s.optYes, 'yes'),
                      (s.optNotSure, 'unsure'),
                    ], sym.waterBroken, (v) => sym = sym.copyWith(waterBroken: v)),
                    q(s.qBleeding, [
                      (s.bleedNone, 'none'),
                      (s.bleedLight, 'light'),
                      (s.bleedHeavy, 'heavy'),
                    ], sym.bleeding, (v) => sym = sym.copyWith(bleeding: v)),
                    q(s.qMovementReduced, [
                      (s.optNo, 'no'),
                      (s.optYes, 'yes'),
                      (s.optNotSure, 'unsure'),
                    ], sym.movementReduced,
                        (v) => sym = sym.copyWith(movementReduced: v)),
                    q(s.qSeverePain, [
                      (s.optNo, 'no'),
                      (s.optYes, 'yes'),
                    ], sym.severePain, (v) => sym = sym.copyWith(severePain: v)),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: pregFilledStyle().copyWith(
                          minimumSize: const WidgetStatePropertyAll(
                              Size.fromHeight(50)),
                        ),
                        onPressed: () {
                          setState(() => _symptoms = sym);
                          Navigator.of(ctx).pop();
                          // Symptoms can override the reading (e.g. emergency).
                          _speakInterpretation();
                        },
                        child: Text(s.doneWord,
                            style: pvManrope(
                                fontSize: 14.5, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ]),
            ),
          );
        });
      },
    );
  }

  // Kept for revert: `_laborChip` drew "felt like labour" as an orange (yes)
  // or blue (no) pill at 15%. It is the neutral `_tag` now.

  /// The contractions logged so far this session, newest first - so the record
  /// grows in front of the mother without opening the summary or history.
  Widget _sessionList(S s) {
    if (_current.isEmpty) return const SizedBox.shrink();
    final p = pvStorePalette;
    final items = _current.reversed.toList();
    return PregCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(s.thisSessionContractions, style: _cardTitleStyle())),
          // Kept for revert: the count in _activeColor (orange).
          Text('${_current.length}',
              style: pvManrope(
                  fontSize: 15, fontWeight: FontWeight.w800, color: p.ink1)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const SizedBox(width: 28),
          Expanded(child: Text(s.timeColumn, style: _columnStyle())),
          Expanded(child: Text(s.durationColumn, style: _columnStyle())),
          Expanded(child: Text(s.intervalColumn, style: _columnStyle())),
        ]),
        const Divider(height: 14, thickness: 1, color: kPvLine),
        for (int i = 0; i < items.length; i++)
          _sessionRow(s, items[i], _current.length - i),
      ]),
    );
  }

  Widget _sessionRow(S s, Contraction c, int number) {
    final p = pvStorePalette;
    final start = DateTime.tryParse(c.startIso) ?? DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        SizedBox(
            width: 28,
            child: Text('$number',
                style: pvManrope(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink3))),
        Expanded(child: Text(s.formatClock(start), style: _cellStyle())),
        Expanded(
            child: Text(s.minSecLabel(c.durationSeconds), style: _cellStyle())),
        Expanded(
            child: Text(
                c.intervalSeconds == 0 ? '-' : s.minSecLabel(c.intervalSeconds),
                style: _cellStyle())),
      ]),
    );
  }

  // ---- shared bits ----------------------------------------------------------

  /// The timer face. Kept for revert: an orange (active) or blue (rest) ring
  /// on its own colour at 12%, the numbers in that colour. The ink ring while
  /// a contraction runs, a grey one while she rests; white inside.
  Widget _timerCircle(String label, {required bool active}) {
    final p = pvStorePalette;
    return Container(
      width: 230,
      height: 230,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: active ? kPvInk : p.ink3, width: 4),
      ),
      child: Text(label,
          style: pvManrope(
              fontSize: 52, fontWeight: FontWeight.w800, color: p.ink1)),
    );
  }

  Widget _stat(String label, String value) {
    final p = pvStorePalette;
    return Column(children: [
      Text(value,
          style: pvManrope(
              fontSize: 20, fontWeight: FontWeight.w800, color: p.ink1)),
      const SizedBox(height: 2),
      Text(label,
          textAlign: TextAlign.center,
          style: pvManrope(fontSize: 11.5, height: 1.3, color: p.ink3)),
    ]);
  }

  /// The big button. Kept for revert: it was filled with _activeColor (orange)
  /// on every phase. The one ink: it is the thing she presses.
  Widget _bottomButton(BuildContext context, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: FilledButton(
          style: pregFilledStyle(),
          onPressed: onTap,
          child: Text(label,
              style: pvManrope(
                  fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
        ),
      ),
    );
  }
}

/// One answer in the safety check: white with the hairline, the ink when
/// chosen (the trying-to-conceive tool pill, redrawn here).
class _ChoicePill extends StatelessWidget {
  const _ChoicePill(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? kPvInk : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? kPvInk : kPvLine, width: 1.5),
            ),
            child: Text(label,
                style: pvManrope(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? Colors.white : pvStorePalette.ink1)),
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
//  Pattern insight (shared)
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
//  Two-layer assessment engine (NOT a diagnosis - see the product spec)
//   Layer 1 - classify the pattern from the contraction data alone.
//   Layer 2 - a medical-symptom override that takes priority over Layer 1.
// ---------------------------------------------------------------------------

enum LaborState { insufficient, noPattern, earlyLabor, laborLikely, activeLabor }

enum AssessLevel {
  insufficient,
  noPattern,
  earlyLabor,
  laborLikely,
  activeLabor,
  preterm,
  emergency,
}

/// The mother's reported symptoms (Layer 2 inputs). Defaults are the "all-clear"
/// values; gestational age comes from her profile, not here.
class ContractionSymptoms {
  const ContractionSymptoms({
    this.waterBroken = 'no', // no | yes | unsure
    this.bleeding = 'none', // none | light | heavy
    this.movementReduced = 'no', // no | yes | unsure
    this.severePain = 'no', // no | yes
  });
  final String waterBroken;
  final String bleeding;
  final String movementReduced;
  final String severePain;

  bool get isEmergency =>
      waterBroken == 'yes' ||
      bleeding == 'heavy' ||
      movementReduced == 'yes' ||
      severePain == 'yes';

  bool get anyReported =>
      waterBroken != 'no' ||
      bleeding != 'none' ||
      movementReduced != 'no' ||
      severePain != 'no';

  ContractionSymptoms copyWith({
    String? waterBroken,
    String? bleeding,
    String? movementReduced,
    String? severePain,
  }) =>
      ContractionSymptoms(
        waterBroken: waterBroken ?? this.waterBroken,
        bleeding: bleeding ?? this.bleeding,
        movementReduced: movementReduced ?? this.movementReduced,
        severePain: severePain ?? this.severePain,
      );
}

double _mean(Iterable<num> xs) {
  if (xs.isEmpty) return 0;
  // Sum with a loop (not reduce) - reduce on a List<int> would reject the
  // widened num closure at runtime ("(num,num)=>num is not (int,int)=>int").
  num sum = 0;
  for (final x in xs) {
    sum += x;
  }
  return sum / xs.length;
}

/// Interval regularity 0..1 (1 = perfectly even), from the coefficient of
/// variation. Needs at least two intervals.
double _regularity(List<int> intervals) {
  if (intervals.length < 2) return 0;
  final m = _mean(intervals);
  if (m <= 0) return 0;
  final variance = _mean(intervals.map((i) => (i - m) * (i - m)));
  final cv = variance <= 0 ? 0.0 : math.sqrt(variance) / m;
  return (1 - cv).clamp(0.0, 1.0);
}

bool _intervalsDecreasing(List<int> intervals) {
  if (intervals.length < 4) return false;
  final half = intervals.length ~/ 2;
  return _mean(intervals.sublist(half)) < _mean(intervals.sublist(0, half)) * 0.95;
}

bool _durationsIncreasing(List<int> durations) {
  if (durations.length < 4) return false;
  final half = durations.length ~/ 2;
  return _mean(durations.sublist(half)) > _mean(durations.sublist(0, half)) * 1.05;
}

int _trackingSeconds(List<Contraction> cs) {
  if (cs.isEmpty) return 0;
  final start = DateTime.tryParse(cs.first.startIso);
  final end = DateTime.tryParse(cs.last.endIso);
  if (start == null || end == null) return 0;
  return end.difference(start).inSeconds;
}

/// Layer 1 - classify the pattern from the contractions alone.
LaborState classifyContractions(List<Contraction> cs) {
  final n = cs.length;
  if (n < 3) return LaborState.insufficient;

  final durs = cs.map((c) => c.durationSeconds).toList();
  final avgDur = _mean(durs);
  final ints =
      cs.where((c) => c.intervalSeconds > 0).map((c) => c.intervalSeconds).toList();
  final avgIntSec = ints.isEmpty ? double.infinity : _mean(ints);
  final avgIntMin = avgIntSec / 60;
  final reg = _regularity(ints);
  final tracking = _trackingSeconds(cs);

  // State 4 - Active labour likely.
  if (avgIntSec <= 300 &&
      avgDur >= 60 &&
      reg >= 0.80 &&
      (tracking >= 3600 || n >= 8)) {
    return LaborState.activeLabor;
  }
  // State 3 - Labour pattern likely.
  if (n >= 5 && avgDur > 30 && avgIntSec <= 600 && reg >= 0.70) {
    return LaborState.laborLikely;
  }
  // State 2 - Possible early labour.
  if (n >= 5 &&
      avgDur >= 20 &&
      avgDur <= 45 &&
      avgIntMin >= 5 &&
      avgIntMin <= 20 &&
      reg >= 0.5 &&
      (_intervalsDecreasing(ints) || _durationsIncreasing(durs))) {
    return LaborState.earlyLabor;
  }
  // State 1 - No clear labour pattern (fallback for 3+ contractions).
  return LaborState.noPattern;
}

/// Layer 2 over Layer 1, applying the override priority order.
AssessLevel assessContractions(
    List<Contraction> cs, int gestationWeeks, ContractionSymptoms sym) {
  if (sym.isEmergency) return AssessLevel.emergency;
  final state = classifyContractions(cs);
  final laborish = state == LaborState.earlyLabor ||
      state == LaborState.laborLikely ||
      state == LaborState.activeLabor;
  if (gestationWeeks < 37 && laborish) return AssessLevel.preterm;
  return switch (state) {
    LaborState.activeLabor => AssessLevel.activeLabor,
    LaborState.laborLikely => AssessLevel.laborLikely,
    LaborState.earlyLabor => AssessLevel.earlyLabor,
    LaborState.noPattern => AssessLevel.noPattern,
    LaborState.insufficient => AssessLevel.insufficient,
  };
}

String _levelKey(AssessLevel l) => switch (l) {
      AssessLevel.emergency => 'emergency',
      AssessLevel.preterm => 'preterm',
      AssessLevel.activeLabor => 'active',
      AssessLevel.laborLikely => 'likely',
      AssessLevel.earlyLabor => 'early',
      AssessLevel.noPattern => 'noPattern',
      AssessLevel.insufficient => 'insufficient',
    };

/// The pattern summary line (Layer 1 only) for the static summary screen.
String contractionPattern(S s, List<Contraction> cs) {
  final state = classifyContractions(cs);
  final level = switch (state) {
    LaborState.activeLabor => AssessLevel.activeLabor,
    LaborState.laborLikely => AssessLevel.laborLikely,
    LaborState.earlyLabor => AssessLevel.earlyLabor,
    LaborState.noPattern => AssessLevel.noPattern,
    LaborState.insufficient => AssessLevel.insufficient,
  };
  return s.assessSummary(_levelKey(level));
}


// ---------------------------------------------------------------------------
//  Session summary
// ---------------------------------------------------------------------------

class _SummaryScreen extends StatelessWidget {
  const _SummaryScreen({required this.controller, required this.contractions});
  final PregnancyController controller;
  final List<Contraction> contractions;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final p = pvStorePalette;
    final cs = contractions;
    final durations = cs.map((c) => c.durationSeconds).toList();
    final intervals =
        cs.where((c) => c.intervalSeconds > 0).map((c) => c.intervalSeconds).toList();
    final avgDur = durations.isEmpty
        ? 0
        : (durations.reduce((a, b) => a + b) / durations.length).round();
    final avgIntSec = intervals.isEmpty
        ? 0
        : (intervals.reduce((a, b) => a + b) / intervals.length).round();
    final longest = durations.isEmpty ? 0 : durations.reduce((a, b) => a > b ? a : b);
    final shortestIntSec =
        intervals.isEmpty ? 0 : intervals.reduce((a, b) => a < b ? a : b);

    String summaryText() => '${s.lastHourLabel}:\n'
        '${cs.length} ${s.contractionsLoggedLabel.toLowerCase()}.\n'
        '${s.avgDurationLabel}: ${s.minSecLabel(avgDur)}.\n'
        '${s.avgIntervalLabel}: ${s.minSecLabel(avgIntSec)}.\n'
        '${s.longestDurationLabel}: ${s.minSecLabel(longest)}.\n'
        '${s.shortestIntervalLabel}: ${s.minSecLabel(shortestIntSec)}.\n'
        '${contractionPattern(s, cs)}\n'
        '${s.consultProvider}';

    return Scaffold(
      // Kept for revert: appBar: AppBar(title: Text(s.sessionSummaryTitle)).
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
        children: [
          _pageTitle(s.sessionSummaryTitle),
          const SizedBox(height: 22),
          // Kept for revert: Text(s.currentPatternLabel, headlineSmall).
          PregSectionHeading(s.currentPatternLabel),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.7,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _metric(s.contractionsLoggedLabel, '${cs.length}'),
              _metric(s.avgDurationLabel, s.minSecLabel(avgDur)),
              _metric(s.avgIntervalLabel, s.minSecLabel(avgIntSec)),
              _metric(s.longestDurationLabel, s.minSecLabel(longest)),
            ],
          ),
          const SizedBox(height: 16),
          // Kept for revert: a grey block (neutral50, radius 16). A white card.
          SizedBox(
            width: double.infinity,
            child: PregCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(contractionPattern(s, cs),
                    style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink1)),
                const SizedBox(height: 8),
                Text(s.consultProvider,
                    style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: pregFilledStyle().copyWith(
              minimumSize: const WidgetStatePropertyAll(Size.fromHeight(50)),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await Clipboard.setData(ClipboardData(text: summaryText()));
              messenger.showSnackBar(SnackBar(content: Text(s.summaryCopied)));
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(s.copySummaryCta,
                style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    final p = pvStorePalette;
    return PregCard(
      padding: const EdgeInsets.all(14),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvFraunces(
                    fontSize: 24, fontWeight: FontWeight.w600, color: p.ink1)),
            const SizedBox(height: 2),
            Text(label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontSize: 12, height: 1.3, color: p.ink3)),
          ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  History + session detail
// ---------------------------------------------------------------------------

class _ContractionHistoryScreen extends StatelessWidget {
  const _ContractionHistoryScreen({required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    return Scaffold(
      // Kept for revert: appBar: AppBar(title: Text(s.historyLabel)).
      appBar: AppBar(),
      body: AnimatedBuilder(
        animation: ToolsStore.instance,
        builder: (context, _) {
          final sessions = ToolsStore.instance.contractionSessions;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
            children: [
              _pageTitle(s.historyLabel),
              const SizedBox(height: 16),
              // Kept for revert: one outlined card per session. They open a
              // session, so they are rows with a drawn mark in one white card.
              PregRowCard(
                empty: s.noContractionSessions,
                children: [
                  for (final session in sessions)
                    _sessionRow(context, session, s),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sessionRow(BuildContext context, ContractionSession session, S s) {
    final p = pvStorePalette;
    final date = DateTime.tryParse(session.dateIso);
    final cs = session.contractions;
    final durations = cs.map((c) => c.durationSeconds).toList();
    final intervals =
        cs.where((c) => c.intervalSeconds > 0).map((c) => c.intervalSeconds).toList();
    final avgDur = durations.isEmpty
        ? 0
        : (durations.reduce((a, b) => a + b) / durations.length).round();
    final avgIntSec = intervals.isEmpty
        ? 0
        : (intervals.reduce((a, b) => a + b) / intervals.length).round();
    final labor = session.laborResponse;
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            _SessionDetailScreen(controller: controller, session: session),
      )),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Row(children: [
          PvMarkWell(p: p, hue: _kContractionHue, size: 44, mark: IntentMark.chartLog),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(date != null ? s.formatLongDate(date) : session.dateIso,
                  style: pvManrope(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: p.ink1)),
              const SizedBox(height: 2),
              Text(
                  '${cs.length} ${s.contractionsLoggedLabel.toLowerCase()} · '
                  '${s.avgDurationLabel} ${s.minSecLabel(avgDur)} · '
                  '${s.avgIntervalLabel} ${s.minSecLabel(avgIntSec)}',
                  style: pvManrope(fontSize: 12.5, height: 1.35, color: p.ink3)),
              if (labor != null) ...[
                const SizedBox(height: 6),
                // Kept for revert: an orange (yes) or blue (no) pill.
                _tag(s.feltInLabour(labor == 'yes')),
              ],
            ]),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
        ]),
      ),
    );
  }
}

class _SessionDetailScreen extends StatelessWidget {
  const _SessionDetailScreen({required this.controller, required this.session});
  final PregnancyController controller;
  final ContractionSession session;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    return Scaffold(
      // Kept for revert: appBar: AppBar(title: Text(s.sessionSummaryTitle)).
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
        children: [
          _pageTitle(s.sessionSummaryTitle),
          const SizedBox(height: 16),
          if (session.laborResponse != null) ...[
            // Kept for revert: a tinted block (orange or blue at 12%) with a
            // heart glyph. A tag now.
            Align(
              alignment: Alignment.centerLeft,
              child: _tag(s.feltInLabour(session.laborResponse == 'yes')),
            ),
            const SizedBox(height: 16),
          ],
          PregCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(children: [
              Row(children: [
                Expanded(child: Text(s.timeColumn, style: _columnStyle())),
                Expanded(child: Text(s.durationColumn, style: _columnStyle())),
                Expanded(child: Text(s.intervalColumn, style: _columnStyle())),
              ]),
              const Divider(height: 18, thickness: 1, color: kPvLine),
              for (final c in session.contractions)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    Expanded(
                        child: Text(
                            s.formatClock(
                                DateTime.tryParse(c.startIso) ?? DateTime.now()),
                            style: _cellStyle())),
                    Expanded(
                        child: Text(s.minSecLabel(c.durationSeconds),
                            style: _cellStyle())),
                    Expanded(
                        child: Text(
                            c.intervalSeconds == 0
                                ? '-'
                                : s.minSecLabel(c.intervalSeconds),
                            style: _cellStyle())),
                  ]),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}
