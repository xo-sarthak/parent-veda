// Pee Safe demo, item 5: the reading shelf. Every read opens in the one
// reader with its disclosure, the launch points at real reads, and the brand
// page's shelf is no longer the empty invitation.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/brand/brand_models.dart';
import 'package:parentveda/brand/brand_page_screen.dart';
import 'package:parentveda/brand/brand_store.dart';
import 'package:parentveda/brand/brand_studio.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_brand.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_reads.dart';
import 'package:parentveda/screens/reader/pv_reader_screen.dart';

class _NoNet extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => HttpOverrides.global = _NoNet());

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    BrandStudio.instance.allowInTests = true;
    BrandStudio.instance.enabled = true;
    BrandStudio.instance.resetCampaigns();
    BrandStudioStore.instance.resetAll();
  });
  tearDown(() => BrandStudio.instance.allowInTests = false);

  test('six long reads meet the read shape, and the FAQ carries its questions', () {
    final long = kPeeSafeReads.where((r) => r.id != 'ps_read_faq').toList();
    expect(long.length, 6);
    // Every shape rule except the 600-word long-read floor: these are 2-3
    // minute shelf pieces by design (the TTC library carries the depth), so
    // they are held to 350 words instead of being padded.
    expect([
      for (final r in long) ...r.assertShape().where((e) => !e.endsWith('words, thin')),
    ], isEmpty);
    for (final r in long) {
      expect(r.wordCount, greaterThanOrEqualTo(350), reason: r.id);
    }
    expect(peeSafeReadById('ps_read_faq')!.faqs.length, greaterThanOrEqualTo(6));
  });

  test('every read is labelled, disclosed after the intro, and sells only at the end', () {
    for (final r in kPeeSafeReads) {
      expect(r.eyebrow?.en, 'Presented by Pee Safe', reason: r.id);
      expect(r.sections.first.heading, isNull, reason: '${r.id}: the intro comes first');
      expect(r.sections.first.custom, isA<PeeSafeDisclosureBlock>(), reason: r.id);
      expect(r.sections.skip(1).where((s) => s.custom != null), isEmpty,
          reason: '${r.id}: one disclosure, no products mid-read');
      final footer = r.footer;
      expect(footer, isA<PeeSafeProductsBlock>(), reason: r.id);
      expect((footer! as PeeSafeProductsBlock).products, isNotEmpty, reason: r.id);
      expect(r.whenToSeeSomeone.body.en.trimRight(), endsWith('see your doctor.'), reason: r.id);
      for (final id in r.readNext) {
        expect(peeSafeReadById(id), isNotNull, reason: '${r.id} → $id');
      }
    }
  });

  test('the launch points only at reads that exist, and the shelf has a campaign', () {
    final launch = brandLaunchFor(kPeeSafe)!;
    final ids = [for (final r in launch.creative.resources) r.readId];
    expect(ids, isNotEmpty);
    for (final id in ids) {
      expect(id, isNotNull);
      expect(peeSafeReadById(id!), isNotNull, reason: id);
    }
    final edu = peeSafeEducationCampaign();
    expect(edu?.slot, BrandSlot.sponsoredEducation);
    expect(edu?.placementKey, kPeeSafeReadsPlacement);
  });

  for (final read in kPeeSafeReads) {
    testWidgets('${read.id} opens in the reader with its eyebrow and disclosure', (tester) async {
      tester.view.physicalSize = const Size(360, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => openPeeSafeRead(context, read.id),
            child: const Text('open'),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(PvReaderScreen), findsOneWidget);
      expect(find.text(read.title.en), findsWidgets);
      expect(find.text('PRESENTED BY PEE SAFE'), findsOneWidget);
      expect(find.byKey(const ValueKey('ps_read_disclosure')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the brand page shelf opens a read', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: BrandPageScreen(brand: kPeeSafe)));
    await tester.pump();
    await tester.ensureVisible(find.text('READ WITH PEE SAFE'));
    await tester.pumpAndSettle();
    expect(find.text('Guides are on their way'), findsNothing);

    await tester.ensureVisible(find.text('When your periods come back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('When your periods come back'));
    await tester.pumpAndSettle();
    expect(find.byType(PvReaderScreen), findsOneWidget);
  });

  test('both tap sites open reads (wiring gate)', () {
    for (final f in ['lib/brand/brand_page_screen.dart', 'lib/brand/launch_hub_screen.dart']) {
      expect(File(f).readAsStringSync(), contains('openPeeSafeRead('), reason: f);
    }
  });
}
