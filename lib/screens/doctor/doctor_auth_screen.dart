// =============================================================================
//  DoctorAuthScreen — the way into ParentVeda+.
// -----------------------------------------------------------------------------
//  Email, then a six-digit code from the email. Nothing to invent, nothing to
//  remember. (Slack's "logging in" flow, Mobbin audit #8; the user's call,
//  2026-09-18.) Password stays as the quiet fallback for an account that has
//  one — it is a link under the button, not the default.
//
//  WHAT IS DELIBERATELY ABSENT, because the parent auth flow has all of it and
//  none of it belongs here: no role picker, no due date, no stage selector, no
//  WhatsApp opt-in, no employer benefit, no "sign in as which doctor?" dropdown.
//
//  That dropdown is the important omission. In the parent build a doctor picks
//  themselves from a list of everyone in the compiled catalogue — a testing
//  affordance, and a bad identity: something you choose from a menu is not proof
//  of who you are. Here the account IS the identity. Sign in, and the server
//  answers who you are from expert_accounts (see DoctorSession.resolveFromServer).
//
//  HOW A DOCTOR GETS IN WITHOUT ANYONE TYPING SQL. An admin writes their email
//  against their expert id in expert_invites (0084). The code proves they own
//  that email; claim_expert_invite() then links expert_accounts; resolve finds
//  it. The user described this as "we feed the email in the back end, they
//  just log in" — that is exactly what it is, with the proof of ownership
//  being the code rather than nothing.
//
//  So this screen cannot make you a doctor. It can only let a doctor in. If the
//  account has no expert record, it says so plainly rather than offering a list
//  to pick from — the honest failure, and the one that keeps the door shut.
//
//  ⚠️ DASHBOARD DEPENDENCY: the code arrives through Supabase's **Magic Link**
//  email template, which must contain {{ .Token }} — the same trap
//  docs/AUTH-SETUP.md §3b describes for Reset Password. Without it the email
//  arrives with no code and nothing on this side can tell.
//
//  Kept for revert: the previous build was email + password only, with the
//  fields in ppPanel and a violet-filled button; the password path below is
//  that build, restyled.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../doctor/doctor_session.dart';
import 'doctor_chrome.dart';

class DoctorAuthScreen extends StatefulWidget {
  const DoctorAuthScreen({super.key, required this.onSignedIn});

  /// Called after a successful sign-in AND a successful identity resolve.
  final VoidCallback onSignedIn;

  @override
  State<DoctorAuthScreen> createState() => _DoctorAuthScreenState();
}

enum _Step { email, code, password }

