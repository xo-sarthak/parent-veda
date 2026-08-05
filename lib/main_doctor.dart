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
//  doctor needs none of them. This boots four:
//
//      DoctorSession        who am I
//      DoctorRoster         who is booked with me   (by DoctorScaffold)
//      DoctorScheduleStore  when do I work
//      NotificationService  the reminder before a call
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
//  be LINKED for this app to let them in. Today that link is created by the
//  parent build's testing picker, or by SQL:
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
import 'screens/doctor/doctor_scaffold.dart';
import 'services/notification_service.dart';
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

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  runApp(const ParentVedaExpertApp());
}

class ParentVedaExpertApp extends StatefulWidget {
  const ParentVedaExpertApp({super.key});

  @override
  State<ParentVedaExpertApp> createState() => _ParentVedaExpertAppState();
}

class _ParentVedaExpertAppState extends State<ParentVedaExpertApp> {
  /// null = still deciding. Avoids a flash of the sign-in screen for a doctor
  /// who is already signed in — which on a phone reads as "it logged me out"
  /// and is the fastest way to lose trust in an app someone uses daily.
  ///
  /// ONLY tracks the FIRST resolve. Once that has happened, whether a doctor is
  /// signed in is DoctorSession's answer, not this field's — see build(). It
  /// used to be the only answer, which is why signing out was impossible: the
  /// Profile cleared the session and this field never heard about it, so the
  /// dashboard stayed on screen.
  bool? _resolved;

  @override
  void initState() {
    super.initState();
    // Tells the shared doctor screens they are in the standalone app, where
    // "leave" means sign out rather than return to the parent app.
    DoctorSession.standalone = true;
    NotificationService.instance.init();
    DoctorScheduleStore.instance.init();
    _resolve();
  }

  Future<void> _resolve() async {
    // A session restored from disk still has to be checked against the server:
    // an expert who was unlinked yesterday must not open a dashboard today.
    await DoctorSession.instance.resolveFromServer();
    if (mounted) setState(() => _resolved = true);
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
          if (_resolved != true) return const _Booting();
          if (DoctorSession.instance.active) return const DoctorScaffold();
          return DoctorAuthScreen(onSignedIn: () => setState(() {}));
        },
      ),
    );
  }
}

class _Booting extends StatelessWidget {
  const _Booting();

  @override
  Widget build(BuildContext context) => const Scaffold(
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
