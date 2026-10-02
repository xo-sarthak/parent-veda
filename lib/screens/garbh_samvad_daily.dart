// =============================================================================
//  Samvad, daily - record in your voice
// -----------------------------------------------------------------------------
//  ⚠️ THE MOST IMPORTANT SCREEN IN THE REBUILD, and the change is not visual.
//
//  Samvad used to open on four tabs: Affirmations, Stories, Mantras, Spiritual
//  Reading. Tabs at the top of a daily practice make today's task ambiguous -
//  she arrives to do one thing and is handed a filing cabinet, so the first
//  decision of the day is which drawer, not whether to speak.
//
//  Now: one thing to say aloud, one primary action, and the library below the
//  fold where a library belongs.
//
//  ---------------------------------------------------------------------------
//  ⚠️ RECORDING IS THE DEFAULT, NARRATION IS THE FALLBACK, AND THAT ORDER IS
//  THE ENTIRE POINT OF THE SECTION
//  ---------------------------------------------------------------------------
//  A narrator reading a story to her baby is content. Her own voice reading it
//  is the thing her baby will recognise at birth, and it is the only thing
//  here that no other app can supply. The moment "Listen" is the primary
//  button, Garbh Sanskar becomes a podcast with a pregnancy theme.
//
//  So the narrator stays - a woman with a sore throat, no privacy, or simply
//  no wish to hear herself must not be locked out - but it is a quiet text
//  link, never a button of equal weight.
//
//  ⚠️ THE CONFIRMATION NEVER SAYS "COMPLETED". It says what happened for the
//  baby: "Your baby heard your voice for 2 min 40 sec today." Completion
//  language describes her performance; this describes the child's experience,
//  which is the difference the whole rebuild rests on.
//
//  ⚠️ AND IT WRITES TO MY JOURNAL ON SAVE. Nothing here is consumed and
//  discarded. See garbh_rebuild_data.dart.
// =============================================================================

import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../data/garbh_data.dart';
import 'doors/pv_door_chrome.dart' show pvDoorPad;
import 'garbh/garbh_daily_shell.dart';
import 'pregnancy/preg_chrome.dart' show pregFilledStyle;
import 'products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;
import '../models/garbh_content.dart';
import '../data/garbh_rebuild_data.dart';
// Kept for revert (2026-10-02): import '../localization/app_language.dart';
import '../services/garbh_narrator.dart';
import '../services/garbh_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/pv_fonts.dart';
import 'garbh_journal_screen.dart';

const _ink = Color(0xFF201C24); // V3 ink1
const _muted = Color(0xFF2F2C30); // V3 ink3
// ignore: unused_element
const _cream = Color(0xFFFFFFFF); // V3 ground — white since 2026-09-17; was 0xFFF5F3F6
const _accSamvad = Color(0xFFB98A7E);

class GarbhSamvadDailyScreen extends StatefulWidget {
  const GarbhSamvadDailyScreen({
    super.key,
    required this.controller,
    this.onOpenLibrary,
    this.piece,
    this.day,
  });

  final PregnancyController controller;

  /// The pregnancy day to serve; null is today. The home passes the day on its
  /// date strip so the piece it names is the piece she reads.
  final int? day;

  /// A specific passage to read, instead of today's rotation.
  ///
  /// ⚠️ SINCE THE DOOR. Talk & read's affirmation rail — "You are loved",
  /// "Grow gently" — opens each one HERE, on the record-first screen, rather
  /// than on the library's inline card. The point of the section is her
  /// voice; a card that opened a page with no record button would have quietly
  /// demoted the one thing no other app can supply. Null means today's piece.
  final GarbhPrompt? piece;

  /// The four shelves, below the fold. Passed in rather than imported so this
  /// screen does not reach into the 2,000-line pillar file.
  final VoidCallback? onOpenLibrary;

  @override
  State<GarbhSamvadDailyScreen> createState() =>
      _GarbhSamvadDailyScreenState();
}

