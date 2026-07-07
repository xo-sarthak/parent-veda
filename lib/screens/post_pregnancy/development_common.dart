// =============================================================================
//  ParentVeda Development — shared UI building blocks
// -----------------------------------------------------------------------------
//  Playful, optimistic, activity-driven (deliberately warmer/brighter than
//  Health): area cards with their own accent, supportive progress words (never
//  percentages), and activity cards. pp-themed, no emojis.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_development_data.dart';

/// A supportive progress pill — "Growing", never a number.
Widget devWordPill(DevWord w, Color accent) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(devWordLabel(w), style: ppBody(11, color: accent, w: FontWeight.w700)),
    );

/// A soft, encouraging progress bar (not a score — just visual warmth).
Widget devProgressBar(DevWord w, Color accent) => ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 6,
        color: accent.withValues(alpha: 0.12),
        child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: devWordFraction(w), child: Container(color: accent)),
      ),
    );

Widget devSectionHeader(String title, {String? action, VoidCallback? onAction}) => Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: ppJakarta(18))),
        if (action != null) GestureDetector(onTap: onAction, behavior: HitTestBehavior.opaque, child: ppSeeAll(action)),
      ],
    );

/// A playful area card — its own accent, current stage, supportive word.
class DevAreaCard extends StatelessWidget {
  const DevAreaCard({super.key, required this.area, required this.onTap, this.width});
  final DevArea area;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [area.accent.withValues(alpha: 0.10), area.accent.withValues(alpha: 0.03)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: area.accent.withValues(alpha: 0.22)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Icon(area.icon, size: 20, color: area.accent)),
          const Spacer(),
          devWordPill(area.word, area.accent),
        ]),
        const SizedBox(height: 12),
        Text(area.name, style: ppJakarta(15).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(area.stage, style: ppBody(12, color: area.accent, w: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(area.summary, style: ppBody(12.5, h: 1.45), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 12),
        devProgressBar(area.word, area.accent),
      ]),
    );
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: width != null ? SizedBox(width: width, child: card) : card,
    );
  }
}

/// An activity list card (thumb-free, icon-led — activities are about doing).
class DevActivityCard extends StatelessWidget {
  const DevActivityCard({super.key, required this.activity, required this.onTap});
  final DevActivity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final area = devAreaById(activity.areaId);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 46, height: 46, alignment: Alignment.center, decoration: BoxDecoration(color: area.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)), child: Icon(area.icon, size: 22, color: area.accent)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(activity.title, style: ppJakarta(14.5).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),
              Row(children: [
                Icon(Icons.schedule_rounded, size: 12.5, color: ppMuted),
                const SizedBox(width: 4),
                Text('${activity.minutes} min', style: ppBody(11.5, color: ppMuted, w: FontWeight.w600)),
                const SizedBox(width: 10),
                Flexible(child: Text('${activity.difficulty} · ${area.name}', style: ppBody(11.5, color: ppMuted, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
        ]),
      ),
    );
  }
}

/// A compact rail activity card.
class DevActivityRailCard extends StatelessWidget {
  const DevActivityRailCard({super.key, required this.activity, required this.onTap, this.width = 180});
  final DevActivity activity;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final area = devAreaById(activity.areaId);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: area.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(area.icon, size: 20, color: area.accent)),
          const SizedBox(height: 12),
          Text(activity.title, style: ppJakarta(14).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text('${activity.minutes} min · ${activity.difficulty}', style: ppBody(11.5, color: ppMuted, w: FontWeight.w600)),
        ]),
      ),
    );
  }
}
