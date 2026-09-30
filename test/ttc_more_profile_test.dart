// =============================================================================
//  TTC's More, Profile and Settings, split (2026-09-29)
// -----------------------------------------------------------------------------
//  The user, on build 18: the More bento was "poor", and the fifth tab and the
//  avatar showed the same screen. Now:
//    · MORE (the fifth tab) holds what the app OFFERS beyond the four tabs,
//      in headed sections, and nothing about her account;
//    · PROFILE (the avatar) holds who she is, and ONE Settings row;
//    · SETTINGS holds account, preferences, notifications, privacy, support,
//      about, and Developer last, gated.
//
//  What this file holds:
//    1. More shows only offerings, in order, and every row and link lands on
//       its route (tapped, not read: the wiring gate is about a thumb).
//    2. Profile has exactly one Settings row; Settings has Developer last,
//       gated as before.
//    3. Every former You row is on exactly one of the three (the ledger,
//       `kTtcFormerYouRows`), and every row the content table has is in it.
//    4. His More and his profile hide her private rows.
//    5. Nothing overflows at 360dp, at 1x and 1.5x text.
//    6. (2026-09-29) What she HAS bought or booked is on the profile, two
//       tiles under the hero (Your orders, Your bookings), hers and his;
//       More has no orders, bookings or addresses; the addresses are in
//       Settings, Account.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/profile/pv_settings_screen.dart';
import 'package:parentveda/screens/profile/pv_you_chrome.dart'
    show PvProfileRow, PvProfileTile, PvYouRow;
import 'package:parentveda/screens/profile/pv_you_content.dart';
import 'package:parentveda/screens/profile/pv_you_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_home_version.dart';
import 'package:parentveda/screens/ttc/ttc_more_tab.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pv_order_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

const _profile = PvYouScreen(stage: LifeStage.tryingToConceive);
const _hisProfile = PvYouScreen(stage: LifeStage.tryingToConceive, father: true);
const _more = TtcMoreTab(bottomNav: TtcBottomNav(active: 4, v3: true));

