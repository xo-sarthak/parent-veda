// =============================================================================
//  The practice players — one per animation kind
// -----------------------------------------------------------------------------
//  From the animation spec in `ParentVeda_Mindbody_twelve_practice_cards.pdf`.
//  Reference feel, in the brief's words: *"the Bend stretching app. A simple
//  looping figure, a timer, a step line, and nothing else on screen. Calm, no
//  music, no voice, no scores."*
//
//  ⚠️ ONE BREATHING COMPONENT, CONFIGURED FOUR WAYS. The brief asks for this
//  explicitly — *"Build this once and reuse it"* — and it is the difference
//  between four players that drift and one that cannot. Box breathing traces a
//  square instead of a circle, alternate nostril adds a side indicator, and ten
//  breaths together counts to ten with two markers. All three are `TtcBreathAnim`
//  fields, not separate widgets.
//
//  ⚠️ EVERY PLAYER IS OPTIONAL. The brief: *"The step text must be readable on
//  its own for someone who cannot see the animation."* So none of these owns the
//  steps, the timer or the safety note — the screen draws those, and the player
//  sits above them. A card with no player at all still works.
//
//  ⚠️ AND NOTHING CELEBRATES. No confetti, no chime, no "well done" — the brief
//  forbids all three, and the reason is the same one that keeps streaks out of
//  this area: a screen that celebrates finishing makes the days you did not open
//  it into days you let something down.
//
//  ⚠️ A SOUND IS NOT A CELEBRATION (2026-09-28). The user asked for sound
//  wherever something counts or times, including a chime at the end. The
//  brief's "no chime" was about praise for finishing; the end tone here is a
//  signal that the time is up, for someone whose eyes are closed, the same
//  job the last vibration already did. It is one soft two-note bell, with no
//  words and nothing on screen added to it. Every cue has a "Sound cues"
//  switch beside the vibration switch, and the phone's silent mode wins. See
//  lib/ttc/ttc_cue_sounds.dart for the cues and the audio-context choice.
// =============================================================================

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_cue_sounds.dart';
import '../../ttc/ttc_practice_data.dart';
import '../../widgets/breathing_circle.dart';
import '../../widgets/figure_highlight.dart';
import '../v2/v2_palette.dart';
import 'ttc_mind_today_screen.dart' show kTtcMoveHue, kTtcBreatheHue;

// -----------------------------------------------------------------------------
//  The two colours every player draws with
// -----------------------------------------------------------------------------
//  ⚠️ RESOLVED ONCE AND PASSED DOWN, NOT READ IN SIX PAINTERS. These used to be
//  the fixed TTC tool tokens — a violet circle and a lilac ring — which is why
//  a breathing practice opened from a sand-coloured door looked like a screen
//  borrowed from somewhere else. The accent is now the practice's OWN hue, the
//  same one its block wears on Today, so the card you tapped and the circle you
//  get are the same colour.
//
//  A painter cannot read an inherited widget, so this travels as a value rather
//  than through the tree.
class TtcPracticeSkin {
  const TtcPracticeSkin({required this.p, required this.accent});

  final V2Palette p;

  /// The moving part: the circle, the arc, the count.
  final Color accent;

  /// The still part behind it. A hairline, never a shadow.
  Color get track => p.line;

  /// The skin for one practice, from the palette on screen.
  factory TtcPracticeSkin.of(TtcPractice practice) => TtcPracticeSkin.atHue(
      practice.kind == TtcPracticeKind.move ? kTtcMoveHue : kTtcBreatheHue);

  /// The calm end of the pair, for a sit that belongs to no library.
  factory TtcPracticeSkin.breathe() => TtcPracticeSkin.atHue(kTtcBreatheHue);

  factory TtcPracticeSkin.atHue(double hue) {
    final p = V2PaletteStore.instance.current;
    return TtcPracticeSkin(
      p: p,
      // The block tint is a pale wash — right behind large type, far too weak
      // for a 5pt arc — so the accent is that hue taken down to ink strength.
      accent: HSLColor.fromColor(v2BlockTint(hue, p))
          .withSaturation(0.44)
          .withLightness(0.36)
          .toColor(),
    );
  }
}

/// Whether a breathing session vibrates on each change of breath. Off by
/// default and remembered on this phone.
///
/// ⚠️ A NOTIFIER OUTSIDE THE SESSION (launch sanity MB14, 2026-09-28). The
/// setting used to be a line of text inside the session that was secretly a
/// toggle. The practice page now shows it as a labelled switch with the other
/// setting (the steps following the timer), away from the ring, so the
/// session and the switch have to read one value.
final ValueNotifier<bool> ttcPracticeVibrate = ValueNotifier<bool>(false);
const String _kVibrateKey = 'ttc_practice_vibrate';
bool _vibrateLoaded = false;

