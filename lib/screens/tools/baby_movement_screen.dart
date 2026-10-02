// =============================================================================
//  Baby Movement Tracker  (Week 28+)
// -----------------------------------------------------------------------------
//  Awareness, not counting. Movements are grouped into SESSIONS: the mother taps
//  "Start Session", logs movements by tapping the heart, and the session ends
//  when she taps "End Session" - or when she leaves this screen / the app is
//  backgrounded. History shows one entry per session (e.g. "20 June · Session 2").
//  The primary screen NEVER shows a long scroll of timestamps: it gives a calm
//  count + the last time, with all times one tap away. An optional memory note
//  saves to Dear Baby. Philosophy per the product spec.
//
//  ⚠️ ONE PARENTVEDA (2026-09-30, the pregnancy restyle). The trying-to-
//  conceive tool shape through `preg_chrome.dart`: the serif page title under
//  a bare back arrow, the disclaimer as a quiet note on the page (not an amber
//  box), white cards with the hairline, and the one ink for the heart she taps
//  and every button. Movement records moved from the app bar into the page as
//  a row with a drawn mark, named for what it opens.
//
//  ⚠️ REDRAWN AROUND ONE CONTROL (2026-10-02, the user: "do the same for the baby
//  movement tracker: the Mobbin pass, the UI, UX and usability"). The same pass
//  as the contraction timer, with the same references: Garmin's hydration
//  counter (a big numeral in a circle you tap, with the last time under it,
//  https://mobbin.com/screens/0bae4e24-9731-4f36-8b1c-91e5545a873c), Oura's and
//  Messages' one-numeral timer, and Shop's and Structured's timelines (an event
//  as a dot on a line, the full list one tap away).
//    · THE HEART IS THE COUNT: one disc, the number of movements in it, nothing
//      pinned and no second button to find. Idle, the same disc is "start".
//    · THE CHIPS BECAME A LINE: each movement is a dot on the session's own
//      timeline, so a cluster or a quiet stretch shows at a glance; the times
//      are one tap away.
//    · THE NOTE FOLDS: "Remember this moment" opens only when she wants it.
//    · NO TARGET, ON PURPOSE. The tool is awareness, not counting; the disc
//      shows a count and never a goal, a ring to fill or a "good" number.
//    · THE TWO READS at the foot are the reader's own "Read next" rail
//      (`pregToolReadNext`), the way they sit at the end of an article.
//  Every clinical line is word for word what it was.
// =============================================================================

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/app_language.dart';
import '../../services/daily_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/tools_store.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart';
// Kept for revert (the start card's own mark, now the hero's): import '../doors/pv_list_row.dart' show PvMarkWell;
import '../../data/reads/pregnancy_reads_weekly_a.dart' show kPregWeekReadPrefix;
import '../doors/pv_door_router.dart' show openPvDoorRead;
import '../pregnancy/preg_chrome.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../pregnancy/preg_tool_parts.dart';
import '../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;

/// The Tools tab's "Track" hue, so the marks here match the row she tapped.
const double _kMovementHue = 206;

/// The page title on a pushed tool page, announced as a heading.
Widget _pageTitle(String text) =>
    Semantics(header: true, child: Text(text, style: pregPageTitleStyle()));

/// A card's own title: the serif, smaller than a section heading.
TextStyle _cardTitleStyle() => pvFraunces(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  height: 1.2,
  letterSpacing: -0.3,
  color: pvStorePalette.ink1,
);

/// A tag or a time: a neutral pill (a tint is allowed on a pill).
Widget _pill(String label, {bool strong = false}) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  decoration: BoxDecoration(
    color: pvStorePalette.surfaceAlt,
    borderRadius: BorderRadius.circular(999),
  ),
  child: Text(
    label,
    style: pvManrope(
      fontSize: strong ? 12.5 : 12,
      fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
      color: strong ? pvStorePalette.ink1 : pvStorePalette.ink2,
    ),
  ),
);

class BabyMovementScreen extends StatefulWidget {
  const BabyMovementScreen({super.key, required this.controller});

