// =============================================================================
//  ProfileAskStrip — progressive profiling, one quiet question at a time
// -----------------------------------------------------------------------------
//  The Living Family Profile is meant to GROW, not to be filled in on day one.
//  This is how: a single, dismissible strip that appears inside a screen where
//  its question is obviously relevant, and never again after that.
//
//  THE RULES (docs/PERSONALIZATION.md §9):
//   1. INLINE, never modal. It sits in the page like any other card. It must
//      never block, cover, or interrupt what she came here to do.
//   2. ONCE. shouldAsk() returns false forever after markAsked(), whether she
//      answered or dismissed. We do not nag.
//   3. IT STATES ITS PAYOFF. Every strip says what answering unlocks. A question
//      that cannot explain why it is being asked should not be asked.
//   4. ONE TAP. Chips only. Nothing to type, nothing to submit.
//   5. IT IS SKIPPABLE, visibly. "Not now" is always right there.
//
//  Dismissing marks the field asked, so this is genuinely a one-shot per field
//  across the whole app - not once per screen.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/family_profile.dart';
import '../services/profile_analytics.dart';
import '../theme/app_theme.dart';

/// What a strip offers, for one profile field.
class AskOption {
  const AskOption(this.label, this.onPick);
  final String label;

  /// Applies the answer to the store. The strip handles markAsked itself.
  final VoidCallback onPick;
}

class ProfileAskStrip extends StatefulWidget {
  const ProfileAskStrip({
    super.key,
    required this.field,
    required this.question,
    required this.payoff,
    required this.options,
    required this.surface,
    this.icon = Icons.auto_awesome_rounded,
    this.multi = false,
  });

  /// Which profile field this asks about. Also the once-only key.
  final ProfileField field;

  /// The question, in her language, short.
  final String question;

  /// What answering unlocks. Never omitted.
  final String payoff;

  final List<AskOption> options;

  /// WHERE this strip is being shown ('symptom_companion', 'tools_hub', ...).
  /// The same question can succeed in one place and fail in another, so without
  /// this an analytics run cannot tell a bad question from a bad placement.
  final String surface;

  final IconData icon;

  /// When true the strip stays open after a pick so she can choose several,
  /// and closes on "Done". Single-select strips close on the first tap.
  final bool multi;

  @override
  State<ProfileAskStrip> createState() => _ProfileAskStripState();
}

class _ProfileAskStripState extends State<ProfileAskStrip> {
  final _p = FamilyProfileStore.instance;

  /// Latched at build time. Without this the strip would vanish mid-animation
  /// the instant she taps a chip, which reads as the app snatching it away.
  bool? _show;
  bool _picked = false;

  /// True once she has acted on it either way, so dispose knows the difference
  /// between "left without touching it" and "dealt with it".
  bool _acted = false;

  void _close() {
    _acted = true;
    ProfileAnalytics.instance
        .stripDismissed(widget.field.name, widget.surface, afterPicking: _picked);
    _p.markAsked(widget.field);
    if (mounted) setState(() => _show = false);
  }

  @override
  void dispose() {
    // She saw it and left without answering or dismissing. Previously this was
    // indistinguishable from the strip never appearing at all - and it is the
    // most useful signal we have that a question was not worth her time.
    if (_show == true && !_acted) {
      ProfileAnalytics.instance
          .stripAbandoned(widget.field.name, widget.surface);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_show == null) {
      _show = _p.shouldAsk(widget.field);
      // The honest denominator: only count a strip we actually rendered.
      if (_show == true) {
        ProfileAnalytics.instance
            .stripShown(widget.field.name, widget.surface);
      }
    }
    if (_show != true) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _p,
      builder: (context, _) => Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: AppTheme.primary50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.primary100),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(widget.icon, size: 18, color: AppTheme.primary600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(widget.question,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary900)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(widget.payoff,
              style: GoogleFonts.manrope(
                  fontSize: 12.5, height: 1.45, color: AppTheme.neutral600)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final o in widget.options)
              _chip(o.label, () {
                o.onPick();
                _acted = true;
                ProfileAnalytics.instance
                    .stripAnswered(widget.field.name, widget.surface, o.label);
                if (widget.multi) {
                  setState(() => _picked = true);
                } else {
                  _close();
                }
              }),
          ]),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _close,
              child: Text(
                // Once she has picked something in a multi-select, "Not now"
                // would be the wrong word for what the button does.
                _picked ? 'Done' : 'Not now',
                style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.neutral500),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _chip(String label, VoidCallback onTap) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppTheme.primary100),
            ),
            child: Text(label,
                style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary700)),
          ),
        ),
      );
}

// ---- the five pregnancy strips ---------------------------------------------
//  Defined once, here, so a screen wires in a single widget and the wording
//  stays consistent wherever a field is asked about.

/// Conditions — for the symptom / weight / reports screens.
ProfileAskStrip pregHealthStrip(String surface) => ProfileAskStrip(
      surface: surface,
      field: ProfileField.pregHealth,
      question: 'Has your doctor mentioned anything to watch?',
      payoff:
          'We use this to pick reads, foods and answers that fit you - and to skip the ones that do not.',
      icon: Icons.medical_information_outlined,
      multi: true,
      options: [
        for (final c in PregCondition.values)
          AskOption(c.label,
              () => FamilyProfileStore.instance.togglePregCondition(c)),
      ],
    );

/// Priorities — for the Tools hub, which is what the ordering feeds.
ProfileAskStrip pregPrioritiesStrip(String surface) => ProfileAskStrip(
      surface: surface,
      field: ProfileField.pregPriorities,
      question: 'What would you most like help with?',
      payoff: 'The tools you pick move to the top of this page.',
      icon: Icons.tune_rounded,
      multi: true,
      options: [
        for (final p in PregPriority.values)
          AskOption(
              p.label, () => FamilyProfileStore.instance.togglePregPriority(p)),
      ],
    );

/// Diet — for food and nutrition surfaces.
ProfileAskStrip dietStrip(String surface) => ProfileAskStrip(
      surface: surface,
      field: ProfileField.diet,
      question: 'How do you eat?',
      payoff:
          'So the meals and foods we suggest are ones you would actually eat.',
      icon: Icons.restaurant_outlined,
      options: [
        for (final d in DietPreference.values)
          AskOption(d.label, () => FamilyProfileStore.instance.setDiet(d)),
      ],
    );
