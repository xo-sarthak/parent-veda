// =============================================================================
//  AuthFlowScreen — ParentVeda auth (Claude Design "Soft solid", UI only)
// -----------------------------------------------------------------------------
//  Faithful Flutter build of the "ParentVeda Auth - Transparent Logo" design
//  (Soft-solid treatment: a radial purple→white wash, glass cards, floating
//  dots, Plus Jakarta Sans). Eight screens with internal navigation:
//    welcome → login / signup → profile → success, plus forgot → otp → reset.
//  No backend — buttons just navigate. [onDone] fires when auth completes
//  (Success → "Get started"), so the caller can enter the app.
// =============================================================================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// ---- Soft-solid palette (from the design) ---------------------------------
const _bg = Color(0xFFFBF6FE);
const _bgCenter = Color(0xFFF4E9FF);
const _purple = Color(0xFF7C3FC4);
const _purpleDeep = Color(0xFF5E2AA3);
const _ink = Color(0xFF1F1238);
const _ink2 = Color(0xFF4A2585);
const _muted = Color(0xFF7B6B8E);
const _muted2 = Color(0xFF857591);
const _label = Color(0xFF8B7AA0);
const _pink = Color(0xFFC2407A);
const _fieldBg = Color(0xFFF7F2FD);
const _fieldBorder = Color(0x297C3FC4);
const _hint = Color(0xFFB6A9C6);
const _logoAsset = 'assets/brand/pv-mark.png';

// ---- Brand logos (official multi-colour marks, rendered as inline SVG) -----
const _googleSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">'
    '<path fill="#FFC107" d="M43.611 20.083H42V20H24v8h11.303c-1.649 4.657-6.08 8-11.303 8-6.627 0-12-5.373-12-12s5.373-12 12-12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4 12.955 4 4 12.955 4 24s8.955 20 20 20 20-8.955 20-20c0-1.341-.138-2.65-.389-3.917z"/>'
    '<path fill="#FF3D00" d="M6.306 14.691l6.571 4.819C14.655 15.108 18.961 12 24 12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4 16.318 4 9.656 8.337 6.306 14.691z"/>'
    '<path fill="#4CAF50" d="M24 44c5.166 0 9.86-1.977 13.409-5.192l-6.19-5.238C29.211 35.091 26.715 36 24 36c-5.202 0-9.619-3.317-11.283-7.946l-6.522 5.025C9.505 39.556 16.227 44 24 44z"/>'
    '<path fill="#1976D2" d="M43.611 20.083H42V20H24v8h11.303c-.792 2.237-2.231 4.166-4.087 5.571l6.19 5.238C36.971 39.205 44 34 44 24c0-1.341-.138-2.65-.389-3.917z"/></svg>';
const _appleSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512">'
    '<path fill="#1A1A1A" d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"/></svg>';
const _facebookSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
    '<path fill="#1877F2" d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>';

/// Shared-prefs key set true once the auth flow completes (local "remember me",
/// no backend). Splash reads it to skip auth on later launches; Profile's
/// sign-out clears it to replay the flow.
const String kAuthCompletedKey = 'auth_completed';

class AuthFlowScreen extends StatefulWidget {
  const AuthFlowScreen({super.key, required this.onDone});

  /// Fired when auth completes (Success → "Get started"), with the due date the
  /// mother optionally picked on the Profile step (null if she skipped it).
  final void Function(DateTime? dueDate) onDone;

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
  String _screen = 'welcome';
  String _stage = ''; // pregnant | new | trying
  DateTime? _pickedDue; // chosen on the Profile step → fed into the app

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _confirm = TextEditingController();
  final _otp = List.generate(5, (_) => TextEditingController());
  final _otpNodes = List.generate(5, (_) => FocusNode());

  static const _backMap = {
    'login': 'welcome',
    'signup': 'welcome',
    'profile': 'signup',
    'forgot': 'login',
    'otp': 'forgot',
    'reset': 'otp',
    'success': 'welcome',
  };