class _GarbhSamvadDailyScreenState extends State<GarbhSamvadDailyScreen> {
  final AudioRecorder _rec = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _recording = false;
  bool _busy = false;
  String? _clipPath;
  int _elapsed = 0;
  Timer? _tick;

  /// ⚠️ CAPPED. The spec sets about five minutes, and the reason is Indian
  /// mobile data rather than attention span: an uncapped recording on a slow
  /// connection is a file that never finishes uploading the day the family
  /// flow ships.
  static const int _maxSeconds = 300;

  int get _week => widget.day == null
      ? widget.controller.currentWeek
      : garbhWeekForDay(widget.day!);
  int get _trimester => garbhTrimester(_week);

  @override
  void dispose() {
    _tick?.cancel();
    _rec.dispose();
    _player.dispose();
    // A narrator left reading to an empty room is the audio bug this app has
    // met before (see `RagaAudioStore`'s header).
    GarbhNarrator.instance.stop();
    super.dispose();
  }

  /// `samvad.<prompt id>` — a library piece's id already carries `rtb_`,
  /// a mantra's `mantra_`, a trimester prompt's is bare.
  String get _narrationKey => 'samvad.${_todaysPiece.id}';

  GarbhPrompt get _todaysPiece {
    if (widget.piece case final p?) return p;
    final pieces = samvadForTrimester(_trimester);
    final day = (widget.day ?? widget.controller.currentDay).clamp(1, 280);
    return pieces[(day - 1) % pieces.length];
  }

