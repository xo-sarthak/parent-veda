// =============================================================================
//  Guardrails for the no-invented-data rule
// -----------------------------------------------------------------------------
//  Data about a child comes from the parent. These tests lock in the two ways
//  that rule has been broken before: shipping a figure nobody entered, and
//  leaking a placeholder token into the UI.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_common.dart';
import 'package:parentveda/screens/post_pregnancy/pp_growth_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_health_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_names_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_vaccine_data.dart';

void main() {
  test('a fresh child has no measurements we invented', () {
    final c = ChildProfileStore.instance;
    expect(ChildProfileStore.hasValue(c.weightKg), isFalse,
        reason: 'a prefixed baby weight is exactly what we must never ship');
    expect(ChildProfileStore.hasValue(c.heightCm), isFalse);
    expect(ChildProfileStore.hasValue(c.headCm), isFalse);
  });

  test('nothing about the child is pre-filled', () {
    expect(GrowthStore.instance.isEmpty, isTrue);
    expect(HealthStore.instance.medications, isEmpty);
    expect(HealthStore.instance.allergies, isEmpty);
    expect(HealthStore.instance.reports, isEmpty);
    expect(HealthStore.instance.symptoms, isEmpty);
    expect(HealthStore.instance.hasAnyEntry, isFalse);
    // The emergency card carried a blood group and a paediatrician's phone.
    expect(HealthStore.instance.emergency, isNull);
    // A dose is "done" only when she marks it.
    expect(kVaxVisits.where((v) => VaxStore.instance.statusOf(v) == VaxStatus.done),
        isEmpty);
    // The timeline is built from her records, so it starts empty too.
    expect(healthTimelineSorted(), isEmpty);
  });

  test('ppFill resolves every placeholder token', () {
    final name = ChildProfileStore.instance.name;
    expect(ppFill('{child} and {their} nap, {they} said, hold {them}'),
        '$name and ${ChildProfileStore.instance.their} nap, '
        '${ChildProfileStore.instance.they} said, hold '
        '${ChildProfileStore.instance.them}');
    expect(ppFill('no placeholder here'), 'no placeholder here');
  });

  test('no {child} placeholder can reach the UI unfilled', () {
    // Every bundled string carrying a token must be rendered through ppFill.
    // This walks the source: a file holding a token must either be a data
    // catalogue (rendered elsewhere) or call ppFill itself.
    final offenders = <String>[];
    final dir = Directory('lib/screens/post_pregnancy');
    for (final f in dir.listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      final src = f.readAsStringSync();
      if (!src.contains('{child}')) continue;
      final isCatalogue = f.path.contains('_data.dart');
      if (!isCatalogue && !src.contains('ppFill')) {
        offenders.add(f.path);
      }
    }
    expect(offenders, isEmpty,
        reason: 'these render a placeholder without ppFill: $offenders');
  });

  test('baby naming starts with nothing chosen for her', () {
    final s = NameMatchStore.instance;
    // Six seeded likes and a crowned "Aarav" used to ship. Harmless while
    // likes were private - but both parents starting from the SAME six would
    // "match" on all six before either had swiped, faking the one moment the
    // feature exists for.
    expect(s.liked, isEmpty);
    expect(s.crowned, isEmpty);
    expect(s.matches, isEmpty);
    expect(s.matchedCount, 0);
  });

  test('a match needs both parents, so likes alone never count as one', () {
    final s = NameMatchStore.instance;
    addTearDown(() => s.liked.toList().forEach(s.skip));
    s.like('Vihaan');
    s.like('Kabir');
    expect(s.likedCount, 2, reason: 'her own likes');
    // matchedCount reads the intersection from the database, never _liked.
    // This is the bug the whole brief was about: the UI said "3 names you've
    // BOTH said yes to" while counting one person.
    expect(s.matchedCount, 0,
        reason: 'liking alone is not agreement - the partner has not voted');
  });
}
