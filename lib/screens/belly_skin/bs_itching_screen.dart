// =============================================================================
//  BsItchingScreen - Area 3, the safety core of Belly & Skin
// -----------------------------------------------------------------------------
//  ⚠️ THIS PAGE IS A SAFETY ROUTE, NOT A SKINCARE ARTICLE, AND EVERY DECISION
//  BELOW IS DOWNSTREAM OF THAT ONE SENTENCE.
//
//  Four parts, in the order review set them:
//
//    1. Usually harmless   - stretching skin, dryness. Said first, because it
//                            is what is happening to nearly every woman who
//                            opens this page.
//    2. How to soothe it   - moisturising, gentle bathing, avoiding irritants.
//    3. THE WARNING        - intense itching, especially palms and soles, can
//                            signal cholestasis of pregnancy (ICP).
//    4. Two ways out       - talk to your doctor, and read what ICP actually
//                            is.
//
//  ⚠️ THE WARNING MOVED BELOW THE TIPS, REVERSING WHAT THIS FILE USED TO DO.
//  The old arrangement put it directly under the intro on the argument that
//  position carries urgency. See `kBsItchingWarningTitle` in
//  belly_skin_data.dart for the full reasoning behind the reversal; the short
//  version is that this order is how a clinician explains it, and the intro
//  copy already said "further down this page" while the card sat above.
//
//  ⚠️ "LEARN ABOUT ICP" IS NOW A REAL DESTINATION. This screen shipped with an
//  `onSeeDoctorInfo` seam and a comment saying no complications page existed
//  among the files that build owned. One does now - `icp_cholestasis` in
//  `conditions_data.dart` - and the two were never joined. That is the wiring
//  gate in miniature: the seam was built, the destination was built, and the
//  page went on offering a bottom sheet that said "call your doctor" because
//  nobody passed the callback. It no longer depends on a callback at all.
//
//  ⚠️ NO PRODUCT ANYWHERE ON THIS PAGE, and it is enforced by construction
//  rather than by discipline: there is no `BsProduct` data reachable from
//  here and nothing below builds one. The last soft nudge - a bullet reading
//  "or the belly oil ritual" - came out with this pass.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/belly_skin_data.dart';
import '../../data/conditions_data.dart';
import '../../services/pregnancy_controller.dart';
import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/problem_hub_screen.dart' show HubPill;
import '../v2/v2_palette.dart';
import '../../widgets/pv_placeholders.dart';
import '../conditions/condition_detail_screen.dart';
import 'bs_article_screen.dart' show BsBlockView;

const _lang = AppLanguage.english;

class BsItchingScreen extends StatelessWidget {
  const BsItchingScreen({super.key, this.onSeeDoctorInfo, this.pregnancy});

  /// ⚠️ THREADED IN, NEVER CONSTRUCTED HERE. The ICP page needs a controller,
  /// and the tempting shortcut - `PregnancyController()` at the call site -
  /// creates a second, disposable controller holding a placeholder due date.
  /// It would compile, render, and quietly show her a condition page keyed to
  /// the wrong week, with a leaked listener behind it. Nullable because this
  /// screen has a legitimate standalone use in previews.
  final PregnancyController? pregnancy;

  /// ⚠️ KEPT, BUT NO LONGER LOad-BEARING. It was the seam for a complications
  /// hand-off that did not exist when this file was written; the ICP page now
  /// exists and this screen routes to it directly. The parameter stays so a
  /// host that wants to intercept the doctor action (a booking flow, say) can
  /// still do so, and so no existing call site breaks.
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
          const SizedBox(height: 26),

          // ---- 1 · USUALLY HARMLESS ---------------------------------------
          // Named outright rather than asked as "Is this normal?". The
          // question form makes her supply the worry; the statement answers it
          // before she has to.
          _H('Usually harmless', p),
          const SizedBox(height: 10),
          for (final b in kBsItchingHarmless) ...[
            BsBlockView(block: b, p: p),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 12),

          // ---- 2 · HOW TO SOOTHE IT ---------------------------------------
          _H('How to soothe it', p),
          const SizedBox(height: 10),
          for (final b in kBsItchingSoothe) ...[
            BsBlockView(block: b, p: p),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 20),

          // ---- 3 · THE WARNING --------------------------------------------
          _WarningCard(
              p: p,
              onSeeDoctorInfo: onSeeDoctorInfo,
              pregnancy: pregnancy),
          const SizedBox(height: 20),
          _FootDisclaimer(p: p),
        ],
      ),
    );
  }
}

/// A section heading, in the section's own type scale.
class _H extends StatelessWidget {
  const _H(this.text, this.p);
  final String text;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Text(text,
      style: pvFraunces(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: -0.4,
          color: p.ink1));
}

class _WarningCard extends StatelessWidget {
  const _WarningCard(
      {required this.p, this.onSeeDoctorInfo, this.pregnancy});
  final V2Palette p;
  final VoidCallback? onSeeDoctorInfo;
  final PregnancyController? pregnancy;

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
        // ⚠️ TWO ACTIONS, NOT ONE, AND THEY ANSWER DIFFERENT QUESTIONS.
        //
        // Review asked for both: "Talk to your doctor." and "Learn about ICP".
        // A woman reading this card is in one of two states, and a single
        // button serves only one of them. If she has the symptom, she needs
        // the fastest route to a person and nothing else. If she is reading
        // ahead, or has been told the word and does not know what it means,
        // she needs the explanation - and giving her only "see your doctor"
        // sends her to Google, which on this particular condition returns
        // stillbirth statistics.
        //
        // ⚠️ THE DOCTOR ACTION IS FIRST AND FILLED; ICP IS SECOND AND QUIET.
        // Both matter, but only one of them is time-sensitive.
        HubPill(
          label: kBsItchingWarningCta.of(_lang),
          icon: Icons.medical_information_outlined,
          p: p,
          fullWidth: true,
          onTap: () => _seeDoctor(context),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _openIcp(context),
            style: TextButton.styleFrom(foregroundColor: accent),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text('Learn about ICP',
                style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: accent)),
          ),
        ),
      ]),
    );
  }

  /// Opens the Complications library's own ICP page.
  ///
  /// ⚠️ IT DEGRADES TO THE DOCTOR SHEET RATHER THAN TO A DEAD TAP. `mmm`
  /// lookups by id return null if the entry is ever renamed, and on this page
  /// a tap that does nothing is worse than on any other in the app: she has
  /// just read that her symptom might be a real complication. So a missing
  /// page falls through to the same "call your doctor today" sheet.
  void _openIcp(BuildContext context) {
    final c = pregnancy;
    final icp = kAllConditions.where((x) => x.id == 'icp_cholestasis');
    // No controller and no page are both "we cannot show the explainer", and
    // both fall through to the same place rather than to a dead tap.
    if (c == null || icp.isEmpty) {
      _seeDoctor(context);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'conditions/icp_cholestasis'),
      builder: (_) => ConditionDetailScreen(entry: icp.first, pregnancy: c),
    ));
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
