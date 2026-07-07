// =============================================================================
//  SplashScreen - the launch screen ("Warm Nest" Direction B)
// -----------------------------------------------------------------------------
//  The first thing shown when the app opens: the ParentVeda mark on a soft
//  lavender→blush gradient with the "Nurturing wisdom" tagline, gently fading
//  in. After a short beat it cross-fades into MainScaffold. Content controllers
//  keep loading in the background; MainScaffold shows its own loader if needed.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_language.dart';
import '../services/father_content_controller.dart';
import '../services/home_content_controller.dart';
import '../services/pregnancy_controller.dart';
import '../services/remote/sync_registry.dart';
import '../theme/app_theme.dart';
import 'auth/auth_flow_screen.dart';
// father_daily_screen import parked - the paired father now lands on the unified
// MainScaffold (father mode), not the standalone Father Daily screen.
// import 'father/father_daily_screen.dart';
import 'main_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.pregnancy,
    required this.home,
    required this.father,
  });

  final PregnancyController pregnancy;
  final HomeContentController home;
  final FatherContentController father;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _scale = Tween(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));
    _c.forward();
    _timer = Timer(const Duration(milliseconds: 2200), _goHome);
  }

  Future<void> _goHome() async {
    if (!mounted) return;
    final nav = Navigator.of(context); // capture before navigating
    // First run shows the auth flow; once completed (local flag, no backend) we
    // skip straight to the app on later launches.
    var authed = false;
    var role = 'mother';
    try {
      final prefs = await SharedPreferences.getInstance();
      authed = prefs.getBool(kAuthCompletedKey) ?? false;
      role = prefs.getString(kUserRoleKey) ?? 'mother';
    } catch (_) {/* default to showing auth */}
    if (!mounted) return;
    if (authed) {
      nav.pushReplacement(role == 'father' ? _fatherRoute() : _mainRoute());
      return;
    }
    nav.pushReplacement(MaterialPageRoute(
      builder: (_) => AuthFlowScreen(onDone: (due, isFather) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(kAuthCompletedKey, true);
          await prefs.setString(kUserRoleKey, isFather ? 'father' : 'mother');
        } catch (_) {/* best-effort */}
        // Wire the auth Profile due date into the app's real due date.
        // PINNED TO WEEK 20 (testing): disabled so login can't move the week.
        // Re-enable with the load() restore block in pregnancy_controller.dart.
        // if (!isFather && due != null) await widget.pregnancy.setDueDate(due);
        // Load the real profile name(s) so the app shows them (not placeholders).
        await widget.pregnancy.loadProfileFromCloud();
        // Re-pull every store's cloud data now that we're logged in, so a fresh
        // login shows the user's data without needing an app restart.
        SyncRegistry.resyncAll();
        nav.pushReplacement(isFather ? _fatherRoute() : _mainRoute());
      }),
    ));
  }

  Route<void> _mainRoute() => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, _, _) => MainScaffold(
          pregnancy: widget.pregnancy,
          home: widget.home,
          father: widget.father,
        ),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      );

  // Father (paired partner) lands on the SAME shell as the mother - the unified
  // father (Slate) MainScaffold, so both entry points share one structure.
  Route<void> _fatherRoute() => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, _, _) => MainScaffold(
          pregnancy: widget.pregnancy,
          home: widget.home,
          father: widget.father,
          isFather: true,
        ),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      );

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.pregnancy.language);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.surfaceContainerHigh,
              AppTheme.surfaceContainer,
              Color(0xFFFFE9EE),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 70,
              left: -50,
              child: _blob(200, AppTheme.secondary100.withValues(alpha: 0.55)),
            ),
            Positioned(
              bottom: 80,
              right: -50,
              child: _blob(200, AppTheme.primary100.withValues(alpha: 0.60)),
            ),
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // The background-removed mark floats cleanly on the
                      // gradient (no white card behind it).
                      Image.asset('assets/brand/pv-mark-transparent.png',
                          width: 168),
                      const SizedBox(height: 24),
                      Text(
                        'ParentVeda',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary600,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.splashTagline,
                        style: GoogleFonts.fraunces(
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.primary700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  s.splashFooter,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.neutral400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A soft glowing blob (translucent circle + same-colour blur halo).
  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 60, spreadRadius: 24),
          ],
        ),
      );
}
