// Partner Editions A2: ProgrammeStore forgets an account that leaves, the
// "Only for {name}" rail, the You chip and benefit card, and the wiring gate
// for all of it on the source.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/care_partner/care_partner_models.dart';
import 'package:parentveda/care_partner/care_partner_store.dart';
import 'package:parentveda/screens/post_pregnancy/pp_learning_data.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/services/credits_store.dart';
import 'package:parentveda/services/entitlement_store.dart';
import 'package:parentveda/services/partner_brand.dart';
import 'package:parentveda/services/programme_store.dart';
import 'package:parentveda/services/remote/sync_registry.dart';
import 'package:parentveda/widgets/partner_benefit_card.dart';
import 'package:parentveda/widgets/partner_exclusive_rail.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sponsor = SponsorInfo(id: 's1', name: 'Northwind Systems');

LearningProgram _prog(
  String id, {
  String? sponsor,
  String? partner,
  LearningStatus status = LearningStatus.available,
  String title = 'Planning leave and the return to work',
}) => LearningProgram(
  id: id,
  kind: LearningKind.masterclass,
  instructorId: '',
  title: title,
  subtitle: '',
  topics: const [],
  accent: const Color(0xFF000000),
  price: 'Free',
  status: status,
  isLiveScheduled: true,
  startLabel: '6 Nov',
  audienceSponsorId: sponsor,
  audiencePartnerId: partner,
);

CarePartner _care({String type = CarePartnerType.doctor}) => CarePartner(
  id: 'p1',
  name: type == CarePartnerType.doctor
      ? 'Dr Meera Rao'
      : 'Bloom Fertility Centre',
  type: type,
  status: PartnerStatus.active,
);

