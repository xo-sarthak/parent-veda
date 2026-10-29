// =============================================================================
//  ParentVeda+ — the entrypoint for the DOCTOR app.
// -----------------------------------------------------------------------------
//  Build it with:
//
//      flutter build apk --release --flavor doctor \
//        --target lib/main_doctor.dart
//
//  SAME REPOSITORY, SAME lib/, DIFFERENT FRONT DOOR. Flutter allows any number
//  of entrypoints, so this shares every model, every screen and the one
//  SupabaseRepo with the parent app. A separate repository would mean two
//  copies of the booking engine drifting apart, which is the failure this
//  codebase has been bitten by more than once.
//
//  WHAT IT DELIBERATELY DOES NOT DO
//
//  main.dart initialises roughly forty stores — journal, bump, garbh, food,
//  watch, leaps, recipes, reads, entitlements, referrals, brand campaigns. A
//  doctor needs none of them. This boots five:
//
//      DoctorSession        who am I
//      DoctorRoster         who is booked with me   (by DoctorScaffold)
//      DoctorScheduleStore  when do I work
//      NotificationService  the reminder before a call
//      ExpertStore          the admin-panel experts, so a doctor onboarded
//                           through Directus can be found at all
//
//  So it is genuinely a smaller app rather than the same app with things
//  hidden. Nothing on this screen can navigate into the parent experience,
//  because the parent experience is not in the widget tree at all.
//
//  THE IDENTITY IS THE ACCOUNT, NOT A CHOICE
//
//  The parent build reaches doctor mode through a picker listing every expert
//  in the compiled catalogue. That is a testing affordance and it must not
//  survive into a clinician's hands: an identity you select from a dropdown is
//  not an identity. Here, signing in is followed by
//  DoctorSession.resolveFromServer(), which asks the database who this account
//  is (expert_accounts, then partner_accounts). An account with no expert
//  record is signed back out and told so.
//
//  ⚠️ CONSEQUENCE, worth knowing before the first demo: an expert must already
//  be LINKED for this app to let them in. The real link is an expert_invites
//  row, claimed at sign-in by claim_expert_invite() (0084). Since 0123 the
//  parent build's testing picker links only accounts in dev_testers, and the
//  app can no longer write expert_accounts directly. The SQL editor still can:
//
//      insert into public.expert_accounts (user_id, expert_id)
//      values ((select id from auth.users where email = '...'), 'exp_neha')
//      on conflict (user_id) do update set expert_id = excluded.expert_id;
//
//  There is no self-serve doctor signup, on purpose — see STILL-OPEN §5.1.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'doctor/doctor_schedule_store.dart';
import 'doctor/doctor_session.dart';
import 'screens/doctor/doctor_auth_screen.dart';
import 'screens/doctor/doctor_cant_reach.dart';
import 'screens/doctor/doctor_scaffold.dart';
import 'services/expert_store.dart';
import 'services/notification_service.dart';
import 'services/remote/supabase_repo.dart';
import 'supabase_config.dart';
import 'theme/app_theme.dart';
import 'localization/app_language.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait, for the same reason as the parent app: every doctor screen is a
  // single column and the bottom nav in landscape covers the row you were
  // reading. A clinician checking a schedule one-handed should not have the
  // layout change under them because the phone tilted.
  await SystemChrome.setPreferredOrientations(
      const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(ParentVedaExpertApp(backendUp: await startBackend()));
}

/// Starts Supabase; false when it threw. It used to be a bare await, so a
/// failure here (corrupt local session storage, a bad config) was a crash on
/// launch with no screen at all. The house rule is that an uninitialised
/// backend behaves like being signed out, never like a crash; here it gets
/// the can't-reach screen and a Try again (Partner Editions D1, item 1).
Future<bool> startBackend() async {
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
    return true;
  } catch (e) {
    debugPrint('[doctor] Supabase.initialize failed: $e');
    return false;
  }
}

/// Where the first screen stands. Only the BOOT; once [ready], whether a
/// doctor is signed in is DoctorSession's answer (see build()).
enum _Boot { booting, backendDown, offline, ready }

class ParentVedaExpertApp extends StatefulWidget {
  const ParentVedaExpertApp({super.key, this.backendUp = true});

  /// False when [startBackend] failed: the app opens on the can't-reach screen
  /// and asks the server nothing until Try again succeeds.
  final bool backendUp;

  @override
  State<ParentVedaExpertApp> createState() => _ParentVedaExpertAppState();
}

