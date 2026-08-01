// =============================================================================
//  Health Wallet — two live versions, and the two lines that matter.
// -----------------------------------------------------------------------------
//  V1 (the shipped HealthHomeScreen) was retired from the toggle on
//  2026-08-01, once the comparison against what ships had been made. It is
//  commented in place, not deleted, and the tests below hold that distinction:
//  the branch is still in the file, the screen is still on disk, and nothing
//  in the toggle reaches it.
//
//  The two that are specific to this feature are clinical rather than
//  editorial, which is why they are asserted rather than trusted to a comment:
//
//    1. V3's status card never tells a parent her child is healthy. The app
//       knows what has been typed into it and nothing else, and the gap
//       between those is where a green dot does harm.
//
//    2. Nothing is created from an extracted document without a human
//       confirming it. A misread dose becomes a recurring alarm for the wrong
//       amount, delivered on time, with the app's authority behind it.
//
//  V2 keeps both of the brief's originals on purpose. A V2 with the sharp
//  edges filed off is V3 with a different title, and then there is nothing to
//  compare.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/models/reminder.dart';
import 'package:parentveda/screens/post_pregnancy/pp_health_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_wallet_data.dart';

/// Strip comment lines before asserting a word is ABSENT — these files quote
/// the brief's wording while declining it.
String _code(String src) => src
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

/// Splice adjacent string literals back together before asserting on COPY.
///
/// Dart wraps long prose across lines as `'…is the right ' 'call.'`, so a
/// sentence that reads as one thing on screen is two literals in the source
/// and a naive contains() misses it. Cost me two red tests to notice.
String _prose(String src) => _code(src).replaceAll(RegExp(r"'\s+'"), '');

/// One class out of a file, so an assertion about the upload screen is neither
/// satisfied nor broken by the reminders screen sitting next to it.
String _classBody(String src, String name) {
  final start = src.indexOf('class $name ');
  if (start < 0) return '';
  final next = RegExp(r'\nclass ').firstMatch(src.substring(start + 1));
  return next == null
      ? src.substring(start)
      : src.substring(start, start + 1 + next.start);
}

