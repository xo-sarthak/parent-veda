// =============================================================================
//  ToolsScreen  -  the "Tools" tab landing (a grid of tools)
// -----------------------------------------------------------------------------
//  The first tool is "Your Pregnancy Journey" (the map). The remaining tiles are
//  gentle "coming soon" placeholders, so the tab already reads as a growing
//  toolbox where future tools (trackers, planners) will slot in.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import 'community_screen.dart';
import 'garbh_screen.dart';
import 'journey_map_screen.dart';
import 'products_screen.dart';
// Old "Understanding Your Report" screen - merged into TestsScansReportsScreen.
// Kept commented for revert.
// import 'report_screen.dart';
import 'tools/baby_movement_screen.dart';
import 'tools/contraction_tracker_screen.dart';
import 'tools/hospital_bag_screen.dart';
import 'tools/kegel_care_screen.dart';
import 'tools/tests_scans_reports_screen.dart';
import 'tools/weight_tracker_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key, required this.controller});

  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;

    void open(Widget Function() builder) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => builder()));

    final tools = <_ToolInfo>[
      _ToolInfo(
          s.babyMovementTracker, Icons.favorite_rounded, AppTheme.secondary500,
          onTap: () => open(() => BabyMovementScreen(controller: controller))),
      _ToolInfo(s.toolWeightTitle, Icons.monitor_weight_rounded,
          AppTheme.tertiary400,
          onTap: () => open(() => WeightTrackerScreen(controller: controller))),
      _ToolInfo(s.toolKegelTitle, Icons.self_improvement_rounded,
          AppTheme.secondary400,
          onTap: () => open(() => KegelCareScreen(controller: controller))),
      _ToolInfo(s.toolContractionTitle, Icons.timer_rounded,
          AppTheme.primary400,
          onTap: () =>
              open(() => ContractionTrackerScreen(controller: controller))),
      _ToolInfo(s.hbName, Icons.luggage_rounded, AppTheme.tertiary500,
          onTap: () => open(() => HospitalBagScreen(controller: controller))),
      // Merged "Tests, Scans & Reports" (Section 16) replaces the old
      // "Understanding Your Report" tile.
      _ToolInfo(s.tsrTitle, Icons.fact_check_rounded, AppTheme.primary500,
          onTap: () =>
              open(() => TestsScansReportsScreen(controller: controller))),
      _ToolInfo(s.gsTitle, Icons.spa_rounded, AppTheme.tertiary500,
          onTap: () => open(() => GarbhScreen(controller: controller))),
      _ToolInfo(s.cmTitle, Icons.forum_rounded, AppTheme.secondary500,
          onTap: () => open(() => CommunityScreen(controller: controller))),
      _ToolInfo(s.prTitle, Icons.shopping_bag_rounded, AppTheme.primary500,
          onTap: () => open(() => ProductsScreen(controller: controller))),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Text(s.toolsTitle, style: text.headlineMedium),
          const SizedBox(height: 6),
          Text(s.toolsIntro, style: text.bodyMedium),
          const SizedBox(height: 20),
          _JourneyFeatureCard(controller: controller),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 14.0;
              final tileWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final t in tools)
                    SizedBox(
                      width: tileWidth,
                      child: _ToolTile(
                          info: t,
                          comingSoonLabel: s.comingSoon,
                          openLabel: s.openLabel),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _JourneyFeatureCard extends StatelessWidget {
  const _JourneyFeatureCard({required this.controller});

  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => JourneyMapScreen(controller: controller),
          ),
        ),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary500, AppTheme.primary400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary900.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.map_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.toolJourneyTitle,
                      style: text.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.toolJourneySubtitle,
                      style: text.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.info,
    required this.comingSoonLabel,
    required this.openLabel,
  });

  final _ToolInfo info;
  final String comingSoonLabel;
  final String openLabel;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final available = info.onTap != null;
    final body = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: info.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(info.icon, color: info.color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            info.title,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          if (available)
            Row(children: [
              Text(openLabel,
                  style: text.labelSmall?.copyWith(color: info.color)),
              const SizedBox(width: 2),
              Icon(Icons.arrow_forward_rounded, size: 14, color: info.color),
            ])
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                comingSoonLabel,
                style: text.labelSmall?.copyWith(color: AppTheme.neutral600),
              ),
            ),
        ],
      ),
    );
    if (!available) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: info.onTap,
        child: body,
      ),
    );
  }
}

class _ToolInfo {
  const _ToolInfo(this.title, this.icon, this.color, {this.onTap});
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
}
