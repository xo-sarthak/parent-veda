// =============================================================================
//  Journey map node model
// -----------------------------------------------------------------------------
//  The Pregnancy Journey trail is a sequence of "stops". There are week
//  checkpoints (open the week card stack) and milestone nodes of several types,
//  each opening its own card. Milestone content is authored in
//  lib/data/journey_milestones.dart (bilingual, via LocalizedText).
// =============================================================================

import '../localization/app_language.dart';

/// The kind of node — drives colour, icon and which card opens on tap.
enum JourneyNodeType {
  week, // major week checkpoint -> week card stack
  achievement, // gold celebration -> achievement modal
  medical, // purple -> medical information sheet
  babyDev, // blue -> baby development card
  mother, // pink -> mother experience card
  pvJourney, // ParentVeda green -> journey celebration card
  feature, // teal -> feature preview (launch is "coming soon")
}

/// A labelled block of prose inside a card (e.g. "Why this matters" + text).
class CardSection {
  const CardSection(this.label, this.body);
  final LocalizedText label;
  final LocalizedText body;
}

/// A labelled bullet list inside a card (e.g. "Preparation tips" + items).
class BulletBlock {
  const BulletBlock(this.label, this.items);
  final LocalizedText label;
  final List<LocalizedText> items;
}

/// A milestone authored in journey_milestones.dart.
class JourneyMilestone {
  const JourneyMilestone({
    required this.id,
    required this.type,
    required this.anchorWeek,
    required this.title,
    required this.emoji,
    this.anchorDay,
    this.rangeLabel,
    this.sections = const [],
    this.bullets = const [],
    this.ctaWeek,
    this.launchComingSoon = false,
  });

  final String id;
  final JourneyNodeType type;

  /// Representative gestational week (drives trail position + day = week*7).
  final int anchorWeek;

  /// Optional explicit pregnancy day (1–280) — used by [JourneyNodeType.pvJourney]
  /// "Day 30/100/…" milestones instead of [anchorWeek]*7.
  final int? anchorDay;

  /// Short title (also the card heading).
  final LocalizedText title;

  /// A small emoji shown on the node and in the card header.
  final String emoji;

  /// Optional display override for spread-out timing, e.g. "Week 6–8".
  final LocalizedText? rangeLabel;

  final List<CardSection> sections;
  final List<BulletBlock> bullets;

  /// If set, the card shows a "View Week N" / related-week action.
  final int? ctaWeek;

  /// Feature-unlock nodes: "Launch" leads to a coming-soon placeholder.
  final bool launchComingSoon;

  /// Pregnancy day this milestone sits at (for trail ordering / position).
  double get posDay => (anchorDay ?? anchorWeek * 7).toDouble();
}

/// A resolved stop on the trail — either a week checkpoint or a milestone.
class MapNode {
  const MapNode({
    required this.type,
    required this.posDay,
    this.weekLabel,
    this.routeWeek,
    this.milestone,
  });

  final JourneyNodeType type;

  /// Pregnancy day used to order + position the node on the trail.
  final double posDay;

  /// For week checkpoints: the week number shown inside the node.
  final int? weekLabel;

  /// Week to open when tapped (week checkpoints, and milestone CTAs).
  final int? routeWeek;

  /// The milestone behind this node (null for plain week checkpoints).
  final JourneyMilestone? milestone;

  bool get isWeekCheckpoint => type == JourneyNodeType.week;
}
