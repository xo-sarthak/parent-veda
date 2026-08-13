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

import '../services/family_profile.dart';
import '../services/profile_analytics.dart';
import '../theme/app_theme.dart';
import '../theme/pv_fonts.dart';
import '../localization/app_language.dart';

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
        title: Text(S.now.uiPersonaliseParentveda),
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
                style: pvJakarta(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary900)),
          ]),
          const SizedBox(height: 10),
          Text(
            S.now.uiNothingHereRequiredCan,
            style: pvManrope(
                fontSize: 13.5, height: 1.5, color: AppTheme.neutral500),
          ),
        ]),
      );

  Widget _footer() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          S.now.uiAnswersStayDeviceOwn,
          style: pvManrope(
              fontSize: 12, height: 1.5, color: AppTheme.neutral500),
        ),
      );

  // ---- sections -------------------------------------------------------------

  //  This screen reads `S.now` / `.now` rather than taking a language, which is
  //  how it was already written throughout: it is pushed from Profile, has no
  //  controller in scope, and the toggle that could change the language lives
  //  on the screen underneath it. Threading a language in would be a good
  //  change and a separate one; mixing two conventions inside one file to make
  //  half of it right is worse than either convention applied consistently.
  Widget _parity() => _card(
        S.now.askParityQ,
        S.now.askParityWhy,
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final v in Parity.values)
            _chip(v.label.now, _p.parity == v,
                () => _p.setParity(_p.parity == v ? null : v)),
        ]),
      );

  Widget _conditions() => _card(
        S.now.askHealthQLong,
        S.now.askHealthWhyLong,
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final c in PregCondition.values)
            _chip(c.label.now, _p.hasPregCondition(c),
                () => _p.togglePregCondition(c)),
        ]),
      );

  Widget _priorities() => _card(
        S.now.askPrioritiesQ,
        S.now.askPrioritiesWhyLong,
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final p in PregPriority.values)
            _chip(p.label.now, _p.wantsPreg(p), () => _p.togglePregPriority(p)),
        ]),
      );

  Widget _diet() => _card(
        S.now.askDietQ,
        S.now.askDietWhyLong,
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final d in DietPreference.values)
            _chip(d.label.now, _p.diet == d,
                () => _p.setDiet(_p.diet == d ? null : d)),
        ]),
      );

  // DEBT, stated rather than hidden: this card is still English on both sides.
  // LearningStyle is journey-agnostic - the parenting profile screen renders
  // the same five chips - so translating it would put Devanagari into the
  // parenting stage, which CLAUDE.md keeps deliberately unmigrated. It joins
  // the others when parenting does. Leaving the whole card English is the
  // lesser of the two evils: a Hindi question above English chips reads like a
  // rendering failure, whereas a coherent English card reads like a gap.
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
              style: pvJakarta(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary900)),
          const SizedBox(height: 6),
          // Every question says what it unlocks. A question that cannot explain
          // its own payoff should not be asked at all.
          Text(why,
              style: pvManrope(
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
                  style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: on ? Colors.white : AppTheme.primary900)),
            ]),
          ),
        ),
      );
}