  Future<void> _toggleRecord() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (_recording) {
        await _stop();
      } else {
        await _start();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _start() async {
    if (!await _rec.hasPermission()) {
      if (!mounted) return;
      // ⚠️ NOT AN ERROR DIALOG. A refused mic is a normal answer, and the
      // narrator is right there - so this points at the way through rather
      // than at what went wrong.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'To record your voice, ParentVeda needs the microphone. You can '
            'still listen to the narrator below.'),
      ));
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final d = Directory('${dir.path}/garbh');
    if (!d.existsSync()) d.createSync(recursive: true);
    final path = '${d.path}/samvad_${DateTime.now().microsecondsSinceEpoch}.m4a';
    await _rec.start(const RecordConfig(), path: path);
    if (!mounted) return;
    setState(() {
      _recording = true;
      _elapsed = 0;
      _clipPath = null;
    });
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed++);
      if (_elapsed >= _maxSeconds) _toggleRecord();
    });
  }

  Future<void> _stop() async {
    _tick?.cancel();
    final path = await _rec.stop();
    if (!mounted) return;
    setState(() {
      _recording = false;
      _clipPath = path;
    });
  }

  Future<void> _playBack() async {
    final p = _clipPath;
    if (p == null) return;
    await _player.stop();
    await _player.play(DeviceFileSource(p));
  }

  /// ⚠️ SAVE IS WHERE COMPLETION FIRES, NOT WHERE RECORDING STOPS.
  ///
  /// Stopping is not finishing: she may want to hear it back and record it
  /// again, and a stop that silently counted the day would make the re-record
  /// button pointless. Completion belongs to the moment she decides the thing
  /// is good enough to keep.
  Future<void> _save() async {
    final p = _clipPath;
    if (p == null) return;
    final seconds = _elapsed;

    await GarbhJournalStore.instance.add(GarbhJournalEntry(
      id: 'voice_${DateTime.now().microsecondsSinceEpoch}',
      kind: GarbhEntryKind.myVoice,
      week: _week,
      tsMs: DateTime.now().millisecondsSinceEpoch,
      // ⚠️ THE TITLE, NOT THE TEXT — 2026-09-12. A story's text is two
      // hundred words, and the album lists titles; twelve rows of a whole
      // passage is an album she cannot read. `GarbhPrompt.title` exists for
      // exactly this ("a short name for the prompt").
      title: _todaysPiece.title,
      seconds: seconds,
      path: p,
    ));
    GarbhStore.instance.markDone('samvad');

    if (!mounted) return;
    setState(() {
      _clipPath = null;
      _elapsed = 0;
    });
    _showHeard(seconds);
  }

  void _showHeard(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    final said = mins > 0 ? '$mins min $secs sec' : '$secs sec';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.favorite_rounded, size: 34, color: _accSamvad),
          const SizedBox(height: 14),
          // ⚠️ THE SENTENCE THE WHOLE SCREEN EXISTS FOR. Never "completed".
          // Rewritten 2026-09-29: "Your baby heard your voice" was not true
          // before hearing starts (about week 18), so it now says what she did.
          Text('You spoke to your baby for $said today.',
              textAlign: TextAlign.center,
              style: pvFraunces(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: _ink)),
          const SizedBox(height: 10),
          Text("It's saved in My Journal, under week $_week.",
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 13, height: 1.5, color: _muted)),
        ]),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(MaterialPageRoute<void>(
                settings: const RouteSettings(name: 'garbh/journal'),
                builder: (_) => const GarbhJournalScreen(),
              ));
            },
            child: Text('See My Journal',
                style: pvManrope(
                    fontWeight: FontWeight.w700, color: _accSamvad)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Done',
                style:
                    pvManrope(fontWeight: FontWeight.w700, color: _muted)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.controller.language;
    final piece = _todaysPiece;

//  // Kept for revert (2026-10-02): the cream page, its app bar, the tinted "why" box and
//  // the filled `_RecordButton`. The pillar shell (`GarbhDailyShell`) replaced it.
//      return Scaffold(
//        backgroundColor: _cream,
//        appBar: AppBar(
//          backgroundColor: _cream,
//          surfaceTintColor: Colors.transparent,
//          elevation: 0,
//          foregroundColor: _ink,
//          title: Text(lang.isHindi ? 'संवाद' : 'Samvad',
//              style: pvFraunces(
//                  fontSize: 18, fontWeight: FontWeight.w600, color: _ink)),
//        ),
//        body: SafeArea(
//          top: false,
//          child: ListView(
//            padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
//            children: [
//              // ---- why today ------------------------------------------------
//              Container(
//                width: double.infinity,
//                padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
//                decoration: BoxDecoration(
//                  color: _accSamvad.withValues(alpha: 0.10),
//                  borderRadius: BorderRadius.circular(16),
//                ),
//                child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: [
//                      Text('WHY WEEK $_week MATTERS',
//                          style: pvManrope(
//                              fontSize: 9.5,
//                              fontWeight: FontWeight.w800,
//                              letterSpacing: 1.2,
//                              color: _accSamvad)),
//                      const SizedBox(height: 7),
//                      Text(garbhWeekReason(_week).of(lang),
//                          style: pvManrope(
//                              fontSize: 13.5, height: 1.6, color: _ink)),
//                    ]),
//              ),
//              const SizedBox(height: 26),
//
//              // ---- the one thing to say -------------------------------------
//              Text('SAY THIS ALOUD',
//                  style: pvManrope(
//                      fontSize: 9.5,
//                      fontWeight: FontWeight.w800,
//                      letterSpacing: 1.2,
//                      color: _muted)),
//              const SizedBox(height: 12),
//              Text(piece.text.of(lang),
//                  style: pvFraunces(
//                      fontSize: 20,
//                      fontWeight: FontWeight.w500,
//                      height: 1.5,
//                      color: _ink)),
//              const SizedBox(height: 26),
//
//              // ---- the primary action ---------------------------------------
//              _RecordButton(
//                recording: _recording,
//                elapsed: _elapsed,
//                busy: _busy,
//                onTap: _toggleRecord,
//              ),
//
//              if (_clipPath != null && !_recording) ...[
//                const SizedBox(height: 14),
//                // ⚠️ HEAR IT BEFORE KEEPING IT. Without playback the only way to
//                // find out what was recorded is to save it, and a mother who
//                // dislikes her own recording and cannot check first will not
//                // record a second time.
//                Row(children: [
//                  Expanded(
//                    child: OutlinedButton.icon(
//                      onPressed: _playBack,
//                      style: OutlinedButton.styleFrom(
//                          foregroundColor: _ink,
//                          side: const BorderSide(color: Color(0x22000000)),
//                          padding: const EdgeInsets.symmetric(vertical: 13)),
//                      icon: const Icon(Icons.play_arrow_rounded, size: 19),
//                      label: const Text('Listen back'),
//                    ),
//                  ),
//                  const SizedBox(width: 10),
//                  Expanded(
//                    child: OutlinedButton.icon(
//                      onPressed: () => setState(() {
//                        _clipPath = null;
//                        _elapsed = 0;
//                      }),
//                      style: OutlinedButton.styleFrom(
//                          foregroundColor: _muted,
//                          side: const BorderSide(color: Color(0x22000000)),
//                          padding: const EdgeInsets.symmetric(vertical: 13)),
//                      icon: const Icon(Icons.refresh_rounded, size: 19),
//                      label: const Text('Again'),
//                    ),
//                  ),
//                ]),
//                const SizedBox(height: 10),
//                SizedBox(
//                  width: double.infinity,
//                  child: FilledButton(
//                    onPressed: _save,
//                    style: FilledButton.styleFrom(
//                        backgroundColor: _accSamvad,
//                        padding: const EdgeInsets.symmetric(vertical: 15)),
//                    child: Text('Keep this',
//                        style: pvManrope(
//                            fontSize: 15,
//                            fontWeight: FontWeight.w700,
//                            color: Colors.white)),
//                  ),
//                ),
//              ],
//
//              const SizedBox(height: 18),
//              // ---- the narrator, quiet and secondary ------------------------
//              //
//              // ⚠️ REAL SINCE SAMVAD TO FINAL, 2026-09-12. It was a snackbar
//              // saying "coming soon". `GarbhNarrator` plays a recording when
//              // the narration manifest lists one under `samvad.<piece id>`,
//              // and the device's own voice at a gentle pace when it does not —
//              // so a professional narrator replaces the TTS one passage at a
//              // time by editing the manifest. Still a text link, never a
//              // button of equal weight: see the header.
//              AnimatedBuilder(
//                animation: GarbhNarrator.instance,
//                builder: (context, _) {
//                  final key = _narrationKey;
//                  final speaking = GarbhNarrator.instance.speakingKey == key;
//                  return Center(
//                    child: TextButton(
//                      onPressed: () => speaking
//                          ? GarbhNarrator.instance.stop()
//                          : GarbhNarrator.instance.speak(
//                              key, piece.text.of(lang),
//                              lang: lang),
//                      child: Text(
//                          speaking
//                              ? 'Stop the narrator'
//                              : 'Or listen to the narrator read it',
//                          style: pvManrope(
//                              fontSize: 12.5,
//                              fontWeight: FontWeight.w600,
//                              color: speaking ? _accSamvad : _muted)),
//                    ),
//                  );
//                },
//              ),
//
//              const SizedBox(height: 30),
//              // ---- the library, below the fold ------------------------------
//              //
//              // ⚠️ BELOW, NOT ON TOP. The four shelves are still here and still
//              // complete; what changed is that they no longer stand between her
//              // and today's task.
//              if (widget.onOpenLibrary != null)
//                Material(
//                  color: Colors.white,
//                  borderRadius: BorderRadius.circular(18),
//                  child: InkWell(
//                    onTap: widget.onOpenLibrary,
//                    borderRadius: BorderRadius.circular(18),
//                    child: Padding(
//                      padding: const EdgeInsets.fromLTRB(16, 15, 14, 16),
//                      child: Row(children: [
//                        const Icon(Icons.library_books_outlined,
//                            size: 20, color: _accSamvad),
//                        const SizedBox(width: 13),
//                        Expanded(
//                          child: Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              children: [
//                                Text('Choose something else to read',
//                                    style: pvManrope(
//                                        fontSize: 14,
//                                        fontWeight: FontWeight.w700,
//                                        color: _ink)),
//                                const SizedBox(height: 3),
//                                Text(
//                                    'Affirmations, stories, mantras and '
//                                    'spiritual reading.',
//                                    style: pvManrope(
//                                        fontSize: 12,
//                                        height: 1.4,
//                                        color: _muted)),
//                              ]),
//                        ),
//                        const Icon(Icons.chevron_right_rounded,
//                            size: 19, color: _muted),
//                      ]),
//                    ),
//                  ),
//                ),
//            ],
//          ),
//        ),
    // THE RECORD-FIRST LAYOUT (2026-10-02, Mobbin: Givingli's "Tap to Record",
    // Noom's recording close, Mindtrip's large readable passage). The piece is a
    // big serif card, the record disc is the one thing to press, and what comes
    // after (listen back, again, keep) is one row. The "why" is a line that opens.
    // Every piece of the recording logic above is as it was.
    final p = pvStorePalette;
    return GarbhDailyShell(
      pillarId: 'samvad',
      title: piece.title.of(lang),
      intro: 'Read this to your baby in your own voice. What you keep goes into '
          'My Journal.',
      children: [
        pvDoorPad(Container(
          key: const ValueKey('samvad_passage'),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x14000000)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SAY THIS ALOUD',
                style: pvManrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: p.ink3)),
            const SizedBox(height: 12),
            Text(piece.text.of(lang),
                style: pvFraunces(
                    fontSize: 21, fontWeight: FontWeight.w500, height: 1.55, color: p.ink1)),
          ]),
        )),
        const SizedBox(height: 26),
        Center(
          child: _RecordDisc(
            recording: _recording,
            elapsed: _elapsed,
            busy: _busy,
            onTap: _toggleRecord,
          ),
        ),
        if (_clipPath != null && !_recording) ...[
          const SizedBox(height: 18),
          // ⚠️ HEAR IT BEFORE KEEPING IT. Without playback the only way to find out
          // what was recorded is to save it, and a mother who dislikes her own
          // recording and cannot check first will not record a second time.
          pvDoorPad(Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const ValueKey('samvad_listen'),
                onPressed: _playBack,
                style: OutlinedButton.styleFrom(
                    foregroundColor: kPvInk,
                    side: const BorderSide(color: kPvLine, width: 1.5),
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(48)),
                icon: const Icon(Icons.play_arrow_rounded, size: 19),
                label: const Text('Listen back'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                key: const ValueKey('samvad_again'),
                onPressed: () => setState(() {
                  _clipPath = null;
                  _elapsed = 0;
                }),
                style: OutlinedButton.styleFrom(
                    foregroundColor: p.ink2,
                    side: const BorderSide(color: kPvLine, width: 1.5),
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(48)),
                icon: const Icon(Icons.refresh_rounded, size: 19),
                label: const Text('Again'),
              ),
            ),
          ])),
          const SizedBox(height: 10),
          pvDoorPad(SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const ValueKey('samvad_keep'),
              onPressed: _save,
              style: pregFilledStyle().copyWith(
                  minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52))),
              child: Text('Keep this',
                  style: pvManrope(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          )),
        ],
        const SizedBox(height: 8),
        // ---- the narrator, quiet and secondary ---------------------------------
        //
        // ⚠️ REAL SINCE SAMVAD TO FINAL, 2026-09-12. `GarbhNarrator` plays a
        // recording when the narration manifest lists one under
        // `samvad.<piece id>`, and the device's own voice at a gentle pace when it
        // does not. Still a text link, never a button of equal weight.
        AnimatedBuilder(
          animation: GarbhNarrator.instance,
          builder: (context, _) {
            final key = _narrationKey;
            final speaking = GarbhNarrator.instance.speakingKey == key;
            return Center(
              child: TextButton(
                key: const ValueKey('samvad_narrator'),
                onPressed: () => speaking
                    ? GarbhNarrator.instance.stop()
                    : GarbhNarrator.instance.speak(key, piece.text.of(lang), lang: lang),
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                child: Text(
                    speaking ? 'Stop the narrator' : 'Or listen to the narrator read it',
                    style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: speaking ? p.ink1 : p.ink3)),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        const GarbhDoneLine(
            pillarId: 'samvad', finishLine: 'This finishes when you keep your recording.'),
        const SizedBox(height: 18),
        // On the page, not folded: why this week is the question this section
        // exists to answer.
        garbhNote('samvad', 'Why week $_week matters', garbhWeekReason(_week).of(lang)),
        // The library, below the fold: still here and still complete; it just
        // no longer stands between her and today's task.
        if (widget.onOpenLibrary != null) ...[
          const SizedBox(height: 10),
          GarbhOnwardRow(
            pillarId: 'samvad',
            label: 'Choose something else to read',
            onTap: widget.onOpenLibrary!,
          ),
        ],
      ],
    );
  }
}

