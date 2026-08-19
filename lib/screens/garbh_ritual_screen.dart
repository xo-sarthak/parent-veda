// =============================================================================
//  My ritual - what she already does, or wants to start
// -----------------------------------------------------------------------------
//  ⚠️ THE PREMISE IS THAT SHE ALREADY HAS ONE. Most Indian mothers do, and it
//  predates the app by years. A pregnancy app that ignores that and offers its
//  own practice instead is asking her to run two, which is how the app's one
//  loses. Asking what she already does and then putting it on the same card as
//  everything else costs nothing and makes the card hers.
//
//  ---------------------------------------------------------------------------
//  ⚠️ MULTI-FAITH BY CONSTRUCTION, NOT BY DISCLAIMER
//  ---------------------------------------------------------------------------
//  The list is deliberately not ordered by how common each practice is in
//  India. An ordering by majority puts every woman who is not in it below the
//  fold on the one screen that is explicitly about her own faith, and a note
//  saying "other traditions welcome" underneath does not undo that. So Gita,
//  Quran, Bible, japa and five minutes of silence are interleaved and sit at
//  the same weight. See `kGarbhRituals`.
//
//  ⚠️ AND "FIVE MINUTES OF SILENCE" IS IN THE SAME LIST, not in an "other"
//  bucket. A woman with no religious practice is not an exception to be
//  handled; she is one of the options.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE GITA PLAN IS THE STRONGEST ITEM AND IT IS THE ONLY ONE WITH A BAR
//  ---------------------------------------------------------------------------
//  Everything else here is a habit, and a habit has no end, so the only thing
//  it can ever do is break. The 40-week plan is a completion arc with a
//  deadline that lands the week before her due date, so every day moves a bar
//  that is visibly going somewhere. Giving the others a progress bar too would
//  flatten that difference and turn eight habits into eight things she is
//  behind on.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/garbh_rebuild_data.dart';
import '../localization/app_language.dart';
import '../services/pregnancy_controller.dart';
import '../theme/pv_fonts.dart';

const _ink = Color(0xFF2E2A32);
const _muted = Color(0xFF8A8290);
const _cream = Color(0xFFFBF9F6);
const _accent = Color(0xFF8A6D3B); // Kriya's warm gold - a practice, not a task

class GarbhRitualScreen extends StatelessWidget {
  const GarbhRitualScreen({super.key, required this.controller});

  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final store = GarbhJournalStore.instance;
    final lang = controller.language;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => Scaffold(
        backgroundColor: _cream,
        appBar: AppBar(
          backgroundColor: _cream,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          foregroundColor: _ink,
          title: Text('My ritual',
              style: pvFraunces(
                  fontSize: 18, fontWeight: FontWeight.w600, color: _ink)),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
            children: [
              Text('What do you already do, or want to start?',
                  style: pvFraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: _ink)),
              const SizedBox(height: 8),
              Text(
                  'Pick as many as you like. Whatever you choose appears on '
                  'your daily card, alongside everything else.',
                  style: pvManrope(fontSize: 13.5, height: 1.55, color: _muted)),
              const SizedBox(height: 24),

              for (final r in kGarbhRituals) ...[
                _RitualRow(
                  ritual: r,
                  on: store.hasRitual(r.id),
                  week: controller.currentWeek,
                  lang: lang,
                  onTap: () {
                    store.toggleRitual(r.id);
                    store.markRitualsAsked();
                  },
                ),
                const SizedBox(height: 10),
              ],

              const SizedBox(height: 18),
              // ⚠️ NOTHING IS COMPULSORY, AND SAYING SO IS PART OF THE SCREEN.
              // A multi-select with no explicit "none of these is fine" reads
              // as a form she has to fill, on a subject where being asked to
              // declare a practice she does not have would be worse than not
              // asking at all.
              Text(
                  'None of these is required. You can change this any time, '
                  'and skipping it changes nothing else in the app.',
                  style: pvManrope(fontSize: 12, height: 1.55, color: _muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RitualRow extends StatelessWidget {
  const _RitualRow({
    required this.ritual,
    required this.on,
    required this.week,
    required this.lang,
    required this.onTap,
  });

  final GarbhRitual ritual;
  final bool on;
  final int week;
  final AppLanguage lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final plan = ritual.isPlan ? gitaPlanProgress(week) : null;

    return Material(
      color: on ? _accent.withValues(alpha: 0.10) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 15, 14, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: on
                    ? _accent.withValues(alpha: 0.35)
                    : const Color(0x14000000)),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(
                      on
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 20,
                      color: on ? _accent : _muted),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ritual.name.of(lang),
                              style: pvFraunces(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _ink)),
                          const SizedBox(height: 3),
                          Text(ritual.blurb.of(lang),
                              style: pvManrope(
                                  fontSize: 12.5,
                                  height: 1.4,
                                  color: _muted)),
                        ]),
                  ),
                  if (ritual.hasCounter)
                    // A japa counter is a different shape from a done tick,
                    // and saying so on the row means she is not surprised by
                    // it later.
                    Text('COUNTER',
                        style: pvManrope(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.9,
                            color: _muted)),
                ]),

                // ---- the one progress bar in the section -----------------
                if (plan != null && on) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: plan.progress,
                      minHeight: 6,
                      backgroundColor: _accent.withValues(alpha: 0.18),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(_accent),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ⚠️ THE PROGRESS LINE SAYS PROGRESS ONLY. The promise
                  // that it lands before her due date already sits in the
                  // blurb above, where she reads it BEFORE choosing - which
                  // is where a promise belongs. Repeating it here made the
                  // same sentence appear twice in one card, which reads as a
                  // rendering bug rather than as emphasis. Found by a test
                  // asserting the phrase appears once.
                  Text(
                      plan.weeksLeft == 0
                          ? 'Finished, as planned.'
                          : 'Week $week of ${plan.finishWeek}. '
                              '${plan.weeksLeft} weeks to go.',
                      style: pvManrope(
                          fontSize: 12, height: 1.5, color: _ink)),
                ],
              ]),
        ),
      ),
    );
  }
}