/// Reads the remembered setting once per run of the app.
void _loadPracticeVibrate() {
  if (_vibrateLoaded) return;
  _vibrateLoaded = true;
  SharedPreferences.getInstance().then((p) {
    ttcPracticeVibrate.value = p.getBool(_kVibrateKey) ?? false;
  }).catchError((Object _) {});
}

/// Turns the vibration on or off, and remembers it.
void ttcSetPracticeVibrate(bool on) {
  _vibrateLoaded = true;
  ttcPracticeVibrate.value = on;
  if (on) HapticFeedback.mediumImpact();
  SharedPreferences.getInstance()
      .then((p) => p.setBool(_kVibrateKey, on))
      .catchError((Object _) => false);
}

/// The vibration as a labelled switch, the same shape as the steps switch.
class TtcVibrateSwitch extends StatelessWidget {
  const TtcVibrateSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    _loadPracticeVibrate();
    final p = V2PaletteStore.instance.current;
    return ValueListenableBuilder<bool>(
      valueListenable: ttcPracticeVibrate,
      builder: (context, on, _) => MergeSemantics(
        child: Row(children: [
          Expanded(
            child: Text('Vibrate on each breath',
                style: pvManrope(fontSize: 13.5, height: 1.4, color: p.ink1)),
          ),
          Switch(value: on, onChanged: ttcSetPracticeVibrate),
        ]),
      ),
    );
  }
}

/// The sound cues as a labelled switch, the same shape as the vibration one
/// (2026-09-28). ON by default and remembered on this phone; the store is
/// `TtcCueSounds`, so every player on screen reads one value.
///
/// "Sound cues" names what it turns on: a tone as each breath or timed step
/// begins and one as the practice ends, never music or a voice. Opal keeps a
/// Mute control beside its breathing player
/// (https://mobbin.com/screens/b7a85dff-8e86-4211-9dec-73f5bf2ac492).
class TtcSoundSwitch extends StatelessWidget {
  const TtcSoundSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final cues = TtcCueSounds.instance;
    return ListenableBuilder(
      listenable: cues,
      builder: (context, _) => MergeSemantics(
        child: Row(children: [
          Expanded(
            child: Text('Sound cues',
                style: pvManrope(fontSize: 13.5, height: 1.4, color: p.ink1)),
          ),
          Switch(value: cues.enabled, onChanged: cues.setEnabled),
        ]),
      ),
    );
  }
}

/// The wall clock the player reads. A seam for tests only (2026-09-27): a
/// widget test's pump moves timers, not `DateTime.now`, so a test that wants
/// to see a practice finish sets this and moves it. Never set it in the app.
@visibleForTesting
DateTime Function() ttcPracticeNow = DateTime.now;

/// Where a session is, in whole seconds.
///
/// ⚠️ ELAPSED IS COMPUTED FROM A TIMESTAMP, NOT COUNTED UP BY THE TICKER. A
/// counter that increments on every tick drifts, and drifts by more the longer
/// the practice runs and the busier the device is — which is worst on the
/// ten-minute walk, the one session somebody actually leaves running. Wall-clock
/// arithmetic is also what survives the screen locking.
class _Clock {
  Duration held = Duration.zero;
  DateTime? startedAt;

  bool get running => startedAt != null;

  Duration get elapsed =>
      held + (startedAt == null ? Duration.zero : ttcPracticeNow().difference(startedAt!));

  void start() => startedAt ??= ttcPracticeNow();

  void pause() {
    if (startedAt == null) return;
    held += ttcPracticeNow().difference(startedAt!);
    startedAt = null;
  }

  void reset() {
    held = Duration.zero;
    startedAt = null;
  }
}

/// The shared session shell: a player, a ring, and pause / restart.
///
/// ⚠️ TWO WAYS IN, AND THE SECOND ONE IS WHY THIS TAKES AN ANIM RATHER THAN A
/// PRACTICE. The garbh sanskar course asks twice for a plain sit with a ring
/// behind nothing at all — session 1's two minutes of sitting still, session 3's
/// five minutes of attention on the breath — and neither is a card in the
/// library, because neither is a thing you would put on Today. Building a second
/// timer for them would be a second clock to keep in step with this one; the
/// brief's instruction for the whole course is *"Reuse, do not rebuild."*
///
/// So the widget holds what it actually draws with, and `TtcPracticeSession.sit`
/// is the door for anything that has a duration and no card.
class TtcPracticeSession extends StatefulWidget {
  TtcPracticeSession({
    super.key,
    required TtcPractice practice,
    this.onFinished,
    this.onProgress,
    this.caption,
    this.stepClock = false,
    this.showVibrate = true,
    this.showSound = true,
  })  : anim = practice.anim,
        steps = practice.steps,
        skinFor = (() => TtcPracticeSkin.of(practice));

