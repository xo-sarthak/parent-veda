// =============================================================================
//  Baby Movement Tracker  (Week 28+)
// -----------------------------------------------------------------------------
//  Awareness, not counting. One big tap area logs a movement timestamp; the
//  primary screen NEVER shows counts — only reassurance and timestamps. Counts
//  live in History / Doctor reference. An optional memory note saves to Dear
//  Baby. Philosophy per the product spec.
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

class _BabyMovementScreenState extends State<BabyMovementScreen> {
  final _store = ToolsStore.instance;
  final _noteCtrl = TextEditingController();
  bool _justLogged = false;

  @override
  void initState() {
    super.initState();
    _store.init();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  S get _s => S(widget.controller.language);

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
        title: Text(s.movementToolTitle),
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
          final times = _store.todayMovements;
          final active = _store.babyActiveToday;
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
              // Big tap area.
              Center(child: _tapCircle(context)),
              const SizedBox(height: 20),
              if (active)
                Center(
                  child: Text(
                    '❤️ ${s.babyActiveTodayMsg}',
                    style: text.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
              // Today's movements — timestamps only, NO counts.
              if (times.isNotEmpty) ...[
                Text(s.todaysMovements, style: text.headlineSmall),
                const SizedBox(height: 10),
                for (final t in times.reversed)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outlineVariant),
                    ),
                    child: Row(children: [
                      const Text('❤️ ', style: TextStyle(fontSize: 14)),
                      Text(s.formatClock(t), style: text.bodyLarge),
                    ]),
                  ),
                const SizedBox(height: 16),
              ],
              // Optional memory → Dear Baby.
              _memoryCard(context),
            ],
          );
        },
      ),
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
//  History (counts live here, never on the tracking screen)
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
          final history = ToolsStore.instance.movementHistory;
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
              for (final day in history)
                _DayCard(
                  controller: controller,
                  dateIso: day.dateIso,
                  times: day.times,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.controller,
    required this.dateIso,
    required this.times,
  });

  final PregnancyController controller;
  final String dateIso;
  final List<DateTime> times;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final date = DateTime.tryParse(dateIso) ?? times.first;
    final start = times.first;
    final end = times.last;
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
          Text(s.formatLongDate(date), style: text.titleMedium),
          const SizedBox(height: 6),
          Text('${s.startWord}: ${s.formatClock(start)}   ·   '
              '${s.endWord}: ${s.formatClock(end)}',
              style: text.bodyMedium),
          const SizedBox(height: 4),
          Text(s.movementsLoggedCount(times.length),
              style: text.titleSmall?.copyWith(color: AppTheme.secondary600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in times)
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
