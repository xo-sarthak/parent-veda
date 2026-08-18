// =============================================================================
//  Feel tab - calm right now
// -----------------------------------------------------------------------------
//  Everything here is free. Breathing (the most-used tool - built for real,
//  see mm_breathing_screen.dart), Calm-now/SOS (a real 60-second grounding
//  flow, not a link to one), guided meditations and calming audio (both
//  honest PvVideoPlaceholder/stub cards - the files do not exist yet, the
//  shape they will arrive in does), and an on-demand affirmation card.
//
//  ⚠️ SOS REPEAT DETECTION LIVES HERE, WIRED TO `MindMoodStore.registerSosOpen`
//  - three opens inside fifteen minutes surfaces the crisis path once the
//  grounding flow finishes. See CLAUDE.md's crisis-path rule; the path itself
//  lives in mm_crisis_path.dart and is never rebuilt here.
// =============================================================================

import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/garbh_data.dart' show kSamvadT1;
import '../../data/mind_mood_data.dart';
import '../../models/garbh_content.dart' show GarbhPrompt;
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_placeholders.dart';
import '../v2/v2_palette.dart';
import 'mm_breathing_screen.dart';
import 'mm_crisis_path.dart';

class MmFeelTab extends StatelessWidget {
  const MmFeelTab({super.key});

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 40),
      children: [
        _SosCard(p: p),
        const SizedBox(height: 26),
        _SectionHeading(p: p, text: 'Breathing exercises'),
        const SizedBox(height: 4),
        Text(
            'A guided, animated follow-along. Pick what your body needs '
            'right now.',
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
        const SizedBox(height: 14),
        for (final ex in kMmBreathingExercises) ...[
          _BreathingCard(exercise: ex, p: p),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 16),
        Text('Prefer to watch along?',
            style: pvManrope(
                fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink3)),
        const SizedBox(height: 10),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kMmBreathingExercises.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final ex = kMmBreathingExercises[i];
              return SizedBox(
                width: 220,
                child: PvVideoPlaceholder(
                  title: '${ex.name.now}, guided',
                  subtitle: ex.description.now,
                  duration: '3 MIN',
                  hue: 344, // SolutionType.watch's hue, app-wide
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 30),
        _SectionHeading(p: p, text: 'Guided meditations'),
        const SizedBox(height: 4),
        Text(
            'For you, not for the baby. Garbh Sanskar already holds that '
            'connection - this is just for you.',
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
        const SizedBox(height: 14),
        for (final m in kMmMeditations) ...[
          PvVideoPlaceholder(
            title: m.title.now,
            subtitle: m.subtitle.now,
            duration: m.durationLabel.now,
            hue: 344,
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 16),
        _SectionHeading(p: p, text: 'Calming audio'),
        const SizedBox(height: 12),
        for (final a in kMmCalmAudio) ...[
          _AudioRow(audio: a, p: p),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 24),
        _AffirmationCard(p: p),
      ],
    );
  }
}

// =============================================================================
//  Calm-now / SOS
// =============================================================================

class _SosCard extends StatelessWidget {
  const _SosCard({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(160, p);
    final ink = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.34)
        .toColor();
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openSosFlow(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [tint, tint.withValues(alpha: 0.55)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.self_improvement_rounded, size: 26, color: ink),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calm now',
                      style: pvFraunces(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: p.ink1)),
                  const SizedBox(height: 3),
                  Text('60 seconds. A breath, then grounding, then steady.',
                      style: pvManrope(
                          fontSize: 12.5, height: 1.4, color: p.ink2)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: ink),
          ]),
        ),
      ),
    );
  }
}

void _openSosFlow(BuildContext context) {
  final crossedThreshold = MindMoodStore.instance.registerSosOpen();
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: 'mind_mood_sos'),
    builder: (_) => _MmSosFlowScreen(offerCrisisAtEnd: crossedThreshold),
  ));
}

class _MmSosFlowScreen extends StatefulWidget {
  const _MmSosFlowScreen({required this.offerCrisisAtEnd});
  final bool offerCrisisAtEnd;

  @override
  State<_MmSosFlowScreen> createState() => _MmSosFlowScreenState();
}

class _MmSosFlowScreenState extends State<_MmSosFlowScreen> {
  int _step = 0;
  bool _done = false;

  void _advance() {
    if (_step >= kMmSosFlow.length - 1) {
      setState(() => _done = true);
      return;
    }
    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(160, p);

    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(Icons.close_rounded, color: p.ink3),
              ),
            ),
            Expanded(
              child: Center(
                child: _done
                    ? _SosClosing(offerCrisis: widget.offerCrisisAtEnd, p: p)
                    : _SosStepView(
                        key: ValueKey(_step),
                        step: kMmSosFlow[_step],
                        tint: tint,
                        p: p,
                        onDone: _advance,
                      ),
              ),
            ),
            if (!_done) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < kMmSosFlow.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _step ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i <= _step ? tint : p.line,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 26),
            ],
          ]),
        ),
      ),
    );
  }
}

class _SosStepView extends StatefulWidget {
  const _SosStepView(
      {super.key, required this.step, required this.tint, required this.p, required this.onDone});
  final MmSosStep step;
  final Color tint;
  final V2Palette p;
  final VoidCallback onDone;

