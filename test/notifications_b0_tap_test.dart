// =============================================================================
//  Phase 6b B0: every notification tap opens its page through ONE opener
// -----------------------------------------------------------------------------
//  What this file holds, in order of how much it would hurt to lose:
//
//    1. Every 6a kind, in all three stages, is pinned to its destination. A
//       new kind with no row here fails the build, and only Parenting's age
//       note may land on a home (the age page IS the child's home).
//    2. A tap opens THE message it was for, by id, not "the newest of its
//       kind": yesterday's tip opens yesterday's tip.
//    3. Every stage message carries its address in the notification, in the
//       shape a server push will use (`link_kind`, `link_id`).
//    4. No silent tap: a gone message, a missing page, a closed profile and an
//       unknown kind each say so.
//    5. The wiring: main.dart registers the opener; the service reads the
//       payload; a tap that launched the app is held until the opener exists.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/notification_opener.dart';
import 'package:parentveda/screens/ttc/chats/ttc_chat.dart' show ttcFirstOpenable;
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/notification_link.dart';
import 'package:parentveda/services/notification_service.dart';
import 'package:parentveda/services/pp_messages_store.dart';
import 'package:parentveda/services/preg_messages_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_fertility_help_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_messages_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

String _code(String path) => File(path).readAsStringSync().replaceAll('\r\n', '\n');

/// The body of `case <Enum>.<kind>:` inside the first switch after [fnHead]
/// in [source]: the lines up to the next live `case` or the switch's close.
/// Comment lines are skipped, so a "kept for revert" case does not count.
String _caseBody(String source, String fnHead, String enumName, String kind) {
  final start = source.indexOf(fnHead);
  expect(start, greaterThanOrEqualTo(0), reason: '$fnHead not found');
  final lines = source.substring(start).split('\n');
  final out = <String>[];
  var inCase = false;
  for (final raw in lines.skip(1)) {
    final line = raw.trim();
    if (line.startsWith('//')) continue;
    if (line.startsWith('case $enumName.')) {
      if (inCase && out.isNotEmpty) break; // the next case: done
      if (line.startsWith('case $enumName.$kind:')) inCase = true;
      continue;
    }
    if (raw.startsWith('}')) break; // end of the function
    if (inCase) out.add(line);
  }
  return out.join('\n');
}

/// Records what would have gone to the phone, payload included.
class _Phone implements TtcMessagePhone {
  final Map<int, String?> payloads = {};
  @override
  Future<void> schedule(
      {required int id, required String title, required String body, required DateTime when, String? payload}) async {
    payloads[id] = payload;
  }

  @override
  Future<void> cancel(int id) async => payloads.remove(id);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUpAll(() async {
    CycleStore.instance;
    TtcStore.instance;
    LifeStageStore.instance;
    TtcLogStore.instance;
    TtcTreatmentStore.instance;
    await TtcFertilityHelpStore.instance.load();
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  });

