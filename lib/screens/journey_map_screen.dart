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

  static const double _slotSpacing = 84;
  static const double _weekSize = 52;
  static const double _milestoneSize = 40;
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
    super.dispose();
  }

  /// The nodes currently shown: everything for "All", else only the selected
  /// category (week checkpoints appear only in "All").
  List<MapNode> get _visibleNodes {
    if (_filter == null) return _nodes;
    return _nodes.where((n) => n.type == _filter).toList();
  }

  /// Fractional slot index for the mother's current pregnancy day, over [list].
  double _currentIndex(List<MapNode> list) {
    final day = _c.currentDay.toDouble();
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

  @override
  Widget build(BuildContext context) {
    final s = S(_c.language);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(s.journeyTitle)),
          body: ListView(
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
        const hereBox = _weekSize * 2.4;

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: JourneyPathPainter(
                    geometry: geometry,
                    currentIndex: currentIndex,
                  ),
                ),
              ),
              for (int i = 0; i < nodes.length; i++)
                _positionedNode(geometry.pointAtIndex(i.toDouble()), nodes[i]),
              Positioned(
                left: herePoint.dx - hereBox / 2,
                top: herePoint.dy - hereBox / 2,
                child: YouAreHereMarker(
                  pulse: _pulse,
                  label: s.youAreHere,
                  diameter: _weekSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _positionedNode(Offset point, MapNode node) {
    final isWeek = node.isWeekCheckpoint;
    final size = isWeek ? _weekSize : _milestoneSize;
    final Widget marker;
    if (isWeek) {
      final week = node.weekLabel!;
      marker = JourneyNodeMarker(
        label: '$week',
        state: _weekState(week),
        diameter: _weekSize,
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
}
