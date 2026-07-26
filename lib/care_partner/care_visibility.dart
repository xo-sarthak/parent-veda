// =============================================================================
//  CareVisibility — where, when and how a Care Partner appears
// -----------------------------------------------------------------------------
//  The spec is explicit: DO NOT hardcode UI placements. A lactation consultant
//  should appear around breastfeeding, latching and milk supply; a
//  paediatrician around vaccination, growth and milestones; a hospital around
//  home and profile. Those are not screen names — they are TOPICS, and screens
//  get renamed, split and merged constantly while topics do not.
//
//  So a placement is described as:
//        stage  +  topic  +  surface
//  and never as "the third card on my_child_screen.dart".
//
//  This deliberately mirrors how BrandStudio.resolve() already works for
//  sponsorship (context in, campaign or null out), because that shape has
//  proven itself here. What is NOT shared is the vocabulary: a Care Partner is
//  the parent's doctor, not an advertiser, and nothing in this file may ever
//  render through the sponsorship components.
// =============================================================================

import 'package:flutter/foundation.dart';

import 'care_partner_models.dart';

/// Topics a partner can be relevant to. Strings, not an enum, for the same
/// reason partner types are: the admin panel must be able to introduce
/// "pelvic_floor" or "sleep_regression" without an app release.
class CareTopic {
  CareTopic._();

  static const String breastfeeding = 'breastfeeding';
  static const String latching = 'latching';
  static const String milkSupply = 'milk_supply';
  static const String pumping = 'pumping';
  static const String vaccination = 'vaccination';
  static const String growth = 'growth';
  static const String nutrition = 'nutrition';
  static const String milestones = 'milestones';
  static const String exercises = 'exercises';
  static const String recovery = 'recovery';
  static const String pelvicFloor = 'pelvic_floor';
  static const String sleep = 'sleep';
  static const String mentalHealth = 'mental_health';
  static const String fertility = 'fertility';
  static const String scans = 'scans';

  /// A sensible default set per partner type, used when the admin panel has
  /// configured nothing. Without this a new partner would be invisible
  /// everywhere, which reads as broken rather than as "not configured".
  static Set<String> defaultsFor(String partnerType) => switch (partnerType) {
        CarePartnerType.lactationConsultant => {
            breastfeeding, latching, milkSupply, pumping,
          },
        CarePartnerType.doctor => {vaccination, growth, nutrition, milestones},
        CarePartnerType.physiotherapist => {exercises, recovery, pelvicFloor},
        CarePartnerType.nutritionist => {nutrition, growth},
        CarePartnerType.psychologist => {mentalHealth, sleep},
        CarePartnerType.ivfCentre => {fertility, scans},
        CarePartnerType.diagnosticLab => {scans},
        _ => const {},
      };
}

/// Named places a partner may appear. Surfaces, not screens — a surface can be
/// moved to a different screen without touching any partner's configuration.
enum CareSurface {
  /// The one-time welcome after attribution: "Dr Rao invited you".
  welcome,

  /// A quiet line on the daily home.
  home,

  /// Inside content about one of the partner's topics.
  topic,

  /// The Care Circle screen — always shown there, never suppressed.
  careCircle,

  /// The parent's profile.
  profile,
}

/// How often a placement may reappear.
enum CareFrequency { once, daily, always }

/// One partner's rules. Everything here is admin-configurable, which is why it
/// round-trips through a map.
@immutable
class CareVisibilityRule {
  const CareVisibilityRule({
    this.topics = const {},
    this.surfaces = const {CareSurface.careCircle},
    this.priority = 0,
    this.frequency = CareFrequency.daily,
    this.dismissible = true,
    this.expiresAt,
  });

  final Set<String> topics;
  final Set<CareSurface> surfaces;

  /// Higher wins when two partners could both appear. Matters once a family
  /// has more than one — see the parked open point.
  final int priority;

  final CareFrequency frequency;
  final bool dismissible;
  final DateTime? expiresAt;

  /// The rules a partner gets when nothing has been configured for them.
  static CareVisibilityRule defaultsFor(String partnerType) =>
      CareVisibilityRule(
        topics: CareTopic.defaultsFor(partnerType),
        // Home is deliberately absent. The daily home is the most valuable
        // space in the app and a partner credit there has to be a decision
        // someone makes in the admin panel, not something a new partner gets
        // by default.
        surfaces: const {
          CareSurface.welcome,
          CareSurface.careCircle,
          CareSurface.topic,
          CareSurface.profile,
        },
      );

