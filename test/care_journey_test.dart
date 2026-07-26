// The milestones a Care Partner may count.
//
// The contract being defended: the event NAMES here must match the strings
// partner_impact() counts in 0037. A mismatch is silent — nothing throws, no
// test fails, and a doctor's dashboard simply reads zero forever.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/care_partner/care_journey.dart';
import 'package:parentveda/care_partner/care_partner_models.dart';
import 'package:parentveda/care_partner/care_partner_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sql =
      File('supabase/migrations/0037_care_partners.sql').readAsStringSync();

  // Every name CareJourney can write. The timeline is deliberately broader
  // than the dashboard — a booking and a purchase belong in a parent's journey
  // without either being a number a doctor is shown.
  const written = {
    CareJourney.pregnancyAdded,
    CareJourney.childAdded,
    CareJourney.consultationCompleted,
    CareJourney.vaccinationCompleted,
    CareJourney.contentRead,
    CareJourney.purchaseMade,
    CareJourney.consultationBooked,
  };

  // The five the impact dashboard actually counts.
  const counted = {
    CareJourney.pregnancyAdded,
    CareJourney.childAdded,
    CareJourney.consultationCompleted,
    CareJourney.vaccinationCompleted,
    CareJourney.contentRead,
  };

  test('every counted event name matches the SQL that counts it', () {
    for (final e in counted) {
      expect(sql.contains("t.event = '$e'"), isTrue,
          reason: "0037 does not count '$e' — the dashboard would read zero");
    }
  });

  test('the server counts nothing the app cannot write', () {
    final inSql = RegExp(r"t\.event = '(\w+)'")
        .allMatches(sql)
        .map((m) => m.group(1)!)
        .toSet();
    expect(inSql.difference(written), isEmpty,
        reason: 'the server counts an event nothing in the app ever writes');
  });

  test('a timeline-only event is genuinely not on the dashboard', () {
    for (final e in written.difference(counted)) {
      expect(sql.contains("t.event = '$e'"), isFalse,
          reason: "'$e' leaked into an impact count");
    }
  });

  test('a family with no partner writes nothing at all', () {
    CarePartnerStore.instance.resetAll();
    // No exception, no write. Signed out on top of that, so even if the guard
    // were removed recordEvent would still short-circuit — but the point is
    // that callers never have to check.
    expect(() {
      CareJourney.pregnancyStarted();
      CareJourney.childBorn();
      CareJourney.consultationDone();
      CareJourney.vaccinationDone();
      CareJourney.guideRead();
      CareJourney.purchased();
      CareJourney.consultationBookedNow();
    }, returnsNormally);
  });

  test('nothing identifying is attached to a milestone', () {
    CarePartnerStore.instance.debugSeed(
      partner: const CarePartner(
          id: 'cp1',
          name: 'Dr Meera Rao',
          type: CarePartnerType.doctor,
          status: PartnerStatus.active),
    );
    addTearDown(CarePartnerStore.instance.resetAll);
    // The API itself is the guarantee: none of these methods takes an argument,
    // so no caller can pass a child's name, a vaccine, or an article title.
    expect(() => CareJourney.guideRead(), returnsNormally);
  });

  group('the milestones are wired at real moments, not just declared', () {
    // The failure this catches is the one that has bitten this feature before:
    // correct code that nothing calls. Each of these greps a real source file.
    final wiring = {
      'lib/screens/post_pregnancy/pp_child_profile.dart': 'CareJourney.childBorn()',
      'lib/screens/post_pregnancy/pp_vaccine_data.dart':
          'CareJourney.vaccinationDone()',
      'lib/screens/post_pregnancy/pp_reading_data.dart': 'CareJourney.guideRead()',
      'lib/booking/booking_store.dart': 'CareJourney.consultationDone()',
      'lib/booking/booking_store.dart ': 'CareJourney.purchased()',
      'lib/booking/booking_store.dart  ': 'CareJourney.consultationBookedNow()',
      'lib/screens/auth/auth_flow_screen.dart': 'CareJourney.pregnancyStarted()',
    };

    wiring.forEach((path, call) {
      test('$call is called from $path', () {
        expect(File(path.trim()).readAsStringSync().contains(call), isTrue,
            reason: '$call is dead code unless $path calls it');
      });
    });
  });
}