/// Words that are never on More: account, settings, support, preferences,
/// developer, and her private rows.
const _neverOnMore = [
  'Settings',
  'Account',
  'Sign out',
  'Delete account',
  'Not signed in',
  'Signed in',
  'Data and privacy',
  'Help',
  'Contact us',
  'Get help now',
  'Support',
  'Language',
  'Reminders',
  'WhatsApp updates',
  'What you see',
  'Preferences',
  'Developer · debug only',
  'Notes for your doctor',
  'Your answers',
  'I got a positive test',
  // 2026-09-29: what she HAS bought or booked is on her profile.
  'Your orders',
  'Your bookings',
  'Orders',
  'Bookings',
  'Delivery addresses',
  kTtcMoreBookingsHeading,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    TtcPartnerMode.instance.on = false;
    TtcHomeVersionStore.instance.set(TtcHomeVersion.v3);
  });
  tearDown(() => TtcPartnerMode.instance.on = false);

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    double width = 392,
    double height = 6000,
    double textScale = 1.0,
    List<NavigatorObserver> observers = const [],
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        navigatorObservers: observers,
        builder: (c, w) => MediaQuery(
          data: MediaQuery.of(c)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: w!,
        ),
        home: child,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Set<String> texts(WidgetTester tester, [Finder? within]) => {
        for (final e in (within == null
                ? find.byType(Text)
                : find.descendant(of: within, matching: find.byType(Text)))
            .evaluate())
          if ((e.widget as Text).data != null) (e.widget as Text).data!,
        // A RichText-only label (none today) would be missed; Text covers
        // every row the three screens draw.
      };

  Future<void> openSettings(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(kPvProfileSettingsRowKey));
    await tester.tap(find.byKey(kPvProfileSettingsRowKey));
    await tester.pumpAndSettle();
    expect(find.byType(PvSettingsScreen), findsOneWidget);
  }

  // ===========================================================================
  group('More: only what the app offers', () {
    testWidgets('the sections, in order, and nothing of the account',
        (tester) async {
      await pump(tester, _more);
      expect(tester.takeException(), isNull);
      // The page's serif title (the bar's pill says More too).
      expect(find.text(kTtcMoreTitle), findsWidgets);
      final headings = [
        kTtcMoreExpertsHeading,
        kTtcMoreCoursesHeading,
        kTtcMoreGroupsHeading,
        // Kept for revert (2026-09-29, the section moved to the profile):
        //   kTtcMoreBookingsHeading,
        // 2026-09-29: every article and every film, one list each.
        kTtcMoreReadWatchHeading,
        // Off More since 2026-09-30 (the user). Kept for revert:
        //   kTtcMoreJourneyHeading,
        kTtcMoreBenefitsHeading,
      ];
      var y = -1.0;
      for (final h in headings) {
        expect(find.text(h), findsOneWidget, reason: 'no "$h" heading');
        final dy = tester.getTopLeft(find.text(h)).dy;
        expect(dy, greaterThan(y), reason: '"$h" is out of order');
        y = dy;
      }
      final all = texts(tester);
      for (final w in _neverOnMore) {
        expect(all, isNot(contains(w)), reason: '"$w" is not an offering');
      }
    });

    testWidgets('each consult shows its specialty and price, the andrologist '
        'says Coming soon, and paid looks the same everywhere', (tester) async {
      await pump(tester, _more);
      final experts = ttcMoreSections(partner: false)
          .firstWhere((s) => s.id == 'experts');
      expect(experts.rows, isNotEmpty);
      for (final r in experts.rows) {
        final row = find.byKey(ValueKey('ttc_more_row_${r.id}'));
        expect(row, findsOneWidget, reason: r.id);
        expect(r.line, isNotEmpty, reason: '${r.id} names no specialty');
        if (r.id == 'ttc_consult_androl') {
          expect(r.tag, TtcOfferKind.comingSoon);
          expect(r.price, isNull,
              reason: 'no price on a consult she cannot book');
        } else {
          expect(r.tag, TtcOfferKind.paid, reason: r.id);
          expect(r.price, startsWith('₹'), reason: r.id);
          expect(
              find.descendant(of: row, matching: find.text(r.price!)),
              findsOneWidget);
          expect(find.descendant(of: row, matching: find.text('Paid')),
              findsOneWidget);
          expect(
              find.descendant(
                  of: row, matching: find.byIcon(Icons.lock_outline_rounded)),
              findsOneWidget);
        }
      }
      expect(find.text('Coming soon'), findsOneWidget);
      // Every paid row on the page: a price and the one Paid pill.
      for (final s in ttcMoreSections(partner: false)) {
        for (final r in s.rows) {
          if (r.tag == TtcOfferKind.paid) {
            expect(r.price, isNotNull, reason: r.id);
          }
        }
      }
    });

    testWidgets('no Material icon as row art: every row draws a mark',
        (tester) async {
      await pump(tester, _more);
      for (final s in ttcMoreSections(partner: false)) {
        for (final r in s.rows) {
          final row = find.byKey(ValueKey('ttc_more_row_${r.id}'));
          expect(find.descendant(of: row, matching: find.byType(CustomPaint)),
              findsWidgets,
              reason: '${r.id} has no drawn mark');
        }
      }
    });

    testWidgets('every row and link lands where its label says',
        (tester) async {
      final names = <String?>[];
      final expected = <String, String>{
        'ttc_course_garbh': 'ttc/courses',
        // Kept for revert (2026-09-29, now the profile's tiles):
        //   'bookings': 'bookings',
        //   'orders': 'store/orders',
        // 2026-09-29, Read and watch.
        'all_reads': 'ttc/all_reads',
        'all_videos': 'ttc/all_videos',
        // Off More since 2026-09-30. Kept for revert:
        //   'map': 'ttc/map',
        //   'chapter': 'ttc/chapter',
        'employer': 'employer',
        'invite': 'invite',
      };
      final rows = [
        for (final s in ttcMoreSections(partner: false)) ...s.rows,
      ];
      for (final r in rows) {
        // Kept for revert (2026-09-29, the addresses are in Settings now):
        //   if (r.id == 'addresses') continue; // a sheet, checked below
        await pump(tester, _more, observers: [_Names(names.add)]);
        final row = find.byKey(ValueKey('ttc_more_row_${r.id}'));
        await tester.ensureVisible(row);
        names.clear();
        await tester.tap(row);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        final want = expected[r.id] ?? 'learn/offering/${r.id}';
        expect(names, contains(want), reason: '${r.title} went to $names');
        // A page that cannot build here (a network store) is not this
        // test's question; the route is.
        tester.takeException();
      }

      // The delivery addresses open the address sheet. Checked on the source:
      // the sheet first awaits the order store's one-time load, whose future
      // belongs to whichever test created the singleton, so tapping it here
      // proves nothing about the row.
      // ⚠️ 2026-09-29: the row is in Settings, Account now (pv_you_screen's
      // `_deliveryAddressesRow`). Kept for revert, the More check:
      //   final src = File('lib/screens/ttc/ttc_more_tab.dart')...
      //   RegExp(r"id: 'addresses',[\s\S]{0,400}?"
      //       r'open: \(c\) => showPvAddressesSheet\(c\)')
      final src = File('lib/screens/profile/pv_you_screen.dart')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(
          RegExp(r'Widget _deliveryAddressesRow\(V2Palette p\) \{[\s\S]{0,700}?'
                  r'open: \(c\) => showPvAddressesSheet\(c\)')
              .hasMatch(src),
          isTrue,
          reason: 'Delivery addresses must open the address sheet');

      // The two links.
      for (final (key, want) in [
        ('ttc_more_link_experts', 'ttc/consults'),
        ('ttc_more_all_programmes', 'ttc/prepare'),
      ]) {
        await pump(tester, _more, observers: [_Names(names.add)]);
        names.clear();
        await tester.ensureVisible(find.byKey(ValueKey(key)));
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(names, contains(want), reason: key);
        tester.takeException();
      }
    });

    test('the bar still lights More for the tab and the consults', () {
      expect(kTtcMoreRoute, kTtcYouRoute);
      expect(ttcV3ActiveFor(kTtcMoreRoute, 0), 4);
      expect(ttcV3ActiveFor('ttc/consults', 0), 4);
      expect(ttcV3ActiveFor('ttc/courses', 0), 4);
    });
  });

  // ===========================================================================
  group('Profile and Settings', () {
    testWidgets('the profile: identity, stage, answers, doctor, family, '
        'saved, and exactly one Settings row', (tester) async {
      await pump(tester, _profile);
      expect(tester.takeException(), isNull);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byKey(kPvProfileSettingsRowKey), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget,
          reason: 'one Settings entry, nothing else named Settings');
      // V3 (2026-09-29): the hero and the glance lead, "Your stage" (the
      // chapter stepper) is gone and "Your journey" holds the positive test.
      // Kept for revert, the V2 keys:
      //   'pv_profile_stage', 'pv_profile_answers', 'pv_profile_doctor',
      //   'pv_profile_family', 'pv_profile_things',
      for (final k in [
        'pv_profile_hero',
        'pv_profile_answers',
        'pv_profile_doctor',
        'pv_profile_journey',
        'pv_profile_family',
        'pv_profile_things',
      ]) {
        expect(find.byKey(ValueKey(k)), findsOneWidget, reason: k);
      }
      for (final w in [
        'Developer · debug only',
        'Language',
        'Sign out',
        'Delete account',
        'Help',
        kTtcMoreExpertsHeading,
        'Journey map',
      ]) {
        expect(find.text(w), findsNothing, reason: '"$w" is not on Profile');
      }
      // Unpaired, the partner is said once, on the Family row with its
      // Invite, not under her name as well (2026-09-30). Kept for revert:
      //   expect(find.text('Not paired with your partner yet'), findsOneWidget);
      expect(find.text('Not paired with your partner yet'), findsNothing);
      expect(find.byKey(const ValueKey('pv_profile_partner_row')), findsOneWidget);
    });

    testWidgets('Settings: its sections in order, Developer last and gated',
        (tester) async {
      await pump(tester, _profile);
      await openSettings(tester);
      var y = -1.0;
      for (final h in [
        'ACCOUNT',
        'PREFERENCES',
        'NOTIFICATIONS',
        'PRIVACY AND DATA',
        'SUPPORT',
        'ABOUT',
      ]) {
        expect(find.text(h), findsOneWidget, reason: h);
        final dy = tester.getTopLeft(find.text(h)).dy;
        expect(dy, greaterThan(y), reason: '$h is out of order');
        y = dy;
      }
      // Tests run in debug, so the gate is open: Developer is drawn, and
      // below everything else.
      expect(kPvShowDeveloper, isTrue);
      final dev = find.text('DEVELOPER · DEBUG ONLY');
      expect(dev, findsOneWidget);
      expect(tester.getTopLeft(dev).dy,
          greaterThan(tester.getTopLeft(find.text('ParentVeda')).dy),
          reason: 'Developer sits under the footer, last');
      // The gate is the one it always was.
      final src = File('lib/screens/profile/pv_you_screen.dart')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(src, contains('const bool kPvShowDeveloper = kDebugMode || kPvDevBuild;'));
      expect(src, contains('developer: kPvShowDeveloper ? () => _developer(p) : null,'));
    });

    testWidgets('a choice made in Settings repaints Settings', (tester) async {
      addTearDown(() => TtcLang.instance.hinglish = false);
      await pump(tester, _profile);
      await openSettings(tester);
      expect(find.text('English'), findsOneWidget);
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('हिंदी').last);
      await tester.pumpAndSettle();
      expect(find.byType(PvSettingsScreen), findsOneWidget);
      expect(find.text('हिंदी'), findsOneWidget);
    });

    test('the avatar opens the profile, not the More tab', () {
      final src = File('lib/screens/ttc/ttc_profile_screen.dart')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      final live = src
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      final body = RegExp(r'void openTtcProfile\(BuildContext context\) \{[\s\S]*?\n\}')
          .firstMatch(live)!
          .group(0)!;
      expect(body, contains('openPvYou('));
      expect(body, isNot(contains('openTtcTabV3')));
    });
  });

  // ===========================================================================
  group('Profile V3: a hero, no stepper, marks, one tint', () {
    DateTime day(int ago) {
      final n = DateTime.now();
      return DateTime(n.year, n.month, n.day).subtract(Duration(days: ago));
    }

    test('V3 is the profile that ships', () {
      expect(kPvTtcProfileV2, isTrue);
      expect(kPvTtcProfileV3, isTrue);
    });

    testWidgets('the hero: her name, a status line from her cycle, and her '
        'partner status', (tester) async {
      CycleStore.instance
        ..logPeriodStart(day(39))
        ..logPeriodStart(day(11));
      await pump(tester, _profile);
      expect(tester.takeException(), isNull);
      final hero = find.byKey(const ValueKey('pv_profile_hero'));
      expect(hero, findsOneWidget);
      // No name given in a test: the honest placeholder, and an Add.
      expect(find.descendant(of: hero, matching: find.text('You')),
          findsOneWidget);
      expect(find.descendant(of: hero, matching: find.text('Add your name')),
          findsOneWidget);
      // Derived, never asked: day 12 of the cycle her last period opened.
      expect(
          find.descendant(
              of: hero,
              matching: find.text('Trying to conceive · cycle day 12')),
          findsOneWidget);
      // Kept for revert (2026-09-30, the partner line only once paired):
      //   find.descendant(of: hero,
      //       matching: find.text('Not paired with your partner yet'))
      expect(find.byKey(const ValueKey('pv_profile_partner')), findsNothing);
      // The glance: her usual cycle (28 days, her own) and periods logged.
      final glance = find.byKey(const ValueKey('pv_profile_glance'));
      expect(glance, findsOneWidget);
      expect(find.descendant(of: glance, matching: find.text('28 days')),
          findsOneWidget);
      expect(find.descendant(of: glance, matching: find.text('2')),
          findsOneWidget);
    });

    testWidgets('with nothing logged the line is the stage alone and the '
        'glance says what fills it', (tester) async {
      await pump(tester, _profile);
      expect(find.text('Trying to conceive'), findsOneWidget);
      expect(find.textContaining('cycle day'), findsNothing);
      // An invitation, not dashes (2026-09-30). Kept for revert:
      //   find.text('Log your period on Today and your cycle facts fill in.')
      expect(find.byKey(const ValueKey('pv_profile_glance_invite')),
          findsOneWidget);
      expect(find.text('Your cycle at a glance'), findsOneWidget);
      expect(find.text('--'), findsNothing);
      expect(find.byKey(const ValueKey('pv_profile_glance_action')),
          findsOneWidget);
    });

    testWidgets('the photo: a camera badge on the avatar opens add a photo',
        (tester) async {
      await pump(tester, _profile);
      expect(find.byKey(const ValueKey('pv_profile_photo_badge')),
          findsOneWidget);
      // One way in: the avatar, with the badge drawn on it.
      await tester.tap(find.byKey(const ValueKey('pv_profile_avatar_tap')));
      await tester.pumpAndSettle();
      expect(find.text('Add a photo'), findsOneWidget);
      expect(find.byKey(const ValueKey('pv_profile_photo_camera')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('pv_profile_photo_gallery')),
          findsOneWidget);
      // No photo yet, so nothing to remove.
      expect(find.byKey(const ValueKey('pv_profile_photo_remove')),
          findsNothing);
    });

    testWidgets('his profile has no camera badge: the photo is hers',
        (tester) async {
      await pump(tester, _hisProfile);
      expect(find.byKey(const ValueKey('pv_profile_photo_badge')),
          findsNothing);
    });

    testWidgets('an empty answer says so, and one row changes them',
        (tester) async {
      await pump(tester, _profile);
      expect(find.text('Not answered'), findsWidgets);
      expect(find.text('--'), findsNothing);
      expect(find.text('What you told us when you joined. You can change any answer.'),
          findsOneWidget);
      expect(find.byKey(const ValueKey('pv_profile_change_answers')),
          findsOneWidget);
    });

    // Settings' "Your details" was taken back out the same night: Reminders
    // already opens that page (test/ttc_no_repetition_test.dart).

    testWidgets('no chapter stepper: the positive test is a row of its own',
        (tester) async {
      await pump(tester, _profile);
      expect(find.byKey(const ValueKey('pv_profile_stage')), findsNothing);
      for (final chapter in ['Trying', 'Pregnancy', 'Parenting', '6+']) {
        expect(find.text(chapter), findsNothing,
            reason: 'the stepper label "$chapter" is back');
      }
      final row = find.byKey(const ValueKey('pv_profile_positive_test'));
      expect(row, findsOneWidget);
      expect(
          find.descendant(
              of: row, matching: find.text('I got a positive test')),
          findsOneWidget);
    });

    testWidgets('every former Profile row lands where it did', (tester) async {
      final names = <String?>[];
      for (final (key, want) in [
        ('pv_profile_change_answers', 'you/details'),
        ('pv_profile_positive_test', 'ttc/positive_test'),
        ('pv_profile_partner_row', 'you/partner'),
        ('pv_profile_settings', kPvSettingsRoute),
      ]) {
        await pump(tester, _profile, observers: [_Names(names.add)]);
        names.clear();
        final f = find.byKey(ValueKey(key));
        await tester.ensureVisible(f);
        await tester.tap(f);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(names, contains(want), reason: '$key went to $names');
        tester.takeException();
      }
      for (final (label, want) in [
        ('Notes for your doctor', 'you/doctor_notes'),
        ('Saved', 'saved'),
      ]) {
        await pump(tester, _profile, observers: [_Names(names.add)]);
        names.clear();
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(names, contains(want), reason: '$label went to $names');
        tester.takeException();
      }
    });

    testWidgets('every row that goes somewhere leads with a drawn mark, on '
        'the profile and in Settings', (tester) async {
      await pump(tester, _profile);
      final rows = find.byType(PvProfileRow).evaluate().toList();
      expect(rows.length, greaterThanOrEqualTo(8));
      for (final r in rows) {
        final row = r.widget as PvProfileRow;
        expect(row.mark, isNot(isA<Icon>()), reason: row.title);
      }
      expect(find.byType(PvYouRow), findsNothing,
          reason: 'a line-icon row on the V3 profile');
      await openSettings(tester);
      final sections = find.byWidgetPredicate((w) =>
          w.key is ValueKey<String> &&
          (w.key as ValueKey<String>).value.startsWith('pv_settings_') &&
          (w.key as ValueKey<String>).value != 'pv_settings_developer');
      expect(sections, findsWidgets);
      var n = 0;
      for (final e in find
          .descendant(of: sections, matching: find.byType(PvYouRow))
          .evaluate()) {
        final row = e.widget as PvYouRow;
        expect(row.leading, isNotNull, reason: 'Settings "${row.title}"');
        n++;
      }
      expect(n, greaterThanOrEqualTo(10));
    });

    test('no off-palette colour in the profile files', () {
      for (final path in [
        'lib/screens/profile/pv_you_screen.dart',
        'lib/screens/profile/pv_you_chrome.dart',
        'lib/screens/profile/pv_you_content.dart',
        'lib/screens/profile/pv_settings_screen.dart',
        'lib/screens/profile/pv_profile_marks.dart',
      ]) {
        final src = File(path).readAsStringSync();
        for (final bad in ['ttcTitleInk', '0xFF2D144C', 'ttcPurple']) {
          expect(src.contains(bad), isFalse, reason: '$bad in $path');
        }
      }
      // The V3 parts use ink, tints and hairlines: never the violet action.
      final chrome = File('lib/screens/profile/pv_you_chrome.dart')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      final v3 = chrome.substring(chrome.indexOf('THE PROFILE, V3'));
      expect(v3.contains('p.action'), isFalse);
      expect(v3.contains('0xFF6A30B6'), isFalse);
      final marks =
          File('lib/screens/profile/pv_profile_marks.dart').readAsStringSync();
      expect(marks.contains('p.action'), isFalse);
      expect(marks.contains('Color(0x'), isFalse,
          reason: 'marks derive every colour from the one tint');
    });
  });

  // ===========================================================================
  group('Your orders and Your bookings: on the profile, under the hero', () {
    testWidgets('two equal tiles directly under the hero, above the glance',
        (tester) async {
      await pump(tester, _profile);
      expect(tester.takeException(), isNull);
      final hero = find.byKey(const ValueKey('pv_profile_hero'));
      final orders = find.byKey(const ValueKey('pv_profile_orders'));
      final bookings = find.byKey(const ValueKey('pv_profile_bookings'));
      final glance = find.byKey(const ValueKey('pv_profile_glance'));
      expect(orders, findsOneWidget);
      expect(bookings, findsOneWidget);
      expect(find.byType(PvProfileTile), findsNWidgets(2));
      // Side by side, the same size.
      final a = tester.getRect(orders);
      final b = tester.getRect(bookings);
      expect(a.top, b.top);
      expect(a.size, b.size);
      expect(a.right, lessThan(b.left));
      // Under the hero, before the glance and every group.
      expect(a.top, greaterThanOrEqualTo(tester.getRect(hero).bottom));
      // The glance's rect starts at its own top padding.
      expect(a.bottom, lessThanOrEqualTo(tester.getRect(glance).top));
      expect(a.bottom,
          lessThan(tester.getTopLeft(
              find.byKey(const ValueKey('pv_profile_answers'))).dy));
      // Titles, a drawn mark each, and "None yet" with nothing bought.
      expect(find.descendant(of: orders, matching: find.text('Your orders')),
          findsOneWidget);
      expect(
          find.descendant(of: bookings, matching: find.text('Your bookings')),
          findsOneWidget);
      for (final t in [orders, bookings]) {
        expect(find.descendant(of: t, matching: find.byType(CustomPaint)),
            findsWidgets);
        expect(find.descendant(of: t, matching: find.byType(Icon)),
            findsNothing, reason: 'a mark, not a Material icon');
      }
    });

    testWidgets('each tile lands on its route', (tester) async {
      final names = <String?>[];
      for (final (key, want) in [
        ('pv_profile_orders', 'store/orders'),
        ('pv_profile_bookings', 'bookings'),
      ]) {
        await pump(tester, _profile, observers: [_Names(names.add)]);
        names.clear();
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(names, contains(want), reason: '$key went to $names');
        tester.takeException();
      }
    });

    test('the lines: counts and dates, never more than the store says', () {
      final now = DateTime(2026, 9, 29, 10); // a Tuesday
      expect(pvProfileOrdersLine(const [], now: now), 'None yet');
      PvOrder order(PvOrderStatus s, int daysAgo) => PvOrder(
            id: 'o$daysAgo${s.name}',
            createdAt: now.subtract(Duration(days: daysAgo)),
            lines: const [],
            subtotal: 0,
            delivery: 0,
            address: const PvAddress(
                id: 'a',
                name: 'A',
                phone: '1',
                line1: 'x',
                city: 'Pune',
                pin: '411001',
                state: 'MH'),
            status: s,
          );
      expect(pvProfileOrdersLine([order(PvOrderStatus.paid, 1)], now: now),
          '1 confirmed'); // was '1 on the way' (2026-09-29, honest wording)
      expect(
          pvProfileOrdersLine(
              [order(PvOrderStatus.paid, 1), order(PvOrderStatus.placed, 0)],
              now: now),
          '1 waiting for payment');
      expect(pvProfileOrdersLine([order(PvOrderStatus.paid, 20)], now: now),
          '1 order');
      expect(
          pvProfileOrdersLine(
              [order(PvOrderStatus.paid, 20), order(PvOrderStatus.preview, 2)],
              now: now),
          '2 orders');

      expect(pvProfileBookingsLine(next: null, total: 0, now: now),
          'None yet');
      expect(pvProfileBookingsLine(next: null, total: 3, now: now),
          '3 bookings');
      expect(
          pvProfileBookingsLine(
              next: DateTime(2026, 10, 2, 17), total: 1, now: now),
          'Next: Fri 2 Oct');
      expect(
          pvProfileBookingsLine(
              next: DateTime(2026, 9, 29, 18), total: 1, now: now),
          'Next: today');
      expect(
          pvProfileBookingsLine(
              next: DateTime(2026, 9, 30, 9), total: 1, now: now),
          'Next: tomorrow');
    });

    testWidgets('Delivery addresses: once, in Settings, Account',
        (tester) async {
      await pump(tester, _profile);
      expect(find.text(kPvDeliveryAddressesTitle), findsNothing);
      await openSettings(tester);
      final row = find.text(kPvDeliveryAddressesTitle);
      expect(row, findsOneWidget);
      final account = tester.getTopLeft(find.text('ACCOUNT')).dy;
      final prefs = tester.getTopLeft(find.text('PREFERENCES')).dy;
      final y = tester.getTopLeft(row).dy;
      expect(y, greaterThan(account));
      expect(y, lessThan(prefs));
    });
  });

  // ===========================================================================
  group('every former row has exactly one home', () {
    test('every row the TTC content table holds is in the ledger', () {
      final content = pvYouContentFor(LifeStage.tryingToConceive);
      final rows = <String>{
        for (final t in content.tiles) t.title,
        for (final g in content.groups!)
          for (final t in g.things) t.title,
        for (final t in content.journeyThings) t.title,
        'I got a positive test',
        'Your partner',
        'Language',
        'Reminders',
        'WhatsApp updates',
        'Help',
        'Invite a friend',
        'Employer benefits',
        'About ParentVeda',
        'Not signed in',
        'Data and privacy',
        'Delete account',
      };
      for (final r in rows) {
        expect(kTtcFormerYouRows.containsKey(r), isTrue,
            reason: '"$r" has no home decided in kTtcFormerYouRows');
      }
    });

    testWidgets('each is on its home and on neither of the other two',
        (tester) async {
      await pump(tester, _profile);
      final profile = texts(tester);
      await openSettings(tester);
      final settings = texts(tester, find.byType(PvSettingsScreen));
      await pump(tester, _more);
      final more = texts(tester);
      final pages = {
        TtcRowHome.profile: profile,
        TtcRowHome.settings: settings,
        TtcRowHome.more: more,
      };
      for (final e in kTtcFormerYouRows.entries) {
        final (home, label) = e.value;
        for (final page in pages.entries) {
          expect(
            page.value.contains(label),
            page.key == home,
            reason: '"${e.key}" (as "$label") should be on ${home.name} '
                'only; checking ${page.key.name}',
          );
        }
      }
    });
  });

  // ===========================================================================
  group('his side', () {
    testWidgets('his More: what is for him or both, nothing of hers',
        (tester) async {
      TtcPartnerMode.instance.on = true;
      await pump(tester, _more);
      expect(tester.takeException(), isNull);
      final all = texts(tester);
      for (final w in _neverOnMore) {
        expect(all, isNot(contains(w)), reason: w);
      }
      expect(all, contains('Male fertility consultation'));
      expect(all, isNot(contains('Gynaecologist consultation')),
          reason: 'a consult for her alone');
      expect(all, isNot(contains('The PCOS programme')),
          reason: 'a group for women');
    });

    testWidgets('his profile: no answers of hers, no notes for her doctor',
        (tester) async {
      await pump(tester, _hisProfile);
      expect(tester.takeException(), isNull);
      expect(find.text('Notes for your doctor'), findsNothing);
      expect(find.text('YOUR ANSWERS'), findsNothing);
      expect(find.text('I got a positive test'), findsNothing);
      expect(find.byKey(kPvProfileSettingsRowKey), findsOneWidget);
      // V3: no glance of her cycle, no cycle day, no Edit of her name; his
      // journey row says how his side moves.
      expect(find.byKey(const ValueKey('pv_profile_glance')), findsNothing);
      expect(find.textContaining('cycle day'), findsNothing);
      expect(find.byKey(const ValueKey('pv_profile_edit')), findsNothing);
      expect(find.byKey(const ValueKey('pv_profile_journey_his')),
          findsOneWidget);
    });

    testWidgets('his profile has Your orders and Your bookings too, each '
        'landing on its route', (tester) async {
      final names = <String?>[];
      for (final (key, want) in [
        ('pv_profile_orders', 'store/orders'),
        ('pv_profile_bookings', 'bookings'),
      ]) {
        await pump(tester, _hisProfile, observers: [_Names(names.add)]);
        expect(tester.takeException(), isNull);
        expect(find.text(kPvProfileOrdersTitle), findsOneWidget);
        expect(find.text(kPvProfileBookingsTitle), findsOneWidget);
        names.clear();
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(names, contains(want), reason: '$key went to $names');
        tester.takeException();
      }
    });
  });

  // ===========================================================================
  group('it holds', () {
    for (final (w, scale) in [(360.0, 1.0), (360.0, 1.5), (392.0, 1.5)]) {
      testWidgets('${w.toInt()}dp at ${scale}x: More, his More, Profile and '
          'Settings', (tester) async {
        await pump(tester, _more, width: w, height: 5000, textScale: scale);
        expect(tester.takeException(), isNull, reason: 'More');
        TtcPartnerMode.instance.on = true;
        await pump(tester, _more, width: w, height: 5000, textScale: scale);
        expect(tester.takeException(), isNull, reason: 'his More');
        TtcPartnerMode.instance.on = false;
        await pump(tester, _profile, width: w, height: 5000, textScale: scale);
        expect(tester.takeException(), isNull, reason: 'Profile');
        await openSettings(tester);
        expect(tester.takeException(), isNull, reason: 'Settings');
        // 2026-09-29: his profile, with the orders and bookings tiles.
        await pump(tester, _hisProfile,
            width: w, height: 5000, textScale: scale);
        expect(tester.takeException(), isNull, reason: 'his Profile');
        expect(find.byType(PvProfileTile), findsNWidgets(2));
      });
    }
  });
}

class _Names extends NavigatorObserver {
  _Names(this.onName);
  final void Function(String?) onName;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onName(route.settings.name);
}
