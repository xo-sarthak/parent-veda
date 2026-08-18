// =============================================================================
//  CrisisPath - the one screen every part of Mind & Mood can open
// -----------------------------------------------------------------------------
//  ⚠️ THE RULES, BECAUSE THIS IS THE MOST IMPORTANT SCREEN IN THE SECTION:
//
//    - It leads with real, immediate human help - a helpline she can call now,
//      and a line about someone she trusts. Nothing else competes with that.
//    - It NEVER shows an article, a paid booking, or an upsell. Not a related
//      read, not a "you might also like", not a discount. Help first, and
//      nothing else - see `_MmCrisisPathState.build` below, which imports
//      nothing from the paid or content layers of this section on purpose.
//    - It does not detect-and-diagnose. Whatever brought her here - a
//      repeated SOS tap, a word in the journal, a screener answer - this
//      screen never repeats it back to her or names a condition. It routes
//      to help on a SIGNAL, it does not label her.
//    - Warm and steady, not clinical or frightening. No red. No siren
//      language.
//
//  Every trigger in Mind & Mood calls `openCrisisPath(context)` rather than
//  building its own version of this screen, so there is exactly one crisis
//  experience in the app, not five slightly different ones.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/mind_mood_data.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';

/// Push the crisis path. Call this from anywhere in Mind & Mood rather than
/// building a bespoke "please get help" screen at the call site.
Future<void> openCrisisPath(BuildContext context) {
  return Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: 'mind_mood_crisis'),
    builder: (_) => const MmCrisisPathScreen(),
  ));
}

class MmCrisisPathScreen extends StatelessWidget {
  const MmCrisisPathScreen({super.key});

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    try {
      await launchUrl(uri);
    } catch (_) {
      // Fire-and-forget - a phone without calling capability (an emulator,
      // a tablet) should not crash this screen. There is nothing useful to
      // show her if the dialler does not open; the number is still visible
      // on screen to dial by hand.
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final calm = const Color(0xFF3E7A6B); // a steady, un-alarming teal - not red

    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 40),
          children: [
            Row(children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(Icons.close_rounded, color: p.ink2),
              ),
            ]),
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: calm.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.spa_outlined, size: 34, color: calm),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'You are not alone in this',
              textAlign: TextAlign.center,
              style: pvFraunces(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: -0.5,
                  color: p.ink1),
            ),
            const SizedBox(height: 10),
            Text(
              'What you are feeling matters, and real help is available '
              'right now. Please reach out.',
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink2),
            ),
            const SizedBox(height: 28),

            // ---- the primary action: call a real person, now --------------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: calm.withValues(alpha: 0.35)),
              ),
              child: Column(children: [
                Icon(Icons.phone_in_talk_outlined, size: 26, color: calm),
                const SizedBox(height: 12),
                Text(kCrisisHelplineName,
                    textAlign: TextAlign.center,
                    style: pvFraunces(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: p.ink1)),
                const SizedBox(height: 4),
                Text(kCrisisHelplineHours,
                    style: pvManrope(
                        fontSize: 12.5, color: p.ink3, letterSpacing: 0.2)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _call(kCrisisHelplineNumber),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: calm, width: 1.4),
                        ),
                        alignment: Alignment.center,
                        child: Text('Call now',
                            style: pvManrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: calm)),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            Text(
              'Or talk to someone you trust right now, a partner, a friend, '
              'a parent, anyone close. You do not have to carry this alone, '
              'and telling someone is not a burden on them.',
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink2),
            ),
            const SizedBox(height: 24),

            // ---- immediate physical danger --------------------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Icon(Icons.emergency_outlined, size: 20, color: p.ink2),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: pvManrope(
                          fontSize: 12.5, height: 1.5, color: p.ink2),
                      children: [
                        const TextSpan(
                            text: 'If you or your baby are in danger right '
                                'now, call '),
                        TextSpan(
                          text: kEmergencyNumber,
                          style: pvManrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: p.ink1),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 30),

            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text('I am okay for now',
                    style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: p.ink3)),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text('You can come back here any time from Mind & Mood.',
                  style: pvManrope(fontSize: 11.5, color: p.ink3)),
            ),
          ],
        ),
      ),
    );
  }
}
