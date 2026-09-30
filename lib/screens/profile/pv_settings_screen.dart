// =============================================================================
//  PvSettingsScreen — the one Settings page behind the profile (2026-09-29)
// -----------------------------------------------------------------------------
//  The user, on build 18: More must not hold "account, support, settings or
//  developer"; those belong in Profile, behind ONE Settings entry. So the
//  profile keeps what is about her, and everything about how the app behaves
//  for her, her account, and help sits here, in this order:
//
//    Account · Preferences · Notifications · Privacy and data · Support ·
//    About · (Developer, last, under the footer, debug and PV_DEV builds only)
//
//  From Mobbin (2026-09-29):
//   * Airbnb, Profile: the profile page ends in ONE settings row; settings are
//     a page of their own, never mixed into the profile.
//     https://mobbin.com/screens/8f7c5b27-db62-48f9-a403-7b8bdba1253b
//   * Flo, the profile menu and its Settings: the identity and "Report for a
//     doctor" first, then one Settings row; data requests on their own page.
//     https://mobbin.com/screens/b633224b-1ff0-48de-b39b-23f37ea41c41
//     https://mobbin.com/screens/d32631ca-6238-41f7-b605-9f3e87e3e037
//   * Klima, Settings: Account first with the facts as values on the right
//     (name, email), then App (notifications, privacy), then help.
//     https://mobbin.com/screens/2e1ab43e-5136-4599-ac9e-2f4e1323eaed
//   * Co-Star, Settings: Support holds "Mental health resources" and "Crisis
//     text line" beside feedback; our Get help now sits in Support the same
//     way.
//     https://mobbin.com/screens/6a37be28-9dbe-42d0-a60c-0a8601edede1
//   * Finch and Asana, Settings: headed white groups of rows, a version
//     line at the foot.
//     https://mobbin.com/screens/9f3079cb-12d4-464e-a75e-ca3f169520c6
//     https://mobbin.com/screens/26b77b00-208d-4d1f-91c0-20843986418a
//
//  ⚠️ THE ROWS ARE THE PROFILE'S OWN BUILDERS. The language, the WhatsApp
//  switch and the phone live in the profile's state, so this page is built
//  from closures that state hands in, and repaints on its stores plus a tick
//  the state bumps on every setState (the pattern the More bento's pages used
//  and `test/pv_more_bento_test.dart` proved: a choice made here repaints
//  here). Nothing is copied, so a row cannot say one thing here and another
//  on another stage.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import 'pv_you_chrome.dart';

/// One headed group on the Settings page.
class PvSettingsSection {
  const PvSettingsSection({
    required this.title,
    required this.rows,
    this.lead,
  });
  final String title;
  final String? lead;
  final List<Widget> rows;
}

/// The Settings route's name.
const String kPvSettingsRoute = 'you/settings';

class PvSettingsScreen extends StatelessWidget {
  const PvSettingsScreen({
    super.key,
    required this.sections,
    required this.listen,
    this.developer,
    this.footer = 'ParentVeda',
  });

  /// Built on every repaint, so a value is always the current one.
  final List<PvSettingsSection> Function() sections;

  /// The team's section, drawn LAST, under the footer, or null. The caller
  /// gates it (`kPvShowDeveloper`); this page never decides it.
  final Widget Function()? developer;

  final Listenable listen;
  final String footer;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Scaffold(
      backgroundColor: p.ground,
      body: ListenableBuilder(
        listenable: listen,
        builder: (context, _) => CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: PvYouTopBar(title: 'Settings')),
            // ⚠️ THE PROFILE'S GROUPS (2026-09-29, V3): the same grey heading,
            // gutter, gaps and hairlines as the profile, so the page behind
            // the Settings row reads as the same app. Kept for revert:
            //   PvYouSection(key: …, title: s.title, lead: s.lead,
            //       children: s.rows)
            for (final s in sections())
              SliverToBoxAdapter(
                child: PvProfileGroup(
                  key: ValueKey('pv_settings_${s.title.toLowerCase()}'),
                  title: s.title,
                  lead: s.lead,
                  children: s.rows,
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                // Kept for revert: EdgeInsets.fromLTRB(20, 22, 20, 0).
                padding: const EdgeInsets.fromLTRB(
                  kPvProfileGutter + 4,
                  kPvProfileGroupGap,
                  kPvProfileGutter,
                  0,
                ),
                child: Text(
                  footer,
                  style: pvManrope(fontSize: 11.5, color: p.ink3),
                ),
              ),
            ),
            // ⚠️ DEVELOPER LAST, UNDER THE FOOTER (the user, 2026-09-27): it
            // is never in a store build, so it reads as apart from the page
            // she will get.
            if (developer != null)
              SliverToBoxAdapter(
                key: const ValueKey('pv_settings_developer'),
                child: developer!(),
              ),
            SliverToBoxAdapter(
              child: SizedBox(
                  height: 40 + MediaQuery.of(context).padding.bottom),
            ),
          ],
        ),
      ),
    );
  }
}