  @override
  void dispose() {
    for (final c in [_email, _password, _name, _confirm, ..._otp]) {
      c.dispose();
    }
    for (final n in _otpNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _go(String s) {
    FocusScope.of(context).unfocus();
    setState(() => _screen = s);
  }

  void _soon(String label) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
        content: Text('$label — coming soon'),
        duration: const Duration(milliseconds: 1100)));

  @override
  Widget build(BuildContext context) {
    final canBack = _screen != 'welcome';
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        // Soft-solid background — radial purple wash fading to near-white.
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -1.15),
                radius: 1.15,
                colors: [_bgCenter, _bg],
                stops: [0.0, 0.62],
              ),
            ),
          ),
        ),
        // Playful floating dots.
        const _Dot(top: 150, left: 24, size: 14, color: Color(0x80F0567A)),
        const _Dot(top: 220, right: 36, size: 9, color: Color(0x807C3FC4)),
        const _Dot(bottom: 130, left: 40, size: 10, color: Color(0x73A24DD6)),
        SafeArea(
          child: Stack(children: [
            // Animated screen swap (the design's "pvIn" entrance).
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 360),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.03), end: Offset.zero)
                        .animate(anim),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(key: ValueKey(_screen), child: _current()),
              ),
            ),
            // Back button.
            if (canBack)
              Positioned(
                top: 6,
                left: 10,
                child: _BackButton(
                    onTap: () => _go(_backMap[_screen] ?? 'welcome')),
              ),
          ]),
        ),
      ]),
    );
  }

  Widget _current() {
    switch (_screen) {
      case 'login':
        return _login();
      case 'signup':
        return _signup();
      case 'profile':
        return _profile();
      case 'forgot':
        return _forgot();
      case 'otp':
        return _otp_();
      case 'reset':
        return _reset();
      case 'success':
        return _success();
      default:
        return _welcome();
    }
  }

  // ===========================================================================
  //  WELCOME
  // ===========================================================================
  Widget _welcome() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Image.asset(_logoAsset, width: 50, height: 50),
            const SizedBox(width: 11),
            Text('ParentVeda',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: _ink2)),
          ]),
          const SizedBox(height: 24),
          _socialProofChip(),
          const SizedBox(height: 18),
          RichText(
            text: TextSpan(
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 33,
                  height: 1.13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  color: _ink),
              children: const [
                TextSpan(text: 'Care that grows\nwith your '),
                TextSpan(text: 'family.', style: TextStyle(color: _pink)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 300,
            child: Text(
              'Gentle, expert guidance for pregnancy and every milestone after.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                  color: _muted),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(spacing: 8, runSpacing: 8, children: const [
            _FeaturePill('Track', _purple),
            _FeaturePill('Learn', Color(0xFFF0567A)),
            _FeaturePill('Community', Color(0xFFA24BD6)),
          ]),
          const SizedBox(height: 28),
          _glass(
            child: Column(children: [
              _primaryBtn('Create account', () => _go('signup')),
              const SizedBox(height: 12),
              _outlineBtn('Log in', () => _go('login')),
              _orDivider('OR CONTINUE WITH'),
              _socialRow(),
            ]),
          ),
        ]),
      );

  Widget _socialProofChip() => Container(
        padding: const EdgeInsets.fromLTRB(7, 6, 13, 6),
        decoration: BoxDecoration(
          color: const Color(0x127C3FC4),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0x1F7C3FC4)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 40,
            height: 18,
            child: Stack(children: const [
              _MiniAv(0, _purple),
              _MiniAv(11, Color(0xFFF0567A)),
              _MiniAv(22, Color(0xFFA24BD6)),
            ]),
          ),
          const SizedBox(width: 9),
          Text('Loved by 50,000+ parents',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _purpleDeep)),
        ]),
      );

  // ===========================================================================
  //  LOGIN
  // ===========================================================================
  Widget _login() => _formScroll([
        _centeredHeader('Welcome back', 'Log in to continue your journey.'),
        const SizedBox(height: 14),
        _glass(
          child: Column(children: [
            _field(_email, 'Email', 'you@email.com',
                keyboard: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _field(_password, 'Password', '••••••••', obscure: true),
            Align(
              alignment: Alignment.centerRight,
              child: _link('Forgot password?', () => _go('forgot'),
                  color: _pink),
            ),
            const SizedBox(height: 8),
            _primaryBtn('Log in', () => _go('success')),
            _orDivider('OR'),
            _socialRow(),
          ]),
        ),
        const SizedBox(height: 18),
        _footerSwitch('New here?', 'Sign up', () => _go('signup')),
      ]);

  // ===========================================================================
  //  SIGN UP
  // ===========================================================================
  Widget _signup() => _formScroll([
        _centeredHeader(
            'Create your account', 'Join a caring community of parents.'),
        const SizedBox(height: 14),
        _glass(
          child: Column(children: [
            _field(_name, 'Full name', 'Your name'),
            const SizedBox(height: 14),
            _field(_email, 'Email', 'you@email.com',
                keyboard: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _field(_password, 'Password', 'Create a password', obscure: true),
            const SizedBox(height: 6),
            _primaryBtn('Continue', () => _go('profile')),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: _label),
                children: const [
                  TextSpan(text: 'By continuing you agree to our '),
                  TextSpan(
                      text: 'Terms',
                      style: TextStyle(
                          color: _purple, fontWeight: FontWeight.w700)),
                  TextSpan(text: ' & '),
                  TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                          color: _purple, fontWeight: FontWeight.w700)),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 18),
        _footerSwitch('Already have an account?', 'Log in', () => _go('login')),
      ]);

  // ===========================================================================
  //  PROFILE
  // ===========================================================================
  Widget _profile() => _formScroll([
        _centeredHeader(
            'Tell us about you', "We'll personalise tips just for you.",
            showLogo: false),
        const SizedBox(height: 14),
        _glass(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('I AM CURRENTLY',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: _label)),
            const SizedBox(height: 9),
            Row(children: [
              _stageBtn('Pregnant', 'expecting', 'pregnant'),
              const SizedBox(width: 9),
              _stageBtn('New parent', '0–2 yrs', 'new'),
              const SizedBox(width: 9),
              _stageBtn('Trying', 'to conceive', 'trying'),
            ]),
            const SizedBox(height: 18),
            _dateField("Due date / baby's birthday"),
            const SizedBox(height: 6),
            _primaryBtn('Finish setup', () => _go('success')),
            const SizedBox(height: 12),
            Center(child: _link('Skip for now', () => _go('success'), color: _label)),
          ]),
        ),
      ]);

  Widget _stageBtn(String title, String sub, String key) {
    final active = _stage == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _stage = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0x1F7C3FC4) : const Color(0x99FFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: active ? _purple : const Color(0x1F7C3FC4),
                width: 2),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: active ? const Color(0xFF5B2596) : _muted)),
            const SizedBox(height: 2),
            Text(sub,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: (active ? const Color(0xFF5B2596) : _muted)
                        .withValues(alpha: 0.7))),
          ]),
        ),
      ),
    );
  }

  // ===========================================================================
  //  FORGOT
  // ===========================================================================
  Widget _forgot() => _formScroll([
        _centeredHeader('Forgot password?',
            "No worries — enter your email and we'll send a reset code."),
        const SizedBox(height: 14),
        _glass(
          child: Column(children: [
            _field(_email, 'Email', 'you@email.com',
                keyboard: TextInputType.emailAddress),
            const SizedBox(height: 4),
            _primaryBtn('Send reset code', () => _go('otp')),
          ]),
        ),
        const SizedBox(height: 18),
        _footerSwitch('Remembered it?', 'Log in', () => _go('login')),
      ]);

  // ===========================================================================
  //  OTP
  // ===========================================================================
  Widget _otp_() => _formScroll([
        _centeredHeader(
            "Verify it's you", 'Enter the 5-digit code we just sent.'),
        const SizedBox(height: 14),
        _glass(
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 5; i++) ...[
                  _otpBox(i),
                  if (i < 4) const SizedBox(width: 10),
                ],
              ],
            ),
            const SizedBox(height: 20),
            _primaryBtn('Verify', () => _go('reset')),
            const SizedBox(height: 14),
            RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _muted2),
                children: [
                  const TextSpan(text: "Didn't get it? "),
                  TextSpan(
                    text: 'Resend code',
                    style: const TextStyle(
                        color: _purple, fontWeight: FontWeight.w800),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _soon('Resend'),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ]);

  Widget _otpBox(int i) => SizedBox(
        width: 48,
        height: 58,
        child: TextField(
          controller: _otp[i],
          focusNode: _otpNodes[i],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) {
            if (v.isNotEmpty && i < 4) _otpNodes[i + 1].requestFocus();
            if (v.isEmpty && i > 0) _otpNodes[i - 1].requestFocus();
          },
          style: GoogleFonts.plusJakartaSans(
              fontSize: 24, fontWeight: FontWeight.w800, color: _ink),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: _fieldBg,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: _fieldBorder, width: 2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: _purple, width: 2)),
          ),
        ),
      );

  // ===========================================================================
  //  RESET
  // ===========================================================================
  Widget _reset() => _formScroll([
        _centeredHeader(
            'Set a new password', 'Make it something only you know.'),
        const SizedBox(height: 14),
        _glass(
          child: Column(children: [
            _field(_password, 'New password', 'New password', obscure: true),
            const SizedBox(height: 14),
            _field(_confirm, 'Confirm password', 'Re-enter password',
                obscure: true),
            const SizedBox(height: 4),
            _primaryBtn('Reset password', () => _go('success')),
          ]),
        ),
      ]);

  // ===========================================================================
  //  SUCCESS
  // ===========================================================================
  Widget _success() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _SuccessBadge(),
              const SizedBox(height: 24),
              Text("You're all set!",
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: _ink)),
              const SizedBox(height: 6),
              SizedBox(
                width: 270,
                child: Text(
                  'Welcome to the ParentVeda family. Your journey begins now. 💜',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                      color: _muted),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 200,
                child:
                    _primaryBtn('Get started', () => widget.onDone(_pickedDue)),
              ),
            ],
          ),
        ),
      );

  // ===========================================================================
  //  Shared building blocks
  // ===========================================================================
  Widget _formScroll(List<Widget> children) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Column(children: children),
      );

  Widget _centeredHeader(String title, String sub, {bool showLogo = true}) =>
      Column(children: [
        if (showLogo) ...[
          Image.asset(_logoAsset, width: 60, height: 60),
          const SizedBox(height: 10),
        ] else
          const SizedBox(height: 8),
        Text(title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.55,
                color: _ink)),
        const SizedBox(height: 4),
        SizedBox(
          width: 290,
          child: Text(sub,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: _muted2)),
        ),
      ]);

  Widget _glass({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        decoration: BoxDecoration(
          color: const Color(0xF2FFFFFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xA6FFFFFF)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x2E4C1D78),
                blurRadius: 50,
                offset: Offset(0, 20),
                spreadRadius: -8),
          ],
        ),
        child: child,
      );

  Widget _primaryBtn(String label, VoidCallback onTap) => SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_purple, _purpleDeep]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x4D5E2AA3),
                  blurRadius: 26,
                  offset: Offset(0, 12)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(label,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _outlineBtn(String label, VoidCallback onTap) => SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: _purple,
            side: const BorderSide(color: Color(0x387C3FC4), width: 2),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: onTap,
          child: Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      );

  Widget _field(TextEditingController c, String label, String hint,
      {bool obscure = false, TextInputType? keyboard}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5, fontWeight: FontWeight.w700, color: _label)),
      const SizedBox(height: 7),
      TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboard,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 15, fontWeight: FontWeight.w600, color: _ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 15, fontWeight: FontWeight.w500, color: _hint),
          filled: true,
          fillColor: _fieldBg,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _fieldBorder, width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _purple, width: 2)),
        ),
      ),
    ]);
  }

  // A tappable date field (Profile due date) → real DateTime, fed into the app.
  Widget _dateField(String label) {
    final has = _pickedDue != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5, fontWeight: FontWeight.w700, color: _label)),
      const SizedBox(height: 7),
      Material(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: _pickDue,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _fieldBorder, width: 1.5),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 17, color: _purple),
              const SizedBox(width: 11),
              Text(has ? _fmtDate(_pickedDue!) : 'Select a date',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: has ? _ink : _hint)),
            ]),
          ),
        ),
      ),
    ]);
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDue ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1, now.month + 1),
    );
    if (picked != null) setState(() => _pickedDue = picked);
  }

  static String _fmtDate(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  Widget _orDivider(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 18, 0, 14),
        child: Row(children: [
          const Expanded(child: Divider(color: Color(0x247C3FC4), height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(text,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: const Color(0xFFA294B5))),
          ),
          const Expanded(child: Divider(color: Color(0x247C3FC4), height: 1)),
        ]),
      );

  Widget _socialRow() => Row(children: [
        Expanded(child: _socialBtn('Google', _googleSvg)),
        const SizedBox(width: 10),
        Expanded(child: _socialBtn('Apple', _appleSvg)),
        const SizedBox(width: 10),
        Expanded(child: _socialBtn('Facebook', _facebookSvg)),
      ]);

  Widget _socialBtn(String label, String svg) => Material(
        color: const Color(0xBFFFFFFF),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _soon(label),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x247C3FC4), width: 1.5),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SvgPicture.string(svg, height: 20),
              const SizedBox(height: 6),
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5A4A70))),
            ]),
          ),
        ),
      );

  Widget _link(String text, VoidCallback onTap, {required Color color}) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(text,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ),
      );

  Widget _footerSwitch(String lead, String action, VoidCallback onTap) =>
      Center(
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14, fontWeight: FontWeight.w600, color: _muted2),
            children: [
              TextSpan(text: '$lead '),
              TextSpan(
                text: action,
                style: const TextStyle(
                    color: _purple, fontWeight: FontWeight.w800),
                recognizer: TapGestureRecognizer()..onTap = onTap,
              ),
            ],
          ),
        ),
      );
}