  /// A ring, a clock, and nothing else. For a sit the course asks for.
  TtcPracticeSession.sit({
    super.key,
    required int seconds,
    this.onFinished,
  })  : anim = TtcTimerAnim(seconds: seconds),
        steps = const [],
        onProgress = null,
        caption = null,
        stepClock = false,
        showVibrate = false,
        // A sit has an end tone, so it carries the switch that silences it.
        showSound = true,
        skinFor = (() => TtcPracticeSkin.breathe());

  /// Called once, when the timer reaches the end on its own (never on a
  /// pause, never when she leaves). The practice screen marks the practice
  /// done here and says so, with an undo (2026-09-27): finishing a Headspace
  /// or Calm session completes it, and a separate "Mark done" she had to
  /// scroll to after the timer was the step people skip.
  final VoidCallback? onFinished;

  /// Every tick: how far through (0 to 1) and whether the clock is running.
  /// The practice screen moves its lit step with this when she lets it.
  final void Function(double progress, bool running)? onProgress;

  /// What the middle of a drawn-figure ring says. Null keeps "Follow the
  /// steps as you go".
  final String? caption;

  /// Whether a drawn-figure ring counts down each step rather than the whole
  /// practice (launch sanity MB11, 2026-09-28). True while the lit step
  /// follows the timer: the steps split the time evenly, the same split the
  /// practice page lights the list by.
  final bool stepClock;

  /// Whether a breathing session draws its own vibration switch. The practice
  /// page passes false and draws `TtcVibrateSwitch` with its other setting;
  /// the course sessions keep it here.
  final bool showVibrate;

  /// Whether the session draws its own "Sound cues" switch (2026-09-28). The
  /// practice page passes false and draws `TtcSoundSwitch` with its other
  /// settings; the Sanskar breath and the course sessions keep it here.
  final bool showSound;

  final TtcPracticeAnim anim;

  /// Only the body scan reads these — it names the part it is lighting.
  final List<String> steps;

  /// ⚠️ A CLOSURE, NOT A COLOUR. The palette can change under a running session
  /// (the ground switcher repaints the whole app), so the skin has to be
  /// resolved in `build` rather than captured in the constructor.
  final TtcPracticeSkin Function() skinFor;

  @override
  State<TtcPracticeSession> createState() => TtcPracticeSessionState();
}

class TtcPracticeSessionState extends State<TtcPracticeSession> {
  final _clock = _Clock();
  Timer? _ticker;

  // ⚠️ HANDS-FREE, ADDED 2026-09-27 (tools rebuild). The circle was the only
  // cue, so a practice done with eyes closed meant opening them to check.
  // Three things now carry it without looking:
  //  · a gentle vibration on each change of breath, OFF by default and
  //    remembered on this phone (Headspace and Calm both offer it as an
  //    opt-in; buzzing someone who did not ask is not calm);
  //  · the screen stays awake while the timer runs (a phone that dims at
  //    thirty seconds ends a five-minute practice on the mat);
  //  · the timer stops itself at the end, with one last vibration if she
  //    asked for them. Until now it ran on past zero with the button still
  //    saying "Pause".
  // Mobbin: Life Reset's breathing player (the phase word, the count and the
  // time left, https://mobbin.com/screens/8cad3cd9-ead8-429c-8d48-a9fd14c76bc9),
  // Opal's "Breathe In" with its Mute control
  // (https://mobbin.com/screens/b7a85dff-8e86-4211-9dec-73f5bf2ac492).
  // Kept for revert (2026-09-28), the state before `ttcPracticeVibrate`:
  //   static const _vibrateKey = 'ttc_practice_vibrate';
  //   static bool? _vibrateCache;
  //   bool _vibrate = _vibrateCache ?? false;
  bool get _vibrate => ttcPracticeVibrate.value;
  String? _lastPhase;

  /// The timed step the last tick was on, for the step cue. Null before the
  /// first tick of a run, so pressing Start does not sound a "step changed".
  int? _lastStep;

  int get _total => widget.anim.seconds;
  int get _left => (_total - _clock.elapsed.inSeconds).clamp(0, _total);

  bool get _isBreath => widget.anim is TtcBreathAnim;

  /// Whether the vibration is on. Public for a test.
  bool get vibrate => _vibrate;

