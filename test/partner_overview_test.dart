// =============================================================================
//  Partners P2 · Overview and the monthly report (employer, school)
// -----------------------------------------------------------------------------
//  Renders the real tab against SponsorAdminStore.setForTest. What it holds:
//    * contract facts always show; behaviour shows "—" with a reason when the
//      server suppressed it, never 0;
//    * the threshold in the words is the server's min_cohort, not a literal 5;
//    * unlimited seats and a full programme each say so;
//    * the report and its PDF come from one model.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/partner_app/partner_org_session.dart';
import 'package:parentveda/partner_app/partner_report.dart';
import 'package:parentveda/screens/partner_app/partner_report_screen.dart';
import 'package:parentveda/screens/partner_app/partner_tabs.dart';
import 'package:parentveda/services/sponsor_admin_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

PartnerOrg _org({String kind = 'employer'}) => PartnerOrg(
  kind: PartnerOrgKind.sponsor,
  id: 'acme',
  name: 'Acme Corp',
  status: 'active',
  sponsorKind: kind,
);

SponsorDashboard _dash({
  bool suppressed = false,
  int? seats = 40,
  int? seatsLeft = 26,
  int listed = 0,
  int activated = 14,
  int? rate = 35,
  int min = 5,
}) => SponsorDashboard(
  sponsorId: 'acme',
  sponsorName: 'Acme Corp',
  kind: 'employer',
  activated: activated,
  removed: 1,
  activatedLast30d: 3,
  eligibleListed: listed,
  suppressed: suppressed,
  minCohort: min,
  seatsPurchased: seats,
  seatsLeft: seatsLeft,
  activationRate: rate,
  consultationsBooked: suppressed ? null : 19,
  consultationsCompleted: suppressed ? null : 6,
  consultationsUpcoming: suppressed ? null : 2,
);

/// Six months ending this month, as sponsor_engagement returns them.
List<SponsorEngagementPoint> _engagement({required bool withheld}) {
  final n = DateTime.now();
  return [
    for (var i = 5; i >= 0; i--)
      SponsorEngagementPoint(
        month: DateTime(n.year, n.month - i),
        activePeople: withheld ? null : 6 + i,
        sessions: withheld ? null : 20,
        avgSessionMin: withheld ? null : 4.5,
      ),
  ];
}

List<SponsorTrendPoint> _trend() {
  final n = DateTime.now();
  return [
    for (var i = 4; i >= 0; i--)
      SponsorTrendPoint(
        month: DateTime(n.year, n.month - i),
        activatedInMonth: 2,
        activatedCumulative: 14 - 2 * i,
        consultationsBooked: i == 4 ? null : 3,
      ),
  ];
}

