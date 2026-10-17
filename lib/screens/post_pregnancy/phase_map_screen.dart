// =============================================================================
//  PhaseMapScreen — the whole 0–5 year road, and where he is on it
// -----------------------------------------------------------------------------
//  Replaces the Leap Calendar. The difference is not cosmetic: the leap calendar
//  showed ten equal stops at fixed weeks, which was the part of the Wonder Weeks
//  framework that failed replication. This shows twenty AAP/CDC-aligned age
//  phases of deliberately unequal width, because that is how development is
//  actually checkpointed clinically.
//
//  Phases behind him are settled, the current one is marked, and the ones ahead
//  are readable but quiet. Nothing is locked — a parent can read ahead as far
//  as she likes.
//
//  ⚠️ REDESIGNED 2026-10-15 (the user: "very bland … random stuff listed, not
//  intuitive"). Mobbin §22: Noom's course map and Alan's journey (a painted
//  disc per stop on a dashed rail, the current stop ringed and larger),
//  Duolingo's section banners and Moonly's chapter headings (where am I in a
//  long road). So the screen now opens on HIM — the current phase as a painted
//  hero — and the twenty phases sit in five chapters a parent already uses
//  (Newborn, Baby, Young toddler, Toddler, Little kid), each stop with its own
//  painting. The chapters are derived from `startMonth`, never a list of
//  numbers, so a re-cut phase lands in the right chapter by itself.
//
//  Paintings: assets/phases/phase_NN.webp, one per phase, made from the
//  prompts in docs/PHASE-PAINTING-PROMPTS.md. A phase with no file yet shows
//  its number in a disc of its own accent (Image.asset's errorBuilder), so the
//  screen is complete before any painting arrives.
//
//  Wide (≥ 600, a tablet): the stops become a two-column grid of tiles and the
//  hero sits side by side; the column is capped at 720 and centred.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/pp_phase_docs.dart' show ppPhaseDocFor;
import 'phase_detail_screen.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_phases_data.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart' show PvPress;
import '../v2/v2_palette.dart';

/// The painting for phase [n] (1–20).
String phasePaintingPath(int n) =>
    'assets/phases/phase_${n.toString().padLeft(2, '0')}.webp';

/// The five chapters of the road, by where a phase starts.
const List<({String name, String span, double until})> kPhaseChapters = [
  (name: 'Newborn', span: '0–3 months', until: 3),
  (name: 'Baby', span: '3–12 months', until: 12),
  (name: 'Young toddler', span: '1–2 years', until: 24),
  (name: 'Toddler', span: '2–3 years', until: 36),
  (name: 'Little kid', span: '3–5 years', until: double.infinity),
];

/// Which chapter (index into [kPhaseChapters]) a phase belongs to.
int phaseChapterOf(AgePhase p) {
  for (var i = 0; i < kPhaseChapters.length; i++) {
    if (p.startMonth < kPhaseChapters[i].until) return i;
  }
  return kPhaseChapters.length - 1;
}

/// One line under a phase's name: the doc's first Living Through title, or
/// that its guide is coming. Never authored text (DOC-ONLY, 2026-10-14).
String phaseStopLine(AgePhase p) {
  final doc = ppPhaseDocFor(p.number);
  if (doc == null) return 'Guide coming';
  return doc.living.isNotEmpty ? doc.living.first.title : '';
}

// ⚠️ THE HOUSE LOOK, 2026-10-17 (the user: "very old UI, font not matching
// and very purple"). Every phase's `accent` is ppPurple (pp_phases_data.dart),
// so the whole road was lilac, and titles were Fraunces at w400 beside
// Pregnancy's w600. Colours now come from V2Palette, marks are ink, and
// headings take Pregnancy's section weight. The layout is unchanged.
// The old values are noted inline as "was ..." for revert.
V2Palette get _c => V2PaletteStore.instance.current;
const Color _mark = ppInk; // was phase.accent
TextStyle _serif(double size) => pvFraunces(
  fontSize: size,
  fontWeight: FontWeight.w600,
  height: 1.15,
  letterSpacing: -0.45,
  color: _c.ink1,
);

/// The first sentence of the doc's hero, for the "now" card.
String _firstSentence(String s) {
  final m = RegExp(r'^(.+?[.!?])(\s|$)').firstMatch(s.trim());
  return (m?.group(1) ?? s).trim();
}

class PhaseMapScreen extends StatefulWidget {
  const PhaseMapScreen({super.key});

