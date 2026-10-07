// =============================================================================
//  Parenting trust fixes, wave 1 (gap analysis P1, Behind · Trust, 2026-10-07)
// -----------------------------------------------------------------------------
//  Every one of these showed a parent something that was not true: doctors our
//  own code calls fictional, a community where anyone could post as a
//  paediatrician, seed reviews on every product, mock deals, courses with
//  ratings and no lessons, one stranger's sample film under every title. Each
//  is pinned here on the screens a parent reaches, at 1.5x text on a 360 phone,
//  and against the source where the fix is a guard.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/booking/booking_catalog.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/data/reads/read_adapters.dart';
import 'package:parentveda/experts/pregnancy_experts.dart';
import 'package:parentveda/screens/learn/pv_learn_catalog.dart';
import 'package:parentveda/screens/learn/pv_offering_screen.dart';
import 'package:parentveda/screens/post_pregnancy/community_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_community_detail_screen.dart';
import 'package:parentveda/data/community_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_expert_honesty.dart';
import 'package:parentveda/screens/post_pregnancy/pp_experts_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_learning_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_opening_soon.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reading_data.dart';
import 'package:parentveda/screens/post_pregnancy/provider_profile_screen.dart';
import 'package:parentveda/screens/post_pregnancy/provider_results_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';

String _live(String path) =>
    File(path).readAsStringSync().split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');

/// A 360-wide phone at 1.5x text, the size every new screen is checked at.
Future<void> _pump(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(size: Size(360, 780), textScaler: TextScaler.linear(1.5)),
      child: home,
    ),
  ));
  await tester.pump();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the community is held behind Opening soon', () {
    testWidgets('the feed draws the honest page, with nothing overflowing', (tester) async {
      await _pump(tester, const CommunityScreen());
      expect(find.byKey(const ValueKey('pp_community_opening_soon')), findsOneWidget);
      expect(find.text('Tell me when it opens'), findsOneWidget);
      expect(find.textContaining('Verified by'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a room opened from a recipe or a read lands on the same page', (tester) async {
      await _pump(tester, PpCommunityDetailScreen(community: kParentingCommunities.first));
      expect(find.byKey(const ValueKey('pp_community_opening_soon')), findsOneWidget);
    });

    test('the flag is off, and "Doctor mode" can never reach a release build', () {
      expect(kPpCommunityOpen, isFalse);
      final src = File('lib/screens/post_pregnancy/community_screen.dart').readAsStringSync();
      expect(src, contains("if (kDebugMode) IconButton(\n            tooltip: 'Doctor mode (test)'".replaceAll('\n', src.contains('\r\n') ? '\r\n' : '\n')));
    });
  });

  group('fictional experts are not shown as real', () {
    test('the bundled parenting roster is placeholders; the pregnancy roster is untouched', () {
      expect(ppExpertIsPlaceholder(expertById('neha')), isTrue);
      expect(ppExpertIsPlaceholder(expertById('ananya')), isTrue);
      for (final e in kPregnancyExperts) {
        expect(ppExpertIsPlaceholder(e), isFalse, reason: e.id);
      }
    });

    testWidgets('a placeholder profile shows no council number, hospital or Book', (tester) async {
      await _pump(tester, ProviderProfileScreen(expert: expertById('neha')));
      expect(find.byKey(const ValueKey('pp_experts_opening_soon')), findsOneWidget);
      expect(find.textContaining('DMC Reg.'), findsNothing);
      expect(find.textContaining('Max Smart'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Find help with no real expert says so instead of listing fiction', (tester) async {
      await _pump(tester, const ProviderResultsScreen());
      expect(find.byKey(const ValueKey('pp_experts_opening_soon')), findsOneWidget);
    });

    test('no placeholder is a bookable consult', () {
      final ids = kPpBundledExpertIds;
      for (final o in BookingCatalog.instance.offerings()) {
        if (o.kind != OfferingKind.consult) continue;
        expect(ids.contains(o.expertId), isFalse, reason: o.id);
      }
    });
  });

  group('courses that are not made are not sold', () {
    test('every bundled programme is a placeholder, with no rating or seats in Learn', () {
      for (final p in kLearningPrograms) {
        expect(ppProgramIsPlaceholder(p.id), isTrue, reason: p.id);
        final v = PvLearnCatalog.instance.byId(p.id);
        if (v == null) continue;
        expect(v.rating, isNull, reason: p.id);
        expect(v.seatsLeft, isNull, reason: p.id);
      }
    });

    testWidgets('opening one shows Opening soon, not a price', (tester) async {
      final v = PvLearnCatalog.instance.all(stage: LifeStage.parenting).firstWhere((v) => ppProgramIsPlaceholder(v.id));
      await _pump(tester, Builder(builder: (context) {
        return Scaffold(body: Center(child: TextButton(onPressed: () => pvOpenOffering(context, v), child: const Text('open'))));
      }));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_program_opening_soon')), findsOneWidget);
      expect(find.byType(PvOfferingScreen), findsNothing);
    });
  });

  group('reads, vaccines, products, films', () {
    test('the home reads are signed by the editorial desk, with no tick', () {
      for (final a in kReadArticles) {
        expect(a.author, kPpEditorialAuthor, reason: a.id);
        expect(pvReadFromReadArticle(a).reviewed, isFalse, reason: a.id);
      }
    });

    test('no vaccine footer names a reviewer', () {
      for (final f in ['lib/screens/post_pregnancy/vax_tracker_screen.dart', 'lib/screens/post_pregnancy/vaccination_screen.dart']) {
        expect(_live(f).contains('Reviewed by Dr.'), isFalse, reason: f);
        expect(_live(f), contains('Indian Academy of Paediatrics'));
      }
    });

    test('the mock deals rail is off', () {
      expect(_live('lib/screens/post_pregnancy/reco_category_screen.dart').contains('recoDealsSection(category)'), isFalse);
    });

    test('the sample film plays in debug builds only', () {
      expect(_live('lib/screens/post_pregnancy/video/pv_video_config.dart'), contains('const bool kUseDevVideos = kDebugMode;'));
    });

    test('Brand Studio and Launches are behind the developer switch', () {
      final src = _live('lib/screens/post_pregnancy/explore_drawer.dart');
      final gate = src.indexOf('if (kPvShowDeveloper) ...[');
      expect(gate, greaterThan(0));
      expect(src.indexOf("'Brand Studio'"), greaterThan(gate));
      expect(src.indexOf("'Launches'"), greaterThan(gate));
    });

    test('attachments are copied out of the picker cache before upload', () {
      expect(_live('lib/screens/post_pregnancy/pp_attachments.dart'), contains('final kept = await _keepLocal(a.path);'));
    });
  });

  test('the shared Opening soon page reads at 1.5x on a small phone', () {
    // Pinned by the widget tests above; this guards the words the gap
    // analysis asked for, so a later edit cannot drift them.
    expect(File('lib/screens/post_pregnancy/pp_opening_soon.dart').readAsStringSync(), contains("'Tell me when it opens'"));
  });
}