// ---- small visual pieces ---------------------------------------------------

class _Dot extends StatelessWidget {
  const _Dot(
      {this.top, this.left, this.right, this.bottom,
      required this.size,
      required this.color});
  final double? top, left, right, bottom;
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      );
}

class _MiniAv extends StatelessWidget {
  const _MiniAv(this.left, this.color);
  final double left;
  final Color color;
  @override
  Widget build(BuildContext context) => Positioned(
        left: left,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2)),
        ),
      );
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill(this.label, this.dot);
  final String label;
  final Color dot;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xB3FFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x1F7C3FC4)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5A4A70))),
        ]),
      );
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xB3FFFFFF),
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x244C1D78),
                    blurRadius: 16,
                    offset: Offset(0, 6)),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: _purple, size: 20),
          ),
        ),
      );
}

class _SuccessBadge extends StatefulWidget {
  const _SuccessBadge();
  @override
  State<_SuccessBadge> createState() => _SuccessBadgeState();
}

class _SuccessBadgeState extends State<_SuccessBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 650))
        ..forward();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pop = CurvedAnimation(parent: _c, curve: Curves.elasticOut);
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(alignment: Alignment.center, children: [
        Container(
          width: 130,
          height: 130,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
                colors: [Color(0x407C3FC4), Color(0x007C3FC4)]),
          ),
        ),
        ScaleTransition(
          scale: pop,
          child: Container(
            width: 104,
            height: 104,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_purple, _purpleDeep]),
              boxShadow: [
                BoxShadow(
                    color: Color(0x667C3FC4),
                    blurRadius: 36,
                    offset: Offset(0, 18)),
              ],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
          ),
        ),
      ]),
    );
  }
}