class _DoctorAuthScreenState extends State<DoctorAuthScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  _Step _step = _Step.email;
  bool _busy = false;
  String? _error;

  /// Must agree with Authentication → Email → "Email OTP Length" in the
  /// dashboard (6; the project defaulted to 8 once — AUTH-SETUP §3b).
  static const _codeLength = 6;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  String get _emailText => _email.text.trim().toLowerCase();

  bool get _emailLooksRight =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_emailText);

  Future<void> _sendCode() async {
    if (!_emailLooksRight) {
      setState(() => _error = 'Enter the email ParentVeda has for you.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // shouldCreateUser stays true: a doctor who has never signed into the
      // parent app has no auth user yet, and the invite is claimed AFTER the
      // code proves the email. A stranger who types an unknown email gets a
      // code, gets in, claims nothing, resolves nothing, and is signed out
      // with the message below — the door stays shut, and nobody can use
      // this form to test whether a clinician has an account.
      await Supabase.instance.client.auth.signInWithOtp(email: _emailText);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _step = _Step.code;
      });
    } on AuthException catch (e) {
      if (mounted) setState(() { _busy = false; _error = e.message; });
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Could not reach ParentVeda. Check your connection.';
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    final code = _code.text.trim();
    if (code.length != _codeLength) {
      setState(() => _error = 'Enter the $_codeLength-digit code from the email.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.email,
        email: _emailText,
        token: code,
      );
      await _afterSignIn();
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message.toLowerCase().contains('expired')
              ? 'That code has expired. Send a new one.'
              : 'That code is not right. Check the email and try again.';
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

  Future<void> _signInWithPassword() async {
    final password = _password.text;
    if (!_emailLooksRight || password.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth
          .signInWithPassword(email: _emailText, password: password);
      await _afterSignIn();
    } on AuthException catch (e) {
      // Supabase says the same thing for a wrong password and an address that
      // has never registered. Passed through unchanged on purpose.
      if (mounted) setState(() { _busy = false; _error = e.message; });
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Could not reach ParentVeda. Check your connection.';
        });
      }
    }
  }

  /// TWO STEPS after the credential, and the second is the one that matters.
  /// Signing in proves the account; it does not make anyone a doctor. The
  /// server decides that, and an account with no expert record must be told
  /// so rather than shown an empty dashboard it cannot explain.
  Future<void> _afterSignIn() async {
    if (!mounted) return;
    await DoctorSession.instance.claimInvite();
    final ok = await DoctorSession.instance.resolveFromServer();
    if (!mounted) return;
    if (!ok) {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      setState(() {
        _busy = false;
        _step = _Step.email;
        _code.clear();
        _error = 'This email is not registered with ParentVeda+. '
            'If you consult with us, write to partners@parentveda.com and we will add it.';
      });
      return;
    }
    widget.onSignedIn();
  }

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: Column(children: [
          SizedBox(
            height: 48,
            child: Row(children: [
              if (_step != _Step.email)
                IconButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                            _step = _Step.email;
                            _error = null;
                          }),
                  icon: Icon(Icons.arrow_back_rounded, color: p.ink1),
                  tooltip: 'Back',
                ),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.medical_services_outlined, size: 22, color: p.ink1),
                  ),
                  const SizedBox(width: 12),
                  Text('ParentVeda+', style: dcStrong(17)),
                ]),
                const SizedBox(height: 28),
                ...switch (_step) {
                  _Step.email => _emailStep(p),
                  _Step.code => _codeStep(p),
                  _Step.password => _passwordStep(p),
                },
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  DcNotice(_error!, problem: true),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ObPrimary(
                p: p,
                label: _busy
                    ? 'One moment…'
                    : switch (_step) {
                        _Step.email => 'Send me a code',
                        _Step.code => 'Sign in',
                        _Step.password => 'Sign in',
                      },
                onTap: _busy
                    ? null
                    : switch (_step) {
                        _Step.email => _sendCode,
                        _Step.code => _verifyCode,
                        _Step.password => _signInWithPassword,
                      },
              ),
              const SizedBox(height: 10),
              if (_step == _Step.email)
                TextButton(
                  onPressed: _busy ? null : () => setState(() { _step = _Step.password; _error = null; }),
                  child: Text('Use a password instead', style: dcStrong(14, color: p.action)),
                )
              else if (_step == _Step.code)
                TextButton(
                  onPressed: _busy ? null : _sendCode,
                  child: Text('Send a new code', style: dcStrong(14, color: p.action)),
                )
              else
                TextButton(
                  onPressed: _busy ? null : () => setState(() { _step = _Step.email; _error = null; }),
                  child: Text('Sign in with a code instead', style: dcStrong(14, color: p.action)),
                ),
            ]),
          ),
        ]),
      ),
    );
  }

  List<Widget> _emailStep(dynamic p) => [
        Text('Sign in', style: dcTitle(32)),
        const SizedBox(height: 8),
        Text(
          'For doctors, counsellors and partner clinics. Enter the email ParentVeda has for you and we will send a code.',
          style: dcMeta(15),
        ),
        const SizedBox(height: 24),
        DcInput(
          label: 'Email',
          controller: _email,
          hint: 'you@clinic.com',
          keyboard: TextInputType.emailAddress,
          autofocus: true,
          onSubmitted: (_) => _sendCode(),
        ),
        const SizedBox(height: 20),
        Text(
          'Accounts are created by ParentVeda. If you consult with us and cannot sign in, write to partners@parentveda.com.',
          style: dcMeta(13, color: p.ink3),
        ),
      ];

  List<Widget> _codeStep(dynamic p) => [
        Text('Check your email', style: dcTitle(32)),
        const SizedBox(height: 8),
        Text.rich(TextSpan(children: [
          TextSpan(text: 'We sent a $_codeLength-digit code to ', style: dcMeta(15)),
          TextSpan(text: _emailText, style: dcStrong(15)),
          TextSpan(text: '. It expires in an hour.', style: dcMeta(15)),
        ])),
        const SizedBox(height: 24),
        DcInput(
          label: 'Code',
          controller: _code,
          hint: '••••••',
          keyboard: TextInputType.number,
          autofocus: true,
          onSubmitted: (_) => _verifyCode(),
        ),
        const SizedBox(height: 20),
        Text(
          'Nothing there? Check spam, or send a new code below.',
          style: dcMeta(13, color: p.ink3),
        ),
      ];

  List<Widget> _passwordStep(dynamic p) => [
        Text('Sign in with a password', style: dcTitle(32)),
        const SizedBox(height: 8),
        Text('For accounts that were set up with one.', style: dcMeta(15)),
        const SizedBox(height: 24),
        DcInput(
          label: 'Email',
          controller: _email,
          hint: 'you@clinic.com',
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        DcInput(
          label: 'Password',
          controller: _password,
          obscure: true,
          onSubmitted: (_) => _signInWithPassword(),
        ),
      ];
}