  // ===========================================================================
  group('1. every kind is pinned to its destination', () {
    // TTC routes by surface id; the first one that resolves is opened.
    const ttc = <TtcMessageKind, String>{
      TtcMessageKind.windowOpens: 'ttc_window',
      TtcMessageKind.periodCame: 'ttc_read/ttc_read_period_came',
      TtcMessageKind.lateByOne: 'ttc_chat/should_test',
      TtcMessageKind.cycleReport: 'ttc_chat/cycle_report',
      TtcMessageKind.tryingLong: 'ttc_fertility_help',
      TtcMessageKind.waitStarts: 'ttc_read/ttc_read_two_week_wait',
      TtcMessageKind.periodSoon: 'ttc_read/ttc_read_when_to_test',
      TtcMessageKind.dayLine: 'ttc_cycle',
      TtcMessageKind.checkIn: 'ttc_symptom_log',
      TtcMessageKind.offer: 'ttc_shop',
      TtcMessageKind.treatment: 'ttc_treatment',
    };

    test('TTC: each kind opens its own surface, never the Messages list', () {
      for (final k in TtcMessageKind.values) {
        expect(ttc.containsKey(k), isTrue, reason: 'a new TTC kind needs a row here: $k');
        expect(k.destinations.first, ttc[k], reason: '$k');
        final opens = ttcFirstOpenable(k.destinations);
        expect(opens, isNotNull, reason: '$k resolves to nothing');
        expect(opens, isNot('ttc_messages'), reason: '$k');
      }
    });

    // Pregnancy and Parenting route in a switch; each case is pinned by what
    // it pushes.
    const preg = <PregMessageKind, String>{
      PregMessageKind.newWeek: "'pregnancy/week'",
      PregMessageKind.dayLine: "'pregnancy/week'",
      PregMessageKind.checkIn: r"'bracket/$kSymptomsBracketId'",
      PregMessageKind.offer: '_openOffer(context, m.ref)',
      PregMessageKind.firstVisit: "'preg_scan_read_first_visit'",
      PregMessageKind.datingScan: "'scans/detail'",
      PregMessageKind.glucoseTest: "'scans/detail'",
      PregMessageKind.growthScan: "'scans/detail'",
      PregMessageKind.ntScan: "'bracket/pregnancy_scans_tests'",
      PregMessageKind.anomalyScan: "'bracket/pregnancy_scans_tests'",
      PregMessageKind.tdap: "'preg_scan_read_vaccines'",
      PregMessageKind.movements: "'tools/movement'",
      PregMessageKind.hospitalBag: "'tools/hospital_bag'",
      PregMessageKind.babyArrived: 'showPvAddChildSheet(context, arrival: true)',
    };

    test('Pregnancy: each kind opens its own page, never the home', () {
      final src = _code('lib/screens/pregnancy/preg_messages_screen.dart');
      for (final k in PregMessageKind.values) {
        expect(preg.containsKey(k), isTrue, reason: 'a new Pregnancy kind needs a row here: $k');
        // Grouped cases share the body of the last case in the group.
        var body = _caseBody(src, 'void openPregMessage(', 'PregMessageKind', k.name);
        if (body.isEmpty) {
          final group = {
            PregMessageKind.datingScan: 'growthScan',
            PregMessageKind.glucoseTest: 'growthScan',
            PregMessageKind.ntScan: 'anomalyScan',
          }[k];
          body = _caseBody(src, 'void openPregMessage(', 'PregMessageKind', group ?? k.name);
        }
        expect(body, contains(preg[k]), reason: '$k');
        expect(body, isNot(contains('isFirst')), reason: '$k must not go home');
      }
    });

    const pp = <PpMessageKind, String>{
      PpMessageKind.vaccine: "'pp/vaccines'",
      PpMessageKind.offer: '_openOffer(context, m.ref)',
      PpMessageKind.milestones: 'PhaseDetailScreen(phase: phase)',
      PpMessageKind.activity: 'PhaseDetailScreen(phase: phase)',
      PpMessageKind.tip: 'SavedTipScreen(tip: tip)',
      // The one home: the age note's page IS the child's home (B0, the
      // user's call, 2026-10-30).
      PpMessageKind.age: 'popUntil((r) => r.isFirst)',
    };

    test('Parenting: each kind opens its own page; only the age note goes home', () {
      final src = _code('lib/screens/post_pregnancy/pp_messages_screen.dart');
      for (final k in PpMessageKind.values) {
        expect(pp.containsKey(k), isTrue, reason: 'a new Parenting kind needs a row here: $k');
        final body = _caseBody(src, 'void openPpMessage(', 'PpMessageKind', k.name);
        expect(body, contains(pp[k]), reason: '$k');
        if (k != PpMessageKind.age) {
          expect(body, isNot(contains('isFirst')), reason: '$k must not go home');
        }
      }
    });

    test('Parenting: a dated or staged message names its day and its stage', () {
      expect(ppMessageDay('tip:2026-11-02'), DateTime(2026, 11, 2));
      expect(ppMessageDay('child:abc|tip:2026-11-02'), DateTime(2026, 11, 2));
      expect(ppMessageDay('act:2026-11-2'), DateTime(2026, 11, 2));
      expect(ppMessageDay('child:abc|act:2026-1-12'), DateTime(2026, 1, 12));
      expect(ppMessageDay('phase:4'), isNull);
      expect(ppMessagePhaseNumber('phase:4'), 4);
      expect(ppMessagePhaseNumber('child:abc|phase:12'), 12);
      expect(ppMessagePhaseNumber('tip:2026-11-02'), isNull);
      // The activity is picked by the same month count the page opens on.
      expect(ppActivityMonthsOn(DateTime(2026, 1, 1), DateTime(2026, 3, 3)), 2);
      expect(_code('lib/services/pp_messages_store.dart'), contains('final months = ppActivityMonthsOn(f.dob, day);'));
    });
  });

