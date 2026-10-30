// "Our experts" directory (2026-10-30): five real profiles, none bookable, no
// contact details anywhere, and the You screen actually opens the list.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/experts/expert.dart';
import 'package:parentveda/experts/panel_experts.dart';

/// Every string field on an expert, flattened, for the privacy scan.
List<String> _allText(Expert e) => [
  e.id,
  e.name,
  e.credential,
  e.backLabel,
  e.rating,
  e.reviewsCount,
  e.mid.$1,
  e.mid.$2,
  e.fee.$1,
  e.fee.$2,
  e.whyHeading,
  e.why,
  ...e.tags,
  e.ctaPrice,
  e.ctaSub,
  e.ctaLabel,
  e.disclaimer,
  e.location,
  ...e.qualifications,
  e.experience,
  e.practisesAt,
  e.registration,
  ...e.memberships,
  e.category,
  e.blurb,
  e.timings,
];

void main() {
  test(
    'five panel experts, each with a name, a credential and qualifications',
    () {
      expect(kPanelExperts, hasLength(5));
      expect({for (final e in kPanelExperts) e.id}, hasLength(5));
      for (final e in kPanelExperts) {
        expect(e.name.trim(), isNotEmpty, reason: e.id);
        expect(e.credential.trim(), isNotEmpty, reason: e.id);
        expect(e.qualifications, isNotEmpty, reason: e.id);
        expect(e.tags.length, greaterThanOrEqualTo(3), reason: e.id);
        expect(e.hasProfile, isTrue, reason: e.id);
      }
    },
  );

  test('none is bookable, rated, priced or reviewed', () {
    for (final e in kPanelExperts) {
      expect(e.timings, isEmpty, reason: '${e.id} must not be bookable');
      expect(e.rating, isEmpty, reason: e.id);
      expect(e.reviews, isEmpty, reason: e.id);
      expect(e.fee, ('', ''), reason: e.id);
      expect(e.priceValue, 0, reason: e.id);
      expect(e.seeded, isFalse, reason: e.id);
      expect(e.topPick, isFalse, reason: e.id);
    }
  });

  test('no email, no phone number in any field', () {
    final tenDigits = RegExp(r'\d{10}');
    // Also catches a number written with spaces or dashes: 98765 43210.
    final spaced = RegExp(r'(?:\d[\s-]?){10,}');
    for (final e in kPanelExperts) {
      for (final t in _allText(e)) {
        expect(t.contains('@'), isFalse, reason: '${e.id}: "$t"');
        expect(tenDigits.hasMatch(t), isFalse, reason: '${e.id}: "$t"');
        expect(spaced.hasMatch(t), isFalse, reason: '${e.id}: "$t"');
      }
    }
  });

  test('all five are universal: an expert is never only for a stage', () {
    for (final e in kPanelExperts) {
      expect(e.domain, 'universal', reason: e.id);
    }
  });

  test('registration is printed as supplied, and Keya has none', () {
    final byId = {for (final e in kPanelExperts) e.id: e};
    expect(
      byId['panel_maneesha']!.registration,
      'Indian Association of Physiotherapists, Life Member (L-34296)',
    );
    expect(byId['panel_keya']!.registration, isEmpty);
    for (final e in kPanelExperts) {
      expect(
        e.disclaimer.toLowerCase().contains('verified'),
        isFalse,
        reason: e.id,
      );
    }
  });

  test(
    '"Dr." is kept for the two who carry it, with the qualification beside it',
    () {
      expect(kPanelNameNote['panel_maneesha'], 'Physiotherapist');
      expect(kPanelNameNote['panel_simran'], 'PhD');
      for (final e in kPanelExperts.where((x) => x.name.startsWith('Dr. '))) {
        expect(kPanelNameNote.containsKey(e.id), isTrue, reason: e.id);
      }
    },
  );

  test('"Helps with" is the first three tags', () {
    final m = kPanelExperts.firstWhere((e) => e.id == 'panel_maneesha');
    expect(
      panelHelpsWith(m),
      "Helps with: Women's health, Breastfeeding, Birth doula",
    );
  });

  test('the You screen opens the directory (wiring gate)', () {
    final you = File(
      'lib/screens/profile/pv_you_screen.dart',
    ).readAsStringSync();
    expect(you.contains('PvExpertsScreen'), isTrue);
    expect(you.contains("title: 'Our experts'"), isTrue);
    expect(you.contains('The specialists who work with ParentVeda'), isTrue);
    final screen = File(
      'lib/screens/profile/pv_experts_screen.dart',
    ).readAsStringSync();
    expect(screen.contains("'you/experts'"), isTrue);
    expect(screen.contains('onlyProfile: true'), isTrue);
    final results = File(
      'lib/screens/post_pregnancy/provider_results_screen.dart',
    ).readAsStringSync();
    expect(results.contains('Meet our experts'), isTrue);
  });
}