  @override
  State<PhaseMapScreen> createState() => _PhaseMapScreenState();
}

class _PhaseMapScreenState extends State<PhaseMapScreen> {
  final _chapterKeys = List.generate(kPhaseChapters.length, (_) => GlobalKey());
  final _scroll = ScrollController();

  // ⚠️ THE CHIPS FOLLOW THE READER, 2026-10-17 (the user: "those toggles of
  // newborn, baby, young toddler aren't clickable"). They did scroll, but the
  // dark pill was pinned to his own chapter, and the last chapters can barely
  // scroll, so a tap looked dead. The pill now moves on tap and tracks the
  // chapter whose header has passed the top as she scrolls.
  int? _selected;
  bool _jumping = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_track);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _track() {
    if (_jumping) return;
    var at = -1;
    for (var i = 0; i < _chapterKeys.length; i++) {
      final box =
          _chapterKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy <= 160) at = i;
    }
    // Above the first chapter, the pill rests on his own chapter again.
    final next = at < 0 ? null : at;
    if (next != _selected) setState(() => _selected = next);
  }

  void _open(AgePhase p) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => PhaseDetailScreen(phase: p)));

  void _jump(int chapter) {
    setState(() => _selected = chapter);
    final c = _chapterKeys[chapter].currentContext;
    if (c != null) {
      _jumping = true;
      Scrollable.ensureVisible(
        c,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      ).whenComplete(() => _jumping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildProfileStore.instance;
    return Scaffold(
      backgroundColor: _c.ground, // was ppBg
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: Listenable.merge([child, V2PaletteStore.instance]),
          builder: (context, _) {
            final phases = kPhases;
            final currentIndex = phaseIndexForMonths(
              child.ageInMonths.toDouble(),
            );
            final now = phases[currentIndex];
            final nowChapter = phaseChapterOf(now);
            return LayoutBuilder(
              builder: (context, box) {
                final wide = box.maxWidth >= 600;
                final pad = wide ? 28.0 : 20.0;
                Widget padded(Widget w) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: w,
                );
                return SingleChildScrollView(
                  controller: _scroll,
                  padding: const EdgeInsets.only(top: 12, bottom: 44),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          padded(ppBackBar(context, 'My Child')), // was ppBack
                          const SizedBox(height: 10),
                          padded(ppEyebrow('Birth to five', color: _c.ink3)), // was ppPurple
                          const SizedBox(height: 6),
                          padded(
                            Text(
                              '${child.name}’s journey',
                              style: _serif(wide ? 32 : 28), // was ppFraunces(34 : 29) w400
                            ),
                          ),
                          const SizedBox(height: 18),
                          padded(
                            _NowHero(
                              phase: now,
                              wide: wide,
                              onOpen: () => _open(now),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _ChapterChips(
                            current: _selected ?? nowChapter,
                            onTap: _jump,
                            pad: pad,
                          ),
                          const SizedBox(height: 8),
                          for (var c = 0; c < kPhaseChapters.length; c++)
                            Padding(
                              key: _chapterKeys[c],
                              padding: EdgeInsets.fromLTRB(pad, 22, pad, 0),
                              child: _Chapter(
                                index: c,
                                phases: [
                                  for (final p in phases)
                                    if (phaseChapterOf(p) == c) p,
                                ],
                                currentNumber: now.number,
                                wide: wide,
                                onOpen: _open,
                              ),
                            ),
                          const SizedBox(height: 26),
                          padded(
                            Text(
                              'Every child moves through these at their own pace. The ages are where most children are, never a deadline — and your paediatrician knows your child better than any table does.',
                              textAlign: TextAlign.center,
                              style: ppBody(12, color: _c.ink3, h: 1.55),
                            ),
                          ),
                          const SizedBox(height: 10),
                          padded(
                            Text(
                              'Twenty phases from birth to five years, following the checkpoints paediatricians actually use. They are different lengths on purpose — development moves fastest at the start.',
                              textAlign: TextAlign.center,
                              style: ppBody(12, color: _c.ink3, h: 1.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// The phase's painting, or its number in a disc of its accent until the
/// painting exists.
class PhasePainting extends StatelessWidget {
  const PhasePainting({super.key, required this.phase, this.round = false});
  final AgePhase phase;
  final bool round;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      key: ValueKey('phase-fallback-${phase.number}'),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Was phase.accent at 0.16 and 0.32 (lilac).
          colors: [_c.surfaceAlt, _c.line],
        ),
      ),
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            '${phase.number}',
            style: pvFraunces(fontSize: 30, fontWeight: FontWeight.w600, color: _c.ink2), // was phase.accent
          ),
        ),
      ),
    );
    final img = Image.asset(
      phasePaintingPath(phase.number),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
    );
    return round ? ClipOval(child: img) : img;
  }
}

class _NowHero extends StatelessWidget {
  const _NowHero({
    required this.phase,
    required this.wide,
    required this.onOpen,
  });
  final AgePhase phase;
  final bool wide;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final doc = ppPhaseDocFor(phase.number);
    final line = doc != null && doc.hero.isNotEmpty
        ? _firstSentence(doc.hero.first)
        : kPhaseGuideComing;
    final picture = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: PhasePainting(phase: phase),
      ),
    );
    final words = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'PHASE ${phase.number} · ${phase.ageLabel.toUpperCase()} · NOW',
          style: ppBody(
            10.5,
            color: _c.ink2, // was phase.accent
            w: FontWeight.w800,
          ).copyWith(letterSpacing: 0.9),
        ),
        const SizedBox(height: 6),
        Text(phase.name, style: _serif(24)), // was ppFraunces w400
        const SizedBox(height: 6),
        Text(
          line,
          style: ppBody(13.5, color: _c.ink2, h: 1.5),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 14),
        PvPress(
          child: GestureDetector(
            onTap: onOpen,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                color: ppInk,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Open this phase',
                style: ppBody(
                  13.5,
                  color: Colors.white,
                  w: FontWeight.w700,
                  h: 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // Was phase.accent at 0.07 fill and 0.3 border (a lilac card).
        color: _c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _c.line),
      ),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: picture),
                const SizedBox(width: 20),
                Expanded(flex: 6, child: words),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                picture,
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: words,
                ),
              ],
            ),
    );
  }
}