class _ParentVedaExpertAppState extends State<ParentVedaExpertApp> {
  /// [_Boot.booting] = still deciding. Avoids a flash of the sign-in screen
  /// for a doctor who is already signed in — which on a phone reads as "it
  /// logged me out" and is the fastest way to lose trust in an app someone
  /// uses daily.
  ///
  /// ONLY tracks the BOOT. Once ready, whether a doctor is signed in is
  /// DoctorSession's answer, not this field's — see build(). It used to be the
  /// only answer, which is why signing out was impossible: the Profile cleared
  /// the session and this field never heard about it, so the dashboard stayed
  /// on screen.
  ///
  /// Kept for revert, the bool it replaced (it could not say "offline"):
  /// bool? _resolved;
  late _Boot _boot = widget.backendUp ? _Boot.booting : _Boot.backendDown;

  @override
  void initState() {
    super.initState();
    // Tells the shared doctor screens they are in the standalone app, where
    // "leave" means sign out rather than return to the parent app.
    DoctorSession.standalone = true;
    NotificationService.instance.init();
    DoctorScheduleStore.instance.init();
    // FIVE stores, not four. ExpertStore holds the experts created in the admin
    // panel (expert_profiles), and mergedExperts() folds them into the compiled
    // catalogue. Without it this app sees ONLY the doctors hard-coded at build
    // time — so a doctor onboarded through Directus signs in successfully, and
    // is then invisible to the directory that resolves their own name.
    //
    // Harmless-looking while every test doctor happened to be in the compiled
    // list. It would have failed on the first real onboarding, which is the
    // worst possible moment to find out.
    if (widget.backendUp) {
      ExpertStore.instance.ensureLoaded();
      _resolve();
    }
  }

  Future<void> _resolve() async {
    // A session restored from disk still has to be checked against the server:
    // an expert who was unlinked yesterday must not open a dashboard today.
    var result = await DoctorSession.instance.resolveFromServer();
    // Signed in but nobody: an invite accepted on ANOTHER device has not been
    // claimed on this one, because only the sign-in screen claimed invites.
    // Claim and ask once more before showing her the sign-in form (D1, item 8).
    // Costs nothing for a doctor who resolved; only the unresolved pay for it.
    if (result == DoctorResolve.notADoctor && SupabaseRepo.isLoggedIn) {
      await DoctorSession.instance.claimInvite();
      result = await DoctorSession.instance.resolveFromServer();
    }
    if (!mounted) return;
    // Unreachable is NOT "signed out": her session is live and the server
    // simply did not answer. The sign-in form would ask her to fix something
    // that is not broken (D1, item 2).
    setState(() => _boot = result == DoctorResolve.unreachable ? _Boot.offline : _Boot.ready);
  }

  /// Try again from either can't-reach state.
  Future<void> _retry() async {
    if (_boot == _Boot.backendDown) {
      if (!await startBackend()) return;
      ExpertStore.instance.ensureLoaded();
    }
    await _resolve();
  }

  /// The sign-in screen's "done": resolved, or signed in but unreachable.
  void _afterSignIn() {
    setState(() => _boot = DoctorSession.instance.active ? _Boot.ready : _Boot.offline);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: S.now.uiParentveda,
      debugShowCheckedModeBanner: false,
      // ONE BRAND, TWO AUDIENCES. This used to be its own dark slate/teal
      // theme, on the argument that a clinician should never wonder which app
      // they are in. The argument was sound and the execution was not: only
      // this file and the sign-in screen ever adopted it, so every screen past
      // the front door was already ParentVeda lavender and the app changed
      // colour the moment you signed in.
      //
      // Resolved in favour of the brand. What tells the two apart is the name
      // on the launcher (ParentVeda+), the icon, and a home screen full of
      // patients — not a palette, which mostly signalled "unfinished".
      //
      // Kept for revert:
      //   theme: ThemeData(
      //     useMaterial3: true,
      //     brightness: Brightness.dark,
      //     scaffoldBackgroundColor: const Color(0xFF101418),
      //     colorScheme: ColorScheme.fromSeed(
      //       seedColor: const Color(0xFF3FA9A0), brightness: Brightness.dark),
      //   ),
      theme: AppTheme.light,
      // Listens to DoctorSession rather than to a local flag, so that ANY
      // route out of the session — the Profile's sign out, an account that
      // stops resolving — lands back on the sign-in screen. With a local flag
      // there was no way for the app to hear about it, and no way out.
      home: ListenableBuilder(
        listenable: DoctorSession.instance,
        builder: (context, _) {
          switch (_boot) {
            case _Boot.booting:
              return const _Booting();
            case _Boot.backendDown:
              return DoctorCantReach(onRetry: _retry);
            case _Boot.offline:
              return DoctorCantReach(onRetry: _retry, signedIn: true);
            case _Boot.ready:
              break;
          }
          if (DoctorSession.instance.active) return const DoctorScaffold();
          return DoctorAuthScreen(onSignedIn: _afterSignIn);
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
                strokeWidth: 2.2, color: AppTheme.primary),
          ),
        ),
      );
}
