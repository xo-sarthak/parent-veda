// =============================================================================
//  MyBookingsScreen renders the one history
// -----------------------------------------------------------------------------
//  A rework that quietly fails to render looks identical to one never built, so
//  this pins: the empty state shows with nothing booked, and a booked session
//  shows up with its credit summary once one exists.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_catalog.dart';
import 'package:parentveda/booking/booking_store.dart';
import 'package:parentveda/screens/post_pregnancy/my_bookings_screen.dart';

void main() {
  final store = BookingStore.instance;

  // Reset before AND after: the store is a process-wide singleton and the test
  // runner reuses isolates across files, so a booking left by another file must
  // not bleed into the empty-state assertion here.
  setUp(store.resetAll);
  tearDown(store.resetAll);

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: MyBookingsScreen()));
    await tester.pumpAndSettle();
  }

  testWidgets('empty state shows when nothing is booked', (tester) async {
    await pump(tester);
    expect(find.text('Your classes & sessions'), findsOneWidget);
    expect(find.text('Nothing booked yet'), findsOneWidget);
  });

  testWidgets('a booked session and its credits render', (tester) async {
    final o = BookingCatalog.instance.offeringForCatalog('y_flow_am')!;
    store.purchase(o);
    store.book(BookingCatalog.instance.slotsFor(o.id).first);

    await pump(tester);
    // The booking title appears (upcoming card) and the credit summary shows
    // three of four remaining.
    expect(find.textContaining('Morning Sun Flow'), findsWidgets);
    expect(find.textContaining('3 of 4 left'), findsOneWidget);
    expect(find.text('Nothing booked yet'), findsNothing);
    // The stage tag files it under Parenting.
    expect(find.text('Parenting'), findsWidgets);
  });
}
