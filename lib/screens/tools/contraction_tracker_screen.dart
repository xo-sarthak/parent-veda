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
//
//  ⚠️ REDRAWN AROUND ONE CONTROL (2026-10-02, the user: "very text heavy; run
//  Mobbin and figure out a good UI, UX and functionality"). Mobbin has no
//  contraction timer, so this follows its closest patterns: Oura's and
//  Messages' timer (one huge numeral on a calm ground, one control; see
//  https://mobbin.com/screens/242a57a8-f0de-4669-a9a6-4d7d46e0582c and
//  https://mobbin.com/screens/f8d9681d-1640-4d56-b333-893c9cd440e5), Bumble's
//  record button (one round press target with a ring,
//  https://mobbin.com/screens/aa5c865f-6881-4f20-b494-a1d786bb0b1e), and Noom's
//  and Garmin's session summaries (three big numbers and a small bar chart,
//  https://mobbin.com/screens/dcd65d53-0134-419d-8a5a-3aa41ad45dfa,
//  https://mobbin.com/screens/ea11133b-fd2c-4d39-a12b-a2d4723c68b3).
//    · THE DISC IS THE TIMER AND THE BUTTON: one big circle she can hit with a
//      shaking hand. Tap to start, the numerals count, tap to end, then it
//      rests and counts the gap. Its ring fills over a minute while a
//      contraction runs and over five while she rests. No pinned bar.
//    · THE PARAGRAPHS FOLD: "we can't tell you if it's labour" stays a line she
//      always sees; its body, and "Understanding contractions", open on a tap.
//    · A CALM READING IS ONE LINE (a chip that opens its full wording); an
//      URGENT one stays the full red card, always. Red stays where it means NOW.
//    · TWO SMALL BAR CHARTS replace the table: how long, and how far apart. The
//      table is one tap away. Their reference lines are the 1 minute and 5
//      minute marks the reading already uses, drawn as axis ticks, not advice.
//  The engine below (`classifyContractions`, `assessContractions`) is untouched,
//  and so is every clinical line. The old views are kept for revert.
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
import '../pregnancy/preg_tool_chrome.dart';
import '../pregnancy/preg_tool_parts.dart' show PregFoldRow;
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
      child: _phase == _Phase.home
          // The front page wears the shared shell (2026-09-30, Tools audit). The
          // live phases below keep their app bar: a running timer is an
          // instrument, and a hero would only push it down.
          // The disc is the button now, so nothing is pinned (2026-10-02).
          // Kept for revert: a Column of `_homeView` over a pinned
          // `_bottomButton(contractionStartedCta)`.
          ? Scaffold(
              backgroundColor: pvStorePalette.ground,
              body: _homeViewV2(context),
            )
          : Scaffold(
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
          // One live view for both phases (2026-10-02): the disc changes, the
          // page does not. Kept for revert: `_activeView` and `_restView`.
          child: _liveView(context),
        ),
      ),
    );
  }

  // ---- Home -----------------------------------------------------------------

  /// The home page on the one control: the disc, a safety line she always
  /// sees, and the long text folded.
  Widget _homeViewV2(BuildContext context) {
    final s = _s;
    final hi = widget.controller.language.isHinglish;
    return PregToolScaffold(
      hue: _kContractionHue,
      eyebrow: 'Get ready',
      title: s.contractionToolTitle,
      intro: s.contractionEmpty,
      mark: IntentMark.timelineRail,
      action: Semantics(
        button: true,
        label: s.historyLabel,
        child: Tooltip(
          message: s.historyLabel,
          child: InkWell(
            key: const ValueKey('ct_history'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  _ContractionHistoryScreen(controller: widget.controller),
            )),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration:
                  const BoxDecoration(color: kPvInk, shape: BoxShape.circle),
              child: const Icon(Icons.history_rounded, size: 19, color: Colors.white),
            ),
          ),
        ),
      ),
      children: [
        pregToolPad(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (_symptoms.isEmergency) ...[
            _assessBanner(s),
            const SizedBox(height: 16),
          ],
          Center(
            child: _TimerDisc(
              key: const ValueKey('ct_disc_home'),
              phase: _Phase.home,
              time: null,
              label: s.contractionStartedCta,
              progress: 0,
              semanticLabel: s.contractionStartedCta,
              onTap: _startContraction,
            ),
          ),
          const SizedBox(height: 26),
          // The line that says what this is stays on the page; its body folds.
          _FoldRow(
            fold: 'disclaimer',
            icon: Icons.health_and_safety_outlined,
            title: s.ctDisclaimerTitle,
            body: Text(s.ctDisclaimerBody,
                style: pvManrope(fontSize: 13, height: 1.5, color: pvStorePalette.ink2)),
          ),
          const SizedBox(height: 10),
          _safetyCard(s),
          const SizedBox(height: 10),
          _FoldRow(
            fold: 'about',
            icon: Icons.info_outline_rounded,
            title: s.ctAboutTitle,
            body: Text(s.ctAboutBody,
                style: pvManrope(fontSize: 13, height: 1.5, color: pvStorePalette.ink2)),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              key: const ValueKey('ct_voice_toggle'),
              onPressed: _toggleVoice,
              style: TextButton.styleFrom(foregroundColor: pvStorePalette.ink3),
              icon: Icon(
                  _voiceMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  size: 16),
              label: Text(
                  hi
                      ? (_voiceMuted ? 'Awaaz on karein' : 'Awaaz band karein')
                      : (_voiceMuted ? 'Turn voice guidance on' : 'Mute voice guidance'),
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: pvStorePalette.ink3)),
            ),
          ),
        ])),
      ],
    );
  }

  // ---- Live (active and rest on one page) -------------------------------------

  Widget _liveView(BuildContext context) {
    final s = _s;
    final p = pvStorePalette;
    final active = _phase == _Phase.active;
    final now = DateTime.now();
    final elapsed = active
        ? (_activeStart == null ? 0 : now.difference(_activeStart!).inSeconds)
        : (_lastEnd == null ? 0 : now.difference(_lastEnd!).inSeconds);
    final level = assessContractions(
        _current, widget.controller.currentWeek, _symptoms);
    final urgent =
        level == AssessLevel.emergency || level == AssessLevel.preterm;
    final last = _current.isNotEmpty ? _current.last : null;
    return ListView(
      key: const ValueKey('ct_live'),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        if (!active) ...[
          // An urgent reading is the full red card, always. A calm one is a line.
          if (urgent) _assessBanner(s) else _assessChip(s, level),
          const SizedBox(height: 14),
        ],
        if (_symptoms.anyReported && !_symptoms.isEmergency) ...[
          _safetyCard(s),
          const SizedBox(height: 14),
        ],
        Center(
          child: Text(
            active
                ? s.contractionNumber(_current.length + 1)
                : s.timeSinceLast,
            key: const ValueKey('ct_caption'),
            style: pvManrope(
                fontSize: 13, fontWeight: FontWeight.w700, color: p.ink3),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: _TimerDisc(
            key: ValueKey(active ? 'ct_disc_active' : 'ct_disc_rest'),
            phase: _phase,
            time: s.formatStopwatch(elapsed),
            label: active ? s.contractionEndedCta : s.contractionStartedCta,
            // A minute while a contraction runs, five while she rests.
            progress: (elapsed / (active ? 60 : 300)).clamp(0.0, 1.0),
            semanticLabel:
                '${s.formatStopwatch(elapsed)}. ${active ? s.contractionEndedCta : s.contractionStartedCta}',
            onTap: active ? _endContraction : _startContraction,
          ),
        ),
        if (!active) ...[
          const SizedBox(height: 26),
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (last != null) ...[
                Expanded(
                    child: _stat(s.lastContractionLabel,
                        s.minSecLabel(last.durationSeconds))),
                VerticalDivider(width: 1, thickness: 1, color: kPvLine),
              ],
              Expanded(
                  child: _stat(
                      s.avgDurationLabel, s.minSecLabel(_avgDuration.round()))),
              VerticalDivider(width: 1, thickness: 1, color: kPvLine),
              Expanded(
                  child: _stat(s.avgIntervalLabel,
                      s.minSecLabel(_avgIntervalSec.round()))),
            ]),
          ),
          const SizedBox(height: 22),
          if (_current.isNotEmpty)
            _ContractionCharts(
              key: const ValueKey('ct_charts'),
              s: s,
              durations: [for (final c in _current) c.durationSeconds],
              intervals: [
                for (final c in _current)
                  if (c.intervalSeconds > 0) c.intervalSeconds
              ],
            ),
          const SizedBox(height: 14),
          if (_current.isNotEmpty)
            _FoldRow(
              fold: 'session',
              icon: Icons.format_list_numbered_rounded,
              title: s.thisSessionContractions,
              count: '${_current.length}',
              body: _sessionTable(s),
            ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 6),
          TextButton(
              style: TextButton.styleFrom(foregroundColor: p.ink2),
              onPressed: _endSession,
              child: Text(s.endSessionCta,
                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700))),
        ],
      ],
    );
  }

  /// A calm reading, as one line that opens its full wording. (An urgent one
  /// never comes here: it is `_assessBanner`, the whole red card.)
  Widget _assessChip(S s, AssessLevel level) {
    final p = pvStorePalette;
    final style = _levelStyle(level);
    return Semantics(
      button: true,
      label: s.assessTitle(_levelKey(level)),
      excludeSemantics: true,
      child: InkWell(
        key: const ValueKey('ct_assess_chip'),
        onTap: () => _showAssessSheet(s, level),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPvLine),
          ),
          child: Row(children: [
            Icon(style.icon, color: style.color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(s.assessTitle(_levelKey(level)),
                  style: pvManrope(
                      fontSize: 14.5, fontWeight: FontWeight.w800, height: 1.3, color: p.ink1)),
            ),
            if (_laborResponse != null) ...[
              _tag(s.feltInLabour(_laborResponse == 'yes')),
              const SizedBox(width: 6),
            ],
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      ),
    );
  }

  /// The reading in full: what it says, and the line that always points to her
  /// doctor. The same words the banner carried.
  Future<void> _showAssessSheet(S s, AssessLevel level) {
    final p = pvStorePalette;
    final key = _levelKey(level);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.assessTitle(key),
                style: pvFraunces(
                    fontSize: 21, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
            const SizedBox(height: 10),
            Text(s.assessSummary(key),
                style: pvManrope(fontSize: 14, height: 1.55, color: p.ink1)),
            const SizedBox(height: 14),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.local_hospital_outlined, size: 16, color: p.ink3),
              const SizedBox(width: 8),
              Expanded(
                child: Text(s.ctAlwaysConsult,
                    style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  /// The contractions of this session, as the table, for the fold.
  Widget _sessionTable(S s) {
    final items = _current.reversed.toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const SizedBox(width: 28),
        Expanded(child: Text(s.timeColumn, style: _columnStyle())),
        Expanded(child: Text(s.durationColumn, style: _columnStyle())),
        Expanded(child: Text(s.intervalColumn, style: _columnStyle())),
      ]),
      const Divider(height: 14, thickness: 1, color: kPvLine),
      for (int i = 0; i < items.length; i++)
        _sessionRow(s, items[i], _current.length - i),
    ]);
  }

  // Kept for revert (2026-10-02): the three paragraph cards over a pinned bar.
  // ignore: unused_element
  Widget _homeView(BuildContext context) {
    final s = _s;
    final hi = widget.controller.language.isHinglish;
    // Kept for revert: a Column of a ListView (about card, disclaimer card,
    // safety card, then a 64-pt cuppedHands mark and s.contractionEmpty) over
    // the pinned start button, under an AppBar with voice, safety and history.
    // The mark and the "ready to start" line are now the shell's mark and intro
    // (REDUNDANT there, 2026-09-30, Tools audit). The order below puts the
    // disclaimer first (the line that says what this is) and the long
    // explainer last, so the safety lines are read before the teaching.
    return PregToolScaffold(
      hue: _kContractionHue,
      eyebrow: 'Get ready',
      title: s.contractionToolTitle,
      intro: s.contractionEmpty,
      mark: IntentMark.timelineRail,
      action: Semantics(
        button: true,
        label: s.historyLabel,
        child: Tooltip(
          message: s.historyLabel,
          child: InkWell(
            key: const ValueKey('ct_history'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  _ContractionHistoryScreen(controller: widget.controller),
            )),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration:
                  const BoxDecoration(color: kPvInk, shape: BoxShape.circle),
              child: const Icon(Icons.history_rounded, size: 19, color: Colors.white),
            ),
          ),
        ),
      ),
      children: [
        pregToolPad(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (_symptoms.isEmergency) ...[
            _assessBanner(s),
            const SizedBox(height: 16),
          ],
          // Clear "we're a timer, not a medical app" disclaimer.
          _disclaimerCard(s),
          const SizedBox(height: 12),
          _safetyCard(s),
          const SizedBox(height: 12),
          // What contractions are + true vs false (Braxton Hicks) + how to time.
          _aboutCard(s),
          const SizedBox(height: 8),
          // Voice guidance used to be an app-bar speaker on this page too. It
          // only speaks once a contraction has been timed, and the running
          // phases still carry the speaker, so here it is a quiet line.
          Center(
            child: TextButton.icon(
              key: const ValueKey('ct_voice_toggle'),
              onPressed: _toggleVoice,
              style: TextButton.styleFrom(foregroundColor: pvStorePalette.ink3),
              icon: Icon(
                  _voiceMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  size: 16),
              label: Text(
                  hi
                      ? (_voiceMuted ? 'Awaaz on karein' : 'Awaaz band karein')
                      : (_voiceMuted ? 'Turn voice guidance on' : 'Mute voice guidance'),
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: pvStorePalette.ink3)),
            ),
          ),
        ])),
      ],
    );
  }

  // ---- Active ---------------------------------------------------------------

  // Kept for revert (2026-10-02): the live view replaced it.
  // ignore: unused_element
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

  // Kept for revert (2026-10-02): the live view replaced it.
  // ignore: unused_element
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
  /// a contraction runs, a grey one while she rests; white inside. The disc
  /// (`_TimerDisc`) replaced it (2026-10-02).
  // ignore: unused_element
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
              fontSize: 22, fontWeight: FontWeight.w800, color: p.ink1)),
      const SizedBox(height: 2),
      Text(label,
          textAlign: TextAlign.center,
          style: pvManrope(fontSize: 11.5, height: 1.3, color: p.ink3)),
    ]);
  }

  /// The big button. Kept for revert: it was filled with _activeColor (orange)
  /// on every phase. The one ink: it is the thing she presses. The disc is the
  /// button now (2026-10-02).
  // ignore: unused_element
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

