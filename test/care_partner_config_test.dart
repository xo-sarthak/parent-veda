// 0038 seeds the config tables to match what is compiled into the app. If the
// two drift, a device that has reached the server behaves differently from one
// that has not — and the difference shows up as a partner appearing (or
// vanishing) for reasons nobody can explain. These tests read the migration and
// compare it to the Dart.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/care_partner/care_config.dart';
import 'package:parentveda/care_partner/care_partner_models.dart';
import 'package:parentveda/care_partner/care_visibility.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sql = File('supabase/migrations/0038_care_partner_config.sql')
      .readAsStringSync();

  /// Pulls the seeded ('type', '{topics}', '{surfaces}') tuples out of the
  /// visibility insert.
  Map<String, (Set<String>, Set<String>)> seededRules() {
    final block = sql.substring(
      sql.indexOf('insert into public.care_visibility_rules'),
      sql.indexOf('on conflict do nothing;',
          sql.indexOf('insert into public.care_visibility_rules')),
    );
    final out = <String, (Set<String>, Set<String>)>{};
    for (final m in RegExp(
            r"\('(\w+)',\s*'\{([^}]*)\}',\s*'\{([^}]*)\}'\)",
            multiLine: true)
        .allMatches(block)) {
      Set<String> split(String s) =>
          s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
      out[m.group(1)!] = (split(m.group(2)!), split(m.group(3)!));
    }
    return out;
  }

  test('every partner type known to the app is seeded', () {
    final seeded = seededRules();
    for (final type in CarePartnerType.known) {
      expect(seeded.containsKey(type), isTrue,
          reason: '0038 has no visibility row for "$type"');
    }
  });

  test('the seeded topics match the compiled defaults exactly', () {
    seededRules().forEach((type, row) {
      expect(row.$1, CareTopic.defaultsFor(type),
          reason: 'topics for "$type" drifted between 0038 and '
              'CareTopic.defaultsFor');
    });
  });

  test('no seeded rule puts a partner on the daily home', () {
    seededRules().forEach((type, row) {
      expect(row.$2.contains('home'), isFalse,
          reason: '"$type" is seeded onto the home — that must be a decision '
              'someone makes, not a default');
    });
  });

  test('every seeded rule keeps the partner reachable in the Care Circle', () {
    seededRules().forEach((type, row) {
      expect(row.$2.contains('care_circle'), isTrue,
          reason: '"$type" would be erased from the Care Circle');
    });
  });

  test('the trust-message table refuses advertising language in SQL, not just '
      'in Dart', () {
    expect(sql.contains('care_trust_not_an_advert'), isTrue);
    for (final word in ['sponsor', 'advert', 'promot', 'ad by']) {
      expect(sql.contains(word), isTrue,
          reason: 'the check constraint no longer blocks "$word"');
    }
  });

  test('every trust label seeded is one TrustMessage would actually render',
      () {
    for (final m in RegExp(r"\('(\w+)',\s+'([^']+)'\)").allMatches(sql.substring(
        sql.indexOf('insert into public.care_trust_messages')))) {
      final label = m.group(2)!;
      expect(TrustMessage.isAllowed(label), isTrue,
          reason: '"$label" would be replaced by the fallback at render time');
    }
  });

  test('commission rates are seeded at zero — no invented percentage', () {
    final block = sql.substring(
        sql.indexOf('insert into public.care_commission_rules'));
    for (final m
        in RegExp(r"\('(\w+)',\s*(\d+)\)").allMatches(block)) {
      expect(m.group(2), '0',
          reason: 'a rate was invented for "${m.group(1)}"');
    }
  });

  test('the commission table has no write policy — money is not client-side',
      () {
    final block = sql.substring(sql.indexOf('care_commission_rules'));
    for (final verb in ['for insert', 'for update', 'for delete']) {
      expect(block.contains('on public.care_commission_rules $verb'), isFalse,
          reason: 'a client can $verb commission rules');
    }
  });

  group('CareConfig', () {
    tearDown(CareConfig.instance.reset);

    test('falls back to the compiled rule when nothing has loaded', () {
      const p = CarePartner(
          id: 'x',
          name: 'Dr Meera Rao',
          type: CarePartnerType.lactationConsultant);
      expect(CareConfig.instance.ruleFor(p).topics,
          CareTopic.defaultsFor(CarePartnerType.lactationConsultant));
    });

    test('a partner-specific rule beats their type rule', () {
      const p = CarePartner(
          id: 'x', name: 'Dr Meera Rao', type: CarePartnerType.doctor);
      CareConfig.instance.debugSeed(
        byType: {
          CarePartnerType.doctor: const CareVisibilityRule(
              topics: {CareTopic.vaccination}, surfaces: {CareSurface.topic}),
        },
        byPartner: {
          'x': const CareVisibilityRule(
              topics: {CareTopic.sleep}, surfaces: {CareSurface.topic}),
        },
      );
      expect(CareConfig.instance.ruleFor(p).topics, {CareTopic.sleep});
    });

    test('the knobs have the same defaults the table is seeded with', () {
      expect(CareConfig.instance.attributionWindowDays, 90);
      expect(CareConfig.instance.attributionModel, 'first_touch');
      expect(CareConfig.instance.welcomeMomentEnabled, isTrue);
      expect(CareConfig.instance.tokenRotation, 0);
      expect(sql.contains("('attribution_window_days', '90'::jsonb"), isTrue);
      expect(sql.contains('\'"first_touch"\'::jsonb'), isTrue);
      expect(sql.contains("('welcome_moment_enabled', 'true'::jsonb"), isTrue);
      expect(sql.contains("('token_rotation', '0'::jsonb"), isTrue);
    });

    test("Postgres's care_circle becomes the enum's careCircle", () {
      CareConfig.instance.debugSeed(byType: {
        CarePartnerType.doctor: CareConfig.debugRuleFromRow(const {
          'topics': ['vaccination'],
          'surfaces': ['care_circle', 'topic'],
        }),
      });
      const p = CarePartner(
          id: 'y', name: 'Dr Meera Rao', type: CarePartnerType.doctor);
      expect(CareConfig.instance.ruleFor(p).surfaces,
          {CareSurface.careCircle, CareSurface.topic});
    });
  });
}