class _ChapterChips extends StatelessWidget {
  const _ChapterChips({
    required this.current,
    required this.onTap,
    required this.pad,
  });
  final int current;
  final ValueChanged<int> onTap;
  final double pad;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Row(
        children: [
          for (var i = 0; i < kPhaseChapters.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            PvPress(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: i == current ? ppInk : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: i == current ? ppInk : ppLine),
                  ),
                  child: Text(
                    kPhaseChapters[i].name,
                    style: ppBody(
                      13,
                      color: i == current ? Colors.white : ppInk,
                      w: FontWeight.w700,
                      h: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chapter extends StatelessWidget {
  const _Chapter({
    required this.index,
    required this.phases,
    required this.currentNumber,
    required this.wide,
    required this.onOpen,
  });
  final int index;
  final List<AgePhase> phases;
  final int currentNumber;
  final bool wide;
  final ValueChanged<AgePhase> onOpen;

  @override
  Widget build(BuildContext context) {
    final ch = kPhaseChapters[index];
    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(ch.name, style: _serif(21))), // was ppFraunces w400
        Text(
          '${ch.span} · ${phases.length} ${phases.length == 1 ? 'phase' : 'phases'}',
          style: ppBody(12, color: _c.ink3, w: FontWeight.w600, h: 1.3),
        ),
      ],
    );
    final body = wide
        ? LayoutBuilder(
            builder: (context, box) {
              final w = (box.maxWidth - 14) / 2;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final p in phases)
                    SizedBox(
                      width: w,
                      child: _PhaseTile(
                        phase: p,
                        state: _stateOf(p),
                        onTap: () => onOpen(p),
                      ),
                    ),
                ],
              );
            },
          )
        : Column(
            children: [
              for (var i = 0; i < phases.length; i++)
                _PhaseStop(
                  phase: phases[i],
                  state: _stateOf(phases[i]),
                  first: i == 0,
                  last: i == phases.length - 1,
                  onTap: () => onOpen(phases[i]),
                ),
            ],
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 4),
        Container(height: 1, color: _c.line), // was ppHair
        const SizedBox(height: 12),
        body,
      ],
    );
  }

  _StopState _stateOf(AgePhase p) => p.number < currentNumber
      ? _StopState.past
      : p.number == currentNumber
      ? _StopState.now
      : _StopState.ahead;
}

enum _StopState { past, now, ahead }