  final PregnancyController controller;

  @override
  State<BabyMovementScreen> createState() => _BabyMovementScreenState();
}

class _BabyMovementScreenState extends State<BabyMovementScreen>
    with WidgetsBindingObserver {
  final _store = ToolsStore.instance;
  final _noteCtrl = TextEditingController();
  bool _justLogged = false;

  /// Whether the (otherwise confined) list of this session's times is expanded.
  bool _showAllTimes = false;

  /// How many recent times to show before "View all times".
  static const _timesPreview = 12;

  /// Redraws the page twice a minute while a session runs, so the length of
  /// the session and the end of its timeline keep up without her touching it.
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && _store.hasActiveMovementSession) setState(() {});
    });
    _store.init();
    // No auto-start: the mother begins a session explicitly.
  }

  @override
  void dispose() {
    _tick?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    // Leaving this screen ends the active session.
    _store.endMovementSession();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Backgrounding / closing the app ends the active session too.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _store.endMovementSession();
    }
  }

  S get _s => S(widget.controller.language);

  Future<void> _startSession() async {
    await _store.startMovementSession();
    if (mounted) setState(() => _showAllTimes = false);
  }

  Future<void> _endSession() async {
    final messenger = ScaffoldMessenger.of(context);
    final hadMovements = _store.currentSessionCount > 0;
    await _store.endMovementSession();
    if (!mounted) return;
    setState(() => _showAllTimes = false);
    if (hadMovements) {
      messenger.showSnackBar(SnackBar(content: Text(_s.sessionSavedMsg)));
    }
  }

  Future<void> _logMovement() async {
    await _store.logMovement();
    setState(() => _justLogged = true);
    await Future.delayed(const Duration(milliseconds: 1300));
    if (mounted) setState(() => _justLogged = false);
  }

  Future<void> _saveNote() async {
    final text = _noteCtrl.text.trim();
    if (text.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    FocusScope.of(context).unfocus();
    await DailyStore.instance.addDearBabyNote(
      week: widget.controller.currentWeek,
      prompt: _s.movementNotePrompt,
      text: text,
    );
    _noteCtrl.clear();
    messenger.showSnackBar(SnackBar(content: Text(_s.movementNoteSaved)));
  }

  void _openRecords() => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _MovementHistoryScreen(controller: widget.controller),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = _s;
    // The shell is unchanged (hero, eyebrow, title, the intro only while idle).
    // What is inside it is the one disc and what follows from it.
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final active = _store.hasActiveMovementSession;
        return PregToolScaffold(
          hue: _kMovementHue,
          eyebrow: 'Track',
          title: s.babyMovementTracker,
          mark: active ? null : IntentMark.stepsMark,
          intro: active
              ? null
              : 'A calm way to log your baby\'s movements, one session at a time.',
          children: [
            pregToolPad(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (active) ..._liveViews(context) else ..._idleViews(context),
                  const SizedBox(height: 18),
                  PregNote(s.movementDisclaimer),
                  const SizedBox(height: 22),
                  PregRowCard(
                    children: [
                      PregOfferRow(
                        key: const ValueKey('movement_records_row'),
                        mark: IntentMark.chartLog,
                        hue: _kMovementHue,
                        title: s.movementRecordsTitle,
                        line: 'Every session, with its times',
                        onTap: _openRecords,
                      ),
                    ],
                  ),
                  if (!active) ...[
                    const SizedBox(height: 14),
                    // The teaching the PDF found missing, folded. The line she
                    // must not miss is the title, so it is always on the page.
                    PregFoldRow(
                      keyPrefix: 'bm_fold',
                      fold: 'pattern',
                      icon: Icons.favorite_border_rounded,
                      title:
                          'Fewer, weaker or different movements? Call the same day',
                      body: Text(
                        'From about 28 weeks the pattern matters more than a count. Get to know how '
                        "your baby usually moves. Babies don't move less as they run out of room. If "
                        'the movements are fewer, weaker or different, call your doctor or hospital '
                        'the same day, at any hour. You do not need to count unless your doctor asks you to.',
                        style: pvManrope(
                            fontSize: 13.5, height: 1.55, color: pvStorePalette.ink2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // The two reads, as the reader's own foot: small tiles with their
            // pictures. Not while a session runs, so the heart stays above the fold.
            if (!active) ...[
              const SizedBox(height: 26),
              ...pregToolReadNext(
                context,
                widget.controller,
                const [
                  '${kPregWeekReadPrefix}movement_awareness',
                  'preg_cond_read_less_movement',
                ],
                railKey: const ValueKey('movement_read_next'),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  // ---- No session: the same disc, as "start" --------------------------------

  List<Widget> _idleViews(BuildContext context) {
    final s = _s;
    return [
      Center(
        child: _MovementDisc(
          key: const ValueKey('bm_disc_idle'),
          active: false,
          count: 0,
          label: s.startSession,
          semanticLabel: s.startSession,
          pulse: false,
          onTap: _startSession,
        ),
      ),
      const SizedBox(height: 14),
      // One line, not the paragraph the start card carried (kept in `_startViews`).
      Text(
        s.babyMovedSub,
        textAlign: TextAlign.center,
        style: pvManrope(fontSize: 13.5, height: 1.5, color: pvStorePalette.ink3),
      ),
    ];
  }

  // ---- A session: the heart is the count ------------------------------------

  List<Widget> _liveViews(BuildContext context) {
    final s = _s;
    final p = pvStorePalette;
    final times = _store.currentSessionMovements;
    final count = times.length;
    final session = _store.activeMovementSession;
    final start = DateTime.tryParse(session?.startIso ?? '') ??
        (times.isEmpty ? DateTime.now() : times.first);
    final now = DateTime.now();
    final mins = now.difference(start).inMinutes;
    return [
      Center(
        child: _MovementDisc(
          key: const ValueKey('bm_disc_active'),
          active: true,
          count: count,
          label: _justLogged ? s.movementLogged : s.babyMovedLabel,
          semanticLabel: '${s.babyMovedLabel}. ${s.movementsLoggedCount(count)}',
          pulse: _justLogged,
          onTap: _logMovement,
        ),
      ),
      const SizedBox(height: 20),
      if (count == 0)
        // The empty state keeps its invitation, in one line.
        Text(
          s.babyMovedSub,
          key: const ValueKey('bm_empty'),
          textAlign: TextAlign.center,
          style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink3),
        )
      else ...[
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: _stat('Last movement', s.formatClock(times.last))),
            VerticalDivider(width: 1, thickness: 1, color: kPvLine),
            Expanded(
                child: _stat(s.thisSessionLabel, mins < 1 ? '<1m' : '${mins}m')),
          ]),
        ),
        const SizedBox(height: 18),
        PregCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: _MovementStrip(
            key: const ValueKey('bm_strip'),
            start: start,
            end: now.isAfter(times.last) ? now : times.last,
            times: times,
            startLabel: s.formatClock(start),
            endLabel: 'now',
          ),
        ),
        const SizedBox(height: 12),
        PregFoldRow(
          keyPrefix: 'bm_fold',
          fold: 'times',
          icon: Icons.schedule_rounded,
          title: s.thisSessionLabel,
          count: '$count',
          body: _timesWrap(context, times),
        ),
      ],
      const SizedBox(height: 12),
      PregFoldRow(
        keyPrefix: 'bm_fold',
        fold: 'note',
        icon: Icons.favorite_rounded,
        title: s.rememberThisMoment,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            key: const ValueKey('bm_note_field'),
            controller: _noteCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(hintText: s.movementNoteHint),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: pregFilledStyle(),
              onPressed: _saveNote,
              icon: const Icon(Icons.favorite_rounded, size: 18),
              label: Text(s.talkSaveCta,
                  style: pvManrope(fontSize: 14, fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 14),
      OutlinedButton.icon(
        key: const ValueKey('bm_end'),
        onPressed: _endSession,
        style: OutlinedButton.styleFrom(
          foregroundColor: kPvInk,
          side: const BorderSide(color: kPvLine, width: 1.5),
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(48),
        ),
        icon: const Icon(Icons.stop_circle_outlined),
        label: Text(s.endSession,
            style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700)),
      ),
    ];
  }

  Widget _stat(String label, String value) {
    final p = pvStorePalette;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(value,
          style: pvManrope(fontSize: 22, fontWeight: FontWeight.w800, color: p.ink1)),
      const SizedBox(height: 2),
      Text(label,
          textAlign: TextAlign.center,
          style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, color: p.ink3)),
    ]);
  }

  // Kept for revert (2026-10-02): the start card, the heart with its words, the
  // chips, and the note card always open. `build` replaced it.
  // ignore: unused_element
  Widget _buildClassic(BuildContext context) {
    final s = _s;
    // FRONT PAGE ON THE TOOL SHELL (2026-09-30, Tools audit). The shell's hero
    // (mark, eyebrow, title, intro) replaces the app bar and the in-body title.
    // The intro is one short line while she is idle; while a session RUNS the
    // hero shrinks to eyebrow and title (no mark, no intro) so the heart she taps
    // stays above the fold. The doctor-first disclaimer is a quiet note under the
    // session block in both states (a long intro pushed Start below the fold at
    // 320 wide with large text, found in the smoke test).
    // Kept for revert: Scaffold(appBar: AppBar(), body: ListView([_pageTitle(
    //   s.babyMovementTracker), PregNote(s.movementDisclaimer), ...])).
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final active = _store.hasActiveMovementSession;
        return PregToolScaffold(
          hue: _kMovementHue,
          eyebrow: 'Track',
          title: s.babyMovementTracker,
          mark: active ? null : IntentMark.stepsMark,
          intro: active
              ? null
              : 'A calm way to log your baby\'s movements, one session at a time.',
          children: [
            pregToolPad(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (active)
                    ..._activeViews(context)
                  else
                    ..._startViews(context),
                  const SizedBox(height: 18),
                  PregNote(s.movementDisclaimer),
                  const SizedBox(height: 22),
                  // The records (was the app bar's "History"): a row that opens
                  // somewhere, named for the page it opens.
                  PregRowCard(
                    children: [
                      PregOfferRow(
                        key: const ValueKey('movement_records_row'),
                        mark: IntentMark.chartLog,
                        hue: _kMovementHue,
                        title: s.movementRecordsTitle,
                        line: 'Every session, with its times',
                        onTap: _openRecords,
                      ),
                    ],
                  ),
                  // The teaching the PDF found missing (2026-09-30, "Movement
                  // counting", P3: the gap is "when and why to know the pattern").
                  // Not drawn during a session, so the heart stays above the fold.
                  // The words are the short answers of two reads that already exist.
                  if (!active) ...[
                    const SizedBox(height: 28),
                    const PregSectionHeading("Knowing your baby's pattern"),
                    const SizedBox(height: 8),
                    Text(
                        'From about 28 weeks the pattern matters more than a count. Get to know how '
                        "your baby usually moves. Babies don't move less as they run out of room. If "
                        'the movements are fewer, weaker or different, call your doctor or hospital '
                        'the same day, at any hour. You do not need to count unless your doctor asks you to.',
                        style: pvManrope(fontSize: 14, height: 1.55, color: pvStorePalette.ink2)),
                    const SizedBox(height: 12),
                    PregRowCard(
                      children: [
                        PregOfferRow(
                          key: const ValueKey('movement_read_awareness'),
                          mark: IntentMark.bookMark,
                          hue: _kMovementHue,
                          title: "Knowing your baby's movements",
                          line: "How to learn your baby's pattern, and why the advice is to call, not wait",
                          onTap: () => openPvDoorRead(context, '${kPregWeekReadPrefix}movement_awareness', widget.controller),
                        ),
                        PregOfferRow(
                          key: const ValueKey('movement_read_less'),
                          mark: IntentMark.askDoctor,
                          hue: _kMovementHue,
                          title: 'When the baby moves less',
                          line: "Don't wait until tomorrow, and don't count first",
                          onTap: () => openPvDoorRead(context, 'preg_cond_read_less_movement', widget.controller),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ---- No active session: invite the mother to start one -------------------

  List<Widget> _startViews(BuildContext context) {
    final s = _s;
    final p = pvStorePalette;
    return [
      // Kept for revert: a coral block (secondary50, radius 22) with a 🤰
      // emoji and a coral button. A white card, a drawn mark, the ink.
      PregCard(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
        child: Column(
          children: [
            // REDUNDANT (2026-09-30, Tools audit): the hero already wears this
            // tool's mark. Kept for revert:
            // PvMarkWell(p: p, hue: _kMovementHue, size: 64, mark: IntentMark.bodyMark),
            // const SizedBox(height: 14),
            // Kept for revert (the title said what the button below says, and
            // the sub-line sat between her and the button):
            // Text(s.startSessionTitle, textAlign: TextAlign.center, style: _cardTitleStyle()),
            // const SizedBox(height: 8),
            // Text(s.startSessionSub, textAlign: TextAlign.center, style: ...),
            // const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _startSession,
                style: pregFilledStyle().copyWith(
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(
                  s.startSession,
                  style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              s.startSessionSub,
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2),
            ),
          ],
        ),
      ),
    ];
  }

  // ---- Active session: tap to log, confined summary, end button ------------

  List<Widget> _activeViews(BuildContext context) {
    final s = _s;
    return [
      Center(child: _tapCircle(context)),
      const SizedBox(height: 22),
      _sessionSummary(context),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _endSession,
          // Kept for revert: coral words on a coral edge (secondary600 /
          // secondary300).
          style: OutlinedButton.styleFrom(
            foregroundColor: kPvInk,
            side: const BorderSide(color: kPvLine, width: 1.5),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.stop_circle_outlined),
          label: Text(
            s.endSession,
            style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      const SizedBox(height: 20),
      _memoryCard(context),
    ];
  }

  /// A calm, confined summary of the current session: a big count, the last
  /// time, and all times one tap away - never a long scroll.
  Widget _sessionSummary(BuildContext context) {
    final s = _s;
    final p = pvStorePalette;
    final times = _store.currentSessionMovements; // oldest → newest
    final count = times.length;

    return SizedBox(
      width: double.infinity,
      child: PregCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(s.thisSessionLabel, style: _cardTitleStyle()),
                ),
                // Kept for revert: a coral pill (secondary50 / secondary600).
                Flexible(
                  child: _pill(s.movementsLoggedCount(count), strong: true),
                ),
              ],
            ),
            if (count == 0) ...[
              const SizedBox(height: 10),
              Text(
                s.noMovementsThisSession,
                style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2),
              ),
            ] else ...[
              const SizedBox(height: 8),
              // Kept for revert: the line led with a ❤️ emoji. A small glyph.
              Row(
                children: [
                  Icon(Icons.favorite_border_rounded, size: 15, color: p.ink3),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      s.lastMovementAt(s.formatClock(times.last)),
                      style: pvManrope(fontSize: 13.5, color: p.ink2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _timesWrap(context, times),
            ],
          ],
        ),
      ),
    );
  }

  /// Compact wrapped time chips. Confined to the most-recent [_timesPreview] with
  /// a "View all times" toggle, so a busy day never becomes an endless scroll.
  Widget _timesWrap(BuildContext context, List<DateTime> times) {
    final s = _s;
    final p = pvStorePalette;
    final newestFirst = times.reversed.toList();
    final overflow = newestFirst.length - _timesPreview;
    final shown = _showAllTimes
        ? newestFirst
        : newestFirst.take(_timesPreview).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final t in shown) _pill(s.formatClock(t))],
        ),
        if (overflow > 0) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _showAllTimes = !_showAllTimes),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                _showAllTimes ? s.hideTimesLabel : s.viewAllTimes,
                // Kept for revert: color: AppTheme.secondary600.
                style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: p.ink1,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _tapCircle(BuildContext context) {
    final s = _s;
    // The one thing she presses, so the one ink. Kept for revert: coral
    // (secondary500, secondary400 on a tap) with a coral glow and a ❤️ emoji.
    // The heart stays as a white glyph: the copy says "tap the heart".
    final fill = _justLogged ? pvStorePalette.ink2 : kPvInk;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: _logMovement,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            boxShadow: [
              BoxShadow(
                color: kPvInk.withValues(alpha: 0.18),
                blurRadius: 28,
                spreadRadius: _justLogged ? 6 : 2,
              ),
            ],
          ),
          // FittedBox: at a large text size the circle's words shrink to fit
          // rather than overflow (2026-09-30).
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  _justLogged ? s.movementLogged : s.babyMovedLabel,
                  textAlign: TextAlign.center,
                  style: pvFraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    s.babyMovedSub,
                    textAlign: TextAlign.center,
                    style: pvManrope(
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _memoryCard(BuildContext context) {
    final s = _s;
    // Kept for revert: a grey block (neutral50, radius 18). A white card.
    return PregCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.rememberThisMoment, style: _cardTitleStyle()),
          const SizedBox(height: 10),
          TextField(
            controller: _noteCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(hintText: s.movementNoteHint),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: pregFilledStyle(),
              onPressed: _saveNote,
              icon: const Icon(Icons.favorite_rounded, size: 18),
              label: Text(
                s.talkSaveCta,
                style: pvManrope(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  The disc and the timeline (2026-10-02)
// ---------------------------------------------------------------------------

/// The one control: idle it is a white disc that starts a session; in a session
/// it is the ink heart with the number of movements in it. A tap logs one.
class _MovementDisc extends StatelessWidget {
  const _MovementDisc({
    super.key,
    required this.active,
    required this.count,
    required this.label,
    required this.semanticLabel,
    required this.pulse,
    required this.onTap,
  });

  final bool active;
  final int count;
  final String label;
  final String semanticLabel;

  /// Just logged: the halo widens for a moment.
  final bool pulse;
  final VoidCallback onTap;

  static const double size = 236;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final onInk = active ? Colors.white : p.ink1;
    final quiet = active ? Colors.white.withValues(alpha: 0.82) : p.ink3;
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: active
              ? [
                  BoxShadow(
                    color: kPvInk.withValues(alpha: pulse ? 0.22 : 0.12),
                    blurRadius: 30,
                    spreadRadius: pulse ? 12 : 4,
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: active ? (pulse ? p.ink2 : kPvInk) : Colors.white,
          shape: CircleBorder(
            side: active
                ? BorderSide.none
                : const BorderSide(color: kPvLine, width: 7),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              onTap();
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (active) ...[
                      Icon(Icons.favorite_rounded, size: 26, color: quiet),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('$count',
                            key: const ValueKey('bm_count'),
                            style: pvManrope(
                                fontSize: 72,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                                letterSpacing: -1.5,
                                color: onInk)),
                      ),
                    ] else
                      Icon(Icons.play_arrow_rounded, size: 58, color: onInk),
                    const SizedBox(height: 6),
                    Text(label,
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1.0),
                        style: pvManrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            height: 1.25,
                            color: quiet)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A session as a line from its start to now (or its end), with a dot for each
/// movement. A cluster and a quiet stretch both show at a glance. It states no
/// norm: there is no "good" gap drawn on it.
class _MovementStrip extends StatelessWidget {
  const _MovementStrip({
    super.key,
    required this.start,
    required this.end,
    required this.times,
    required this.startLabel,
    required this.endLabel,
  });

  final DateTime start;
  final DateTime end;
  final List<DateTime> times;
  final String startLabel;
  final String endLabel;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    // A session under a minute long is drawn as a minute, so two taps in the
    // first seconds do not sit on top of each other at the left edge.
    final spanMs = math.max(end.difference(start).inMilliseconds, 60000);
    return Column(children: [
      SizedBox(
        height: 30,
        child: CustomPaint(
          size: const Size(double.infinity, 30),
          painter: _StripPainter(
            fractions: [
              for (final t in times)
                (t.difference(start).inMilliseconds / spanMs).clamp(0.0, 1.0),
            ],
            line: kPvLine,
            dot: kPvInk,
          ),
        ),
      ),
      const SizedBox(height: 6),
      Row(children: [
        Text(startLabel,
            textScaler: const TextScaler.linear(1.0),
            style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink3)),
        const Spacer(),
        Text(endLabel,
            textScaler: const TextScaler.linear(1.0),
            style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink3)),
      ]),
    ]);
  }
}

class _StripPainter extends CustomPainter {
  _StripPainter({required this.fractions, required this.line, required this.dot});
  final List<double> fractions;
  final Color line;
  final Color dot;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 7.0;
    final y = size.height / 2;
    canvas.drawLine(
        Offset(pad, y),
        Offset(size.width - pad, y),
        Paint()
          ..color = line
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
    final w = size.width - pad * 2;
    for (var i = 0; i < fractions.length; i++) {
      final newest = i == fractions.length - 1;
      canvas.drawCircle(
        Offset(pad + w * fractions[i], y),
        newest ? 7 : 5,
        Paint()..color = newest ? dot : dot.withValues(alpha: 0.55),
      );
    }
  }

  @override
  bool shouldRepaint(_StripPainter old) =>
      old.fractions.length != fractions.length ||
      old.line != line ||
      old.dot != dot ||
      !_same(old.fractions, fractions);

  static bool _same(List<double> a, List<double> b) {
    for (var i = 0; i < a.length && i < b.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

// ---------------------------------------------------------------------------
//  History (one entry per session; counts live here, never on the tracker)
// ---------------------------------------------------------------------------

class _MovementHistoryScreen extends StatelessWidget {
  const _MovementHistoryScreen({required this.controller});

  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final p = pvStorePalette;
    return Scaffold(
      // Kept for revert: appBar: AppBar(title: Text(s.movementRecordsTitle)).
      appBar: AppBar(),
      body: AnimatedBuilder(
        animation: ToolsStore.instance,
        builder: (context, _) {
          final history = ToolsStore.instance.movementSessionHistory;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
            children: [
              _pageTitle(s.movementRecordsTitle),
              const SizedBox(height: 10),
              if (history.isEmpty)
                // The empty state keeps its words, under the title now.
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    s.noMovementsYet,
                    style: pvManrope(
                      fontSize: 13.5,
                      height: 1.5,
                      color: p.ink3,
                    ),
                  ),
                )
              else ...[
                Text(
                  s.movementRecordsIntro,
                  style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2),
                ),
                const SizedBox(height: 16),
                for (final rec in history)
                  _SessionCard(controller: controller, rec: rec),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.controller, required this.rec});

  final PregnancyController controller;
  final MovementSessionRecord rec;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final p = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PregCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.formatLongDate(rec.start),
                    style: pvManrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: p.ink1,
                    ),
                  ),
                ),
                // Kept for revert: a coral pill (secondary50 / secondary600).
                _pill(s.sessionNumber(rec.dayIndex), strong: true),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${s.startWord}: ${s.formatClock(rec.start)}   ·   '
              '${s.endWord}: ${s.formatClock(rec.end)}',
              style: pvManrope(fontSize: 13, color: p.ink2),
            ),
            const SizedBox(height: 4),
            Text(
              s.movementsLoggedCount(rec.times.length),
              style: pvManrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: p.ink1,
              ),
            ),
            const SizedBox(height: 12),
            // The session as a line, and its times one tap away (2026-10-02).
            // Kept for revert: a Wrap of every time as a pill, always open.
            _MovementStrip(
              start: rec.start,
              end: rec.end.isAfter(rec.start) ? rec.end : rec.times.last,
              times: rec.times,
              startLabel: s.formatClock(rec.start),
              endLabel: s.formatClock(rec.end),
            ),
            const SizedBox(height: 10),
            PregFoldRow(
              keyPrefix: 'bm_hist',
              fold: rec.id,
              icon: Icons.schedule_rounded,
              title: s.viewAllTimes,
              count: '${rec.times.length}',
              body: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final t in rec.times) _pill(s.formatClock(t))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
