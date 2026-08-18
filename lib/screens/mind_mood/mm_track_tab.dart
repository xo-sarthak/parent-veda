// =============================================================================
//  Track tab - mood check-in, mood patterns, worry journal
// -----------------------------------------------------------------------------
//  ⚠️ NO GAMIFICATION ANYWHERE IN THIS FILE. No streak counter, no "you
//  missed a day", no score, no percentage. Mood patterns render as a row of
//  soft dots and one sentence, never a chart with axes.
//
//  Two of the section's five crisis-path triggers live here:
//    - a worry-journal entry that matches `mmTextHasSafetySignal`
//    - a mood trend severe enough to trip `MmMoodTrend.severeSignal`
//  Both route through `openCrisisPath` from mm_crisis_path.dart, never a
//  bespoke copy of it. See that file's header for why.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/mind_mood_data.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'mm_crisis_path.dart';
import 'mm_talk_tab.dart' show showCounsellingBookingSheet;

class MmTrackTab extends StatefulWidget {
  const MmTrackTab({super.key});

  @override
  State<MmTrackTab> createState() => _MmTrackTabState();
}

class _MmTrackTabState extends State<MmTrackTab> {
  final _store = MindMoodStore.instance;
  final _journalCtrl = TextEditingController();
  String? _activePromptId;

  @override
  void dispose() {
    _journalCtrl.dispose();
    super.dispose();
  }

  void _save(V2Palette p) {
    final text = _journalCtrl.text;
    if (text.trim().isEmpty) return;
    final signal = _store.addJournalEntry(text, promptId: _activePromptId);
    _journalCtrl.clear();
    setState(() => _activePromptId = null);
    FocusScope.of(context).unfocus();
    if (signal) {
      // A gentle, dismissible offer - never a trap, and it never repeats her
      // own words back to her.
      openCrisisPath(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Saved. This stays private to you.'),
        backgroundColor: p.ink1,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  String _dateLabel(int ts) {
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final todayMood = _store.todayMoodId;
        final trend = _store.trend;
        final entries = _store.journalEntries;

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 40),
          children: [
            Text('How are you feeling, today?',
                style: pvFraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                    color: p.ink1)),
            const SizedBox(height: 4),
            Text('No streak, no missed days. Just today.',
                style: pvManrope(fontSize: 12.5, color: p.ink3)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final m in kMmMoodOptions)
                  _MoodChip(
                    option: m,
                    selected: m.id == todayMood,
                    p: p,
                    onTap: () => _store.logMood(m.id),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            Text('How the last few weeks have felt',
                style: pvFraunces(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: p.ink1)),
            const SizedBox(height: 12),
            _TrendCard(trend: trend, p: p),
            if (trend.softNudge) ...[
              const SizedBox(height: 12),
              _NudgeCard(
                p: p,
                text: 'This has been a hard stretch. Talking to someone can '
                    'help.',
                ctaLabel: 'Talk to a counsellor',
                onTap: () => showCounsellingBookingSheet(context),
              ),
            ],
            if (trend.severeSignal) ...[
              const SizedBox(height: 10),
              _NudgeCard(
                p: p,
                text: 'It might help to talk to someone right now, not just '
                    'when it feels easier to.',
                ctaLabel: 'Talk to someone now',
                onTap: () => openCrisisPath(context),
              ),
            ],
            const SizedBox(height: 32),
            Text('Worry journal',
                style: pvFraunces(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: p.ink1)),
            const SizedBox(height: 4),
            Text('Private, and just for you. No one reads this but you.',
                style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < kMmJournalPrompts.length; i++)
                  _PromptChip(
                    label: kMmJournalPrompts[i].now,
                    selected: _activePromptId == 'p$i',
                    p: p,
                    onTap: () {
                      setState(() {
                        _activePromptId = 'p$i';
                        _journalCtrl.text = kMmJournalPrompts[i].now;
                        _journalCtrl.selection = TextSelection.collapsed(
                            offset: _journalCtrl.text.length);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.line),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _journalCtrl,
                minLines: 4,
                maxLines: 8,
                style: pvManrope(fontSize: 14, height: 1.5, color: p.ink1),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write whatever is on your mind.',
                  hintStyle: pvManrope(fontSize: 14, color: p.ink3),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: p.surface,
                    foregroundColor: p.ink1,
                    side: BorderSide(color: p.ink1.withValues(alpha: 0.25)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                onPressed: () => _save(p),
                child: const Text('Save'),
              ),
            ),
            if (entries.isNotEmpty) ...[
              const SizedBox(height: 26),
              Text('Earlier entries',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink3)),
              const SizedBox(height: 10),
              for (final e in entries) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: p.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_dateLabel(e.ts),
                                style: pvManrope(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: p.ink3)),
                            const SizedBox(height: 4),
                            Text(e.text,
                                style: pvManrope(
                                    fontSize: 13, height: 1.5, color: p.ink1)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _store.deleteJournalEntry(e.id),
                        icon: Icon(Icons.close_rounded, size: 16, color: p.ink3),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip(
      {required this.option, required this.selected, required this.p, required this.onTap});
  final MmMoodOption option;
  final bool selected;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(268, p);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? tint : p.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? Colors.transparent : p.line),
          ),
          child: Text(option.label.now,
              style: pvManrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? p.ink1 : p.ink2)),
        ),
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip(
      {required this.label, required this.selected, required this.p, required this.onTap});
  final String label;
  final bool selected;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? p.surfaceAlt : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: p.line),
          ),
          child: Text(label,
              style: pvManrope(fontSize: 11.5, color: p.ink2)),
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.trend, required this.p});
  final MmMoodTrend trend;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    if (!trend.hasEnoughData) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
            'Check in for a few days and this will gently show you the '
            'shape of how you have been feeling.',
            style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2)),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            for (final tone in trend.recentTones)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: v2BlockTint(268, p)
                        .withValues(alpha: 0.35 + tone * 0.13),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
            trend.softNudge
                ? 'Over the last little while, your check-ins have leaned '
                    'heavy.'
                : 'A gentle mix, the way most stretches are.',
            style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2)),
      ]),
    );
  }
}

class _NudgeCard extends StatelessWidget {
  const _NudgeCard(
      {required this.p, required this.text, required this.ctaLabel, required this.onTap});
  final V2Palette p;
  final String text;
  final String ctaLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(text, style: pvManrope(fontSize: 13, height: 1.5, color: p.ink1)),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onTap,
            child: Text(ctaLabel,
                style: pvManrope(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink1)),
          ),
        ),
      ]),
    );
  }
}
