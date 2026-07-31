// =============================================================================
//  DoctorAuthScreen — the way into ParentVeda+.
// -----------------------------------------------------------------------------
//  Email and password. Nothing else.
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
//  So this screen cannot make you a doctor. It can only let a doctor in. If the
//  account has no expert record, it says so plainly rather than offering a list
//  to pick from — the honest failure, and the one that keeps the door shut.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../doctor/doctor_session.dart';

// The doctor app's own palette — deep slate rather than the parent app's
// lavender. A clinician opening this between appointments should never wonder
// which app they are in, and colour is the fastest signal there is.
const _bg = Color(0xFF101418);
const _panel = Color(0xFF181D23);
const _line = Color(0xFF262C34);
const _ink = Color(0xFFF2F5F8);
const _muted = Color(0xFF8A94A0);
const _accent = Color(0xFF3FA9A0);

class DoctorAuthScreen extends StatefulWidget {
  const DoctorAuthScreen({super.key, required this.onSignedIn});

  /// Called after a successful sign-in AND a successful identity resolve.
  final VoidCallback onSignedIn;

  @override
  State<DoctorAuthScreen> createState() => _DoctorAuthScreenState();
}

class _DoctorAuthScreenState extends State<DoctorAuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
      if (!mounted) return;

      // TWO STEPS, and the second is the one that matters. Signing in proves
      // the account; it does not make anyone a doctor. The server decides that,
      // and an account with no expert record must be told so rather than shown
      // an empty dashboard it cannot explain.
      final ok = await DoctorSession.instance.resolveFromServer();
      if (!mounted) return;

      if (!ok) {
        await Supabase.instance.client.auth.signOut();
        if (!mounted) return;
        setState(() {
          _busy = false;
          _error = 'This account is not registered as a ParentVeda expert. '
              'Ask us to link it, then sign in again.';
        });
        return;
      }

      widget.onSignedIn();
    } on AuthException catch (e) {
      // Supabase says the same thing for a wrong password and an address that
      // has never registered. Passed through unchanged on purpose: telling
      // them apart would turn this form into a way to test whether a given
      // clinician has an account.
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 62,
                      height: 62,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.medical_services_outlined,
                          size: 30, color: _accent),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'ParentVeda+',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                        color: _ink),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'For doctors, counsellors and partner clinics.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, height: 1.5, color: _muted),
                  ),
                  const SizedBox(height: 30),
                  _field(_email, 'Email', 'you@clinic.com',
                      keyboard: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  _field(_password, 'Password', '', obscure: true),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A1F24),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF5C2C33)),
                      ),
                      child: Text(_error!,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              height: 1.45,
                              color: const Color(0xFFFFB4BC))),
                    ),
                  ],
                  const SizedBox(height: 22),
                  GestureDetector(
                    onTap: _busy ? null : _submit,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _busy ? _line : _accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: _muted))
                          : Text('Sign in',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF06231F))),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Accounts are created by ParentVeda. If you consult with us '
                    'and cannot sign in, contact your ParentVeda partner manager.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, height: 1.55, color: _muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, String hint,
      {bool obscure = false, TextInputType? keyboard}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: _muted)),
      const SizedBox(height: 7),
      TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboard,
        autocorrect: false,
        enableSuggestions: false,
        style: GoogleFonts.plusJakartaSans(fontSize: 15, color: _ink),
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 15, color: _muted.withValues(alpha: 0.55)),
          filled: true,
          fillColor: _panel,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: _accent, width: 1.6),
          ),
        ),
      ),
    ]);
  }
}
