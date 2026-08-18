// =============================================================================
//  The report filter — the requirement, and the way it rots
// -----------------------------------------------------------------------------
//  "Is it possible to add filter, where user can add filter on a particular test
//   and we just show topics related to it, then user should be able to apply
//   multiple filters, and one topic should be able to be tagged to multiple
//   reports."
//
//  ⚠️ THE FAILURE MODE THESE TESTS EXIST FOR IS NOT A CRASH. It is a filter that
//  compiles, renders, responds to taps and filters nothing — because every topic
//  ended up tagged to every report. That passes any test that only asks "is this
//  topic reachable", which is the test someone naturally writes. So the
//  assertions below are about the SHAPE of the tagging, not its presence.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/data/report_findings_data.dart';
import 'package:parentveda/data/tests_scans_reports_data.dart';
import 'package:parentveda/models/report_finding.dart';

/// The nine reports the screen offers as filters. Kept in step with
/// `_kReportFilters` in `report_screen.dart` by the test below that checks every
/// tag resolves to a real test id.
const _filters = <String>[
  'anomaly_scan',
  'growth_scan',
  'dating_scan',
  'nt_scan',
  'nipt',
  'ogtt',
  'blood_tests',
  'doppler',
  'gbs',
];

List<ReportFinding> _forReports(Set<String> picked) {
  if (picked.isEmpty) return kReportFindings;
  return kReportFindings.where((f) => f.tests.any(picked.contains)).toList();
}

void main() {
  group('the tags point at real reports', () {
    // ⚠️ THE TAG IS AN ID, NOT A LABEL. A typo here is invisible: the topic
    // simply never appears under any filter, and nothing fails.
    test('every tagged test id exists in the tests/scans data', () {
      final known = {for (final t in kTestsScans) t.id};
      for (final f in kReportFindings) {
        for (final id in f.tests) {
          expect(known, contains(id),
              reason: '"${f.id}" is tagged to "$id", which is not a real test — '
                  'the topic will never show under any filter');
        }
      }
    });

    test('and every filter the screen offers is a real test', () {
      final known = {for (final t in kTestsScans) t.id};
      for (final id in _filters) {
        expect(known, contains(id),
            reason: 'the screen offers "$id" as a filter and no such test exists');
      }
    });
  });

  group('one topic can sit on several reports — the point of the feature', () {
    test('at least a third of topics are tagged to more than one', () {
      final multi = kReportFindings.where((f) => f.tests.length > 1).length;
      expect(multi * 3, greaterThanOrEqualTo(kReportFindings.length),
          reason: 'if almost every topic has exactly one report, the model has '
              'quietly become one-owner and the requirement is unmet');
    });

    test('low-lying placenta is on both the anomaly and the growth scan', () {
      // The worked example from the model's own doc comment: it is found at the
      // mid-pregnancy scan and re-checked at every growth scan after it. A
      // one-owner model has to drop one of those, and a mother holding the other
      // report searches and finds nothing.
      final f = kReportFindings.firstWhere((x) => x.id == 'low_lying_placenta');
      expect(f.tests, containsAll(['anomaly_scan', 'growth_scan']));
    });
  });

  group('the tags actually partition — the test that catches a useless filter',
      () {
    test('no single report returns the whole library', () {
      for (final id in _filters) {
        final shown = _forReports({id});
        expect(shown.length, lessThan(kReportFindings.length),
            reason: 'filtering to "$id" shows everything, so the filter does '
                'nothing while looking like it works');
      }
    });

    test('and no topic claims more than four reports', () {
      for (final f in kReportFindings) {
        expect(f.tests.length, lessThanOrEqualTo(4),
            reason: '"${f.id}" is tagged to ${f.tests.length} reports; past a '
                'handful, a tag stops meaning "read off this report"');
      }
    });

    test('every offered filter returns at least one topic', () {
      // A chip that always yields the empty state is worse than no chip.
      for (final id in _filters) {
        expect(_forReports({id}), isNotEmpty,
            reason: '"$id" is offered as a filter and matches no topic');
      }
    });
  });

  group('multiple filters widen, they never narrow', () {
    // ⚠️ THE ONE THING THAT WOULD LOOK BROKEN TO HER. If the two-report case were
    // implemented as AND, the second tap would usually empty the screen. She is
    // asking "what can appear on any of these".
    test('picking two reports shows at least what either shows alone', () {
      for (var i = 0; i < _filters.length; i++) {
        for (var j = i + 1; j < _filters.length; j++) {
          final a = _forReports({_filters[i]}).length;
          final b = _forReports({_filters[j]}).length;
          final both = _forReports({_filters[i], _filters[j]}).length;
          expect(both, greaterThanOrEqualTo(a > b ? a : b),
              reason: '${_filters[i]} + ${_filters[j]} shows fewer topics than '
                  'one of them alone — the filter is ANDing');
        }
      }
    });

    test('selecting every report is not the same as selecting none', () {
      // Because at least one topic is deliberately tagged to nothing: Braxton
      // Hicks is something she feels, and it appears on no report. That untagged
      // topic is why "All" has to be its own chip rather than "everything
      // selected".
      final everything = _forReports(_filters.toSet());
      expect(everything.length, lessThan(kReportFindings.length),
          reason: 'some topics belong to no report at all, and "All" is the only '
              'way to see them');
    });

    test('and no filter is selected by default', () {
      // The repo rule: a feature is never hidden. An unfiltered arrival sees the
      // whole library rather than being made to choose first.
      expect(_forReports(const {}).length, kReportFindings.length);
    });
  });
}