// Kept for revert (2026-10-02): the wide filled button; `_RecordDisc` replaced it.
/// The one big button. Recording state is the label and the colour, never a
/// second control.
// ignore: unused_element
class _RecordButton extends StatelessWidget {
  const _RecordButton({
    required this.recording,
    required this.elapsed,
    required this.busy,
    required this.onTap,
  });

  final bool recording;
  final int elapsed;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = elapsed ~/ 60;
    final s = (elapsed % 60).toString().padLeft(2, '0');
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: busy ? null : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: recording ? const Color(0xFFB3261E) : _accSamvad,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        icon: Icon(recording ? Icons.stop_rounded : Icons.mic_rounded,
            size: 22, color: Colors.white),
        label: Text(
            recording ? 'Stop  ·  $m:$s' : 'Record in your voice',
            style: pvManrope(
                fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}

/// The one thing to press: a big round FilledButton disc with its own words. Idle
/// it says "Record in your voice"; recording it says "Stop · m:ss", and a halo
/// widens behind it. State is the icon, the words and the halo, never a second
/// control (Givingli's "Tap to Record").
///
/// ⚠️ A FILLED BUTTON, STILL: the rebuild's rule is that recording is the one
/// filled control on this screen and the narrator is a text link
/// (`garbh_rebuild_pass2_test.dart` holds it by widget type).
class _RecordDisc extends StatelessWidget {
  const _RecordDisc({
    required this.recording,
    required this.elapsed,
    required this.busy,
    required this.onTap,
  });

  final bool recording;
  final int elapsed;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = elapsed ~/ 60;
    final s = (elapsed % 60).toString().padLeft(2, '0');
    return Semantics(
      container: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 148,
        height: 148,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kPvInk.withValues(alpha: recording ? 0.20 : 0.10),
              blurRadius: 26,
              spreadRadius: recording ? 14 : 6,
            ),
          ],
        ),
        child: FilledButton(
          key: const ValueKey('samvad_record'),
          onPressed: busy ? null : onTap,
          style: FilledButton.styleFrom(
            backgroundColor: kPvInk,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(14),
            fixedSize: const Size(148, 148),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(recording ? Icons.stop_rounded : Icons.mic_rounded, size: 40),
              const SizedBox(height: 6),
              Text(recording ? 'Stop  ·  $m:$s' : 'Record in your voice',
                  key: recording ? const ValueKey('samvad_timer') : null,
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(1.0),
                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, height: 1.25)),
            ]),
          ),
        ),
      ),
    );
  }
}