// ---------------------------------------------------------------------------
//  The disc, the fold and the charts (2026-10-02)
// ---------------------------------------------------------------------------

/// The one control, and the timer: a big round target with the time in it and
/// a ring around it. Filled ink to start a contraction and while one runs
/// (press to stop); white while she rests (press to start the next).
class _TimerDisc extends StatelessWidget {
  const _TimerDisc({
    super.key,
    required this.phase,
    required this.time,
    required this.label,
    required this.progress,
    required this.semanticLabel,
    required this.onTap,
  });

  final _Phase phase;

  /// The numerals, or null at home (a play mark instead).
  final String? time;
  final String label;
  final double progress;
  final String semanticLabel;
  final VoidCallback onTap;

  static const double size = 236;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final filled = phase != _Phase.rest;
    final onInk = filled ? Colors.white : p.ink1;
    final quiet = filled ? Colors.white.withValues(alpha: 0.78) : p.ink3;
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(progress: progress, track: kPvLine, color: kPvInk),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Material(
              color: filled ? kPvInk : Colors.white,
              shape: CircleBorder(
                side: filled ? BorderSide.none : const BorderSide(color: kPvLine),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onTap();
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (time == null)
                          Icon(Icons.play_arrow_rounded, size: 58, color: onInk)
                        else
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(time!,
                                style: pvManrope(
                                    fontSize: 58,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1,
                                    color: onInk)),
                          ),
                        const SizedBox(height: 6),
                        Text(label,
                            textAlign: TextAlign.center,
                            textScaler: const TextScaler.linear(1.0),
                            style: pvManrope(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                height: 1.25,
                                color: quiet)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The ring round the disc: a hairline track and the part that has passed.
class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.track, required this.color});
  final double progress;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const w = 7.0;
    final r = (math.min(size.width, size.height) - w) / 2;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = track
          ..style = PaintingStyle.stroke
          ..strokeWidth = w);
    if (progress > 0) {
      canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          -math.pi / 2,
          2 * math.pi * progress.clamp(0.0, 1.0),
          false,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = w
            ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.track != track || old.color != color;
}

