// =============================================================================
//  Partners P2 · People (employer, school)
// -----------------------------------------------------------------------------
//  The roster tab, rendered against SponsorAdminStore.setForTest:
//    * three statuses, each in its own filter, none mislabelled;
//    * search by name or email;
//    * Remove opens an in-page confirm (no dialog), only on active people,
//      never on the signed-in admin;
//    * an address on the list that activated under another address shows in
//      both places, as the server returns it;
//    * an empty roster explains how to send one; a school says "parent list".
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/partner_app/partner_org_session.dart';
import 'package:parentveda/screens/partner_app/partner_sponsor_people.dart';
import 'package:parentveda/services/sponsor_admin_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

PartnerOrg _org({String kind = 'employer'}) => PartnerOrg(
  kind: PartnerOrgKind.sponsor,
  id: 'acme',
  name: 'Acme Corp',
  status: 'active',
  sponsorKind: kind,
);

SponsorDashboard _dash({int? seatsLeft = 10}) => SponsorDashboard(
  sponsorId: 'acme',
  sponsorName: 'Acme Corp',
  kind: 'employer',
  activated: 3,
  removed: 1,
  activatedLast30d: 1,
  eligibleListed: 4,
  suppressed: true,
  minCohort: 5,
  seatsPurchased: 13,
  seatsLeft: seatsLeft,
);

SponsorMemberRow _r(String email, String status, {String? name}) =>
    SponsorMemberRow.fromMap({
      'work_email': email,
      'full_name': name,
      'status': status,
      'activated_at': status == 'active' ? '2026-09-02T10:00:00Z' : null,
      'removed_at': status == 'removed' ? '2026-10-01T10:00:00Z' : null,
    });

// As sponsor_roster orders it: active, not_activated, removed. Priya is on the
// list under her work address and activated under a personal one, so the
// server returns her twice.
final _roster = [
  _r('hr.lead@acme.com', 'active', name: 'Meera Shah'),
  _r('priya.personal@gmail.com', 'active'),
  _r('ravi@acme.com', 'active', name: 'Ravi Kumar'),
  _r('asha@acme.com', 'not_activated', name: 'Asha Rao'),
  _r('priya@acme.com', 'not_activated', name: 'Priya Iyer'),
  _r('old@acme.com', 'removed', name: 'Leaver One'),
];

Future<void> _pump(WidgetTester t, PartnerOrg org, {String? me}) async {
  t.view.physicalSize = const Size(1080, 4000);
  t.view.devicePixelRatio = 2.5;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PartnerSponsorPeople(org: org, myEmail: me),
      ),
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

  testWidgets('three statuses, counted and labelled; nobody not started '
      'is called Removed', (t) async {
    SponsorAdminStore.instance.setForTest(dashboard: _dash(), roster: _roster);
    await _pump(t, _org());
    expect(find.text('All 6'), findsOneWidget);
    expect(find.text('Activated 3'), findsOneWidget);
    expect(find.text('Not started 2'), findsOneWidget);
    expect(find.text('Removed 1'), findsOneWidget);
    expect(find.text('asha@acme.com · Not activated yet'), findsOneWidget);
    expect(find.text('old@acme.com · Removed 1 Oct 2026'), findsOneWidget);

    await t.ensureVisible(find.text('Removed 1'));
    await t.tap(find.text('Removed 1'));
    await t.pumpAndSettle();
    expect(find.text('Leaver One'), findsOneWidget);
    expect(find.text('Asha Rao'), findsNothing);

    await t.ensureVisible(find.text('Not started 2'));
    await t.tap(find.text('Not started 2'));
    await t.pumpAndSettle();
    expect(find.text('Asha Rao'), findsOneWidget);
    expect(find.text('Leaver One'), findsNothing);
    // Not-started people cannot be removed here; only active members can.
    expect(find.byTooltip('Remove'), findsNothing);
  });

  testWidgets('an address activated elsewhere shows in both lists', (t) async {
    SponsorAdminStore.instance.setForTest(dashboard: _dash(), roster: _roster);
    await _pump(t, _org());
    expect(find.text('priya.personal@gmail.com'), findsOneWidget);
    expect(find.text('Priya Iyer'), findsOneWidget);
  });

  testWidgets('search matches a name or an email', (t) async {
    SponsorAdminStore.instance.setForTest(dashboard: _dash(), roster: _roster);
    await _pump(t, _org());
    await t.enterText(find.byType(TextField), 'ravi');
    await t.pumpAndSettle();
    expect(find.text('Ravi Kumar'), findsOneWidget);
    expect(find.text('Asha Rao'), findsNothing);
    await t.enterText(find.byType(TextField), 'nobody-here');
    await t.pumpAndSettle();
    expect(find.text('Nobody matches "nobody-here".'), findsOneWidget);
  });

  testWidgets('Remove confirms in the page, never a dialog; Keep closes it', (
    t,
  ) async {
    SponsorAdminStore.instance.setForTest(dashboard: _dash(), roster: _roster);
    await _pump(t, _org(), me: 'hr.lead@acme.com');
    // Two active people besides the admin.
    expect(find.byTooltip('Remove'), findsNWidgets(2));
    await t.tap(find.byTooltip('Remove').last);
    await t.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Remove ravi@acme.com?'), findsOneWidget);
    expect(find.textContaining('the plan Acme Corp provides'), findsOneWidget);
    await t.tap(find.text('Keep'));
    await t.pumpAndSettle();
    expect(find.text('Remove ravi@acme.com?'), findsNothing);
  });

  testWidgets('the signed-in admin has no Remove on their own row', (t) async {
    SponsorAdminStore.instance.setForTest(dashboard: _dash(), roster: _roster);
    await _pump(t, _org(), me: 'HR.Lead@acme.com');
    expect(
      find.text('hr.lead@acme.com · Activated 2 Sep 2026 · You'),
      findsOneWidget,
    );
    expect(find.byTooltip('Remove'), findsNWidgets(2));
  });

  testWidgets('every seat taken: a chip and the next step', (t) async {
    SponsorAdminStore.instance.setForTest(
      dashboard: _dash(seatsLeft: 0),
      roster: _roster,
    );
    await _pump(t, _org());
    expect(find.text('All seats taken'), findsOneWidget);
    expect(find.textContaining('All 13 seats are taken'), findsOneWidget);
  });

  testWidgets('an empty roster explains how to send one (school wording)', (
    t,
  ) async {
    SponsorAdminStore.instance.setForTest(dashboard: _dash());
    await _pump(t, _org(kind: 'school'));
    expect(find.text('Your parents appear here'), findsOneWidget);
    expect(find.textContaining('Send us your parent list'), findsOneWidget);
  });

  test('the filter predicate', () {
    final asha = _roster[3];
    expect(
      partnerPeopleMatches(asha, PartnerPeopleFilter.notStarted, 'RAO'),
      isTrue,
    );
    expect(
      partnerPeopleMatches(asha, PartnerPeopleFilter.removed, ''),
      isFalse,
    );
  });
}
