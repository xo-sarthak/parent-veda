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
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../services/daily_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/tools_store.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart';
// Kept for revert (the start card's own mark, now the hero's): import '../doors/pv_list_row.dart' show PvMarkWell;
import '../pregnancy/preg_chrome.dart';
import '../pregnancy/preg_tool_chrome.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _store.init();
    // No auto-start: the mother begins a session explicitly.
  }

  @override
  void dispose() {
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
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final t in rec.times) _pill(s.formatClock(t))],
            ),
          ],
        ),
      ),
    );
  }
}