/// A line that opens: its icon and title are always there, its body is one tap
/// away. The long text of this tool lives behind these. Moved to
/// `PregFoldRow` (`preg_tool_parts.dart`) on 2026-10-02 when the baby movement
/// tracker needed the same; this keeps the contraction tool's own key prefix
/// (`ct_fold_...`), so nothing that finds them changes.
class _FoldRow extends PregFoldRow {
  const _FoldRow({
    required super.fold,
    required super.icon,
    required super.title,
    required super.body,
    super.count,
  }) : super(keyPrefix: 'ct_fold');
}

/// Two small bar charts of the session: how long each contraction lasted, and
/// how far apart they were. The reference lines are the one minute and five
/// minute marks, drawn as axis ticks (not advice), so a bar's height reads
/// against the same marks the reading already uses.
class _ContractionCharts extends StatelessWidget {
  const _ContractionCharts({
    super.key,
    required this.s,
    required this.durations,
    required this.intervals,
  });
  final S s;
  final List<int> durations;
  final List<int> intervals;

  @override
  Widget build(BuildContext context) {
    return PregCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.durationColumn, style: _columnStyle()),
        const SizedBox(height: 6),
        _MiniBars(
            key: const ValueKey('ct_chart_duration'),
            values: durations,
            reference: 60,
            referenceLabel: s.minSecLabel(60)),
        if (intervals.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(s.intervalColumn, style: _columnStyle()),
          const SizedBox(height: 6),
          _MiniBars(
              key: const ValueKey('ct_chart_interval'),
              values: intervals,
              reference: 300,
              referenceLabel: s.minSecLabel(300)),
        ],
      ]),
    );
  }
}

