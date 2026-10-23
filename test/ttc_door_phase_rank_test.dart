// A TTC door opens on where she is (global pass item 13, 2026-10-23).
// See lib/ttc/ttc_phase_rank.dart.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ttc/ttc_age_rank.dart';
import 'package:parentveda/ttc/ttc_fertility_help_rules.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_phase_rank.dart';

void main() {
  const wait = TtcDoorMoment(day: TtcDayPhase.waiting);
  const window = TtcDoorMoment(day: TtcDayPhase.window);
  const period = TtcDoorMoment(day: TtcDayPhase.period);
  const stim = TtcDoorMoment(round: TtcRoundPhase.stimulation);

  List<String> headings(List<TtcFocusSection> s) => [
    for (final x in s) x.heading,
  ];
  List<TtcFocusSection> tab(TtcFocusPage p, String group) => [
    for (final s in p.sections)
      if (s.group == group) s,
  ];

  const conceiving = kTtcConceivingFocus;
  final ivf = kTtcFocusPages.firstWhere(
    (p) => p.bracketId == 'ttc_infertility',
  );

  group('the tab it opens on', () {
    final groups = conceiving.groups!;
    test('in the wait, or late: Waiting and testing', () {
      expect(ttcDoorOpeningGroup(groups, wait), 'waiting');
      expect(
        ttcDoorOpeningGroup(groups, const TtcDoorMoment(day: TtcDayPhase.late)),
        'waiting',
      );
    });
    test('before and in the window: When and how to try', () {
      expect(ttcDoorOpeningGroup(groups, window), 'trying');
      expect(
        ttcDoorOpeningGroup(
          groups,
          const TtcDoorMoment(day: TtcDayPhase.beforeWindow),
        ),
        'trying',
      );
    });
    test('unknown, or a phase no tab is for: opens as before', () {
      expect(ttcDoorOpeningGroup(groups, TtcDoorMoment.none), isNull);
      expect(ttcDoorOpeningGroup(groups, period), isNull);
    });
    test('a clinic round never opens on a cycle-phase tab', () {
      expect(ttcDoorOpeningGroup(groups, stim), isNull);
    });
  });

  group('sections inside a tab', () {
    test('in the wait, the two-week wait leads Waiting and testing', () {
      final out = ttcPhaseOrderSections(tab(conceiving, 'waiting'), wait);
      expect(
        out.first.heading,
        'What happens in the two weeks after ovulation?',
      );
    });
    test('late: testing, then "test says no"; a period day: "says no"', () {
      final late = ttcPhaseOrderSections(
        tab(conceiving, 'waiting'),
        const TtcDoorMoment(day: TtcDayPhase.late),
      );
      expect(headings(late).take(2), [
        'When and how should you take a pregnancy test?',
        'What if the pregnancy test says no?',
      ]);
      final out = ttcPhaseOrderSections(tab(conceiving, 'waiting'), period);
      expect(out.first.heading, 'What if the pregnancy test says no?');
    });
    test('a running round lifts its step on the treatment door', () {
      final out = ttcPhaseOrderSections(tab(ivf, 'going'), stim);
      expect(out.first.heading, 'What will a cycle ask of me?');
      final waiting = ttcPhaseOrderSections(
        tab(ivf, 'going'),
        const TtcDoorMoment(round: TtcRoundPhase.waiting),
      );
      expect(waiting.first.heading, 'The wait, and after the result');
    });
    test('unknown moves nothing', () {
      for (final p in kTtcFocusPages) {
        expect(
          identical(
            ttcPhaseOrderSections(p.sections, TtcDoorMoment.none),
            p.sections,
          ),
          isTrue,
        );
      }
    });
    test('the phase reads lead inside a section', () {
      final s = tab(
        conceiving,
        'waiting',
      ).firstWhere((s) => s.heading.startsWith('When and how should you'));
      final out = ttcPhaseOrderSections([s], wait).single;
      final first = out.tiles.first;
      expect(
        first is TtcArticleTile ? first.readId : null,
        anyOf('ttc_read_when_to_test', 'ttc_read_how_to_test'),
      );
    });
  });

  test(
    'a permutation on every door, every moment: nothing hidden or added',
    () {
      final moments = [
        for (final d in TtcDayPhase.values)
          if (d != TtcDayPhase.any) TtcDoorMoment(day: d),
        for (final r in TtcRoundPhase.values) TtcDoorMoment(round: r),
      ];
      for (final p in kTtcFocusPages) {
        for (final m in moments) {
          final out = ttcPhaseOrderSections(p.sections, m);
          expect(out.length, p.sections.length);
          expect(headings(out).toSet(), headings(p.sections).toSet());
          for (final s in out) {
            final was = p.sections.firstWhere((x) => x.heading == s.heading);
            expect(s.tiles.toSet(), was.tiles.toSet());
            expect(s.tiles.length, was.tiles.length);
            expect(s.phases, was.phases, reason: 'tags must survive the copy');
          }
        }
      }
    },
  );

  test('her moment outranks her age; the age order holds among the rest', () {
    final sections = tab(ivf, 'going');
    final out = ttcPhaseOrderSections(
      ttcAgeOrderSections(sections, FertilityAgeBand.over40),
      stim,
    );
    expect(out.first.heading, 'What will a cycle ask of me?');
    expect(out.length, sections.length);
  });

  test(
    'the age order keeps the tags, so the phase order can still read them',
    () {
      final out = ttcAgeOrderSections(
        tab(conceiving, 'waiting'),
        FertilityAgeBand.over40,
      );
      expect(out.any((s) => s.phases.isNotEmpty), isTrue);
    },
  );

  test('the loss door is never tagged', () {
    final loss = kTtcFocusPages.firstWhere(
      (p) => p.bracketId == 'ttc_after_loss',
    );
    for (final s in loss.sections) {
      expect(s.phases.isEmpty && s.steps.isEmpty, isTrue, reason: s.heading);
    }
    for (final g in loss.groups ?? const <TtcFocusGroup>[]) {
      expect(g.phases.isEmpty && g.steps.isEmpty, isTrue, reason: g.id);
    }
  });

  test('wiring gate: the door opens on her tab and orders by her moment', () {
    final src = File(
      'lib/screens/ttc/doors/ttc_door_screen.dart',
    ).readAsStringSync();
    expect(src, contains('widget.initialGroup ??'));
    expect(src, contains('ttcDoorOpeningGroup('));
    expect(src, contains('ttcPhaseOrderSections('));
    expect(src, contains('ttcDoorMomentNow()'));
  });
}
