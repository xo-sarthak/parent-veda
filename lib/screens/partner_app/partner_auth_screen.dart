// =============================================================================
//  PartnerAuthScreen — the way into ParentVeda Partners
// -----------------------------------------------------------------------------
//  Email + password (MASTER R6): the same account the web portal signs in with,
//  so one login works at the desk and on the phone. Not the doctor app's
//  email code: an HR admin's account is created by ParentVeda with a password,
//  and a code-first screen would ask them for something nobody told them about.
//
//  "Forgot password?" is the parent app's code flow (auth_flow_screen.dart
//  _sendResetCode): a six-digit code from the email, then a new password. Not a
//  link, because a link from Supabase's mail has nowhere to land in an app.
//  ⚠️ DASHBOARD DEPENDENCY, shared with the parent app: the Reset Password
//  template must contain {{ .Token }} (docs/AUTH-SETUP.md §3b).
//
//  THIS SCREEN CANNOT MAKE ANYONE AN ADMIN. Signing in proves the email; the
//  server (my_partner_org, 0136) then says which organisation it runs. A login
//  that runs none is signed straight back out and told where it belongs: a
//  doctor to ParentVeda+, a parent to ParentVeda, anyone else to their
//  ParentVeda contact. Each refusal names the next step (PARTNERS-APP.md P1).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../partner_app/partner_org_session.dart';
import '../../partner_app/partner_sign_out.dart';
import '../doctor/doctor_chrome.dart';
import 'partner_words.dart';

class PartnerAuthScreen extends StatefulWidget {
  const PartnerAuthScreen({super.key, required this.onSignedIn, this.note});

  /// Called after a sign-in whose organisation resolved (live or paused), OR
  /// could not be checked because the server did not answer. Never for a
  /// refusal: that stays here, signed out, with the reason under the form.
  final VoidCallback onSignedIn;

  /// A refusal carried in from the boot (a restored session that no longer
  /// resolves), shown under the form on arrival.
  final String? note;

  @override
  State<PartnerAuthScreen> createState() => _PartnerAuthScreenState();
}

enum _Step { signIn, resetEmail, resetCode, newPassword }