  Map<String, Object?> toMap() => {
        'topics': topics.toList(),
        'surfaces': surfaces.map((s) => s.name).toList(),
        'priority': priority,
        'frequency': frequency.name,
        'dismissible': dismissible,
        'expiresAt': expiresAt?.toIso8601String(),
      };

  static CareVisibilityRule fromMap(Map d) => CareVisibilityRule(
        topics: ((d['topics'] as List?) ?? const [])
            .map((e) => e.toString())
            .toSet(),
        surfaces: ((d['surfaces'] as List?) ?? const [])
            .map((e) => CareSurface.values.firstWhere(
                  (s) => s.name == e,
                  orElse: () => CareSurface.careCircle,
                ))
            .toSet(),
        priority: (d['priority'] as num?)?.toInt() ?? 0,
        frequency: CareFrequency.values.firstWhere(
            (f) => f.name == d['frequency'],
            orElse: () => CareFrequency.daily),
        dismissible: d['dismissible'] as bool? ?? true,
        expiresAt: d['expiresAt'] == null
            ? null
            : DateTime.tryParse(d['expiresAt'].toString()),
      );
}

/// Where the parent is right now. Deliberately describes the SITUATION, not the
/// widget tree.
@immutable
class CareContext {
  const CareContext({
    required this.surface,
    this.topic,
    this.stage,
  });

  final CareSurface surface;

  /// The topic of the content being read, if any.
  final String? topic;

  /// 'pregnancy' | 'parenting'. Null means it does not matter.
  final String? stage;
}

class CareVisibility {
  CareVisibility._();

  /// Should [partner] appear here?
  ///
  /// Returns false rather than throwing for every uncertain case — a partner
  /// wrongly absent is a missed impression; a partner wrongly present in a
  /// medical context the parent did not expect is a breach of the trust this
  /// whole module is built on.
  static bool shouldShow({
    required CarePartner partner,
    required CareVisibilityRule rule,
    required CareContext context,
    bool dismissed = false,
    DateTime? lastShown,
    DateTime? now,
  }) {
    // The Care Circle is the parent's own list of who supports her. It is never
    // suppressed by frequency, dismissal or expiry — she asked to see it.
    if (context.surface == CareSurface.careCircle) return true;

    if (!partner.canAcquire && partner.status != PartnerStatus.inactive) {
      // A pending or rejected partner is not shown at all. An INACTIVE one
      // still appears to families they already brought: the relationship
      // happened, and hiding it would rewrite her history.
      return false;
    }

    if (rule.expiresAt != null &&
        (now ?? DateTime.now()).isAfter(rule.expiresAt!)) {
      return false;
    }

    if (dismissed && rule.dismissible) return false;

    // FREQUENCY. `once` means once ever, `daily` means once per calendar day.
    // Without this the rule round-trips through the admin panel and changes
    // nothing, which is worse than not offering the setting: someone sets a
    // partner to `once` and watches them appear every single day.
    if (lastShown != null) {
      final at = now ?? DateTime.now();
      switch (rule.frequency) {
        case CareFrequency.once:
          return false;
        case CareFrequency.daily:
          if (_sameDay(lastShown, at)) return false;
        case CareFrequency.always:
          break;
      }
    }

    if (!rule.surfaces.contains(context.surface)) return false;

    // On a topic surface the topic must actually match. This is the rule that
    // stops a lactation consultant appearing beside a vaccination article.
    if (context.surface == CareSurface.topic) {
      final t = context.topic;
      if (t == null || t.isEmpty) return false;
      if (!rule.topics.contains(t)) return false;
    }

    return true;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Pick one partner when several could appear: highest priority, then the
  /// most specific (fewest topics — a specialist beats a generalist), then
  /// stable by id so the choice does not flicker between builds.
  static CarePartner? pick(
    List<(CarePartner, CareVisibilityRule)> candidates,
    CareContext context, {
    DateTime? now,
  }) {
    final eligible = candidates
        .where((c) => shouldShow(
            partner: c.$1, rule: c.$2, context: context, now: now))
        .toList()
      ..sort((a, b) {
        final p = b.$2.priority.compareTo(a.$2.priority);
        if (p != 0) return p;
        final s = a.$2.topics.length.compareTo(b.$2.topics.length);
        if (s != 0) return s;
        return a.$1.id.compareTo(b.$1.id);
      });
    return eligible.isEmpty ? null : eligible.first.$1;
  }
}