Future<void> _pump(WidgetTester t, PartnerOrg org) async {
  t.view.physicalSize = const Size(1080, 4000);
  t.view.devicePixelRatio = 2.5;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      home: Scaffold(body: PartnerOverviewTab(org: org)),
    ),
  );
  await t.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    SponsorAdminStore.instance.clear();
  });
  tearDown(SponsorAdminStore.instance.clear);

  group('Overview', () {
    testWidgets('unsuppressed: the four figures, the trend, coming back', (
      t,
    ) async {
      SponsorAdminStore.instance.setForTest(
        dashboard: _dash(),
        trend: _trend(),
        engagement: _engagement(withheld: false),
      );
      await _pump(t, _org());
      expect(find.text('SEATS'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
      expect(find.text('26 left'), findsOneWidget);
      expect(find.text('35% of seats'), findsOneWidget);
      expect(find.text('6'), findsWidgets); // active this month
      expect(find.text('19'), findsOneWidget); // consultations booked
      expect(find.text('6 attended · 2 upcoming'), findsOneWidget);
      expect(find.text('Up 6 since three months ago'), findsOneWidget);
      expect(find.text('Opened ParentVeda, by month'), findsOneWidget);
      expect(find.textContaining('An average visit'), findsOneWidget);
      expect(find.text('Monthly report'), findsOneWidget);
    });

    testWidgets(
      'suppressed: behaviour is a dash with the server threshold, never 0',
      (t) async {
        SponsorAdminStore.instance.setForTest(
          dashboard: _dash(suppressed: true, activated: 3, min: 7),
          engagement: _engagement(withheld: true),
        );
        await _pump(t, _org());
        expect(find.text('Shown once 7 have activated'), findsOneWidget);
        expect(find.text('Shown when 7 or more open it'), findsOneWidget);
        expect(
          find.textContaining('Shown once 7 or more employees open the app'),
          findsOneWidget,
        );
        expect(find.text('—'), findsNWidgets(2));
        // Contract facts are never withheld.
        expect(find.text('3'), findsOneWidget);
      },
    );

    testWidgets('unlimited seats say Unlimited, and take-up is of the list', (
      t,
    ) async {
      SponsorAdminStore.instance.setForTest(
        dashboard: _dash(seats: null, seatsLeft: null, listed: 40, rate: 35),
      );
      await _pump(t, _org());
      expect(find.text('Unlimited'), findsOneWidget);
      expect(find.text('No cap'), findsOneWidget);
      expect(find.text('35% of your list'), findsOneWidget);
      expect(find.textContaining('seats are taken'), findsNothing);
    });

    testWidgets('a full programme warns, with the next step', (t) async {
      SponsorAdminStore.instance.setForTest(
        dashboard: _dash(seats: 14, seatsLeft: 0, activated: 14, rate: 100),
      );
      await _pump(t, _org(kind: 'school'));
      expect(
        find.textContaining('All 14 seats are taken. New parents cannot'),
        findsOneWidget,
      );
    });

    testWidgets('not loaded (no backend): the empty state, not a blank', (
      t,
    ) async {
      await _pump(t, _org());
      expect(find.text('Your numbers live here'), findsOneWidget);
    });

    testWidgets('a load error says so and offers Try again', (t) async {
      SponsorAdminStore.instance.setForTest(
        error: 'We could not load your programme just now.',
      );
      await _pump(t, _org());
      expect(
        find.text('We could not load your programme just now.'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('Monthly report opens a named route', (t) async {
      SponsorAdminStore.instance.setForTest(
        dashboard: _dash(),
        trend: _trend(),
      );
      String? pushed;
      t.view.physicalSize = const Size(1080, 4000);
      t.view.devicePixelRatio = 2.5;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        MaterialApp(
          navigatorObservers: [_Spy((n) => pushed = n)],
          home: Scaffold(body: PartnerOverviewTab(org: _org())),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.text('Monthly report'));
      await t.pumpAndSettle();
      expect(pushed, PartnerReportScreen.routeName);
      expect(find.text('Share as PDF'), findsOneWidget);
      expect(
        find.text('14 of 40 employees are using ParentVeda, 35%.'),
        findsOneWidget,
      );
      expect(find.text('WHAT THIS REPORT DOES NOT CONTAIN'), findsOneWidget);
    });
  });

  group('the report model', () {
    test('headline, figures and the portal arithmetic', () {
      final r = PartnerReport.from(
        _dash(listed: 30),
        _trend(),
        peopleWord: 'parents',
      );
      expect(r.headline, '14 of 30 parents are using ParentVeda, 35%.');
      expect(r.figures.map((f) => f.label), [
        'Activated',
        'On your list',
        'Joined last 30 days',
        'Not started yet',
      ]);
      expect(r.figures.last.value, '16');
      expect(r.change, 'Up 6 since three months ago.');
      // A withheld month is a dash, never 0.
      expect(r.months.first.consults, '—');
    });

    test('unlimited seats and no list: no denominator, no "not started"', () {
      final r = PartnerReport.from(
        _dash(seats: null, seatsLeft: null, rate: null),
        const [],
        peopleWord: 'employees',
      );
      expect(r.headline, '14 employees are using ParentVeda.');
      expect(r.figures[1].value, 'Unlimited');
      expect(r.figures.last.value, '—');
      expect(r.change, isNull);
    });

    test('suppressed: consultations are a sentence with the threshold', () {
      final r = PartnerReport.from(
        _dash(suppressed: true, min: 8),
        const [],
        peopleWord: 'employees',
      );
      expect(r.consults, isEmpty);
      expect(r.consultsWithheld, contains('once 8 people'));
      expect(r.limits.last, contains('below 8 people'));
    });

    test('the PDF builds offline from the same model', () async {
      final r = PartnerReport.from(_dash(), _trend(), peopleWord: 'employees');
      final bytes = await buildPartnerReportPdf(r);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(r.fileName, endsWith('.pdf'));
      expect(r.fileName, contains('Acme-Corp'));
    });
  });
}

class _Spy extends NavigatorObserver {
  _Spy(this.onPush);
  final void Function(String?) onPush;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onPush(route.settings.name);
}