/// The last ten values as bars, the newest on the right, against one reference
/// line. A bar is never taller than the chart: the scale is whichever is larger,
/// the reference with some room above it or the biggest value.
class _MiniBars extends StatelessWidget {
  const _MiniBars({
    super.key,
    required this.values,
    required this.reference,
    required this.referenceLabel,
  });
  final List<int> values;
  final int reference;
  final String referenceLabel;

  static const double height = 54;
  static const double labelWidth = 34;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final shown = values.length > 10 ? values.sublist(values.length - 10) : values;
    final top = math.max(reference * 1.25, shown.fold<int>(0, math.max).toDouble());
    final refY = height - height * reference / top;
    return SizedBox(
      height: height,
      child: Stack(children: [
        Positioned.fill(
          left: labelWidth,
          child: CustomPaint(
            painter: _BarsPainter(
              values: shown,
              top: top,
              reference: reference.toDouble(),
              bar: kPvInk,
              line: p.ink3.withValues(alpha: 0.55),
              slots: 10,
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: (refY - 7).clamp(0.0, height - 14),
          child: Text(referenceLabel,
              textScaler: const TextScaler.linear(1.0),
              style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w700, color: p.ink3)),
        ),
      ]),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.values,
    required this.top,
    required this.reference,
    required this.bar,
    required this.line,
    required this.slots,
  });
  final List<int> values;
  final double top;
  final double reference;
  final Color bar;
  final Color line;
  final int slots;

  @override
  void paint(Canvas canvas, Size size) {
    final slotW = size.width / slots;
    final w = slotW * 0.56;
    // The reference line, dashed.
    final y = size.height - size.height * reference / top;
    final dash = Paint()
      ..color = line
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 7) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + 3.5, size.width), y), dash);
    }
    // Bars from the right, so the newest is always at the edge.
    for (var i = 0; i < values.length; i++) {
      final slot = slots - values.length + i;
      final h = math.max(3.0, size.height * values[i] / top);
      final x = slot * slotW + (slotW - w) / 2;
      final newest = i == values.length - 1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, size.height - h, w, h), const Radius.circular(3)),
        Paint()..color = newest ? bar : bar.withValues(alpha: 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.values != values || old.top != top || old.reference != reference;
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
          // The same two charts as the live page (2026-10-02).
          if (cs.isNotEmpty) ...[
            _ContractionCharts(
              key: const ValueKey('ct_summary_charts'),
              s: s,
              durations: durations,
              intervals: intervals,
            ),
            const SizedBox(height: 16),
          ],
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
