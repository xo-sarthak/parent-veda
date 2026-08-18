// =============================================================================
//  The Scans hub — the guarantees that are not about layout
// -----------------------------------------------------------------------------
//  Scans & tests is the first bracket with a hand-built screen. A bespoke screen
//  is exactly where the bracket model's rules get quietly dropped, because the
//  person building it is thinking about layout rather than permissions. These
//  tests exist so that cannot happen silently.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/scan_extras.dart';
import 'package:parentveda/data/tests_scans_reports_data.dart';
import 'package:parentveda/models/bracket.dart';
import 'package:parentveda/screens/brackets/scan_urgent_screen.dart';
import 'package:parentveda/services/bracket_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final scans = bracketById('pregnancy_scans_tests')!;

  group('the hub may not loosen what the bracket refuses', () {
    // ⚠️ THE ONE THAT MATTERS. A hand-built screen is a new place for a
    // shopping row to appear, and this bracket refuses one outright — the
    // workbook's word is "Not a fit", on a screen a frightened woman reaches
    // by searching "ectopic".
    test('Products stays refused', () {
      expect(isRefused(scans, BracketLayer.products), isTrue);
      expect(canRender(scans, BracketLayer.products), isFalse);
    });

    test('the layers the hub renders are the ones the table allows', () {
      // Content, Tools, Extras, Consult — the four the hub lays out.
      for (final l in [
        BracketLayer.content,
        BracketLayer.tools,
        BracketLayer.consult,
        BracketLayer.extras,
      ]) {
        expect(canRender(scans, l), isTrue, reason: l.name);
      }
    });
  });

  group('the urgent path sells nothing and ends at a person', () {
    testWidgets('no price, no product, no course anywhere on it',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
          const MaterialApp(home: ScanUrgentScreen()));
      await tester.pumpAndSettle();

      // ⚠️ A RUPEE SIGN ON THIS SCREEN IS THE DEFECT. 2am, frightened, possibly
      // bleeding, is the single worst moment in the product to show a price —
      // and doing it once costs more trust than the paid layer could earn back.
      expect(find.textContaining('₹'), findsNothing);
      for (final word in ['Buy', 'Shop', 'Book now', 'Course', '₹']) {
        expect(find.textContaining(word), findsNothing, reason: word);
      }

      // It ends at a human, not at more app.
      expect(find.textContaining('Call'), findsWidgets);
    });

    test('shoulder-tip pain is on the list and is not last', () {
      // The classic sign of a ruptured ectopic. It sounds like nothing, which
      // is exactly why it must not be the line she stops reading before.
      final i = kScanUrgentSigns
          .indexWhere((s) => s.en.toLowerCase().contains('shoulder'));
      expect(i, greaterThanOrEqualTo(0), reason: 'shoulder-tip pain missing');
      expect(i, lessThan(kScanUrgentSigns.length - 1),
          reason: 'shoulder-tip pain must not be the last line');
    });

    test('every urgent sign says what to do, never what it is', () {
      // No diagnosis, and no reassurance either — "probably nothing" is the
      // sentence that keeps someone at home with a ruptured ectopic.
      for (final s in kScanUrgentSigns) {
        final t = s.en.toLowerCase();
        expect(t.contains('probably'), isFalse, reason: s.en);
        expect(t.contains('ectopic'), isFalse, reason: s.en);
        expect(s.hi.trim(), isNotEmpty, reason: '${s.en} has no Hindi');
      }
    });
  });

  group('the content the workbook asked for exists', () {
    test('every scan in the schedule resolves to a library entry', () {
      const ids = [
        'blood_tests', 'dating_scan', 'nt_scan', 'nipt', 'anomaly_scan',
        'ogtt', 'growth_scan', 'doppler', 'gbs',
      ];
      for (final id in ids) {
        expect(kTestsScans.any((s) => s.id == id), isTrue, reason: id);
      }
    });

    test('every scan with a cost has a sane range', () {
      kScanCost.forEach((id, c) {
        expect(kTestsScans.any((s) => s.id == id), isTrue,
            reason: '$id has a price and no library entry');
        expect(c.low, greaterThan(0));
        expect(c.high, greaterThan(c.low),
            reason: '$id: high must exceed low, it is a range');
      });
    });

    // ⚠️ THE MOST INDIA-SPECIFIC LINE IN THE PRODUCT. It is the one thing on a
    // scan page no imported design will ever contain, and the one most likely
    // to be "tidied" into a footnote by someone who does not know the Act.
    test('the PCPNDT line names the law and is bilingual', () {
      expect(kPcpndtLine.en, contains('PCPNDT'));
      expect(kPcpndtLine.hi, contains('PCPNDT'));
      expect(kPcpndtLine.hi, isNot(equals(kPcpndtLine.en)));
      // It must explain WHY, or the refusal reads as the clinic being awkward.
      expect(kPcpndtLine.en.toLowerCase(), contains('law'));
    });

    test('per-scan red flags are bilingual and attach to real scans', () {
      kScanRedFlags.forEach((id, flags) {
        expect(kTestsScans.any((s) => s.id == id), isTrue, reason: id);
        for (final f in flags) {
          expect(f.hi.trim(), isNotEmpty, reason: '$id: "${f.en}" has no Hindi');
          expect(f.hi, isNot(equals(f.en)), reason: '$id: "${f.en}"');
        }
      });
    });
  });
}
