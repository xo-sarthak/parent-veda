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
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../services/daily_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/tools_store.dart';
import '../../theme/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    final s = _s;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.babyMovementTracker),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  _MovementHistoryScreen(controller: widget.controller),
            )),
            icon: const Icon(Icons.history_rounded, size: 18),
            label: Text(s.historyLabel),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          final active = _store.hasActiveMovementSession;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              // Disclaimer (always visible).
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.fatherAmber.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(s.movementDisclaimer, style: text.bodySmall),
              ),
              const SizedBox(height: 24),
              if (active) ..._activeViews(context) else ..._startViews(context),
            ],
          );
        },
      ),
    );
  }

  // ---- No active session: invite the mother to start one -------------------

  List<Widget> _startViews(BuildContext context) {
    final s = _s;
    final text = Theme.of(context).textTheme;
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
        decoration: BoxDecoration(
          color: AppTheme.secondary50,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            const Text('🤰', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 14),
            Text(s.startSessionTitle,
                textAlign: TextAlign.center, style: text.headlineSmall),
            const SizedBox(height: 8),
            Text(
              s.startSessionSub,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: AppTheme.neutral700),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _startSession,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.secondary500,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(s.startSession),
              ),
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
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.secondary600,
            side: const BorderSide(color: AppTheme.secondary300),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.stop_circle_outlined),
          label: Text(s.endSession),
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
    final text = Theme.of(context).textTheme;
    final times = _store.currentSessionMovements; // oldest → newest
    final count = times.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(s.thisSessionLabel, style: text.titleMedium)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.secondary50,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  s.movementsLoggedCount(count),
                  style: text.labelLarge?.copyWith(
                    color: AppTheme.secondary600,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (count == 0) ...[
            const SizedBox(height: 10),
            Text(s.noMovementsThisSession,
                style: text.bodyMedium?.copyWith(color: AppTheme.neutral600)),
          ] else ...[
            const SizedBox(height: 6),
            Text('❤️ ${s.lastMovementAt(s.formatClock(times.last))}',
                style: text.bodyMedium?.copyWith(color: AppTheme.neutral700)),
            const SizedBox(height: 12),
            _timesWrap(context, times),
          ],
        ],
      ),
    );
  }

  /// Compact wrapped time chips. Confined to the most-recent [_timesPreview] with
  /// a "View all times" toggle, so a busy day never becomes an endless scroll.
  Widget _timesWrap(BuildContext context, List<DateTime> times) {
    final s = _s;
    final text = Theme.of(context).textTheme;
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
          children: [
            for (final t in shown)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(s.formatClock(t), style: text.labelSmall),
              ),
          ],
        ),
        if (overflow > 0) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _showAllTimes = !_showAllTimes),
            behavior: HitTestBehavior.opaque,
            child: Text(
              _showAllTimes ? s.hideTimesLabel : s.viewAllTimes,
              style: text.labelLarge?.copyWith(
                color: AppTheme.secondary600,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _tapCircle(BuildContext context) {
    final s = _s;
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: _logMovement,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _justLogged ? AppTheme.secondary400 : AppTheme.secondary500,
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondary500.withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: _justLogged ? 6 : 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('❤️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              _justLogged ? s.movementLogged : s.babyMovedLabel,
              textAlign: TextAlign.center,
              style: text.titleLarge?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                s.babyMovedSub,
                textAlign: TextAlign.center,
                style: text.bodySmall
                    ?.copyWith(color: Colors.white.withValues(alpha: 0.92)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _memoryCard(BuildContext context) {
    final s = _s;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.rememberThisMoment, style: text.titleMedium),
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
              onPressed: _saveNote,
              icon: const Icon(Icons.favorite_rounded, size: 18),
              label: Text(s.talkSaveCta),
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
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(s.movementRecordsTitle)),
      body: AnimatedBuilder(
        animation: ToolsStore.instance,
        builder: (context, _) {
          final history = ToolsStore.instance.movementSessionHistory;
          if (history.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Text(s.noMovementsYet,
                    textAlign: TextAlign.center, style: text.bodyMedium),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Text(s.movementRecordsIntro, style: text.bodyMedium),
              const SizedBox(height: 16),
              for (final rec in history)
                _SessionCard(controller: controller, rec: rec),
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
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(s.formatLongDate(rec.start), style: text.titleMedium),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondary50,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  s.sessionNumber(rec.dayIndex),
                  style: text.labelMedium?.copyWith(
                    color: AppTheme.secondary600,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
              '${s.startWord}: ${s.formatClock(rec.start)}   ·   '
              '${s.endWord}: ${s.formatClock(rec.end)}',
              style: text.bodyMedium),
          const SizedBox(height: 4),
          Text(s.movementsLoggedCount(rec.times.length),
              style: text.titleSmall?.copyWith(color: AppTheme.secondary600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in rec.times)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(s.formatClock(t), style: text.labelSmall),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
