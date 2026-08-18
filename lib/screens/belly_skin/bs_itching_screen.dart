// =============================================================================
//  BsItchingScreen — Area 3, the safety core of Belly & Skin
// -----------------------------------------------------------------------------
//  ONE page, two clearly separated parts, per the approved spec:
//
//    Part 1 — normal pregnancy itching (stretching skin, dryness) and how to
//             soothe it.
//    Part 2 — the warning. Intense itching, especially palms and soles, can
//             signal cholestasis of pregnancy (ICP). Stated plainly, with a
//             route to her doctor.
//
//  ⚠️ THE WARNING IS VISIBLE, NOT BURIED BELOW THE SOOTHING TIPS. It renders
//  as its own card directly under the intro, before Part 1's tips — the same
//  "position carries the urgency, not colour" rule problem_hub_screen.dart's
//  `_UrgentStrip` uses for red-flag content elsewhere in the app. Warm and
//  steady, not alarming: no red, no siren iconography, just impossible to
//  miss.
//
//  ⚠️ NO PRODUCT ANYWHERE ON THIS PAGE. Its only job is to help and to route
//  to a doctor — see `kBsItchingWarning*` in belly_skin_data.dart, which
//  carries no `BsProduct` reference at all, and nothing below constructs one
//  either. That is enforced by construction (there is no product data to
//  render), not by a comment discipline.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/belly_skin_data.dart';
import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/problem_hub_screen.dart' show HubPill;
import '../v2/v2_palette.dart';
import '../../widgets/pv_placeholders.dart';
import 'bs_article_screen.dart' show BsBlockView;

const _lang = AppLanguage.english;

class BsItchingScreen extends StatelessWidget {
  const BsItchingScreen({super.key, this.onSeeDoctorInfo});

  /// Optional hand-off to a fuller complications explainer (e.g. a
  /// Complications/ICP page), when the integrator has one to offer. This
  /// screen's own job is done without it — the doctor CTA below always works
  /// on its own — so a null callback degrades to "call your doctor", never to
  /// a dead tap. See the file header of belly_skin_home_screen.dart for why
  /// this is a callback rather than a hard import: no such destination
  /// exists among the files this build owns.
  final VoidCallback? onSeeDoctorInfo;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final areaHue = kBsAreaInfo[BsArea.itching]!.hue;

    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        elevation: 0,
        foregroundColor: p.ink1,
        title: Text('Itching',
            style: pvJakarta(
                fontSize: 17, fontWeight: FontWeight.w700, color: p.ink1)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
        children: [
          PvVideoPlaceholder(
            title: 'Itchy skin in pregnancy, explained',
            subtitle: 'What is normal, and the one sign worth knowing',
            duration: '4 MIN',
            hue: areaHue,
          ),
          const SizedBox(height: 16),
          Text(kBsItchingIntro.of(_lang),
              style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink2)),
          const SizedBox(height: 22),

          // ---- PART 2 FIRST, ON PURPOSE -----------------------------------
          // Reading order still says "normal, then warning" via the heading
          // below, but the warning card itself sits here — above the tips —
          // because position is what makes it unmissable on a scroll. Burying
          // a real complication under "how to soothe dry skin" would read as
          // reassurance winning the argument.
          _WarningCard(p: p, onSeeDoctorInfo: onSeeDoctorInfo),
          const SizedBox(height: 26),

          Text('Is this normal?',
              style: pvFraunces(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: -0.4,
                  color: p.ink1)),
          const SizedBox(height: 12),
          for (final b in kBsItchingNormal) ...[
            BsBlockView(block: b, p: p),
            const SizedBox(height: 18),
          ],
          const SizedBox(height: 4),
          _FootDisclaimer(p: p),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.p, this.onSeeDoctorInfo});
  final V2Palette p;
  final VoidCallback? onSeeDoctorInfo;

  @override
  Widget build(BuildContext context) {
    // A steady clay tone, not alarm red — "warm and steady, not alarming, but
    // unambiguous" from the spec. The unmistakability comes from the border
    // weight, the icon and the position on the page, not from a loud colour.
    const accent = Color(0xFFB5623E);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.6),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.health_and_safety_outlined,
              color: accent, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(kBsItchingWarningTitle.of(_lang),
                style: pvFraunces(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: p.ink1)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(kBsItchingWarningBody.of(_lang),
            style: pvManrope(
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w600,
                color: p.ink1)),
        const SizedBox(height: 10),
        Text(kBsItchingWarningNote.of(_lang),
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
        const SizedBox(height: 16),
        HubPill(
          label: kBsItchingWarningCta.of(_lang),
          icon: Icons.medical_information_outlined,
          p: p,
          fullWidth: true,
          onTap: () => _seeDoctor(context),
        ),
      ]),
    );
  }

  void _seeDoctor(BuildContext context) {
    if (onSeeDoctorInfo != null) {
      onSeeDoctorInfo!();
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DoctorSheet(),
    );
  }
}

/// The graceful fallback when no complications hand-off is wired: a calm,
/// unambiguous instruction rather than a dead tap. Belly & Skin does not own
/// a Complications/ICP screen or the doctor-booking flow (both live outside
/// the five files this build may touch), so this is the honest floor —
/// "call your doctor" said plainly — with `onSeeDoctorInfo` left as the seam
/// for whoever wires this section in to hand it a real destination.
class _DoctorSheet extends StatelessWidget {
  const _DoctorSheet();

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: p.line),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.local_hospital_outlined, size: 30, color: p.ink1),
          const SizedBox(height: 12),
          Text('Call your doctor today',
              style: pvFraunces(
                  fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
          const SizedBox(height: 8),
          Text(
              'Intense itching on your palms or soles is worth a same-day '
              'call, not a wait-and-see. Your doctor can run a simple blood '
              'test to check for cholestasis (ICP).',
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
          const SizedBox(height: 16),
          HubPill(
            label: 'Got it',
            icon: Icons.check_rounded,
            p: p,
            fullWidth: true,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ]),
      ),
    );
  }
}

class _FootDisclaimer extends StatelessWidget {
  const _FootDisclaimer({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.info_outline_rounded, size: 14, color: p.ink3),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
            'General guidance, not a diagnosis. If in doubt, call your '
            'doctor rather than wait for your next visit.',
            style: pvManrope(fontSize: 11.5, height: 1.4, color: p.ink3)),
      ),
    ]);
  }
}