PartnerLockupInfo _lockup({String kind = 'employer'}) =>
    PartnerLockupInfo(name: 'Northwind Systems', id: 's1', kind: kind);

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() {
    EntitlementStore.instance.setForTest();
    CreditsStore.instance.setForTest();
    CarePartnerStore.instance.resetAll();
    ProgrammeStore.instance.resetForTest();
  });

  group('ProgrammeStore follows the account', () {
    test('a sign-out forgets the last account\'s sessions', () {
      ProgrammeStore.instance.setItemsForTest([
        _prog('a', sponsor: 's1'),
        _prog('b'),
      ]);
      SyncRegistry.resetAll();
      expect(ProgrammeStore.instance.all, isEmpty);
      expect(ProgrammeStore.instance.isServingBackendContent, isFalse);
    });

    test('registered for both the reset and the sign-in resync', () {
      final src = File('lib/services/programme_store.dart').readAsStringSync();
      expect(src, contains('SyncRegistry.registerReset(forgetForAccount)'));
      expect(src, contains('SyncRegistry.register(_refetchForAccount)'));
      expect(src, contains("cacheKey: 'content_programmes_v2'"));
    });

    test('a late answer for the account that left is dropped', () {
      final src = File('lib/services/content_store.dart').readAsStringSync();
      expect(src, contains('final generation = _generation;'));
      expect(src, contains('if (generation != _generation) return;'));
    });

    test('the audience survives the cache round trip', () {
      final s = ProgrammeStore.instance;
      // fromMap/toCacheMap are the subclass contract; reach them the way the
      // base class does, through a cached row.
      final row = <String, dynamic>{
        'id': 'x',
        'kind': 'masterclass',
        'title': 't',
        'audience_sponsor_id': 's1',
        'audience_partner_id': null,
      };
      // ignore: invalid_use_of_protected_member
      final p = s.fromMap(row);
      expect(p.audienceSponsorId, 's1');
      expect(p.isExclusive, isTrue);
      // ignore: invalid_use_of_protected_member
      final again = s.fromMap(s.toCacheMap(p));
      expect(again.audienceSponsorId, 's1');
      expect(again.audiencePartnerId, isNull);
    });

    test('sponsor and credits refetch on the next sign-in', () {
      for (final path in [
        'lib/services/entitlement_store.dart',
        'lib/services/credits_store.dart',
      ]) {
        expect(
          File(path).readAsStringSync(),
          contains('SyncRegistry.register(refresh);'),
          reason: path,
        );
      }
    });

    test('the care partner refetches on the next sign-in', () {
      expect(
        File('lib/care_partner/care_partner_store.dart').readAsStringSync(),
        contains('SyncRegistry.register(refreshFromServer);'),
      );
    });
  });

  group('who the rail is for', () {
    test('no partner: no rail', () {
      expect(
        partnerRailFor(sponsor: null, care: null, programmes: [_prog('a')]),
        isNull,
      );
    });

    test('a partner with nothing exclusive takes no room', () {
      expect(
        partnerRailFor(
          sponsor: _lockup(),
          care: null,
          programmes: [_prog('a')],
        ),
        isNull,
      );
    });

    test('only the sponsor\'s own sessions, never a finished one', () {
      final r = partnerRailFor(
        sponsor: _lockup(),
        care: null,
        programmes: [
          _prog('mine', sponsor: 's1'),
          _prog('other', sponsor: 's2'),
          _prog('done', sponsor: 's1', status: LearningStatus.completed),
          _prog('everyone'),
        ],
      )!;
      expect(r.programmes.map((p) => p.id), ['mine']);
      expect(r.eyebrow, 'Only for Northwind Systems families');
      expect(r.title, 'Included with your benefit');
      expect(r.chip, 'Northwind Systems only');
    });

    test('a school says parents and school', () {
      final r = partnerRailFor(
        sponsor: _lockup(kind: 'school'),
        care: null,
        programmes: [_prog('m', sponsor: 's1')],
      )!;
      expect(r.eyebrow, 'Only for Northwind Systems parents');
      expect(r.title, 'From your school');
    });

    test('consults alone are enough for a sponsor rail', () {
      final r = partnerRailFor(
        sponsor: _lockup(),
        care: null,
        programmes: const [],
        consultsLeft: 2,
      )!;
      expect(r.programmes, isEmpty);
      expect(r.consultsLeft, 2);
    });

    test('a doctor is named in words; a clinic by its name', () {
      final d = partnerRailFor(
        sponsor: null,
        care: _care(),
        programmes: [_prog('d', partner: 'p1')],
      )!;
      expect(d.eyebrow, 'From Dr Meera Rao');
      expect(d.title, "For Dr Meera Rao's patients");
      final c = partnerRailFor(
        sponsor: null,
        care: _care(type: CarePartnerType.ivfCentre),
        programmes: [_prog('c', partner: 'p1')],
      )!;
      expect(c.title, 'For Bloom Fertility Centre patients');
    });

    test('the sponsor wins; the doctor leads only without a sponsor rail', () {
      final both = [_prog('s', sponsor: 's1'), _prog('d', partner: 'p1')];
      expect(
        partnerRailFor(
          sponsor: _lockup(),
          care: _care(),
          programmes: both,
        )!.programmes.single.id,
        's',
      );
      expect(
        partnerRailFor(
          sponsor: _lockup(),
          care: _care(),
          programmes: [_prog('d', partner: 'p1')],
        )!.programmes.single.id,
        'd',
      );
    });

    test('meta says when, or how long', () {
      expect(partnerRailMeta(_prog('a')), 'Live · 6 Nov');
    });
  });

  group('the rail on screen', () {
    final p = V2PaletteStore.instance.current;
    Widget rail() => PartnerExclusiveRail(
      p: p,
      head: (e, t) => Column(children: [Text(e), Text(t)]),
      top: 22,
      bottom: 26,
    );

    testWidgets('no partner: a zero-size box, no gap', (t) async {
      await t.pumpWidget(
        _host(Align(alignment: Alignment.topLeft, child: rail())),
      );
      expect(
        find.byKey(const ValueKey('partner_exclusive_rail')),
        findsNothing,
      );
      expect(t.getSize(find.byType(PartnerExclusiveRail)), Size.zero);
    });

    for (final scale in [1.0, 1.5]) {
      testWidgets('fits 360pt at ${scale}x text, names never cut', (t) async {
        EntitlementStore.instance.setForTest(
          capabilities: {Caps.consultationCredit},
          sponsor: const SponsorInfo(
            id: 's1',
            name: 'The Extremely Long Named Northwind Systems Wellbeing Trust',
          ),
        );
        CreditsStore.instance.setForTest(available: 1);
        ProgrammeStore.instance.setItemsForTest([
          _prog('a', sponsor: 's1'),
          _prog(
            'b',
            sponsor: 's1',
            title: 'Back to work: feeding and childcare',
          ),
        ]);
        t.view.physicalSize = const Size(360, 800);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: _host(rail()),
          ),
        );
        await t.pump();
        expect(t.takeException(), isNull);
        expect(
          find.byKey(const ValueKey('partner_rail_consult')),
          findsOneWidget,
        );
        expect(find.text('1 of 2 left'), findsOneWidget);
        expect(find.byKey(const ValueKey('partner_rail_a')), findsOneWidget);
        // The home's gaps are the rail's padding, drawn only with the rail.
        final pad = t.widget<Padding>(
          find.byKey(const ValueKey('partner_exclusive_rail')),
        );
        expect(pad.padding, const EdgeInsets.only(top: 22, bottom: 26));
      });
    }
  });

  group('You: chip and benefit card', () {
    test('the copy says what is left, in her words', () {
      expect(
        partnerBenefitCopy(consults: true, left: 1, per: 2).$1,
        '1 of 2 consults left',
      );
      expect(
        partnerBenefitCopy(consults: true, left: 2, per: 2).$1,
        '2 of 2 consults left',
      );
      expect(
        partnerBenefitCopy(consults: true, left: 0, per: 2).$2,
        'They renew when your company renews.',
      );
      expect(
        partnerBenefitCopy(consults: false, left: 0, per: 2).$1,
        'See what is included',
      );
    });

    testWidgets('nothing without a sponsor', (t) async {
      await t.pumpWidget(
        _host(const Column(children: [PartnerYouChip(), PartnerBenefitCard()])),
      );
      expect(find.byKey(const ValueKey('partner_you_chip')), findsNothing);
      expect(find.byKey(const ValueKey('partner_benefit_card')), findsNothing);
    });

    for (final scale in [1.0, 1.5]) {
      testWidgets('mark, name and meter fit 360pt at ${scale}x', (t) async {
        EntitlementStore.instance.setForTest(
          capabilities: {Caps.consultationCredit, Caps.masterclassAccess},
          sponsor: _sponsor,
        );
        CreditsStore.instance.setForTest(available: 1);
        t.view.physicalSize = const Size(360, 800);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: _host(
              const SingleChildScrollView(
                child: Column(
                  children: [PartnerYouChip(), PartnerBenefitCard()],
                ),
              ),
            ),
          ),
        );
        expect(t.takeException(), isNull);
        expect(find.text('Northwind Systems'), findsOneWidget);
        expect(find.text('1 of 2 consults left'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('partner_benefit_meter')),
          findsOneWidget,
        );
      });
    }
  });

  group('wiring gate', () {
    String src(String path) => File(path).readAsStringSync();

    test('every home puts the rail at the top of its sheet', () {
      final preg = src('lib/screens/home_v3_screen.dart');
      expect(
        preg,
        contains(
          'V3PregSheet(p: p, children: [\n'
          '            // Partner Editions A2',
        ),
      );
      expect(preg, contains('PartnerExclusiveRail(p: p, head:'));
      for (final path in [
        'lib/screens/ttc/ttc_home_v3.dart',
        'lib/screens/post_pregnancy/pp_home_v3.dart',
      ]) {
        expect(
          src(path),
          contains('PartnerExclusiveRail(p: p, head: (e, t) => _pad(_Head('),
          reason: path,
        );
      }
    });

    test('the live You hero carries the chip and the card follows it', () {
      final you = src('lib/screens/profile/pv_you_screen.dart');
      expect(you, contains('partner: const PartnerYouChip(),'));
      expect(you, contains('const PartnerBenefitCard(),'));
      expect(
        src('lib/screens/profile/pv_you_chrome.dart'),
        contains('?partner,'),
      );
    });

    test(
      'no partner colours, no PresentedBy, a doctor never drawn as a logo',
      () {
        for (final path in [
          'lib/widgets/partner_exclusive_rail.dart',
          'lib/widgets/partner_benefit_card.dart',
        ]) {
          final s = src(path);
          expect(s, isNot(contains('PresentedBy(')), reason: path);
          expect(s, isNot(contains('brandColour')), reason: path);
        }
        expect(
          src('lib/widgets/partner_exclusive_rail.dart'),
          isNot(contains('PartnerMark(')),
        );
      },
    );

    test('the D1 comment replaced the July line, kept for revert', () {
      final s = src('lib/screens/enterprise/employer_benefits_screen.dart');
      expect(s, contains('ONE APP, CO-BRANDED (Partner Editions D1'));
      expect(s, contains('Superseded by D1, kept for revert'));
    });
  });
}
