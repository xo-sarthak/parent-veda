// =============================================================================
//  PregnancyProfileScreen — the pregnancy door into the Living Family Profile
// -----------------------------------------------------------------------------
//  The parenting app has had a profile screen for a while; this is the same
//  engine asked in the pregnancy vocabulary. One brain, two doors: a mother who
//  tells us she is vegetarian here is never asked again once the baby arrives.
//
//  It is NOT an onboarding form. Nothing is required, nothing blocks, and every
//  question says what it unlocks — because a question with no visible payoff is
//  exactly the data-collection this engine was written to avoid.
//
//  GUARDRAIL: what she says here changes CONTENT, RECOMMENDATIONS and ORDERING
//  only. It never changes navigation, section names or where anything lives.
//  See docs/PERSONALIZATION.md.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/family_profile.dart';
import '../services/profile_analytics.dart';
import '../theme/app_theme.dart';

class PregnancyProfileScreen extends StatefulWidget {
  const PregnancyProfileScreen({super.key});

  @override
  State<PregnancyProfileScreen> createState() => _PregnancyProfileScreenState();
}

class _PregnancyProfileScreenState extends State<PregnancyProfileScreen> {
  final _p = FamilyProfileStore.instance;

  @override
  void initState() {
    super.initState();
    // Without this the data could only ever see the little ask strips - a
    // mother filling in six fields here would look like nothing happened.
    ProfileAnalytics.instance.profileOpened(_p.completenessPercent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        elevation: 0,
        title: const Text('Personalise ParentVeda'),
      ),
      body: AnimatedBuilder(
        animation: _p,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            _intro(),
            const SizedBox(height: 20),
            _parity(),
            const SizedBox(height: 16),
            _conditions(),
            const SizedBox(height: 16),
            _priorities(),
            const SizedBox(height: 16),
            _diet(),
            const SizedBox(height: 16),
            _learning(),
            const SizedBox(height: 20),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _intro() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome_rounded,
                size: 20, color: AppTheme.primary600),
            const SizedBox(width: 8),
            Text('${_p.completenessPercent}% complete',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary900)),
          ]),
          const SizedBox(height: 10),
          Text(
            'Nothing here is required, and you can change any of it later. Every answer just helps ParentVeda put the right things in front of you first - it never hides anything or moves things around.',
            style: GoogleFonts.manrope(
                fontSize: 13.5, height: 1.5, color: AppTheme.neutral500),
          ),
        ]),
      );

  Widget _footer() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          'Your answers stay on your device and in your own ParentVeda account. They are used to choose what to show you - never to decide which features you get.',
          style: GoogleFonts.manrope(
              fontSize: 12, height: 1.5, color: AppTheme.neutral500),
        ),
      );

  // ---- sections -------------------------------------------------------------

  Widget _parity() => _card(
        'Is this your first baby?',
        'Changes how much we explain, and what we compare things to.',
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final v in Parity.values)
            _chip(v.label, _p.parity == v,
                () => _p.setParity(_p.parity == v ? null : v)),
        ]),
      );

  Widget _conditions() => _card(
        'Has your doctor mentioned any of these?',
        'We use these to pick articles, foods and answers that fit you. Tap any that apply.',
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final c in PregCondition.values)
            _chip(c.label, _p.hasPregCondition(c),
                () => _p.togglePregCondition(c)),
        ]),
      );

  Widget _priorities() => _card(
        'What would you most like help with?',
        'Pick as many as you like. These float to the top of your tools and reads.',
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final p in PregPriority.values)
            _chip(p.label, _p.wantsPreg(p), () => _p.togglePregPriority(p)),
        ]),
      );

  Widget _diet() => _card(
        'How do you eat?',
        'Shapes recipes and food suggestions, now and after the baby arrives.',
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final d in DietPreference.values)
            _chip(d.label, _p.diet == d,
                () => _p.setDiet(_p.diet == d ? null : d)),
        ]),
      );

  Widget _learning() => _card(
        'How do you prefer to learn?',
        'Some mothers want the science, some want the short version.',
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final l in LearningStyle.values)
            _chip(l.label, _p.learning == l,
                () => _p.setLearning(_p.learning == l ? null : l)),
        ]),
      );

  // ---- pieces ---------------------------------------------------------------

  Widget _card(String title, String why, Widget body) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary900)),
          const SizedBox(height: 6),
          // Every question says what it unlocks. A question that cannot explain
          // its own payoff should not be asked at all.
          Text(why,
              style: GoogleFonts.manrope(
                  fontSize: 12.5, height: 1.45, color: AppTheme.neutral500)),
          const SizedBox(height: 14),
          body,
        ]),
      );

  Widget _chip(String label, bool on, VoidCallback onTap) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: on ? AppTheme.primary600 : AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: on ? AppTheme.primary600 : AppTheme.outlineVariant),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (on) ...[
                const Icon(Icons.check_rounded, size: 15, color: Colors.white),
                const SizedBox(width: 5),
              ],
              Text(label,
                  style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: on ? Colors.white : AppTheme.primary900)),
            ]),
          ),
        ),
      );
}