void main() {
  final v2 = _code(File('lib/screens/post_pregnancy/wallet_v2_screens.dart')
      .readAsStringSync());
  final v3src = File('lib/screens/post_pregnancy/wallet_v3_screens.dart')
      .readAsStringSync();
  final v3 = _code(v3src);
  final v3prose = _prose(v3src);
  final v2src = File('lib/screens/post_pregnancy/wallet_v2_screens.dart')
      .readAsStringSync();
  final v2prose = _prose(v2src);
  final upload = _code(_classBody(v2src, 'WalletUploadScreen'));
  final wrapper = _code(
      File('lib/screens/post_pregnancy/wallet_home_screen.dart').readAsStringSync());
  final drawer = File('lib/screens/post_pregnancy/explore_drawer.dart')
      .readAsStringSync();
  final home = File('lib/screens/post_pregnancy/post_pregnancy_home.dart')
      .readAsStringSync();

  group('nothing was taken away', () {
    test('every shipped health screen still exists', () {
      for (final f in [
        'health_home_screen.dart',
        'health_timeline_screen.dart',
        'health_records_screen.dart',
        'health_growth_screen.dart',
        'health_doctor_visit_screen.dart',
        'health_emergency_screen.dart',
        'health_guide_screen.dart',
      ]) {
        expect(File('lib/screens/post_pregnancy/$f').existsSync(), isTrue,
            reason: '$f is gone — it was to be reused, not replaced');
      }
    });

    test('the old Explore row is commented, not deleted', () {
      expect(
          drawer.contains(
              "// _section(context, Icons.monitor_heart_outlined, 'Health',"),
          isTrue);
    });

    test('the old home quick-action is commented, not deleted', () {
      expect(
          home.contains(
              "// _qa(Icons.monitor_heart_outlined, 'Health', () => _push(const HealthHomeScreen())),"),
          isTrue);
    });

    test('both doors now open the wrapper', () {
      expect(drawer.contains('const WalletHomeScreen()'), isTrue);
      expect(home.contains('const WalletHomeScreen()'), isTrue);
    });

    test('the two live versions are constructed', () {
      for (final s in ['const WalletV2Home()', 'const WalletV3Home()']) {
        expect(wrapper.contains(s), isTrue, reason: '$s is never built');
      }
    });

    test('V1 is retired from the toggle, not removed from the app', () {
      final raw =
          File('lib/screens/post_pregnancy/wallet_home_screen.dart')
              .readAsStringSync();
      // Commented, with the screen still on disk and still importable, so
      // reinstating it is one line rather than an archaeology exercise.
      expect(raw.contains('//   WalletVersion.v1 => const HealthHomeScreen(),'),
          isTrue,
          reason: 'the V1 branch should be commented in place');
      expect(wrapper.contains('const HealthHomeScreen()'), isFalse,
          reason: 'V1 must not still be reachable from the toggle');
      expect(
          File('lib/screens/post_pregnancy/health_home_screen.dart')
              .existsSync(),
          isTrue);
    });

    test('the pill offers two segments, with the third kept for revert', () {
      final raw = File('lib/screens/post_pregnancy/pp_wallet_data.dart')
          .readAsStringSync();
      expect(raw.contains("//   seg('V1', WalletVersion.v1),"), isTrue);
      expect(_code(raw).contains("seg('V1'"), isFalse);
      expect(_code(raw).contains("seg('V2'"), isTrue);
      expect(_code(raw).contains("seg('V3'"), isTrue);
    });
  });

  group('the status card — the line that matters most', () {
    test("the brief's version says Healthy, unaltered", () {
      final s = walletStatusDoc();
      expect(s.headline, 'Healthy',
          reason: 'V2 must keep the brief\'s claim or the comparison is fake');
      expect(s.tone, 'good');
    });

    test('V3 never asserts the child is healthy or fine', () {
      final s = walletStatusRecord();
      final all = '${s.headline} ${s.sub}'.toLowerCase();
      for (final claim in [
        'healthy',
        'all is well',
        'everything looks fine',
        'no concerns',
        'doing well',
        'normal',
      ]) {
        expect(all.contains(claim), isFalse,
            reason: 'V3 status claims "$claim" — the app cannot know that; it '
                'only knows what has been typed in');
      }
    });

    test('V3 talks about the record instead', () {
      final s = walletStatusRecord();
      expect(s.headline.toLowerCase().contains('waiting'), isTrue,
          reason: 'the answerable question is "is anything waiting for you?"');
    });

    test('V3 says out loud what the card is not', () {
      // The disclosure is the other half of declining the green dot: a parent
      // who reads "nothing waiting" must not read it as "all is well".
      expect(v3.contains('What this card is, and is not'), isTrue);
      expect(v3prose.contains('does not mean all is well'), isTrue);
      expect(v3prose.contains('paediatrician is the right call'), isTrue,
          reason: 'anything clinical routes calmly to a doctor');
    });

    test('only V3 carries the disclosure — V2 has the brief\'s card as-is', () {
      expect(v2.contains('What this card is, and is not'), isFalse);
    });
  });

  group('nothing is auto-created from a document', () {
    test('the upload screen never writes a reminder', () {
      // The whole safety argument in one assertion: no path from an upload
      // screen to a reminder being created.
      expect(upload, isNotEmpty, reason: 'WalletUploadScreen not found');
      expect(upload.contains('WalletReminders.add('), isFalse,
          reason: 'a reminder created from an unread document is a dose alarm '
              'nobody checked');
      expect(v3.contains('WalletReminders.add('), isFalse);
      // The reminders HUB may create them — a parent tapped a switch there.
      expect(v2.contains('WalletReminders.add('), isTrue,
          reason: 'the hub is how a reminder is meant to be created');
    });

    test('the extraction is honest about not existing', () {
      expect(v2prose.contains('not wired up yet'), isTrue,
          reason: 'a demo that pretends to read a prescription is the one demo '
              'that could get somebody hurt if believed');
    });

    test('V3 states the confirm-first rule on screen', () {
      expect(v2prose.contains('until you have confirmed each field'), isTrue,
          reason: 'the upload screen is shared; it reads the version to decide '
              'which of the two plans it describes');
    });
  });

  group('reminders reuse the one scheduler', () {
    test('the wallet contributes categories, not a second system', () {
      for (final k in kWalletReminderKinds) {
        expect(k.category.startsWith('hw_'), isTrue,
            reason: '${k.id} would collide with the pregnancy reminders');
      }
    });

    test('every kind is distinct and named', () {
      final ids = <String>{};
      for (final k in kWalletReminderKinds) {
        expect(ids.add(k.id), isTrue, reason: 'duplicate kind: ${k.id}');
        expect(k.label.trim(), isNotEmpty);
        expect(k.blurb.trim(), isNotEmpty, reason: '${k.id} has no explanation');
      }
    });

    test('medicine is deliberately NOT one of them', () {
      // A second source of truth for a dose is the one place in this feature
      // where being wrong has a physical consequence.
      for (final k in kWalletReminderKinds) {
        expect(k.id, isNot('medicine'));
        expect(k.id, isNot('medication'));
      }
      // …and the screen explains where it went, rather than leaving a parent
      // to conclude it is missing.
      expect(v2prose.contains('Medicine reminders live with the medicine'), isTrue);
    });

    test('the brief\'s other reminder kinds are all present', () {
      final ids = kWalletReminderKinds.map((k) => k.id).toSet();
      for (final wanted in [
        'vaccine',
        'followup',
        'checkup',
        'dental',
        'vision',
        'refill',
        'growth',
        'seasonal',
      ]) {
        expect(ids.contains(wanted), isTrue, reason: 'missing: $wanted');
      }
    });

    test('a wallet reminder is recognisable as one', () {
      const r = Reminder(
          id: 'x', title: 't', hour: 9, minute: 0, category: 'hw_dental');
      const other = Reminder(
          id: 'y', title: 't', hour: 9, minute: 0, category: 'kegel');
      expect(WalletReminders.isWallet(r), isTrue);
      expect(WalletReminders.isWallet(other), isFalse);
    });
  });

  group('dates', () {
    test('the record format parses', () {
      expect(walletDate('14 Jun 2026'), DateTime(2026, 6, 14));
      expect(walletDate('2 Jun 2026'), DateTime(2026, 6, 2));
      expect(walletDate('22 July 2026'), DateTime(2026, 7, 22));
    });

    test('nonsense returns null rather than a guess', () {
      // A silently mis-parsed date puts an event in the wrong year and quietly
      // changes what the observations say.
      for (final bad in ['', 'soon', 'Jun 2026', '14 Xyz 2026', '14 Jun']) {
        expect(walletDate(bad), isNull, reason: bad);
      }
    });

    test('round-trips through the label', () {
      final d = DateTime(2026, 8, 1);
      expect(walletDate(walletDateLabel(d)), d);
    });

    test('every seeded health date is readable', () {
      for (final s in kSymptoms) {
        expect(walletDate(s.date), isNotNull, reason: '${s.name}: ${s.date}');
      }
      for (final r in kReports) {
        expect(walletDate(r.date), isNotNull, reason: '${r.name}: ${r.date}');
      }
    });
  });

  group('"understand" observes, never diagnoses', () {
    test('no observation names a cause or a condition', () {
      // "Three fevers" is a count. "Three fevers, which can mean X" is a
      // diagnosis, and is the line this must not cross.
      for (final c in walletConnections()) {
        final all = '${c.title} ${c.body} ${c.action}'.toLowerCase();
        for (final banned in [
          'this means',
          'this suggests',
          'likely',
          'diagnos',
          'you should',
          'probably',
          'indicates',
        ]) {
          expect(all.contains(banned), isFalse,
              reason: '"${c.title}" says "$banned"');
        }
      }
    });

    test('every observation routes to a person, not a conclusion', () {
      for (final c in walletConnections()) {
        expect(c.action.trim(), isNotEmpty, reason: c.title);
      }
    });

    test('the seasonal nudge fires at most once', () {
      // One nudge is a nudge; four is nagging.
      final seasonal =
          walletConnections().where((c) => c.id.startsWith('season_')).toList();
      expect(seasonal.length, lessThanOrEqualTo(1));
    });
  });

  group('the emergency card', () {
    test('carries what a stranger needs in two minutes', () {
      final t = walletEmergencyText();
      for (final field in ['CHILD:', 'BLOOD:', 'ALLERGIES:', 'MEDICINES:']) {
        expect(t.contains(field), isTrue, reason: 'missing $field');
      }
    });

    test('says "not recorded" rather than going blank', () {
      // A blank line beside BLOOD reads as "we lost it"; "not recorded" tells
      // a clinician to stop looking and ask.
      final t = walletEmergencyText();
      for (final line in t.split('\n')) {
        expect(line.trim().endsWith(':'), isFalse,
            reason: 'empty field rendered: "$line"');
      }
    });

    test('the QR holds the text, not a link', () {
      // An emergency is the one moment there may be no internet. A QR that
      // resolves to a URL is a card that fails exactly when it is needed.
      final t = walletEmergencyText();
      expect(t.contains('http'), isFalse);
      expect(v2.contains('Barcode.qrCode().toSvg('), isTrue);
    });

    test('carries no history, address or reports', () {
      final t = walletEmergencyText().toLowerCase();
      for (final banned in ['address', 'report', 'history', 'insurance no']) {
        expect(t.contains(banned), isFalse, reason: 'card leaks $banned');
      }
    });
  });

  group('vaccination is linked, not absorbed', () {
    test('V3 opens the existing tracker', () {
      expect(v3.contains('VaxTrackerScreen()'), isTrue,
          reason: 'folding a large shipped tracker into a Records row would '
              'either duplicate it or strand it');
      expect(v3.contains('Kept separate on purpose'), isTrue);
    });
  });

  group('the version switch', () {
    test('opens on V2, now that V1 is retired', () {
      // Was V1 while the comparison against what ships was being made.
      expect(WalletVersionStore.instance.version, WalletVersion.v2);
    });

    test('a stale V1 selection still renders something', () {
      // The enum value survives for revert, so the switch must answer for it
      // rather than throwing on a value nothing sets any more.
      final raw = File('lib/screens/post_pregnancy/wallet_home_screen.dart')
          .readAsStringSync();
      expect(_code(raw).contains('_ => const WalletV2Home()'), isTrue,
          reason: 'v1 has to fall through to something');
    });

    test('switches, notifies once, and every version is captioned', () {
      final store = WalletVersionStore.instance;
      var fired = 0;
      void l() => fired++;
      store.addListener(l);
      store.setVersion(WalletVersion.v3);
      expect(fired, 1);
      store.setVersion(WalletVersion.v3);
      expect(fired, 1, reason: 're-selecting must not rebuild');
      store.removeListener(l);

      for (final v in WalletVersion.values) {
        store.setVersion(v);
        expect(store.label.trim(), isNotEmpty);
      }
      store.setVersion(WalletVersion.v2);
    });
  });

  group('no decorative emoji in rendered strings', () {
    test('the wireframe glyphs did not survive into the UI', () {
      final emoji = RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true);
      for (final src in [v2, v3, wrapper]) {
        for (final line in src.split('\n')) {
          expect(emoji.hasMatch(line), isFalse, reason: line.trim());
        }
      }
    });
  });
}
