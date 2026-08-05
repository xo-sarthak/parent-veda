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
import '../theme/pv_fonts.dart';
import '../localization/app_language.dart';

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
        title: Text(S.now.uiPersonalizationAnalytics),
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
                  Text(S.now.uiRecording,
                      style: pvJakarta(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary900)),
                  const SizedBox(height: 6),
                  Text(
                    S.now.uiAlwaysOpenToolAsk,
                    style: pvManrope(
                        fontSize: 12.5, height: 1.45, color: AppTheme.neutral500),
                  ),
                  const Divider(height: 22),
                  Text('session ${a.sessionId}  ·  install ${a.installId}',
                      style: GoogleFonts.robotoMono(
                          fontSize: 11, color: AppTheme.neutral500)),
                  const SizedBox(height: 8),
                  Text(
                    S.now.uiBothIdsAreRandom,
                    style: pvManrope(
                        fontSize: 12, height: 1.5, color: AppTheme.neutral500),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    S.now.uiMeasuresOurQuestionsNot,
                    style: pvManrope(
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
                      child: Text(S.now.uiProfileCompleteness,
                          style: pvJakarta(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary900)),
                    ),
                    Text('${FamilyProfileStore.instance.completenessPercent}%',
                        style: pvJakarta(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary600)),
                  ]),
                  const SizedBox(height: 10),
                  Text(
                    'Which fields have been asked: ${_asked()}',
                    style: pvManrope(
                        fontSize: 12.5, height: 1.5, color: AppTheme.neutral500),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: Text('Recent events (${events.length})',
                      style: pvJakarta(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary900)),
                ),
                if (events.isNotEmpty)
                  TextButton(
                    onPressed: a.clearRecent,
                    child: Text(S.now.uiClear),
                  ),
              ]),
              const SizedBox(height: 6),
              if (events.isEmpty)
                _card(
                  child: Text(
                    S.now.uiNoEventsYetOpen,
                    style: pvManrope(
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