  // ===========================================================================
  group('2. a tap opens THE message, by id', () {
    late void Function(TtcMessage?) saved;
    setUp(() {
      saved = TtcMessagesStore.phoneTapOpener;
      TtcMessagesStore.instance.resetForTest();
      NotificationService.instance.setLinkOpener(NotificationOpener.open);
    });
    tearDown(() {
      TtcMessagesStore.phoneTapOpener = saved;
      NotificationService.instance.debugResetLinkOpener();
    });

    TtcMessage tip(String id, Duration ago) => TtcMessage(
        id: id, kind: TtcMessageKind.dayLine, at: DateTime.now().subtract(ago), title: 't', body: 'b');

    test("yesterday's tip opens yesterday's, not today's", () {
      final store = TtcMessagesStore.instance;
      store.apply([tip('tday:yesterday', const Duration(days: 1)), tip('tday:today', const Duration(hours: 1))],
          DateTime.now());
      TtcMessage? opened;
      TtcMessagesStore.phoneTapOpener = (m) => opened = m;
      NotificationService.instance
          .debugTapPayload(const NotificationLink(NotificationLink.ttcMessage, 'tday:yesterday').payload);
      expect(opened?.id, 'tday:yesterday');
      expect(store.delivered().firstWhere((m) => m.id == 'tday:yesterday').read, isTrue);
      expect(store.delivered().firstWhere((m) => m.id == 'tday:today').read, isFalse);
    });

    test('a message that has gone reaches the stage as null, which says so', () {
      var called = false;
      TtcMessage? opened;
      TtcMessagesStore.phoneTapOpener = (m) {
        called = true;
        opened = m;
      };
      NotificationService.instance
          .debugTapPayload(const NotificationLink(NotificationLink.ttcMessage, 'tday:long-gone').payload);
      expect(called, isTrue);
      expect(opened, isNull);
    });

    test('an old notification with no payload still opens, through the same opener', () {
      final store = TtcMessagesStore.instance;
      store.apply([tip('tday:today', const Duration(hours: 1))], DateTime.now());
      TtcMessage? opened;
      TtcMessagesStore.phoneTapOpener = (m) => opened = m;
      expect(store.handlePhoneTap(TtcMessageKind.dayLine.notificationId), isTrue);
      expect(opened?.id, 'tday:today');
    });
  });

  // ===========================================================================
  group('3. every stage message carries its address', () {
    test('the payload is the push shape, and garbage is not a link', () {
      const link = NotificationLink(NotificationLink.ppMessage, 'child:a|tip:2026-11-02');
      expect(NotificationLink.parse(link.payload), link);
      expect(link.payload, contains('"link_kind"'));
      expect(link.payload, contains('"link_id"'));
      expect(NotificationLink.fromData({'link_kind': 'product', 'link_id': 'p1'}),
          const NotificationLink('product', 'p1'));
      expect(NotificationLink.parse(null), isNull);
      expect(NotificationLink.parse(''), isNull);
      expect(NotificationLink.parse('not json'), isNull);
      expect(NotificationLink.parse('{"link_id":"x"}'), isNull);
    });

    test('TTC arms the window with its own message id', () async {
      CycleStore.instance.resetForTest();
      TtcStore.instance.resetForTest();
      TtcLogStore.instance.resetForTest();
      TtcTreatmentStore.instance.resetForTest();
      LifeStageStore.instance
        ..resetForTest()
        ..setStage(LifeStage.tryingToConceive);
      await TtcFertilityHelpStore.instance.reset();
      TtcMessagesStore.instance.resetForTest();
      final phone = _Phone();
      TtcMessagesStore.instance.phone = phone;
      final now = DateTime.now();
      CycleStore.instance
        ..logPeriodStart(now.subtract(const Duration(days: 59)))
        ..logPeriodStart(now.subtract(const Duration(days: 31)))
        ..logPeriodStart(now.subtract(const Duration(days: 3)));
      await TtcMessagesStore.instance.refresh();
      expect(phone.payloads, isNotEmpty);
      for (final p in phone.payloads.values) {
        final link = NotificationLink.parse(p);
        expect(link?.kind, NotificationLink.ttcMessage);
        expect(TtcMessagesStore.instance.messageById(link!.id), isNotNull, reason: link.id);
      }
      final window = NotificationLink.parse(phone.payloads[TtcMessageKind.windowOpens.notificationId]);
      expect(window?.id, startsWith('window:'));
    });

    test('all three stores hand the phone a payload naming their own kind', () {
      for (final (path, kind) in [
        ('lib/ttc/ttc_messages_store.dart', 'ttcMessage'),
        ('lib/services/preg_messages_store.dart', 'pregMessage'),
        ('lib/services/pp_messages_store.dart', 'ppMessage'),
      ]) {
        final src = _code(path);
        expect(src, contains('payload: NotificationLink(NotificationLink.$kind, m.id).payload'), reason: path);
        // The OS phone passes it on to the plugin.
        expect(src, contains('when: when, payload: payload)'), reason: path);
        expect(src, contains('NotificationLink(NotificationLink.$kind, m?.id ?? \'\')'), reason: '$path: the old-id path');
      }
    });
  });