  @override
  State<_SosStepView> createState() => _SosStepViewState();
}

class _SosStepViewState extends State<_SosStepView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: widget.step.seconds), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    final icon = switch (widget.step.kind) {
      MmSosStepKind.breath => Icons.air_rounded,
      MmSosStepKind.senses => Icons.visibility_outlined,
      MmSosStepKind.steadying => Icons.spa_outlined,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
              color: widget.tint.withValues(alpha: 0.55), shape: BoxShape.circle),
          child: Icon(icon, size: 38, color: widget.p.ink1),
        ),
        const SizedBox(height: 26),
        Text(widget.step.prompt.now,
            textAlign: TextAlign.center,
            style: pvFraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: widget.p.ink1)),
        const SizedBox(height: 20),
        TextButton(
          onPressed: widget.onDone,
          child: Text('Next',
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: widget.p.ink3)),
        ),
      ],
    );
  }
}

class _SosClosing extends StatelessWidget {
  const _SosClosing({required this.offerCrisis, required this.p});
  final bool offerCrisis;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.check_circle_outline_rounded, size: 44, color: p.ink2),
      const SizedBox(height: 18),
      Text(
          offerCrisis
              ? 'You have reached for calm a few times in a short while today.'
              : 'That is the full flow.',
          textAlign: TextAlign.center,
          style: pvFraunces(
              fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)),
      const SizedBox(height: 10),
      Text(
          offerCrisis
              ? 'That matters, and it might help to talk it through with a '
                  'real person too, not just breathe through it alone.'
              : 'However you feel right now is exactly the right way to feel.',
          textAlign: TextAlign.center,
          style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
      const SizedBox(height: 26),
      if (offerCrisis) ...[
        SizedBox(
          width: 220,
          child: FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: p.surface,
                foregroundColor: p.ink1,
                side: BorderSide(color: p.ink1.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(vertical: 13)),
            onPressed: () => openCrisisPath(context),
            child: const Text('Talk to someone now'),
          ),
        ),
        const SizedBox(height: 10),
      ],
      TextButton(
        onPressed: () => Navigator.of(context).maybePop(),
        child: Text(offerCrisis ? "I'm okay for now" : 'Done',
            style: pvManrope(fontSize: 13, color: p.ink3)),
      ),
    ]);
  }
}

// =============================================================================
//  Small pieces
// =============================================================================

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.p, required this.text});
  final V2Palette p;
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: pvFraunces(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: p.ink1));
}

class _BreathingCard extends StatelessWidget {
  const _BreathingCard({required this.exercise, required this.p});
  final MmBreathingExercise exercise;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(160, p);
    final ink = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.36)
        .toColor();
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'mind_mood_breathing'),
          builder: (_) => MmBreathingScreen(exercise: exercise),
        )),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.line),
          ),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: tint, borderRadius: BorderRadius.circular(13)),
              child: Icon(Icons.air_rounded, size: 22, color: ink),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name.now,
                      style: pvFraunces(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: p.ink1)),
                  const SizedBox(height: 3),
                  Text(exercise.description.now,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 12, height: 1.4, color: p.ink2)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

class _AudioRow extends StatelessWidget {
  const _AudioRow({required this.audio, required this.p});
  final MmCalmAudio audio;
  final V2Palette p;

  static const Map<String, IconData> _icons = {
    'rain': Icons.water_drop_outlined,
    'om': Icons.self_improvement_outlined,
    'instrumental': Icons.music_note_outlined,
    'humming': Icons.graphic_eq_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(344, p);
    return Semantics(
      label: 'Audio coming soon: ${audio.title.now}',
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration:
                BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)),
            child: Icon(_icons[audio.id] ?? Icons.graphic_eq_rounded,
                size: 20, color: p.ink2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(audio.title.now,
                    style: pvFraunces(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: p.ink1)),
                Text(audio.subtitle.now,
                    style: pvManrope(fontSize: 11.5, color: p.ink3)),
              ],
            ),
          ),
          Text('COMING SOON',
              style: pvManrope(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: p.ink3)),
        ]),
      ),
    );
  }
}

class _AffirmationCard extends StatefulWidget {
  const _AffirmationCard({required this.p});
  final V2Palette p;

  @override
  State<_AffirmationCard> createState() => _AffirmationCardState();
}

class _AffirmationCardState extends State<_AffirmationCard> {
  final _rng = Random();
  GarbhPrompt? _current;

  void _draw() {
    if (kSamvadT1.isEmpty) return;
    GarbhPrompt next;
    do {
      next = kSamvadT1[_rng.nextInt(kSamvadT1.length)];
    } while (kSamvadT1.length > 1 && next.id == _current?.id);
    setState(() => _current = next);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final tint = v2BlockTint(268, p);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint, p.surface],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('AFFIRMATIONS',
            style: pvManrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: p.ink3)),
        const SizedBox(height: 10),
        Text(
            _current?.text.now ??
                'A gentle word for whenever you need one. Tap below to '
                    'start.',
            style: pvFraunces(
                fontSize: 16.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: p.ink1)),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _draw,
            icon: Icon(Icons.refresh_rounded, size: 17, color: p.ink2),
            label: Text(_current == null ? 'Show me one' : 'Another one',
                style: pvManrope(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink2)),
          ),
        ),
      ]),
    );
  }
}
