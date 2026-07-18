// =============================================================================
//  ProfileAnalyticsScreen — the toggle, and proof it is working
// -----------------------------------------------------------------------------
//  Recording is ALWAYS ON. This screen is the window onto it: the live event
//  stream, the session and install ids, and current completeness. Without a
//  window, analytics is a black box you have to take on faith.
//
//  The buffer resets each launch by design - it is for observability, not
//  storage. Durable tester data arrives when a real sink is attached
//  (ProfileAnalytics.setSink), which is one line and no call-site changes.
//
//  WHAT IT IS FOR: judging our QUESTIONS, never the mother. See the header of
//  services/profile_analytics.dart for the constraint that governs this.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/family_profile.dart';
import '../services/profile_analytics.dart';
import '../theme/app_theme.dart';

class ProfileAnalyticsScreen extends StatelessWidget {
  const ProfileAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final a = ProfileAnalytics.instance;
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        elevation: 0,
        title: const Text('Personalization analytics'),
      ),
      body: AnimatedBuilder(
        animation: a,
        builder: (context, _) {
          final events = a.recent;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _card(
                child:
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Recording',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary900)),
                  const SizedBox(height: 6),
                  Text(
                    'Always on. Open a tool with an ask strip and events appear below. Nothing leaves this device.',
                    style: GoogleFonts.manrope(
                        fontSize: 12.5, height: 1.45, color: AppTheme.neutral500),
                  ),
                  const Divider(height: 22),
                  Text('session ${a.sessionId}  ·  install ${a.installId}',
                      style: GoogleFonts.robotoMono(
                          fontSize: 11, color: AppTheme.neutral500)),
                  const SizedBox(height: 8),
                  Text(
                    'Both ids are random and anonymous - never a hardware identifier. The session id is new each launch; the install id persists, so a completion rate can be counted per mother rather than per view.',
                    style: GoogleFonts.manrope(
                        fontSize: 12, height: 1.5, color: AppTheme.neutral500),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This measures our questions, not you: whether a strip is worded well and placed well. It is never used to chase anyone into finishing a profile.',
                    style: GoogleFonts.manrope(
                        fontSize: 12.5, height: 1.5, color: AppTheme.neutral500),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              _card(
                child:
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Text('Profile completeness',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary900)),
                    ),
                    Text('${FamilyProfileStore.instance.completenessPercent}%',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary600)),
                  ]),
                  const SizedBox(height: 10),
                  Text(
                    'Which fields have been asked: ${_asked()}',
                    style: GoogleFonts.manrope(
                        fontSize: 12.5, height: 1.5, color: AppTheme.neutral500),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: Text('Recent events (${events.length})',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary900)),
                ),
                if (events.isNotEmpty)
                  TextButton(
                    onPressed: a.clearRecent,
                    child: const Text('Clear'),
                  ),
              ]),
              const SizedBox(height: 6),
              if (events.isEmpty)
                _card(
                  child: Text(
                    'No events yet. Open Symptom Companion, the Weight Tracker, Tests & Scans or the Tools hub — the ask strip fires as soon as it renders.',
                    style: GoogleFonts.manrope(
                        fontSize: 13, height: 1.5, color: AppTheme.neutral500),
                  ),
                )
              else
                for (final e in events)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _card(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                      child: Text(e,
                          style: GoogleFonts.robotoMono(
                              fontSize: 11.5,
                              height: 1.4,
                              color: AppTheme.primary900)),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  static String _asked() {
    final p = FamilyProfileStore.instance;
    final asked = ProfileField.values.where(p.asked).map((f) => f.name).toList();
    return asked.isEmpty ? 'none yet' : asked.join(', ');
  }

  Widget _card({required Widget child, EdgeInsets? padding}) => Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
      );
}