  // ===========================================================================
  group('4. no silent tap', () {
    test('each stage says when the message has gone or the page is missing', () {
      for (final path in [
        'lib/screens/ttc/ttc_messages_screen.dart',
        'lib/screens/pregnancy/preg_messages_screen.dart',
        'lib/screens/post_pregnancy/pp_messages_screen.dart',
      ]) {
        final src = _code(path);
        expect(src, contains('kNotifMessageGone'), reason: path);
        expect(src, contains('kNotifPageMissing'), reason: path);
      }
      // The two that wait for their profile say so when it never comes.
      expect(_code('lib/screens/ttc/ttc_messages_screen.dart'), contains('pvToast(ctx, kNotifProfileClosed)'));
      expect(_code('lib/screens/pregnancy/preg_messages_screen.dart'), contains('pvToast(ctx, kNotifProfileClosed)'));
    });

    test('a campaign link that has gone, or a kind this build does not know, says so', () {
      final src = _code('lib/screens/notification_opener.dart');
      for (final c in ['kNotifGoneProduct', 'kNotifGoneCourse', 'kNotifGoneExpert', 'kNotifGoneRead', 'kNotifUnknownKind']) {
        expect(src, contains('pvToast(context, $c)'), reason: c);
      }
      expect(NotificationOpener.kinds, containsAll(['product', 'course', 'expert', 'read']));
      expect(NotificationOpener.kinds,
          containsAll([NotificationLink.ttcMessage, NotificationLink.pregMessage, NotificationLink.ppMessage]));
    });

    // Community C3-2 (0147): the three alert kinds, each pinned to its page.
    test('Community alerts: a reply opens the post, a moved session her bookings, at risk Moderation', () {
      final src = _code('lib/screens/notification_opener.dart');
      const head = 'static void _openThing';
      expect(NotificationOpener.kinds,
          containsAll(['community_post', 'booking', 'community_moderation']));
      expect(_caseBody(src, head, 'NotificationLink', 'communityPost'),
          contains('openCommunityPost(context, link.id)'));
      // An empty id still lands somewhere real: Replies to you.
      expect(_caseBody(src, head, 'NotificationLink', 'communityPost'),
          contains('openCommunityActivity(context)'));
      expect(_caseBody(src, head, 'NotificationLink', 'booking'), contains('PvMyLearningScreen()'));
      final mod = _caseBody(src, head, 'NotificationLink', 'communityModeration');
      expect(mod, contains('openCommunityModeration(ctx)'));
      // Not a moderator any more: said, not a silent tap or a queue she may not see.
      expect(mod, contains('pvToast(ctx, kNotifNotModerator)'));
      expect(mod, contains('store.me.isMod'));
    });
  });

  // ===========================================================================
  group('5. wiring', () {
    tearDown(NotificationService.instance.debugResetLinkOpener);

    test('a tap that launched the app is held until the opener exists', () {
      final service = NotificationService.instance;
      service.debugResetLinkOpener();
      const link = NotificationLink(NotificationLink.product, 'p1');
      service.debugTapPayload(link.payload);
      final seen = <NotificationLink>[];
      service.setLinkOpener(seen.add);
      expect(seen, [link]);
      service.debugTapPayload(link.payload);
      expect(seen, [link, link]);
    });

    test('a payload wins over the id; no payload falls back to the id', () {
      final service = NotificationService.instance;
      final links = <NotificationLink>[];
      final ids = <int>[];
      bool listener(int id) {
        ids.add(id);
        return true;
      }

      service.setLinkOpener(links.add);
      service.addTapListener(listener);
      addTearDown(() => service.removeTapListener(listener));
      service.debugTapPayload(const NotificationLink('read', 'r1').payload, id: 918130);
      expect(links, hasLength(1));
      expect(ids, isEmpty);
      service.debugTap(918130);
      expect(ids, [918130]);
    });

    test('main.dart registers the one opener; the service reads and sends the payload', () {
      expect(_code('lib/main.dart'), contains('NotificationService.instance.setLinkOpener(NotificationOpener.open);'));
      final svc = _code('lib/services/notification_service.dart');
      expect(svc, contains('onDidReceiveNotificationResponse: (r) => _deliverResponse(r.id, r.payload)'));
      expect(svc, contains('_deliverResponse(id, payload);'));
      expect(svc, contains('payload: payload,'));
    });
  });
}
