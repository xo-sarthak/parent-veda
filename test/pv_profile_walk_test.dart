// Every row on the trying-to-conceive profile and on its Settings page is
// tapped, one at a time from a fresh screen, and must open something (a page,
// a sheet or a dialog) without an error (2026-09-30, the user: "make sure
// everything works in the profile section and the settings section").
//
// "Opens something" is measured two ways: a route was pushed (a page, a sheet
// or a dialog is a route), or the tap changed the screen's own state (a
// switch). A row that does nothing fails here.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parentveda/screens/profile/pv_you_chrome.dart';
import 'package:parentveda/screens/profile/pv_you_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_home_version.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/widgets/pv_toast.dart';

class _Pushes extends NavigatorObserver {
  final List<Route<dynamic>> pushed = [];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      pushed.add(route);
}

const _profile = PvYouScreen(stage: LifeStage.tryingToConceive);

Future<_Pushes> _pump(WidgetTester tester) async {
  final obs = _Pushes();
  tester.view.physicalSize = const Size(392, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    key: UniqueKey(),
    navigatorObservers: [obs],
    home: _profile,
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  obs.pushed.clear();
  return obs;
}

Future<void> _openSettings(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(kPvProfileSettingsRowKey));
  await tester.tap(find.byKey(kPvProfileSettingsRowKey));
  await tester.pumpAndSettle();
}

/// The words on every tappable row on screen, in order.
List<String> _rowTitles(WidgetTester tester) => [
      for (final e in find.byType(PvProfileRow).evaluate())
        if ((e.widget as PvProfileRow).onTap != null)
          (e.widget as PvProfileRow).title,
      for (final e in find.byType(PvYouRow).evaluate())
        if ((e.widget as PvYouRow).onTap != null) (e.widget as PvYouRow).title,
      for (final e in find.byType(PvProfileTile).evaluate())
        (e.widget as PvProfileTile).title,
    ];

Finder _rowByTitle(String title) => find.byWidgetPredicate((w) =>
    (w is PvProfileRow && w.title == title && w.onTap != null) ||
    (w is PvYouRow && w.title == title && w.onTap != null) ||
    (w is PvProfileTile && w.title == title));

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    TtcPartnerMode.instance.on = false;
    TtcHomeVersionStore.instance.set(TtcHomeVersion.v3);
  });

  // Rows whose tap leaves the app or signs her out: checked to be wired,
  // not followed (a test cannot sign out of a backend it never signed into).
  const leaves = {'Not signed in', 'Sign out', 'Contact us'};

  testWidgets('every profile row opens something', (tester) async {
    await _pump(tester);
    final titles = _rowTitles(tester);
    expect(titles, isNotEmpty);
    for (final t in titles) {
      if (leaves.contains(t)) continue;
      final obs = await _pump(tester);
      final row = _rowByTitle(t).first;
      await tester.ensureVisible(row);
      await tester.tap(row);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull, reason: '"$t" threw');
      expect(obs.pushed, isNotEmpty, reason: '"$t" opened nothing');
    }
  });

  testWidgets('every Settings row opens something', (tester) async {
    await _pump(tester);
    await _openSettings(tester);
    final titles = _rowTitles(tester);
    for (final t in titles) {
      if (leaves.contains(t)) continue;
      final obs = await _pump(tester);
      await _openSettings(tester);
      obs.pushed.clear();
      final row = _rowByTitle(t).last;
      await tester.ensureVisible(row);
      await tester.tap(row);
      await tester.pump();
      // Some rows load a store first (the addresses sheet awaits the order
      // store): give its futures a few frames to settle.
      //
      // ⚠️ NOT `runAsync` (2026-10-31). Real time let google_fonts' font
      // loads (no network in a test, so a 400) fail INSIDE this test, so it
      // failed on the first row it opened, whatever the row did. The trap
      // ttc_palette_consistency_test.dart already names. Kept for revert:
      //   await tester.runAsync(
      //       () => Future<void>.delayed(const Duration(milliseconds: 300)));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 60));
      }
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull, reason: 'Settings › "$t" threw');
      // A switch answers in place: a changed value or a note on screen.
      final answered =
          obs.pushed.isNotEmpty || find.byType(PvToastCard).evaluate().isNotEmpty;
      expect(answered, isTrue, reason: 'Settings › "$t" did nothing');
    }
  });
}