class _PartnerAuthScreenState extends State<PartnerAuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  final _newPassword = TextEditingController();
  _Step _step = _Step.signIn;
  bool _busy = false;
  bool _showPassword = false;
  late String? _error = widget.note;

  /// Must agree with Authentication → Email → "Email OTP Length" (6).
  static const _codeLength = 6;

  /// What each field said when its listener last ran, so only a real edit
  /// clears the error.
  final Map<TextEditingController, String> _seen = {};

  @override
  void initState() {
    super.initState();
    // The error belongs to the moment it was made; editing a field clears it.
    for (final c in [_email, _password, _code, _newPassword]) {
      _seen[c] = c.text;
      c.addListener(() => _clearError(c));
    }
  }

  /// ⚠️ A controller notifies on SELECTION as well as text, and an autofocused
  /// field sets its selection the moment it is laid out. Clearing on every
  /// notification wiped the refusal carried in from the boot before the
  /// person could read it: a turned-away doctor saw a blank form and no reason.
  /// Only a change of TEXT is her editing.
  void _clearError(TextEditingController c) {
    if (c.text == _seen[c]) return;
    _seen[c] = c.text;
    if (_error != null && mounted) setState(() => _error = null);
  }

  @override
  void dispose() {
    // The listeners are closures, so they go with the controllers.
    for (final c in [_email, _password, _code, _newPassword]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _emailText => _email.text.trim().toLowerCase();

  bool get _emailLooksRight =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_emailText);

  void _go(_Step s) => setState(() {
    _step = s;
    _error = null;
    _busy = false;
  });

  /// Runs one network step with the busy state and the two failure kinds:
  /// an AuthException is the server saying no (its words, or ours via
  /// [authText]); anything else is the phone not reaching it.
  Future<void> _attempt(
    Future<void> Function() body, {
    String Function(AuthException)? authText,
  }) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await body();
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = authText?.call(e) ?? e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Could not reach ParentVeda. Check your connection.';
        });
      }
    }
  }

  Future<void> _signIn() async {
    if (!_emailLooksRight || _password.text.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }
    await _attempt(
      () async {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailText,
          password: _password.text,
        );
        await _afterSignIn();
      },
      // Supabase says the same for a wrong password and an unknown email,
      // on purpose (no account probing). Said in our words.
      authText: (e) => e.message.toLowerCase().contains('invalid')
          ? 'That email and password do not match.'
          : e.message,
    );
  }

  Future<void> _sendResetCode() async {
    if (!_emailLooksRight) {
      setState(() => _error = 'Enter the email you sign in with.');
      return;
    }
    await _attempt(() async {
      await Supabase.instance.client.auth.resetPasswordForEmail(_emailText);
      if (!mounted) return;
      _code.clear();
      _go(_Step.resetCode);
    });
  }

  Future<void> _verifyResetCode() async {
    if (_code.text.trim().length != _codeLength) {
      setState(
        () => _error = 'Enter the $_codeLength-digit code from the email.',
      );
      return;
    }
    await _attempt(
      () async {
        // A recovery code returns a SESSION: that is what makes the password
        // change on the next step permissible at all.
        await Supabase.instance.client.auth.verifyOTP(
          type: OtpType.recovery,
          email: _emailText,
          token: _code.text.trim(),
        );
        if (!mounted) return;
        _newPassword.clear();
        _go(_Step.newPassword);
      },
      authText: (e) => e.message.toLowerCase().contains('expired')
          ? 'That code has expired. Send a new one.'
          : 'That code is not right. Check the email and try again.',
    );
  }

  Future<void> _setNewPassword() async {
    if (_newPassword.text.length < 8) {
      setState(() => _error = 'Use at least 8 characters.');
      return;
    }
    await _attempt(() async {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPassword.text),
      );
      // Already signed in by the code; straight on, no second sign-in.
      await _afterSignIn();
    });
  }

  /// The credential proved the email. Now the server says who it is.
  Future<void> _afterSignIn() async {
    final result = await PartnerOrgSession.instance.resolveFromServer();
    if (!mounted) return;
    if (result == PartnerResolve.notAnAdmin) {
      final why = partnerRefusalText(PartnerOrgSession.instance.refusal);
      await forgetPartnerOrgOnThisPhone();
      if (!mounted) return;
      _password.clear();
      setState(() {
        _busy = false;
        _step = _Step.signIn;
        _error = why;
      });
      return;
    }
    // resolved, suspended or unreachable: the app root decides the screen.
    widget.onSignedIn();
  }

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final (label, action) = switch (_step) {
      _Step.signIn => ('Sign in', _signIn),
      _Step.resetEmail => ('Send me a code', _sendResetCode),
      _Step.resetCode => ('Continue', _verifyResetCode),
      _Step.newPassword => ('Save and sign in', _setNewPassword),
    };
    return PopScope(
      // Back inside the reset steps returns to sign in, not out of the app.
      canPop: _step == _Step.signIn,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_busy) _go(_Step.signIn);
      },
      child: Scaffold(
        backgroundColor: p.ground,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    if (_step != _Step.signIn)
                      IconButton(
                        onPressed: _busy ? null : () => _go(_Step.signIn),
                        icon: Icon(Icons.arrow_back_rounded, color: p.ink1),
                        tooltip: 'Back',
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/brand/pv-mark.png',
                          width: 44,
                          height: 44,
                        ),
                        const SizedBox(width: 12),
                        Text('ParentVeda Partners', style: dcStrong(17)),
                      ],
                    ),
                    const SizedBox(height: 28),
                    ...switch (_step) {
                      _Step.signIn => _signInStep(p),
                      _Step.resetEmail => _resetEmailStep(p),
                      _Step.resetCode => _resetCodeStep(p),
                      _Step.newPassword => _newPasswordStep(p),
                    },
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ObPrimary(
                      p: p,
                      label: _busy ? 'One moment…' : label,
                      onTap: _busy ? null : action,
                    ),
                    const SizedBox(height: 10),
                    if (_step == _Step.signIn)
                      TextButton(
                        onPressed: _busy ? null : () => _go(_Step.resetEmail),
                        child: Text(
                          'Forgot password?',
                          style: dcStrong(14, color: p.action),
                        ),
                      )
                    else if (_step == _Step.resetCode)
                      TextButton(
                        onPressed: _busy ? null : _sendResetCode,
                        child: Text(
                          'Send a new code',
                          style: dcStrong(14, color: p.action),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showHide(dynamic p) => IconButton(
    onPressed: () => setState(() => _showPassword = !_showPassword),
    icon: Icon(
      _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      size: 20,
      color: p.ink2,
    ),
    tooltip: _showPassword ? 'Hide password' : 'Show password',
  );

  List<Widget> _signInStep(dynamic p) => [
    Text('Sign in', style: dcTitle(32)),
    const SizedBox(height: 8),
    Text(
      'For employers, schools and clinics running a ParentVeda programme. '
      'Use the email and password you use on the web portal.',
      style: dcMeta(15),
    ),
    const SizedBox(height: 24),
    DcInput(
      label: 'Email',
      controller: _email,
      hint: 'you@company.com',
      keyboard: TextInputType.emailAddress,
      autofocus: true,
    ),
    const SizedBox(height: 14),
    DcInput(
      label: 'Password',
      controller: _password,
      obscure: !_showPassword,
      onSubmitted: (_) => _signIn(),
      errorText: _error,
    ),
    Align(alignment: Alignment.centerRight, child: _showHide(p)),
    const SizedBox(height: 8),
    Text(
      'Accounts are created by ParentVeda. If you run a programme with us '
      'and cannot sign in, write to $kPartnersSupportEmail.',
      style: dcMeta(13, color: p.ink3),
    ),
  ];

  List<Widget> _resetEmailStep(dynamic p) => [
    Text('Reset your password', style: dcTitle(32)),
    const SizedBox(height: 8),
    Text(
      'We will email a $_codeLength-digit code to the address you sign in with.',
      style: dcMeta(15),
    ),
    const SizedBox(height: 24),
    DcInput(
      label: 'Email',
      controller: _email,
      hint: 'you@company.com',
      keyboard: TextInputType.emailAddress,
      autofocus: true,
      onSubmitted: (_) => _sendResetCode(),
      errorText: _error,
    ),
  ];

  List<Widget> _resetCodeStep(dynamic p) => [
    Text('Check your email', style: dcTitle(32)),
    const SizedBox(height: 8),
    // Deliberately "if there is an account": saying "no such account"
    // would let anyone test which companies run a programme with us.
    Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'If there is an account for ', style: dcMeta(15)),
          TextSpan(text: _emailText, style: dcStrong(15)),
          TextSpan(
            text:
                ', a $_codeLength-digit code is on its way. It expires in an hour.',
            style: dcMeta(15),
          ),
        ],
      ),
    ),
    const SizedBox(height: 24),
    DcInput(
      label: 'Code',
      controller: _code,
      hint: '••••••',
      keyboard: TextInputType.number,
      autofocus: true,
      onSubmitted: (_) => _verifyResetCode(),
      errorText: _error,
    ),
    const SizedBox(height: 20),
    Text(
      'Nothing there? Check spam, or send a new code below.',
      style: dcMeta(13, color: p.ink3),
    ),
  ];

  List<Widget> _newPasswordStep(dynamic p) => [
    Text('Choose a new password', style: dcTitle(32)),
    const SizedBox(height: 8),
    Text('It works on the web portal too.', style: dcMeta(15)),
    const SizedBox(height: 24),
    DcInput(
      label: 'New password',
      controller: _newPassword,
      obscure: !_showPassword,
      autofocus: true,
      onSubmitted: (_) => _setNewPassword(),
      errorText: _error,
    ),
    Align(alignment: Alignment.centerRight, child: _showHide(p)),
  ];
}