  @override
  void initState() {
    super.initState();
    _loadPracticeVibrate();
    ttcPracticeVibrate.addListener(_onVibrateChanged);
    // The five tones load when a player opens and unload when the last one
    // closes (2026-09-28). See lib/ttc/ttc_cue_sounds.dart.
    TtcCueSounds.instance.open();
  }

  void _onVibrateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ttcPracticeVibrate.removeListener(_onVibrateChanged);
    TtcCueSounds.instance.close();
    _ticker?.cancel();
    if (_clock.running) WakelockPlus.disable().catchError((Object _) {});
    super.dispose();
  }

  // Kept for revert (2026-09-28): the session's own setter, now
  // `ttcSetPracticeVibrate`.
  //   void _setVibrate(bool on) => ttcSetPracticeVibrate(on);

  double get _fraction => _total == 0
      ? 0
      : (_clock.elapsed.inMilliseconds / 1000.0 / _total).clamp(0.0, 1.0);

  /// Which step the TIMER is on, or null where the timer does not move the
  /// steps. The same splits the ring and the body scan draw with, so the tap
  /// sounds on the frame the words change.
  int? _timedStep() {
    final n = widget.steps.length;
    if (n == 0 || _total == 0) return null;
    final t = _clock.elapsed.inMilliseconds / 1000.0;
    return switch (widget.anim) {
      TtcFigureAnim() when widget.stepClock =>
        (t / (_total / n)).floor().clamp(0, n - 1),
      TtcBodyScanAnim() => (_fraction * (n > 2 ? n - 2 : n))
          .floor()
          .clamp(0, (n > 2 ? n - 2 : n) - 1),
      _ => null,
    };
  }

  void _tick() {
    if (!mounted) return;
    final finished = _left == 0;
    // Kept for revert (2026-09-28), the vibration-only phase check:
    //   if (_vibrate && _isBreath && !finished) {
    //     final m = (widget.anim as TtcBreathAnim)
    //         .toBreathPattern()
    //         .at(_clock.elapsed.inMilliseconds / 1000.0);
    //     final key = '${m.cycle}:${m.index}';
    //     if (_lastPhase != null && key != _lastPhase) {
    //       HapticFeedback.mediumImpact();
    //     }
    //     _lastPhase = key;
    //   }
    //
    // ⚠️ A TONE AS EACH BREATH PHASE BEGINS (2026-09-28). The phase is worked
    // out whether or not she asked for vibration now, because the sound needs
    // it too. The FIRST phase sounds (the in-breath she starts on, or the
    // phase she resumes into), where the vibration still waits for a change:
    // a buzz under the finger that just pressed Start tells her nothing, a
    // rising tone tells her to breathe in.
    if (_isBreath && !finished) {
      final pattern = (widget.anim as TtcBreathAnim).toBreathPattern();
      final m = pattern.at(_clock.elapsed.inMilliseconds / 1000.0);
      final key = '${m.cycle}:${m.index}';
      if (key != _lastPhase) {
        if (_vibrate && _lastPhase != null) HapticFeedback.mediumImpact();
        TtcCueSounds.instance
            .play(ttcCueForBreath(pattern.steps[m.index].kind));
      }
      _lastPhase = key;
    }
    // ⚠️ A SOFT TAP AS A TIMED STEP CHANGES (2026-09-28): the drawn-figure
    // ring while the steps follow the timer, and the body scan as it moves to
    // the next part. Not on the first tick (Start was her own tap), and not
    // when she moves the steps by hand (the button is her own tap too).
    if (!finished) {
      final step = _timedStep();
      if (step != null && _lastStep != null && step != _lastStep) {
        TtcCueSounds.instance.play(TtcCue.step);
      }
      _lastStep = step;
    }
    if (finished) {
      _clock.pause();
      _ticker?.cancel();
      _ticker = null;
      WakelockPlus.disable().catchError((Object _) {});
      if (_vibrate) HapticFeedback.heavyImpact();
      // The end tone: the time is up, for eyes that are closed. Not praise;
      // see the file's header.
      TtcCueSounds.instance.play(TtcCue.done);
      setState(() {});
      widget.onProgress?.call(1, false);
      widget.onFinished?.call();
      return;
    }
    setState(() {});
    widget.onProgress?.call(_fraction, true);
  }

  void _toggle() {
    setState(() {
      if (_clock.running) {
        _clock.pause();
        _ticker?.cancel();
        _ticker = null;
        WakelockPlus.disable().catchError((Object _) {});
      } else {
        if (_left == 0) _clock.reset();
        _lastPhase = null;
        _lastStep = null;
        _clock.start();
        WakelockPlus.enable().catchError((Object _) {});
        // 100ms rather than 1s: the breathing circle moves continuously, and a
        // one-second tick makes it step rather than glide.
        _ticker = Timer.periodic(
            const Duration(milliseconds: 100), (_) => _tick());
      }
    });
    widget.onProgress?.call(_fraction, _clock.running);
  }

  @override
  Widget build(BuildContext context) {
    final skin = widget.skinFor();
    final p = skin.p;
    final anim = widget.anim;
    final done = _left == 0 && _clock.elapsed.inSeconds > 0;
    final t = _clock.elapsed.inMilliseconds / 1000.0;
    final progress = _total == 0 ? 0.0 : (t / _total).clamp(0.0, 1.0);

    return Column(children: [
      // ⚠️ A MINIMUM, NOT A FIXED HEIGHT, AND IT WAS FIXED UNTIL 2026-09-10.
      // Five of the six players are a ring with something small in the middle
      // and fit 232 forever. The body scan is the odd one: it is a Column of a
      // figure AND the name of the body part currently lit, and that caption
      // wraps to as many lines as the step needs — three, at the largest
      // accessibility sizes, which pushed the whole Column past a hard 232 and
      // striped the screen. A floor is enough to stop a breathing circle
      // jumping between phases, and nothing needs a ceiling.
      ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 232),
        child: Center(
          child: switch (anim) {
            TtcBreathAnim() => _Breath(
                spec: anim, seconds: t, progress: progress,
                running: _clock.running, skin: skin),
            TtcBodyScanAnim() =>
              _BodyScan(steps: widget.steps, progress: progress, skin: skin),
            TtcListenAnim() =>
              _Listen(seconds: t, progress: progress, skin: skin),
            TtcFigureAnim() => _figure(t, progress, skin),
            TtcTimerAnim() =>
              _PlainTimer(left: _left, progress: progress, skin: skin),
          },
        ),
      ),
      const SizedBox(height: 18),

      // ---- pause / start, and nothing that scores ------------------------
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _clock.running ? p.surfaceAlt : skin.accent,
              borderRadius: BorderRadius.circular(999),
              border: _clock.running ? Border.all(color: p.line) : null,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                  _clock.running
                      ? Icons.pause_rounded
                      : done
                          ? Icons.replay_rounded
                          : Icons.play_arrow_rounded,
                  size: 19,
                  color: _clock.running ? p.ink1 : Colors.white),
              const SizedBox(width: 8),
              Text(
                  _clock.running
                      ? 'Pause'
                      : done
                          // Was 'Again' (2026-09-27), which read as a prompt
                          // to repeat the practice. Kept for revert
                          // (2026-09-28): 'Start again' and 'Start'; the
                          // button names the timer it starts.
                          ? 'Restart timer'
                          : 'Start timer',
                  style: pvManrope(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _clock.running ? p.ink1 : Colors.white)),
            ]),
          ),
        ),
      ]),

      // ---- time left, once started (2026-09-27) ---------------------------
      // The ring shows it; the words say it. The plain timer already prints
      // its clock inside the ring, so it does not need a second one.
      // The drawn-figure ring prints its own clock since 2026-09-28 (MB11).
      if (anim is! TtcTimerAnim &&
          anim is! TtcFigureAnim &&
          _clock.elapsed > Duration.zero &&
          !done) ...[
        const SizedBox(height: 10),
        Text(_leftLabel(_left),
            style: pvManrope(
                fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink3)),
      ],

      // ---- the optional vibration, breathing only --------------------------
      if (_isBreath && widget.showVibrate) ...[
        const SizedBox(height: 6),
        // A labelled switch, the same as the practice page's (launch sanity
        // MB14, 2026-09-28). It was a line of text that was secretly a toggle.
        // Kept for revert, the text toggle:
        // Semantics(
        // button: true,
        // toggled: _vibrate,
        // label: 'Vibrate on each breath',
        // excludeSemantics: true,
        // child: InkWell(
        // onTap: () => _setVibrate(!_vibrate),
        // borderRadius: BorderRadius.circular(999),
        // child: Padding(
        // padding:
        // const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        // child: Row(mainAxisSize: MainAxisSize.min, children: [
        // Icon(
        // _vibrate
        // ? Icons.vibration_rounded
        // : Icons.mobile_off_rounded,
        // size: 16,
        // color: _vibrate ? p.ink1 : p.ink3),
        // const SizedBox(width: 7),
        // Flexible(
        // child: Text(
        // _vibrate
        // ? 'Vibrate on each breath: on'
        // : 'Vibrate on each breath: off',
        // style: pvManrope(
        // fontSize: 12.5,
        // fontWeight: FontWeight.w700,
        // color: _vibrate ? p.ink1 : p.ink2)),
        // ),
        // ]),
        // ),
        // ),
        // ),
        const TtcVibrateSwitch(),
      ],

      // ---- the sound cues, every kind of session (2026-09-28) -------------
      // Under the vibration switch where there is one, alone where there is
      // not: every session has at least the end tone.
      if (widget.showSound) ...[
        SizedBox(height: _isBreath && widget.showVibrate ? 0 : 6),
        const TtcSoundSwitch(),
      ],

      if (done) ...[
        const SizedBox(height: 14),
        // ⚠️ THE FLATTEST SENTENCE THAT IS STILL WARM. No "well done", no
        // score, no streak. The brief bans a celebration animation on finishing
        // and the reasoning goes further than the animation: praise for
        // finishing is what makes not finishing a failure.
        // Was "That's the whole thing." (2026-09-27): now says she can stop.
        Text("That's the whole practice. You can stop here.",
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
      ],
    ]);
  }

  /// The drawn-figure ring: the time, large, and one small line under it.
  ///
  /// ⚠️ THE RING'S ONE JOB IS HOW LONG IS LEFT (launch sanity MB11,
  /// 2026-09-28). It said "Step 1 of 6" and no time before Start. Now, while
  /// the steps follow the timer, it counts down the step she is on ("0:30")
  /// with "Step 1 of 6" small under it, as Future's exercise player puts the
  /// move's own countdown in the middle
  /// (https://mobbin.com/screens/72efd39a-7519-4765-8b86-eb7494d029ef,
  /// https://mobbin.com/screens/e554df4e-de96-4fc3-81f2-652f44d009ca). Once
  /// she moves the steps herself the ring counts the whole practice.
  Widget _figure(double t, double progress, TtcPracticeSkin skin) {
    final n = widget.steps.length;
    if (widget.stepClock && n > 0 && _total > 0) {
      final per = _total / n;
      final i = (t / per).floor().clamp(0, n - 1);
      final stepLeft = ((i + 1) * per - t).ceil().clamp(0, per.ceil());
      return _Figure(
          progress: progress,
          skin: skin,
          time: _clockLabel(stepLeft),
          caption: widget.caption ?? 'Step ${i + 1} of $n');
    }
    return _Figure(
        progress: progress,
        skin: skin,
        time: _clockLabel(_left),
        caption: widget.caption ?? 'for the whole practice');
  }

  static String _clockLabel(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  static String _leftLabel(int left) {
    final m = left ~/ 60;
    final sec = left % 60;
    return '$m:${sec.toString().padLeft(2, '0')} left';
  }
}

