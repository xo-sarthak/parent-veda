// =============================================================================
//  ParentVeda Partners — the entrypoint for the ORGANISATION app.
// -----------------------------------------------------------------------------
//  Build it with:
//
//      flutter build apk --release --flavor partner \
//        --target lib/main_partner.dart
//
//  The third front door to the same lib/ (Partner Editions P1, MASTER D2).
//  For organisations with several people: an employer, a school, an IVF
//  centre with several doctors. A doctor with their own clinic is their own
//  partner and uses ParentVeda+ (MASTER D3); a parent uses ParentVeda.
//
//  WHAT IT BOOTS: Supabase and PartnerOrgSession. Nothing else. No
//  notifications (an admin has no reminders), no ExpertStore, none of the
//  parent app's forty stores. The tabs load their own numbers when P2-P4
//  give them some.
//
//  THE BOOT, copied from main_doctor.dart (D1) because it was hard-won there:
//
//    * startBackend() wraps Supabase.initialize. A throw is the can't-reach
//      screen with Try again, never a crash on launch.
//    * Resolving returns an enum, so a timeout reads as "unreachable", never
//      as "signed out". The sign-in form would ask her to fix something that
//      is not broken.
//    * The root LISTENS to PartnerOrgSession, so any way out of the session
//      (the Account tab's sign out, a refusal) lands on the sign-in screen
//      without the root having to be told.
//
//  ⚠️ BEFORE THE FIRST DEMO: 0136 must be run, and the admin needs a
//  sponsor_admins row (employer, school) or a partner_accounts row (IVF
//  centre). The SQL for both is at the foot of 0136_partner_org_admins.sql.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'partner_app/partner_org_session.dart';
import 'partner_app/partner_sign_out.dart';
import 'screens/partner_app/partner_auth_screen.dart';
import 'screens/partner_app/partner_hold_screen.dart';
import 'screens/partner_app/partner_scaffold.dart';
import 'screens/partner_app/partner_words.dart';
import 'supabase_config.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Portrait, as the other two apps: every screen is one column.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(ParentVedaPartnersApp(backendUp: await startPartnerBackend()));
}

/// Starts Supabase; false when it threw (main_doctor.dart startBackend, D1).
Future<bool> startPartnerBackend() async {
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
    return true;
  } catch (e) {
    debugPrint('[partners] Supabase.initialize failed: $e');
    return false;
  }
}

/// Where the first screen stands. Once [ready], what shows is the session's
/// answer (see build()).
enum _Boot { booting, backendDown, offline, ready }

class ParentVedaPartnersApp extends StatefulWidget {
  const ParentVedaPartnersApp({
    super.key,
    this.backendUp = true,
    this.retryBackend,
  });

  /// False when the backend failed to start: open on the can't-reach screen
  /// and ask the server nothing until Try again succeeds.
  final bool backendUp;

  /// How Try again restarts the backend. A seam for the widget test, which
  /// cannot initialise Supabase; null means [startPartnerBackend].
  final Future<bool> Function()? retryBackend;

  @override
  State<ParentVedaPartnersApp> createState() => _ParentVedaPartnersAppState();
}

class _ParentVedaPartnersAppState extends State<ParentVedaPartnersApp> {
  late _Boot _boot = widget.backendUp ? _Boot.booting : _Boot.backendDown;

  /// A refusal found at BOOT (a restored session that no longer resolves:
  /// the admin row was removed overnight). Carried to the sign-in screen so
  /// the person is told why they were signed out, not just shown a form.
  String? _note;

  @override
  void initState() {
    super.initState();
    if (widget.backendUp) _resolve();
  }

  Future<void> _resolve() async {
    final result = await PartnerOrgSession.instance.resolveFromServer();
    if (result == PartnerResolve.notAnAdmin) {
      final code = PartnerOrgSession.instance.refusal;
      // Nobody signed in is not a refusal; it is the sign-in screen.
      if (code != 'not_signed_in') {
        _note = partnerRefusalText(code);
        await forgetPartnerOrgOnThisPhone();
      }
    }
    if (!mounted) return;
    setState(
      () => _boot = result == PartnerResolve.unreachable
          ? _Boot.offline
          : _Boot.ready,
    );
  }

  /// Try again from either can't-reach state, or from a paused programme.
  Future<void> _retry() async {
    if (_boot == _Boot.backendDown) {
      if (!await (widget.retryBackend ?? startPartnerBackend)()) return;
    }
    await _resolve();
  }

  Future<void> _signOut() async {
    await forgetPartnerOrgOnThisPhone();
    if (mounted) setState(() => _boot = _Boot.ready);
  }

  void _afterSignIn() {
    final s = PartnerOrgSession.instance;
    setState(() {
      _note = null;
      // Resolved or paused: the session says which. Neither: the server
      // did not answer, and the session is live.
      _boot = s.org != null ? _Boot.ready : _Boot.offline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParentVeda Partners',
      debugShowCheckedModeBanner: false,
      // One brand, the doctor app's resolution (main_doctor.dart): what tells
      // the apps apart is the name and the icon, not a palette.
      theme: AppTheme.light,
      home: ListenableBuilder(
        listenable: PartnerOrgSession.instance,
        builder: (context, _) {
          switch (_boot) {
            case _Boot.booting:
              return const _Booting();
            case _Boot.backendDown:
              return PartnerHoldScreen(
                title: "Can't reach ParentVeda right now",
                body: 'Check your connection, then try again.',
                onRetry: _retry,
              );
            case _Boot.offline:
              return PartnerHoldScreen(
                title: "Can't reach ParentVeda right now",
                body:
                    'You are still signed in, and nothing is lost. '
                    'Check your connection, then try again.',
                onRetry: _retry,
                onSignOut: _signOut,
              );
            case _Boot.ready:
              break;
          }
          final org = PartnerOrgSession.instance.org;
          if (org != null && org.isLive) return PartnerScaffold(org: org);
          if (org != null) {
            return PartnerHoldScreen(
              title: 'Your programme is not live',
              body: partnerHoldText(org),
              onRetry: _retry,
              onSignOut: _signOut,
            );
          }
          return PartnerAuthScreen(onSignedIn: _afterSignIn, note: _note);
        },
      ),
    );
  }
}

class _Booting extends StatelessWidget {
  const _Booting();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.scaffoldBackground,
    body: Center(
      child: SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: AppTheme.primary,
        ),
      ),
    ),
  );
}