/// A stop on the rail: a round painting, the dashed line through it, and the
/// phase beside it. The current stop is larger and ringed in its accent.
class _PhaseStop extends StatelessWidget {
  const _PhaseStop({
    required this.phase,
    required this.state,
    required this.first,
    required this.last,
    required this.onTap,
  });
  final AgePhase phase;
  final _StopState state;
  final bool first;
  final bool last;
  final VoidCallback onTap;

  static const double _rail = 84; // the column the discs sit in

  @override
  Widget build(BuildContext context) {
    final now = state == _StopState.now;
    final past = state == _StopState.past;
    final d = now ? 80.0 : 62.0;
    final line = phaseStopLine(phase);
    return PvPress(
      child: GestureDetector(
        key: ValueKey('phase-stop-${phase.number}'),
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _rail,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!(first && last))
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DashPainter(
                            color: _c.line,
                            topGap: first,
                            bottomGap: last,
                          ),
                        ),
                      ),
                    Container(
                      width: d + (now ? 8 : 0),
                      height: d + (now ? 8 : 0),
                      padding: EdgeInsets.all(now ? 3 : 0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: now ? _mark : _c.line, // was phase.accent : ppHair
                          width: now ? 2 : 1,
                        ),
                      ),
                      child: Opacity(
                        opacity: past ? 0.75 : 1,
                        child: PhasePainting(phase: phase, round: true),
                      ),
                    ),
                    if (past)
                      Positioned(
                        right: (_rail - d) / 2 - 2,
                        top: 10,
                        child: Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ppInk,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            '✓',
                            style: ppBody(
                              10,
                              color: Colors.white,
                              w: FontWeight.w800,
                              h: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: now ? 18 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              phase.ageLabel.toUpperCase(),
                              style: ppBody(
                                10.5,
                                color: now ? _mark : _c.ink3, // was phase.accent : ppMuted
                                w: FontWeight.w800,
                                h: 1.3,
                              ).copyWith(letterSpacing: 0.8),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (now) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _mark, // was phase.accent
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'NOW',
                                style: ppBody(
                                  9,
                                  color: Colors.white,
                                  w: FontWeight.w800,
                                  h: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        phase.name,
                        style: ppJakarta(
                          now ? 16.5 : 15,
                          color: past ? _c.ink2 : _c.ink1, // was ppSoft : ppTitleInk
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (line.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          line,
                          style: ppBody(
                            12.5,
                            color: past ? _c.ink3 : _c.ink2,
                            h: 1.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Center(
                child: Text('›', style: ppBody(22, color: _c.ink3, h: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A stop as a tile, for the two-column grid on a wide screen.
class _PhaseTile extends StatelessWidget {
  const _PhaseTile({
    required this.phase,
    required this.state,
    required this.onTap,
  });
  final AgePhase phase;
  final _StopState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final now = state == _StopState.now;
    final past = state == _StopState.past;
    final line = phaseStopLine(phase);
    return PvPress(
      child: GestureDetector(
        key: ValueKey('phase-stop-${phase.number}'),
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: now ? _mark : _c.line, // was phase.accent : ppHair
              width: now ? 1.6 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: past ? 0.8 : 1,
                      child: PhasePainting(phase: phase),
                    ),
                    if (now || past)
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _mark, // was now ? phase.accent : ppInk
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            now ? 'NOW' : '✓ Done',
                            style: ppBody(
                              10,
                              color: Colors.white,
                              w: FontWeight.w800,
                              h: 1.3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phase.ageLabel.toUpperCase(),
                      style: ppBody(
                        10.5,
                        color: now ? _mark : _c.ink3, // was phase.accent : ppMuted
                        w: FontWeight.w800,
                        h: 1.3,
                      ).copyWith(letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      phase.name,
                      style: ppJakarta(15, color: past ? _c.ink2 : _c.ink1),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (line.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        line,
                        style: ppBody(12.5, color: _c.ink2, h: 1.4),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The dashed rail behind the discs. A gap at the top of the first stop and
/// the bottom of the last, so the rail starts and ends at a painting.
class _DashPainter extends CustomPainter {
  const _DashPainter({
    required this.color,
    required this.topGap,
    required this.bottomGap,
  });
  final Color color;
  final bool topGap;
  final bool bottomGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final x = size.width / 2;
    final from = topGap ? size.height / 2 : 0.0;
    final to = bottomGap ? size.height / 2 : size.height;
    for (var y = from; y < to; y += 9) {
      canvas.drawLine(Offset(x, y), Offset(x, (y + 4).clamp(from, to)), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) =>
      old.color != color || old.topGap != topGap || old.bottomGap != bottomGap;
}

// ---------------------------------------------------------------------------
//  Kept for revert: the plain list this screen was until 2026-10-15.
// ---------------------------------------------------------------------------
// class PhaseMapScreen extends StatelessWidget {
//   const PhaseMapScreen({super.key});
//
//   Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
//
//   @override
//   Widget build(BuildContext context) {
//     final child = ChildProfileStore.instance;
//     return Scaffold(
//       backgroundColor: ppBg,
//       body: SafeArea(
//         bottom: false,
//         child: AnimatedBuilder(
//           animation: child,
//           builder: (context, _) {
//             final months = child.ageInMonths.toDouble();
//             final currentIndex = phaseIndexForMonths(months);
//             return ListView(
//               padding: const EdgeInsets.only(top: 12, bottom: 40),
//               children: [
//                 _pad(ppBack(context, 'My Child')),
//                 const SizedBox(height: 18),
//                 _pad(ppEyebrow('The road so far', color: ppPurple)),
//                 const SizedBox(height: 8),
//                 _pad(Text('${child.name}’s journey', style: ppFraunces(30, h: 1.1))),
//                 const SizedBox(height: 8),
//                 _pad(Text(
//                   'Twenty phases from birth to five years, following the checkpoints paediatricians actually use. They are different lengths on purpose — development moves fastest at the start.',
//                   style: ppBody(14, h: 1.55),
//                 )),
//                 const SizedBox(height: 24),
//                 for (var i = 0; i < kPhases.length; i++)
//                   _pad(_row(context, kPhases[i], i, currentIndex)),
//                 const SizedBox(height: 18),
//                 _pad(Text(
//                   'Every child moves through these at their own pace. The ages are where most children are, never a deadline — and your paediatrician knows your child better than any table does.',
//                   textAlign: TextAlign.center,
//                   style: ppBody(12, color: ppMuted, h: 1.55),
//                 )),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _row(BuildContext context, AgePhase p, int i, int currentIndex) {
//     final past = i < currentIndex;
//     final now = i == currentIndex;
//     final ink = past ? ppMuted : ppInk;
//
//     return PvPress(child: GestureDetector(
//       onTap: () => Navigator.of(context).push(
//         MaterialPageRoute<void>(builder: (_) => PhaseDetailScreen(phase: p)),
//       ),
//       behavior: HitTestBehavior.opaque,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 10),
//         padding: const EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color: now ? p.accent.withValues(alpha: 0.08) : Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: now ? p.accent.withValues(alpha: 0.45) : ppHair,
//             width: now ? 1.4 : 1,
//           ),
//         ),
//         child: Row(children: [
//           // The marker: settled behind him, ringed where he is, open ahead.
//           Container(
//             width: 12,
//             height: 12,
//             decoration: BoxDecoration(
//               color: past ? ppLine : (now ? p.accent : Colors.transparent),
//               shape: BoxShape.circle,
//               border: Border.all(color: now ? p.accent : ppLine, width: 2),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(children: [
//                 Flexible(
//                   child: Text(p.name,
//                       style: ppJakarta(14.5, color: ink), maxLines: 1, overflow: TextOverflow.ellipsis),
//                 ),
//                 if (now) ...[
//                   const SizedBox(width: 8),
//                   Text('NOW',
//                       style: ppBody(9, color: p.accent, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
//                 ],
//                 if (p.checkpoint && !now) ...[
//                   const SizedBox(width: 8),
//                   Icon(Icons.verified_outlined, size: 13, color: ppMuted.withValues(alpha: 0.8)),
//                 ],
//               ]),
//               const SizedBox(height: 3),
//               // Doc-only phases carry no tagline (2026-10-14). Was
//               // '${p.ageLabel} · ${p.tagline}'.
//               Text(
//                   p.tagline.isNotEmpty
//                       ? '${p.ageLabel} · ${p.tagline}'
//                       : phaseAwaitingDoc(p)
//                           ? '${p.ageLabel} · Guide coming'
//                           : p.ageLabel,
//                   style: ppBody(12.5, color: past ? ppMuted : ppSoft, h: 1.4),
//                   maxLines: 1, overflow: TextOverflow.ellipsis),
//             ]),
//           ),
//           const SizedBox(width: 8),
//           const Icon(Icons.chevron_right_rounded, size: 19, color: ppMuted),
//         ]),
//       ),
//     ));
//   }
// }
