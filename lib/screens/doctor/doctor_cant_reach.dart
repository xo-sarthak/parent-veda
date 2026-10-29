// =============================================================================
//  DoctorCantReach — the screen ParentVeda+ shows when it cannot ask the server
// -----------------------------------------------------------------------------
//  Two cases, one screen (Partner Editions D1):
//
//    * The backend never started (Supabase.initialize threw). The app used to
//      crash on launch, which breaks the house rule that an uninitialised
//      backend behaves like being signed out, never like a crash.
//    * She is signed in, but the identity check got no answer. The app used to
//      show the sign-in form after twelve seconds of spinner, as if she had
//      been logged out.
//
//  Either way the honest message is the same: nothing is lost, the phone just
//  cannot reach us, and here is the one thing to do. Never the sign-in form,
//  which would ask her to fix something that is not broken.
// =============================================================================

import 'package:flutter/material.dart';

import 'doctor_art.dart';
import 'doctor_chrome.dart';

class DoctorCantReach extends StatefulWidget {
  const DoctorCantReach({
    super.key,
    required this.onRetry,
    this.signedIn = false,
  });

  /// Tries again. The button shows a spinner until this completes.
  final Future<void> Function() onRetry;

  /// True when a session exists and only the identity check failed: the copy
  /// then says her bookings are safe, which is the worry an offline doctor has.
  final bool signedIn;

  @override
  State<DoctorCantReach> createState() => _DoctorCantReachState();
}

class _DoctorCantReachState extends State<DoctorCantReach> {
  bool _busy = false;

  Future<void> _retry() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onRetry();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Align(
                alignment: Alignment.centerLeft,
                child: DoctorArtTile(
                  mark: DoctorMark.plus,
                  p: p,
                  size: 44,
                  radius: 14,
                ),
              ),
              const SizedBox(height: 18),
              Text("Can't reach ParentVeda right now", style: dcStrong(22)),
              const SizedBox(height: 8),
              Text(
                widget.signedIn
                    ? 'You are still signed in, and your bookings and schedule are safe on the server. '
                          'Check your connection, then try again.'
                    : 'Check your connection, then try again.',
                style: dcMeta(15),
              ),
              const Spacer(flex: 2),
              _busy
                  ? const Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                    )
                  : ObPrimary(p: p, label: 'Try again', onTap: _retry),
            ],
          ),
        ),
      ),
    );
  }
}
