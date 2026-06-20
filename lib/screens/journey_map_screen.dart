// =============================================================================
//  JourneyMapScreen  —  "Your Pregnancy Journey" (the map)
// -----------------------------------------------------------------------------
//  A winding trail from Week 4 → Birth. Week checkpoints open the week card
//  stack; milestone nodes (achievement / medical / baby / mother / journey /
//  feature) open their own cards. A top progress card and a pulsing "you are
//  here" marker anchor the mother in her journey.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../models/journey_node.dart';
import '../services/journey_nodes.dart';
import '../services/pregnancy_controller.dart';
import '../widgets/journey/journey_backdrop.dart';
import '../widgets/journey/journey_geometry.dart';
import '../widgets/journey/journey_node.dart';
import '../widgets/journey/journey_palette.dart';
import '../widgets/journey/journey_celebration.dart';
import '../widgets/journey/journey_path.dart';
import '../widgets/journey/journey_progress_card.dart';
import '../widgets/journey/node_cards.dart';
import '../widgets/journey/upcoming_section.dart';
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

  /// Active category filter; null means "All".
  JourneyNodeType? _filter;

  /// Drives the one-time auto-scroll that lands the map on the current week.
  final ScrollController _scroll = ScrollController();
  final GlobalKey _hereKey = GlobalKey();
  bool _landed = false;

  static const double _slotSpacing = 96;
  static const double _weekSize = 52;
  static const double _milestoneSize = 40;
  static const double _destSize = 62;
  static const double _topPad = 40;
  static const double _bottomPad = 70;

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

  /// On first open, gently scroll so the "you are here" marker lands in view —
  /// a small reveal that anchors the mother on her current week.
  void _maybeLandOnCurrent() {
    if (_landed || !mounted) return;
    final ctx = _hereKey.currentContext;
    if (ctx == null) return;
    _landed = true;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.42,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  /// The nodes currently shown: everything for "All", else only the selected
  /// category (week checkpoints appear only in "All").
  List<MapNode> get _visibleNodes {
    if (_filter == null) return _nodes;
    return _nodes.where((n) => n.type == _filter).toList();
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

  /// Fractional slot index for the mother's current pregnancy day, over [list].
  double _currentIndex(List<MapNode> list) =>
      _indexForDay(_c.currentDay.toDouble(), list);

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

  @override
  Widget build(BuildContext context) {
    final s = S(_c.language);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _maybeLandOnCurrent());
        return Scaffold(
          appBar: AppBar(title: Text(s.journeyTitle)),
          body: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              JourneyProgressCard(controller: _c),
              const SizedBox(height: 14),
              _buildFilters(context, s),
              const SizedBox(height: 8),
              _buildTrail(context, s),
              const SizedBox(height: 8),
              UpcomingSection(
                controller: _c,
                nodes: _nodes,
                onTap: _openMilestone,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(BuildContext context, S s) {
    final chips = <(String, JourneyNodeType?)>[
      (s.filterAll, null),
      ('🏆 ${s.filterAchievements}', JourneyNodeType.achievement),
      ('👶 ${s.filterBaby}', JourneyNodeType.babyDev),
      ('🩺 ${s.filterMedical}', JourneyNodeType.medical),
      ('🌸 ${s.filterMother}', JourneyNodeType.mother),
      ('🔓 ${s.filterFeatures}', JourneyNodeType.feature),
      ('📍 ${s.filterJourney}', JourneyNodeType.pvJourney),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (label, type) = chips[i];
          final selected = _filter == type;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => setState(() => _filter = type),
          );
        },
      ),
    );
  }

  Widget _buildTrail(BuildContext context, S s) {
    final nodes = _visibleNodes;
    if (nodes.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = JourneyGeometry.heightFor(
          nodes.length,
          _slotSpacing,
          topPad: _topPad,
          bottomPad: _bottomPad,
        );
        final geometry = JourneyGeometry(
          size: Size(width, height),
          count: nodes.length,
          topPad: _topPad,
          bottomPad: _bottomPad,
        );
        final currentIndex = _currentIndex(nodes);
        final herePoint = geometry.pointAtIndex(currentIndex);
        const hereBox = _weekSize * 3.0;

        // The destination (end of the journey) only reads as such in the full
        // "All" view — in a filtered view the last node is just a category item.
        final destinationIndex = _filter == null ? nodes.length - 1 : -1;
        final arrivalCenter = destinationIndex >= 0
            ? geometry.pointAtIndex(destinationIndex.toDouble())
            : null;

        // Trimester regions: split the trail where weeks 13→14 and 27→28 fall.
        final idxT1 = _indexForDay(91, nodes);
        final idxT2 = _indexForDay(189, nodes);
        final t1End = geometry.pointAtIndex(idxT1).dy;
        final t2End = geometry.pointAtIndex(idxT2).dy;
        // Slot index of each band's top, used to place its chip clear of the trail.
        final bandTopIdx = <double>[0, idxT1, idxT2];
        final bands = <TrimesterBand>[
          TrimesterBand(top: 0, bottom: t1End, fill: JourneyColors.trimesterFill[0]),
          TrimesterBand(top: t1End, bottom: t2End, fill: JourneyColors.trimesterFill[1]),
          TrimesterBand(top: t2End, bottom: height, fill: JourneyColors.trimesterFill[2]),
        ];

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              // 1 · soft trimester regions + dotted texture + arrival glow
              Positioned.fill(
                child: CustomPaint(
                  painter: JourneyBackdropPainter(
                    bands: bands,
                    arrivalCenter: arrivalCenter,
                  ),
                ),
              ),
              // 2 · trimester chips at the top of each region, placed on the
              //     side opposite the trail so they never sit on a node/label
              for (int i = 0; i < bands.length; i++)
                _bandLabel(
                  i,
                  bands[i].top,
                  geometry.pointAtIndex(bandTopIdx[i]).dx < width / 2,
                  s,
                ),
              // 3 · the winding trail (completed green / future grey)
              Positioned.fill(
                child: CustomPaint(
                  painter: JourneyPathPainter(
                    geometry: geometry,
                    currentIndex: currentIndex,
                  ),
                ),
              ),
              // 4 · node circles (last node becomes the glowing destination)
              for (int i = 0; i < nodes.length; i++)
                _positionedNode(
                  geometry.pointAtIndex(i.toDouble()),
                  nodes[i],
                  isDestination: i == destinationIndex,
                ),
              // 5 · caption pills beside each node (meaning at a glance)
              for (int i = 0; i < nodes.length; i++)
                _positionedLabel(
                  geometry.pointAtIndex(i.toDouble()),
                  nodes[i],
                  width,
                  s,
                  isDestination: i == destinationIndex,
                ),
              // tiny anchor used to auto-scroll the map onto the current week
              Positioned(
                left: herePoint.dx,
                top: herePoint.dy,
                child: SizedBox(key: _hereKey, width: 1, height: 1),
              ),
              // 6 · "you are here" (week · day)
              Positioned(
                left: herePoint.dx - hereBox / 2,
                top: herePoint.dy - hereBox / 2,
                child: YouAreHereMarker(
                  pulse: _pulse,
                  eyebrow: s.youAreHere,
                  detail: s.journeyWeekDay(_c.currentWeek, _c.dayOfWeek),
                  diameter: _weekSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _positionedNode(Offset point, MapNode node,
      {bool isDestination = false}) {
    // The destination gets a larger, glowing marker in a roomy box so its halo
    // isn't clipped.
    if (isDestination) {
      const box = _destSize * 1.9;
      return Positioned(
        left: point.dx - box / 2,
        top: point.dy - box / 2,
        width: box,
        height: box,
        child: DestinationMarker(
          emoji: '👶',
          pulse: _pulse,
          diameter: _destSize,
          onTap: () => _onNodeTap(node),
        ),
      );
    }

    final isWeek = node.isWeekCheckpoint;
    final size = isWeek ? _weekSize : _milestoneSize;
    final Widget marker;
    if (isWeek) {
      final week = node.weekLabel!;
      final state = _weekState(week);
      marker = JourneyNodeMarker(
        label: '$week',
        state: state,
        diameter: _weekSize,
        pulse: state == NodeState.current ? _pulse : null,
        onTap: () => _openWeek(week),
      );
    } else {
      final m = node.milestone!;
      marker = MilestoneMarker(
        emoji: m.emoji,
        color: JourneyColors.forType(m.type),
        reached: node.posDay <= _c.currentDay,
        diameter: _milestoneSize,
        onTap: () => _openMilestone(m),
      );
    }
    return Positioned(
      left: point.dx - size / 2,
      top: point.dy - size / 2,
      width: size,
      height: size,
      child: marker,
    );
  }

  /// A small trimester chip at the top of each region, so the three sections
  /// read clearly as First / Second / Third trimester. [onRight] places it on
  /// the side away from the trail at that point, avoiding overlap with nodes.
  Widget _bandLabel(int i, double top, bool onRight, S s) {
    final ink = JourneyColors.trimesterInk[i];
    return Positioned(
      left: onRight ? null : 12,
      right: onRight ? 12 : null,
      top: top + 8,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: JourneyColors.trimesterFill[i].withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: ink.withValues(alpha: 0.30), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
              Text(
                s.trimesterBandLabel(i).toUpperCase(),
                style: TextStyle(
                  color: ink,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The caption pill beside a node. It sits on the OUTER side of the curve
  /// (right for nodes right-of-centre, left otherwise) so it never crosses the
  /// trail, and grows toward the nearest screen edge.
  Widget _positionedLabel(Offset point, MapNode node, double width, S s,
      {bool isDestination = false}) {
    final isWeek = node.isWeekCheckpoint;
    final size = isDestination
        ? _destSize
        : (isWeek ? _weekSize : _milestoneSize);

    final String text;
    final String? subtitle;
    final Color color;
    final bool reached;
    if (isWeek) {
      final week = node.weekLabel!;
      final state = _weekState(week);
      // The current week is labelled by the "you are here" pill, so we skip its
      // own side label to avoid two pills fighting for the same spot.
      if (state == NodeState.current) return const SizedBox.shrink();
      text = '${s.weekWord} $week';
      subtitle = null; // the title already says the week
      color = JourneyColors.forState(state);
      reached = state != NodeState.future;
    } else {
      final m = node.milestone!;
      text = m.title.of(_c.language);
      subtitle =
          m.rangeLabel?.of(_c.language) ?? '${s.weekWord} ${m.anchorWeek}';
      color = isDestination
          ? JourneyColors.arrivalRose
          : JourneyColors.forType(m.type);
      reached = node.posDay <= _c.currentDay;
    }

    const gap = 8.0;
    const vOffset = 15.0; // ~half a single-line pill, to centre on the node
    final rightSide = point.dx >= width / 2;

    if (rightSide) {
      final left = point.dx + size / 2 + gap;
      final maxW = width - left - 4;
      if (maxW < 30) return const SizedBox.shrink();
      return Positioned(
        left: left,
        top: point.dy - vOffset,
        width: maxW,
        child: Align(
          alignment: Alignment.centerLeft,
          child: JourneyNodeLabel(
            text: text,
            subtitle: subtitle,
            color: color,
            reached: reached,
            maxWidth: maxW,
            onTap: () => _onNodeTap(node),
          ),
        ),
      );
    } else {
      final rightEdge = point.dx - size / 2 - gap;
      final maxW = rightEdge - 4;
      if (maxW < 30) return const SizedBox.shrink();
      return Positioned(
        left: 0,
        top: point.dy - vOffset,
        width: rightEdge,
        child: Align(
          alignment: Alignment.centerRight,
          child: JourneyNodeLabel(
            text: text,
            subtitle: subtitle,
            color: color,
            reached: reached,
            maxWidth: maxW,
            alignEnd: true,
            onTap: () => _onNodeTap(node),
          ),
        ),
      );
    }
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
