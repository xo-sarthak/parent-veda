// The referral poster.
//
// It is exported as an IMAGE, so an overflow stripe would be baked into the
// file a partner then prints and sticks on a wall. Same failure the Memories
// templates hit (a card overflowed by 11px with an empty message), so the same
// discipline: render every shape of content, including the extremes.
//
// The second thing these hold is content, not layout: this card is read by
// PATIENTS. It must never mention money, and it must never carry an
// advertising label over a doctor's name.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/care_partner/care_partner_engine.dart';
import 'package:parentveda/care_partner/care_partner_models.dart';
import 'package:parentveda/care_partner/care_poster_pdf.dart';
import 'package:parentveda/care_partner/partner_dashboard_store.dart';
import 'package:parentveda/screens/doctor/care_poster_screen.dart';
import 'package:parentveda/screens/doctor/care_qr_poster.dart';
import 'package:qr_flutter/qr_flutter.dart';

const _token = 'KM7QX2PDVR';

CarePartner _p({
  String name = 'Dr Meera Rao',
  String type = CarePartnerType.doctor,
  String speciality = 'Obstetrician & Gynaecologist',
  String organisation = 'Rainbow Hospital',
  String city = 'Hyderabad',
  TrustMessage trust = const TrustMessage(),
}) =>
    CarePartner(
      id: 'cp1',
      name: name,
      type: type,
      status: PartnerStatus.active,
      speciality: speciality,
      organisation: organisation,
      city: city,
      trust: trust,
    );

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(PartnerDashboardStore.instance.reset);

  group('the poster never overflows', () {
    final cases = <String, CarePartner>{
      'minimal': _p(name: 'Dr A', speciality: '', organisation: '', city: ''),
      'typical': _p(),
      'organisation': _p(
          name: "Rainbow Children's Hospital",
          type: CarePartnerType.hospital,
          speciality: '',
          organisation: ''),
      // The realistic worst case: a long Indian name, a long speciality and a
      // parent organisation, all at once.
      'maximal': _p(
          name: 'Dr Priyadarshini Venkataraghavan Subramaniam',
          speciality: 'Consultant Obstetrician, Gynaecologist & '
              'Reproductive Endocrinologist',
          organisation: 'Rainbow Children\'s Hospital & Perinatal Centre',
          city: 'Banjara Hills, Hyderabad'),
    };

    for (final format in CarePosterFormat.values) {
      for (final entry in cases.entries) {
        testWidgets('${format.name} / ${entry.key}', (tester) async {
          tester.view.physicalSize = const Size(1200, 2000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(_host(Center(
            child: CareQrPoster(
              partner: entry.value,
              link: CarePartnerEngine.linkFor(_token),
              token: _token,
              format: format,
            ),
          )));
          await tester.pump();

          expect(tester.takeException(), isNull,
              reason: '${format.name}/${entry.key} overflowed');
        });
      }
    }
  });

  group('what a patient reads', () {
    testWidgets('never mentions money', (tester) async {
      await tester.pumpWidget(_host(CareQrPoster(
        partner: _p(),
        link: CarePartnerEngine.linkFor(_token),
        token: _token,
      )));
      for (final w in [
        'commission',
        'earn',
        'partner programme',
        'referral fee',
        '₹',
      ]) {
        expect(find.textContaining(w, findRichText: true), findsNothing,
            reason: 'the poster must not say "$w" — a patient reads this');
      }
    });

    testWidgets('a banned trust label cannot reach a printed wall',
        (tester) async {
      await tester.pumpWidget(_host(CareQrPoster(
        partner: _p(trust: const TrustMessage(primary: 'Sponsored by')),
        link: CarePartnerEngine.linkFor(_token),
        token: _token,
      )));
      expect(find.textContaining('SPONSORED'), findsNothing);
      expect(find.textContaining('INVITED BY'), findsOneWidget);
    });

    testWidgets('the code is printed, because a camera may not scan',
        (tester) async {
      await tester.pumpWidget(_host(CareQrPoster(
        partner: _p(),
        link: CarePartnerEngine.linkFor(_token),
        token: _token,
      )));
      // iOS has no install referrer at all, so this text is the ONLY mechanism
      // there. It is not decoration.
      expect(find.textContaining(_token), findsOneWidget);
    });

    testWidgets('the partner name is present and ParentVeda is the small mark',
        (tester) async {
      await tester.pumpWidget(_host(CareQrPoster(
        partner: _p(),
        link: CarePartnerEngine.linkFor(_token),
        token: _token,
      )));
      expect(find.text('Dr Meera Rao'), findsOneWidget);
      expect(find.text('ParentVeda'), findsOneWidget);
      expect(find.text('Scan to join ParentVeda'), findsOneWidget);
    });
  });

  group('the QR encodes the right thing', () {
    testWidgets('the server token, on the /care/ path, tagged as a QR',
        (tester) async {
      await tester.pumpWidget(_host(CareQrPoster(
        partner: _p(),
        link: CarePartnerEngine.linkFor(_token, channel: ReferralChannel.qr),
        token: _token,
      )));
      final qr = tester.widget<QrImageView>(find.byType(QrImageView));
      final encoded = (qr.key as ValueKey<String>)
          .value
          .replaceFirst('care-poster-qr:', '');
      expect(encoded, contains('/care/$_token'));
      expect(encoded, contains('ch=qr'));
      // Never the parent-invite space.
      expect(encoded, isNot(contains('/invite/')));
    });
  });

  group('CarePosterScreen', () {
    testWidgets('opens on the printable format and can switch', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
          home: CarePosterScreen(partner: _p(), token: _token)));
      await tester.pump();

      expect(find.byType(CareQrPoster), findsOneWidget);
      expect(
          tester.widget<CareQrPoster>(find.byType(CareQrPoster)).format,
          CarePosterFormat.portrait);

      await tester.tap(find.text('For sharing'));
      await tester.pump();
      expect(
          tester.widget<CareQrPoster>(find.byType(CareQrPoster)).format,
          CarePosterFormat.square);
    });

    testWidgets('the poster link is always ch=qr, whatever the format',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
          home: CarePosterScreen(partner: _p(), token: _token)));
      await tester.pump();
      // A printed surface that claimed to be a WhatsApp tap would corrupt the
      // channel numbers on the partner's own dashboard.
      expect(
          tester.widget<CareQrPoster>(find.byType(CareQrPoster)).link,
          contains('ch=qr'));
    });

    testWidgets('offers the PDF first, then the image options', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
          home: CarePosterScreen(partner: _p(), token: _token)));
      await tester.pump();
      // The PDF is the launch-critical one: a partner onboarded tomorrow needs
      // something printable, and it must be the FIRST thing offered.
      expect(find.text('Download for printing'), findsOneWidget);
      expect(find.text('Save image to photos'), findsOneWidget);
      expect(find.text('Share image'), findsOneWidget);
      expect(
          tester.getTopLeft(find.text('Download for printing')).dy,
          lessThan(tester.getTopLeft(find.text('Save image to photos')).dy));
    });
  });

  // ---------------------------------------------------------------------
  // The PDF. Built headlessly, so it can be asserted on without a device.
  // ---------------------------------------------------------------------
  group('the print PDF', () {
    test('builds, and is a real PDF with two pages', () async {
      final bytes = await CarePosterPdf.build(
        partner: _p(),
        link: CarePartnerEngine.linkFor(_token, channel: ReferralChannel.qr),
        token: _token,
      );
      expect(bytes.length, greaterThan(2000));
      // %PDF- header.
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      // A4 poster, then the A5 pair to cut. Two /Type /Page objects.
      final body = String.fromCharCodes(bytes);
      expect(RegExp(r'/Type\s*/Page[^s]').allMatches(body).length,
          greaterThanOrEqualTo(2));
    });

    test('the QR is VECTOR, not an embedded bitmap — the whole point of it',
        () async {
      final bytes = await CarePosterPdf.build(
        partner: _p(),
        link: CarePartnerEngine.linkFor(_token, channel: ReferralChannel.qr),
        token: _token,
      );
      final body = String.fromCharCodes(bytes);
      // An upscaled PNG would appear as an /Image XObject. A vector QR does
      // not, and that is what keeps the modules exact at A4.
      expect(body.contains('/Subtype /Image'), isFalse,
          reason: 'a raster QR upscaled to A4 gives soft-edged modules that a '
              'camera in a dim waiting room often will not read');
    });

    test('an organisation with a very long name still builds', () async {
      final bytes = await CarePosterPdf.build(
        partner: _p(
            name: "Rainbow Children's Hospital & Perinatal Centre, Banjara Hills",
            type: CarePartnerType.hospital,
            speciality: '',
            organisation: ''),
        link: CarePartnerEngine.linkFor(_token),
        token: _token,
      );
      expect(bytes.length, greaterThan(2000));
    });

    test('a banned trust label cannot reach the printed sheet', () async {
      final bytes = await CarePosterPdf.build(
        partner: _p(trust: const TrustMessage(primary: 'Sponsored by')),
        link: CarePartnerEngine.linkFor(_token),
        token: _token,
      );
      // Text in a PDF may be split across show-operators, so this is a coarse
      // check — enough to catch the label going in verbatim.
      final body = String.fromCharCodes(bytes).toUpperCase();
      expect(body.contains('SPONSORED BY'), isFalse);
    });

    test('the filename carries the partner, not the token', () {
      // A token in a filename ends up in a print shop email thread.
      expect(CarePosterPdf.debugSlug('Dr Meera Rao'), 'Dr-Meera-Rao');
      expect(CarePosterPdf.debugSlug("Rainbow Children's Hospital"),
          'Rainbow-Childrens-Hospital');
    });
  });
}
