// =============================================================================
//  PartnerHoldScreen — the Partners app when it cannot open the shell
// -----------------------------------------------------------------------------
//  Three cases, one calm screen, the doctor app's DoctorCantReach widened:
//
//    * the backend never started (Supabase.initialize threw);
//    * signed in, but the identity check got no answer (offline);
//    * signed in, and the organisation exists but is not live (paused, not
//      started, ended; MASTER R2).
//
//  Never the sign-in form for any of them: each would ask the person to fix
//  something that is not broken. Try again is always there; Sign out appears
//  only when somebody IS signed in, so a second admin on a shared phone is
//  never stuck behind the first one's paused programme.
// =============================================================================

import 'package:flutter/material.dart';

import '../doctor/doctor_chrome.dart';

class PartnerHoldScreen extends StatefulWidget {
  const PartnerHoldScreen({
    super.key,
    required this.title,
    required this.body,
    required this.onRetry,
    this.onSignOut,
  });

  final String title;
  final String body;

  /// Tries again. The button shows a spinner until this completes.
  final Future<void> Function() onRetry;

  /// Null when nobody is signed in (the backend never started).
  final Future<void> Function()? onSignOut;

  @override
  State<PartnerHoldScreen> createState() => _PartnerHoldScreenState();
}

class _PartnerHoldScreenState extends State<PartnerHoldScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() f) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await f();
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
                child: Image.asset(
                  'assets/brand/pv-mark.png',
                  width: 44,
                  height: 44,
                ),
              ),
              const SizedBox(height: 18),
              Text(widget.title, style: dcStrong(22)),
              const SizedBox(height: 8),
              Text(widget.body, style: dcMeta(15)),
              const Spacer(flex: 2),
              if (_busy)
                const Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
                )
              else ...[
                ObPrimary(
                  p: p,
                  label: 'Try again',
                  onTap: () => _run(widget.onRetry),
                ),
                if (widget.onSignOut != null) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => _run(widget.onSignOut!),
                    child: Text(
                      'Sign out',
                      style: dcStrong(14, color: p.action),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