// =============================================================================
//  The breathing component — built once, configured per card
// =============================================================================

// ⚠️ THE CIRCLE ITSELF IS `PvBreathingCircle` NOW — 2026-09-12. This was the
// first "one component, configured four ways" in the app, and the Garbh
// pillars brief asked for one component across ALL areas, not one per stage.
// What is TTC's stays here: the progress ring, the two markers, the count-to
// line and the nostril side. The shape, the word and the count are the shared
// widget's, fed the same stopwatch. The old body is in git.
class _Breath extends StatelessWidget {
  const _Breath(
      {required this.spec,
      required this.seconds,
      required this.progress,
      required this.running,
      required this.skin});

  final TtcBreathAnim spec;
  final double seconds;
  final double progress;
  final bool running;
  final TtcPracticeSkin skin;

  @override
  Widget build(BuildContext context) {
    final pattern = spec.toBreathPattern();
    final m = pattern.at(seconds);
    // Step 0 is always the in-breath; the rest of the nostril logic reads
    // the cycle number, as before.
    final inhaling = m.index == 0;
    final rounds = m.cycle;

    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 210,
        height: 210,
        child: CustomPaint(
          painter: _RingPainter(
              progress: progress,
              twoMarkers: spec.twoMarkers,
              accent: skin.accent,
              track: skin.track),
        ),
      ),
      PvBreathingCircle(
        pattern: pattern,
        elapsed: seconds,
        tint: skin.accent,
        ink: skin.p.ink1,
        running: running,
        // ⚠️ A SQUARE FOR BOX BREATHING. "This one is naturally a square, not
        // a circle" — four equal phases around four equal sides.
        square: spec.square,
        size: 150,
        // ⚠️ "READY" IS DRAWN BELOW, CENTRED (launch sanity MB12,
        // 2026-09-28). The shared circle stacks the word over an empty
        // 34pt count line while it rests, so the word sat in the top third
        // of the disc. The real fix belongs in `PvBreathingCircle`, which
        // other stages share, so this player blanks the word there and
        // centres its own over the disc, as Opal centres "Breathe In"
        // (https://mobbin.com/screens/b7a85dff-8e86-4211-9dec-73f5bf2ac492).
        readyLabel: '',
        below: !running
            ? null
            : Column(mainAxisSize: MainAxisSize.min, children: [
                if (spec.countTo != null)
                  Text(
                      'Breath ${rounds.clamp(1, spec.countTo!)} of '
                      '${spec.countTo}',
                      style:
                          pvManrope(fontSize: 11.5, color: skin.p.ink2)),
                // ⚠️ THE SIDE, BECAUSE THE PRACTICE IS ABOUT WHICH SIDE.
                // Alternate nostril breathing with no indication of which
                // nostril is a diagram of ordinary breathing.
                if (spec.nostrils)
                  Text(
                      inhaling
                          ? (rounds.isOdd
                              ? 'In through the left'
                              : 'In through the right')
                          : (rounds.isOdd
                              ? 'Out through the right'
                              : 'Out through the left'),
                      // Bigger and darker (2026-09-27, was 11.5 ink2): the
                      // side is the point of this practice.
                      style: pvManrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: skin.p.ink1)),
              ]),
      ),
      if (!running)
        IgnorePointer(
          child: Text('Ready',
              textAlign: TextAlign.center,
              style: pvManrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  color: skin.p.ink1)),
        ),
    ]);
  }
}

