// =============================================================================
//  JourneyMapScreen  —  "Your Pregnancy Journey" (the map)
// -----------------------------------------------------------------------------
//  A winding trail from Week 4 → Birth. Week checkpoints open the week card
//  stack; milestone nodes (achievement / medical / baby / mother / journey /
//  feature) open their own cards. A top progress card and a pulsing "you are
//  here" marker anchor the mother in her journey.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../localization/app_language.dart';
import '../models/journey_node.dart';
import '../services/journey_dates_store.dart';
import '../services/journey_nodes.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/journey/journey_geometry.dart';
import '../widgets/journey/journey_node.dart';
import '../widgets/journey/journey_palette.dart';
import '../widgets/journey/journey_celebration.dart';
import '../widgets/journey/journey_path.dart';
import '../widgets/journey/node_cards.dart';
import 'weekly_card_stack_screen.dart';

class JourneyMapScreen extends StatefulWidget {
  const JourneyMapScreen({super.key, required this.controller});

  final PregnancyController controller;

  @override
  State<JourneyMapScreen> createState() => _JourneyMapScreenState();
}

class _JourneyMapScreenState extends State<JourneyMapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;
  late final List<MapNode> _nodes;

  /// Drives the one-time auto-scroll that lands the map on the current week.
  final ScrollController _scroll = ScrollController();
  final GlobalKey _hereKey = GlobalKey();
  bool _landed = false;
  bool _catchUpDismissed = false;

  static const double _slotSpacing = 96;
  static const double _topPad = 44;
  static const double _bottomPad = 104;

  PregnancyController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _nodes = buildJourneyNodes();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();
    _pulse = CurvedAnimation(parent: _pulseController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// On first open, scroll so the "you are here" marker sits in the upper-middle
  /// of the viewport (~45% down): the mother opens focused on where she is now,
  /// with the road ahead toward Birth extending downward and away.
  void _maybeLandOnCurrent() {
    if (_landed || !mounted) return;
    final ctx = _hereKey.currentContext;
    if (ctx == null) return;
    _landed = true;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.45,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  /// The mother's current position as a DISPLAY index. The trail renders in
  /// NATURAL order (0 = the start / Week 4 at the top, count-1 = Birth at the
  /// bottom), so the display index is simply the ascending day-index.
  double _currentDisplayIndex() {
    if (_nodes.isEmpty) return 0;
    return _indexForDay(_c.currentDay.toDouble(), _nodes);
  }

  /// Index (in display order) of the node to LAND on when the map opens: the
  /// week checkpoint for the current week if present, else the nearest week
  /// checkpoint. Landing is WEEKLY — it always settles squarely on a week node,
  /// never on the fractional day-point between two weeks.
  int _currentWeekNodeIndex(List<MapNode> display) {
    final cw = _c.currentWeek;
    var best = 0;
    var bestDist = 1 << 30;
    for (var i = 0; i < display.length; i++) {
      final n = display[i];
      if (!n.isWeekCheckpoint || n.weekLabel == null) continue;
      if (n.weekLabel == cw) return i; // exact current-week checkpoint
      final d = (n.weekLabel! - cw).abs();
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return best;
  }

  /// Fractional slot index for an arbitrary pregnancy [day], over [list].
  double _indexForDay(double day, List<MapNode> list) {
    if (list.isEmpty) return 0;
    if (day <= list.first.posDay) return 0;
    if (day >= list.last.posDay) return (list.length - 1).toDouble();
    for (int i = 0; i < list.length - 1; i++) {
      final a = list[i].posDay;
      final b = list[i + 1].posDay;
      if (day >= a && day < b) {
        final span = b - a;
        final f = span <= 0 ? 0.0 : (day - a) / span;
        return i + f;
      }
    }
    return (list.length - 1).toDouble();
  }

  NodeState _weekState(int week) {
    if (week < _c.currentWeek) return NodeState.completed;
    if (week == _c.currentWeek) return NodeState.current;
    return NodeState.future;
  }

  void _openWeek(int week) {
    _c.selectWeek(week);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WeeklyCardStackScreen(controller: _c),
      ),
    );
  }

  void _openMilestone(JourneyMilestone m) {
    final reached = m.posDay <= _c.currentDay;
    final isMajor = m.type == JourneyNodeType.achievement ||
        m.type == JourneyNodeType.pvJourney;
    // Major milestones already reached get a full-screen celebration; future
    // ones (and all other types) open the adaptive preview/info card.
    if (reached && isMajor) {
      showJourneyCelebration(context, controller: _c, milestone: m);
    } else {
      showJourneyNodeCard(
        context,
        controller: _c,
        milestone: m,
        onViewWeek: _openWeek,
      );
    }
  }

  // --- late-joiner catch-up + overdue (additive — the trail is unchanged) -----

  /// Editable personal milestones already behind "now" that she hasn't dated yet
  /// — the moments a late-joiner can fill in so the map reflects HER journey.
  List<JourneyMilestone> _catchUpCandidates() {
    final cur = _c.currentDay;
    return _nodes
        .where((n) => n.milestone != null)
        .map((n) => n.milestone!)
        .where((m) =>
            m.isDatable &&
            m.posDay <= cur &&
            !JourneyDatesStore.instance.isEdited(m.id))
        .toList();
  }

  Widget _overdueBanner(S s) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: AppTheme.secondary100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Text('💛', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.jmOverdueTitle,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary900)),
              const SizedBox(height: 2),
              Text(s.jmOverdueBody(_c.daysPastDue),
                  style: GoogleFonts.manrope(
                      fontSize: 12, height: 1.35, color: AppTheme.neutral700)),
            ]),
          ),
        ]),
      );

  Widget _catchUpBanner(S s) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFFFF1E6), Color(0xFFFDE8F0)]),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppTheme.secondary500.withValues(alpha: 0.16)),
        ),
        child: Row(children: [
          const Text('🧭', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.jmCatchUpTitle,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary900)),
              const SizedBox(height: 2),
              Text(s.jmCatchUpBody,
                  style: GoogleFonts.manrope(
                      fontSize: 12, height: 1.35, color: AppTheme.neutral700)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _showCatchUp,
                behavior: HitTestBehavior.opaque,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(s.jmCatchUpCta,
                      style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.secondary600)),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 15, color: AppTheme.secondary600),
                ]),
              ),
            ]),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded,
                size: 18, color: AppTheme.neutral500),
            onPressed: () => setState(() => _catchUpDismissed = true),
          ),
        ]),
      );

  void _showCatchUp() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => AnimatedBuilder(
        animation: JourneyDatesStore.instance,
        builder: (ctx, _) {
          final s = S(_c.language);
          final list = _catchUpCandidates();
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppTheme.outlineVariant,
                          borderRadius: BorderRadius.circular(99))),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(s.jmCatchUpSheet,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary900)),
                ),
                const SizedBox(height: 12),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(s.jmAllCaughtUp,
                        style: GoogleFonts.manrope(
                            fontSize: 14, color: AppTheme.neutral600)),
                  )
                else
                  for (final m in list) _catchUpRow(s, m),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _catchUpRow(S s, JourneyMilestone m) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: JourneyColors.forType(m.type).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Text(m.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(m.title.of(_c.language),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary900)),
          ),
          OutlinedButton.icon(
            onPressed: () => _pickCatchUpDate(m),
            icon: const Icon(Icons.edit_calendar_rounded, size: 16),
            label: Text(s.jmSetWhen),
          ),
        ]),
      );

  Future<void> _pickCatchUpDate(JourneyMilestone m) async {
    final due = _c.dueDate;
    final current = JourneyDatesStore.instance.dateFor(m.id) ??
        _c.dateForDay(m.posDay.round());
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: _c.dateForDay(1).subtract(const Duration(days: 30)),
      lastDate:
          DateTime(due.year, due.month, due.day).add(const Duration(days: 45)),
      helpText: S(_c.language).jmCatchUpSheet,
    );
    if (picked != null) JourneyDatesStore.instance.setDate(m.id, picked);
  }

  @override
  Widget build(BuildContext context) {
    final s = S(_c.language);
    return AnimatedBuilder(
      animation: Listenable.merge([_c, JourneyDatesStore.instance]),
      builder: (context, _) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _maybeLandOnCurrent());
        return Scaffold(
          backgroundColor: AppTheme.surfaceContainer,
          appBar: AppBar(
            backgroundColor: AppTheme.surfaceContainer,
            elevation: 0,
            title: Text(s.journeyTitle),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF3EEF7), Color(0xFFEAF1EA)],
                stops: [0.0, 0.9],
              ),
            ),
            // Fixed header on top; the winding trail is the sole scroll content
            // (so a node's viewport-Y = nodeY − scrollOffset drives the depth).
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: _TrailHeaderCard(controller: _c),
                ),
                // Overdue: a calm "baby comes when ready" note past the due date.
                if (_c.isOverdue) _overdueBanner(s),
                // Late-joiner catch-up: set real dates for moments already behind.
                if (!_catchUpDismissed && _catchUpCandidates().isNotEmpty)
                  _catchUpBanner(s),
                Expanded(child: _buildTrail(context, s)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrail(BuildContext context, S s) {
    // Natural display order: index 0 = the start / Week 4 (TOP), last = Birth
    // (BOTTOM) — reading top→bottom moves forward in time toward birth.
    final display = _nodes;
    final count = display.length;
    if (count == 0) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = JourneyGeometry.heightFor(
          count,
          _slotSpacing,
          topPad: _topPad,
          bottomPad: _bottomPad,
        );
        final geometry = JourneyGeometry(
          size: Size(width, height),
          count: count,
          topPad: _topPad,
          bottomPad: _bottomPad,
        );
        final points = [
          for (int i = 0; i < count; i++) geometry.pointAtIndex(i.toDouble())
        ];
        final double currentIndex =
            _currentDisplayIndex().clamp(0.0, (count - 1).toDouble()).toDouble();
        // Landing anchor = the CURRENT WEEK checkpoint node (integer index), not
        // the fractional day-point — so opening lands squarely on the week
        // you're in regardless of the day-within-week. (The path painter still
        // uses the fractional currentIndex for progress colouring.)
        final int hereNodeIndex =
            _currentWeekNodeIndex(display).clamp(0, count - 1);
        final herePoint = geometry.pointAtIndex(hereNodeIndex.toDouble());

        // Crisp static nodes + caption pills (no perspective) — reference look.
        final nodeWidgets = <Widget>[];
        for (int i = 0; i < count; i++) {
          nodeWidgets.add(_node(points[i], display[i], i, count));
          final pill = _pill(points[i], display[i], i, count, width, s);
          if (pill != null) nodeWidgets.add(pill);
        }

        return SingleChildScrollView(
          controller: _scroll,
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // the winding trail (white base + dotted overlay, ahead lighter)
                Positioned.fill(
                  child: CustomPaint(
                    painter: JourneyPathPainter(
                      geometry: geometry,
                      currentIndex: currentIndex,
                    ),
                  ),
                ),
                // Crisp nodes + pills (no perspective scaling/fading).
                ...nodeWidgets,
                // tiny anchor used to auto-scroll the map onto the current node
                Positioned(
                  left: herePoint.dx,
                  top: herePoint.dy,
                  child: SizedBox(key: _hereKey, width: 1, height: 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Diameter for a node by role/state — the MapB sizes.
  double _diameterFor(MapNode node, {required bool isDestination}) {
    if (isDestination) return 58;
    if (node.isWeekCheckpoint) {
      switch (_weekState(node.weekLabel!)) {
        case NodeState.current:
          return 60;
        case NodeState.completed:
          return 40;
        case NodeState.future:
          return 44;
      }
    }
    return 36; // milestone — a colour disc with a type icon
  }

  Widget _markerFor(MapNode node, bool isDestination, double size) {
    if (isDestination) {
      final unlocked = node.posDay <= _c.currentDay;
      // The journey's end (Birth) — a clean white disc labelled "Birth".
      final disc = Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Color(0x1F2D144C), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Text(S(_c.language).journeyBirth,
            style: const TextStyle(
                color: Color(0xFFB2AEB5),
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      );
      // A soft radiating glow behind Birth: faint & small while LOCKED ("something
      // special waits here, not yet"), bright, warm & wide once UNLOCKED ("something
      // joyful is happening"). Same white disc; the glow is the addition.
      final glow = unlocked ? JourneyColors.arrivalGold : AppTheme.secondary300;
      final auraAlpha = unlocked ? 0.40 : 0.12;
      final pingAlpha = unlocked ? 0.55 : 0.18;
      final pingScale = unlocked ? 0.95 : 0.42;
      return GestureDetector(
        onTap: () => _onNodeTap(node),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final v = _pulse.value;
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Steady aura — always on, much brighter once unlocked.
                OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: Container(
                    width: size * 1.3,
                    height: size * 1.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: glow.withValues(alpha: auraAlpha),
                    ),
                  ),
                ),
                // Expanding ping — small/faint when locked, wide/bright unlocked.
                OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: Container(
                    width: size * (1.0 + v * pingScale),
                    height: size * (1.0 + v * pingScale),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: glow.withValues(alpha: pingAlpha * (1 - v)),
                    ),
                  ),
                ),
                child!,
              ],
            );
          },
          child: disc,
        ),
      );
    } else if (node.isWeekCheckpoint) {
      final week = node.weekLabel!;
      final state = _weekState(week);
      return JourneyNodeMarker(
        label: '$week',
        state: state,
        diameter: size,
        pulse: state == NodeState.current ? _pulse : null,
        onTap: () => _openWeek(week),
      );
    } else {
      final m = node.milestone!;
      return MilestoneMarker(
        color: JourneyColors.forType(m.type),
        icon: JourneyColors.iconForType(m.type),
        reached: node.posDay <= _c.currentDay,
        diameter: size,
        onTap: () => _openMilestone(m),
      );
    }
  }

  /// A crisp node positioned on the trail (no perspective).
  Widget _node(Offset point, MapNode node, int di, int count) {
    final isDestination = di == count - 1;
    final size = _diameterFor(node, isDestination: isDestination);
    return Positioned(
      left: point.dx - size / 2,
      top: point.dy - size / 2,
      width: size,
      height: size,
      child: _markerFor(node, isDestination, size),
    );
  }

  /// A caption pill centred below a node, clamped to stay fully on-screen.
  /// Shown for Birth ("Welcome"), the start ("Start"), the current stop
  /// ("You're here") and every milestone (its title, wrapping to 2 lines).
  Widget? _pill(
      Offset point, MapNode node, int di, int count, double width, S s) {
    final isDestination = di == count - 1;
    final isStart = di == 0;
    final size = _diameterFor(node, isDestination: isDestination);

    String? text;
    var dark = false;
    if (isDestination) {
      text = s.journeyWelcome;
    } else if (isStart) {
      text = s.journeyStart;
    } else if (node.isWeekCheckpoint) {
      if (_weekState(node.weekLabel!) == NodeState.current) {
        text = s.journeyHerePill;
        dark = true;
      }
    } else {
      // Milestone — show WHEN it falls. For an editable personal moment she's
      // already passed but hasn't dated yet, nudge with "· Set date" so it's
      // obvious she can tell us when it actually happened.
      final m = node.milestone!;
      final edited = JourneyDatesStore.instance.dateFor(m.id);
      final reached = m.posDay <= _c.currentDay;
      if (m.isDatable && reached && edited == null) {
        text = '${m.title.of(_c.language)} · ${s.jmSetWhen}';
      } else {
        final date = edited ?? _c.dateForDay(m.posDay.round());
        text = '${m.title.of(_c.language)} · ${s.jmShortDate(date)}';
      }
    }
    if (text == null) return null;

    // Centre the pill under its node, but clamp so it's never cut at an edge.
    const pillW = 168.0;
    final left = (point.dx - pillW / 2)
        .clamp(8.0, math.max(8.0, width - pillW - 8.0))
        .toDouble();
    return Positioned(
      left: left,
      top: point.dy + size / 2 + 7,
      width: pillW,
      child: Center(
        child: JourneyNodeLabel(
          text: text,
          dark: dark,
          maxWidth: pillW,
          onTap: () => _onNodeTap(node),
        ),
      ),
    );
  }

  /// Tapping a node (circle or its caption) opens the same destination.
  void _onNodeTap(MapNode node) {
    if (node.isWeekCheckpoint) {
      _openWeek(node.weekLabel!);
    } else {
      _openMilestone(node.milestone!);
    }
  }
}

// ---------------------------------------------------------------------------
//  Trail header card — design's "Your trail to birth · N weeks to go" + ring
// ---------------------------------------------------------------------------
class _TrailHeaderCard extends StatelessWidget {
  const _TrailHeaderCard({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final c = controller;
    final togo = PregnancyController.lastContentWeek - c.currentWeek;
    final pct = c.progress;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F2D144C), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              s.journeyTrailKicker.toUpperCase(),
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppTheme.secondary600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              togo <= 0 ? s.weeksToGoNow : s.weeksToGo(togo),
              style: GoogleFonts.fraunces(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary900,
              ),
            ),
          ]),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                value: pct,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                backgroundColor: AppTheme.secondary100,
                valueColor: const AlwaysStoppedAnimation(AppTheme.secondary500),
              ),
            ),
            Text(
              '${(pct * 100).round()}%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary900,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
