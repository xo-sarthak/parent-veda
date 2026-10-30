// Rules for where a Care Partner may appear. The failures that matter here are
// all in one direction: a partner showing up somewhere a parent would read it
// as an advert.

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/care_partner/care_partner_models.dart';
import 'package:parentveda/care_partner/care_visibility.dart';

CarePartner _p({
  String id = 'p1',
  String type = CarePartnerType.lactationConsultant,
  PartnerStatus status = PartnerStatus.active,
}) =>
    CarePartner(id: id, name: 'Dr Meera Rao', type: type, status: status);

void main() {
  group('topic matching', () {
    final partner = _p();
    final rule = CareVisibilityRule.defaultsFor(partner.type);

    test('a lactation consultant appears on breastfeeding content', () {
      expect(
        CareVisibility.shouldShow(
          partner: partner,
          rule: rule,
          context: const CareContext(
              surface: CareSurface.topic, topic: CareTopic.breastfeeding),
        ),
        isTrue,
      );
    });

    test('and NOT beside a vaccination article', () {
      expect(
        CareVisibility.shouldShow(
          partner: partner,
          rule: rule,
          context: const CareContext(
              surface: CareSurface.topic, topic: CareTopic.vaccination),
        ),
        isFalse,
      );
    });

    test('a topic surface with no topic shows nothing', () {
      expect(
        CareVisibility.shouldShow(
          partner: partner,
          rule: rule,
          context: const CareContext(surface: CareSurface.topic),
        ),
        isFalse,
      );
    });
  });

  // Kept for revert: home was OFF by default until Partner Editions A1
  // (2026-10-30, the user deciding D3: a doctor is a "Your doctor" line on
  // every home).
  // test('home is off by default — it has to be switched on deliberately', () {
  //   final partner = _p(type: CarePartnerType.doctor);
  //   expect(
  //     CareVisibility.shouldShow(
  //       partner: partner,
  //       rule: CareVisibilityRule.defaultsFor(partner.type),
  //       context: const CareContext(surface: CareSurface.home),
  //     ),
  //     isFalse,
  //   );
  // });
  group('home (Partner Editions A1)', () {
    final partner = _p(type: CarePartnerType.doctor);
    final rule = CareVisibilityRule.defaultsFor(partner.type);
    const home = CareContext(surface: CareSurface.home);

    test('on by default for a partner who brought her', () {
      expect(CareVisibility.shouldShow(partner: partner, rule: rule, context: home), isTrue);
    });

    test('stands all day: shown once already today does not hide it', () {
      final now = DateTime(2026, 10, 30, 18);
      expect(
        CareVisibility.shouldShow(
            partner: partner, rule: rule, context: home,
            lastShown: DateTime(2026, 10, 30, 9), now: now),
        isTrue,
      );
    });

    test('her dismissal still holds', () {
      expect(
        CareVisibility.shouldShow(partner: partner, rule: rule, context: home, dismissed: true),
        isFalse,
      );
    });

    test('an admin can still take home out of one partner', () {
      const noHome = CareVisibilityRule(surfaces: {CareSurface.careCircle, CareSurface.topic});
      expect(CareVisibility.shouldShow(partner: partner, rule: noHome, context: home), isFalse);
    });

    test('a pending partner never reaches the home', () {
      expect(
        CareVisibility.shouldShow(
            partner: _p(type: CarePartnerType.doctor, status: PartnerStatus.pending),
            rule: rule, context: home),
        isFalse,
      );
    });

    test('daily frequency still applies off the home', () {
      final now = DateTime(2026, 10, 30, 18);
      expect(
        CareVisibility.shouldShow(
            partner: partner, rule: rule, context: const CareContext(surface: CareSurface.profile),
            lastShown: DateTime(2026, 10, 30, 9), now: now),
        isFalse,
      );
    });
  });

  group('status', () {
    test('a pending partner is invisible everywhere but the Care Circle', () {
      final p = _p(status: PartnerStatus.pending);
      final rule = CareVisibilityRule.defaultsFor(p.type);
      expect(
        CareVisibility.shouldShow(
          partner: p,
          rule: rule,
          context: const CareContext(
              surface: CareSurface.topic, topic: CareTopic.breastfeeding),
        ),
        isFalse,
      );
    });

    test('an INACTIVE partner still appears — her history is not rewritten',
        () {
      final p = _p(status: PartnerStatus.inactive);
      final rule = CareVisibilityRule.defaultsFor(p.type);
      expect(
        CareVisibility.shouldShow(
          partner: p,
          rule: rule,
          context: const CareContext(
              surface: CareSurface.topic, topic: CareTopic.breastfeeding),
        ),
        isTrue,
      );
    });

    test('a rejected partner never appears on a content surface', () {
      final p = _p(status: PartnerStatus.rejected);
      final rule = CareVisibilityRule.defaultsFor(p.type);
      expect(
        CareVisibility.shouldShow(
          partner: p,
          rule: rule,
          context: const CareContext(
              surface: CareSurface.topic, topic: CareTopic.breastfeeding),
        ),
        isFalse,
      );
    });
  });

  group('the Care Circle is never suppressed', () {
    const ctx = CareContext(surface: CareSurface.careCircle);

    test('not by dismissal', () {
      expect(
        CareVisibility.shouldShow(
          partner: _p(),
          rule: CareVisibilityRule.defaultsFor(CarePartnerType.doctor),
          context: ctx,
          dismissed: true,
        ),
        isTrue,
      );
    });

    test('not by expiry, and not by a rejected status', () {
      expect(
        CareVisibility.shouldShow(
          partner: _p(status: PartnerStatus.rejected),
          rule: CareVisibilityRule(
              expiresAt: DateTime(2020), surfaces: const {}),
          context: ctx,
        ),
        isTrue,
      );
    });
  });

  test('dismissal hides a dismissible placement, not a fixed one', () {
    final p = _p();
    const ctx = CareContext(
        surface: CareSurface.topic, topic: CareTopic.breastfeeding);
    final base = CareVisibilityRule.defaultsFor(p.type);
    expect(
      CareVisibility.shouldShow(
          partner: p, rule: base, context: ctx, dismissed: true),
      isFalse,
    );
    final fixed = CareVisibilityRule(
        topics: base.topics, surfaces: base.surfaces, dismissible: false);
    expect(
      CareVisibility.shouldShow(
          partner: p, rule: fixed, context: ctx, dismissed: true),
      isTrue,
    );
  });

  test('an expired placement stops showing', () {
    final p = _p();
    final base = CareVisibilityRule.defaultsFor(p.type);
    final rule = CareVisibilityRule(
      topics: base.topics,
      surfaces: base.surfaces,
      expiresAt: DateTime.utc(2026, 1, 1),
    );
    expect(
      CareVisibility.shouldShow(
        partner: p,
        rule: rule,
        context: const CareContext(
            surface: CareSurface.topic, topic: CareTopic.breastfeeding),
        now: DateTime.utc(2026, 6, 1),
      ),
      isFalse,
    );
  });

  group('pick', () {
    const ctx = CareContext(
        surface: CareSurface.topic, topic: CareTopic.breastfeeding);

    test('priority wins', () {
      final low = _p(id: 'a');
      final high = _p(id: 'b');
      final base = CareVisibilityRule.defaultsFor(low.type);
      final chosen = CareVisibility.pick([
        (low, base),
        (
          high,
          CareVisibilityRule(
              topics: base.topics, surfaces: base.surfaces, priority: 5)
        ),
      ], ctx);
      expect(chosen?.id, 'b');
    });

    test('at equal priority the specialist beats the generalist', () {
      final generalist = _p(id: 'gen');
      final specialist = _p(id: 'spec');
      final wide = CareVisibilityRule(
        topics: const {
          CareTopic.breastfeeding,
          CareTopic.sleep,
          CareTopic.nutrition,
          CareTopic.growth,
        },
        surfaces: const {CareSurface.topic},
      );
      final narrow = CareVisibilityRule(
        topics: const {CareTopic.breastfeeding},
        surfaces: const {CareSurface.topic},
      );
      expect(
        CareVisibility.pick([(generalist, wide), (specialist, narrow)], ctx)?.id,
        'spec',
      );
    });

    test('nothing eligible returns null rather than a fallback', () {
      expect(
        CareVisibility.pick([
          (
            _p(),
            CareVisibilityRule(
                topics: const {CareTopic.vaccination},
                surfaces: const {CareSurface.topic})
          ),
        ], ctx),
        isNull,
      );
    });

    test('the choice is stable when everything else ties', () {
      final rule = CareVisibilityRule(
          topics: const {CareTopic.breastfeeding},
          surfaces: const {CareSurface.topic});
      final a = _p(id: 'aaa');
      final b = _p(id: 'bbb');
      expect(CareVisibility.pick([(b, rule), (a, rule)], ctx)?.id, 'aaa');
      expect(CareVisibility.pick([(a, rule), (b, rule)], ctx)?.id, 'aaa');
    });
  });

  group('rules round-trip through the admin panel', () {
    test('toMap/fromMap preserves every field', () {
      final rule = CareVisibilityRule(
        topics: const {CareTopic.sleep, CareTopic.pelvicFloor},
        surfaces: const {CareSurface.home, CareSurface.profile},
        priority: 7,
        frequency: CareFrequency.once,
        dismissible: false,
        expiresAt: DateTime.utc(2027, 3, 4),
      );
      final back = CareVisibilityRule.fromMap(rule.toMap());
      expect(back.topics, rule.topics);
      expect(back.surfaces, rule.surfaces);
      expect(back.priority, 7);
      expect(back.frequency, CareFrequency.once);
      expect(back.dismissible, isFalse);
      expect(back.expiresAt, rule.expiresAt);
    });

    test('an unknown surface from a newer admin panel falls back to the Care '
        'Circle rather than crashing', () {
      final back = CareVisibilityRule.fromMap({
        'surfaces': ['a_surface_this_build_has_never_heard_of'],
      });
      expect(back.surfaces, {CareSurface.careCircle});
    });

    test('an unknown topic string is simply carried, not rejected', () {
      final back = CareVisibilityRule.fromMap({
        'topics': ['sleep_regression'],
      });
      expect(back.topics, {'sleep_regression'});
    });
  });

  test('every partner type has usable defaults or none at all', () {
    for (final type in CarePartnerType.known) {
      final rule = CareVisibilityRule.defaultsFor(type);
      // A type with no topics is fine (a hospital is not topical) but it must
      // still be reachable in the Care Circle.
      expect(rule.surfaces.contains(CareSurface.careCircle), isTrue,
          reason: '$type must appear in the Care Circle');
    }
  });
}