// =============================================================================
//  The other four
// =============================================================================

/// Attention moving down the body, one named part at a time.
class _BodyScan extends StatelessWidget {
  const _BodyScan(
      {required this.steps, required this.progress, required this.skin});
  final List<String> steps;
  final double progress;
  final TtcPracticeSkin skin;

  @override
  Widget build(BuildContext context) {
    // The first and last steps are settling in and coming out, so the scan
    // itself runs over the middle ones.
    final body = steps.length > 2 ? steps.sublist(1, steps.length - 1) : steps;
    final i = (progress * body.length).floor().clamp(0, body.length - 1);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      // The shared figure — TTC drew it first, Kriya's relaxation reuses it.
      PvFigureHighlight(
        highlight: body.isEmpty ? 0 : i / body.length,
        accent: skin.accent,
        line: skin.track,
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: 260,
        child: Text(body.isEmpty ? '' : body[i],
            textAlign: TextAlign.center,
            style: pvManrope(fontSize: 13, height: 1.4, color: skin.p.ink1)),
      ),
    ]);
  }
}

/// A soft pulse and a ring. No audio is bundled — she brings her own.
class _Listen extends StatelessWidget {
  const _Listen(
      {required this.seconds, required this.progress, required this.skin});
  final double seconds;
  final double progress;
  final TtcPracticeSkin skin;

  @override
  Widget build(BuildContext context) {
    final pulse = 0.85 + 0.15 * math.sin(seconds * 0.9);
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 210,
        height: 210,
        child: CustomPaint(
            painter: _RingPainter(
                progress: progress,
                accent: skin.accent,
                track: skin.track)),
      ),
      Transform.scale(
        scale: pulse,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              skin.accent.withValues(alpha: 0.28),
              skin.accent.withValues(alpha: 0.04),
            ]),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 96),
        child: Text('Play your own music',
            style: pvManrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: skin.p.ink2)),
      ),
    ]);
  }
}

/// A drawn figure when one exists, and an honest placeholder until then.
class _Figure extends StatelessWidget {
  const _Figure(
      {required this.progress,
      required this.skin,
      required this.time,
      this.caption});
  final double progress;
  final TtcPracticeSkin skin;

  /// The clock in the middle of the ring (2026-09-28, MB11).
  final String time;

  /// "Step 3 of 6" when the steps follow the timer (2026-09-27): the biggest
  /// thing on screen then says where she is, readable from the mat.
  final String? caption;

  @override
  Widget build(BuildContext context) {
    // ⚠️ WHEN `assetPath` IS FILLED, A Rive OR Lottie PLAYER GOES HERE AND
    // NOTHING ELSE CHANGES. The path is read from the card's data exactly so
    // that dropping a file in is a data edit. The package is not added yet
    // because adding a dependency for six files that do not exist is how a
    // pubspec collects things nobody uses.
    //
    // ⚠️ WHAT THE PLACEHOLDER SHOWS WAS THE HALF THAT LOOKED UNFINISHED. It
    // was a grey icon and the sentence "Follow the steps below" -- an apology,
    // in the largest object on the screen, on six of the twelve cards. The mark
    // is now a wash rather than a subject, the ring it sits in is real
    // information, and the two words left are an instruction rather than a
    // notice about something missing. Nothing is invented: there is still no
    // figure here, and no pretending there is one.
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 210,
        height: 210,
        child: CustomPaint(
            painter: _RingPainter(
                progress: progress,
                accent: skin.accent,
                track: skin.track)),
      ),
      // ⚠️ NO FIGURE BEHIND THE WORDS (2026-09-28, the card family's first
      // rule). A 104pt faded figure sat under "Step 3 of 6", the one thing
      // on screen meant to be read from the mat. The ring is the picture.
      // Headspace's player keeps its words on a clean ground
      // (https://mobbin.com/screens/d5b9ff12-33e0-4ec4-ae64-82c70e68ba0d).
      // Kept for revert:
      //   Icon(Icons.self_improvement_rounded,
      //       size: 104, color: skin.accent.withValues(alpha: 0.10)),
      // The time large and the step small under it, centred as one block
      // (MB11, 2026-09-28). Kept for revert: the caption alone in Fraunces 24,
      // or "Follow the steps / as you go" when there was none.
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text(time,
            style: pvFraunces(
                fontSize: 40, fontWeight: FontWeight.w600, color: skin.p.ink1)),
        if (caption case final c?) ...[
          const SizedBox(height: 2),
          Text(c,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: skin.p.ink2)),
        ],
      ]),
    ]);
  }
}

/// Ten minutes, and nothing else.
class _PlainTimer extends StatelessWidget {
  const _PlainTimer(
      {required this.left, required this.progress, required this.skin});
  final int left;
  final double progress;
  final TtcPracticeSkin skin;

  @override
  Widget build(BuildContext context) {
    final m = left ~/ 60;
    final s = left % 60;
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: 210,
        height: 210,
        child: CustomPaint(
            painter: _RingPainter(
                progress: progress,
                accent: skin.accent,
                track: skin.track)),
      ),
      Text('$m:${s.toString().padLeft(2, '0')}',
          style: pvFraunces(
              fontSize: 40, fontWeight: FontWeight.w600, color: skin.p.ink1)),
    ]);
  }
}

// =============================================================================
//  Painters
// =============================================================================

class _RingPainter extends CustomPainter {
  const _RingPainter(
      {required this.progress,
      required this.accent,
      required this.track,
      this.twoMarkers = false});
  final double progress;
  final Color accent;
  final Color track;
  final bool twoMarkers;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 6;

    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = track);

    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = accent);

    // ⚠️ TWO MARKERS FOR THE ONE PRACTICE THAT IS FOR TWO PEOPLE. It is a small
    // thing and it is the only thing on screen that says "this one is not
    // yours alone" — which is the entire point of that card.
    final dots = twoMarkers ? 2 : 1;
    for (var i = 0; i < dots; i++) {
      final a = -math.pi / 2 + 2 * math.pi * progress + (i * 0.22);
      canvas.drawCircle(c + Offset(math.cos(a) * r, math.sin(a) * r), 6,
          Paint()..color = accent);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.twoMarkers != twoMarkers ||
      old.accent != accent ||
      old.track != track;
}

/// A body outline with one region lit. [highlight] runs 0 (head) → 1 (feet).
// ⚠️ MOVED TO `lib/widgets/figure_highlight.dart` as `PvFigurePainter`,
// 2026-09-12. Kept for revert.
// class _FigurePainter extends CustomPainter {
//   const _FigurePainter(
//       {required this.highlight, required this.accent, required this.line});
//   final double highlight;
//   final Color accent;
//   final Color line;
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final stroke = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.4
//       ..strokeCap = StrokeCap.round
//       ..color = line;
//
//     final cx = size.width / 2;
//     final top = 14.0;
//     final bottom = size.height - 10;
//
//     // head, spine, arms, legs — deliberately schematic. It is a position
//     // indicator, not an anatomy drawing.
//     canvas.drawCircle(Offset(cx, top + 10), 10, stroke);
//     canvas.drawLine(Offset(cx, top + 22), Offset(cx, bottom - 34), stroke);
//     canvas.drawLine(Offset(cx - 26, top + 40), Offset(cx + 26, top + 40), stroke);
//     canvas.drawLine(
//         Offset(cx, bottom - 34), Offset(cx - 18, bottom), stroke);
//     canvas.drawLine(
//         Offset(cx, bottom - 34), Offset(cx + 18, bottom), stroke);
//
//     final y = top + (bottom - top) * highlight.clamp(0.0, 1.0);
//     canvas.drawCircle(
//         Offset(cx, y),
//         17,
//         Paint()..color = accent.withValues(alpha: 0.20));
//   }
//
//   @override
//   bool shouldRepaint(_FigurePainter old) =>
//       old.highlight != highlight ||
//       old.accent != accent ||
//       old.line != line;
// }
