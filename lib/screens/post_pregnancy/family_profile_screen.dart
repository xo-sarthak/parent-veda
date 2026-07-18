// =============================================================================
//  My Family Profile — the Living Family Profile, editable
// -----------------------------------------------------------------------------
//  The settings home for the ParentVeda Personalization Engine. Everything is
//  editable, nothing hidden; a completeness meter invites (never forces) the
//  profile to grow. Tapping a chip writes straight to [FamilyProfileStore], so
//  content/recommendations/priority-ordering update everywhere at once. It
//  changes WHAT the app shows, never WHERE anything lives.
// =============================================================================

import 'package:flutter/material.dart';

import 'family_intelligence_onboarding.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import '../../services/family_profile.dart';

class FamilyProfileScreen extends StatelessWidget {
  const FamilyProfileScreen({super.key});

  FamilyProfileStore get _p => FamilyProfileStore.instance;
  ChildProfileStore get _child => ChildProfileStore.instance;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    // Ensure the store is loaded when reached directly.
    _p.init();
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: Listenable.merge([_p, _child]),
          builder: (context, _) => ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 44),
            children: [
              _pad(Row(children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 34, height: 34, alignment: Alignment.center,
                    decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, size: 16, color: ppInk),
                  ),
                ),
                Expanded(child: Center(child: ppEyebrow('ParentVeda Intelligence', color: ppMuted, spacing: 1.4))),
                const SizedBox(width: 34),
              ])),
              const SizedBox(height: 20),
              _pad(Text('My Family Profile', style: ppFraunces(30, h: 1.1))),
              const SizedBox(height: 8),
              _pad(Text('The more ${_child.name} and your family are known, the more ParentVeda quietly tailors what you see — articles, videos, recipes, products and your daily focus. It never changes where things live.',
                  style: ppBody(14, h: 1.55))),
              const SizedBox(height: 18),
              _pad(_meter(context)),

              const SizedBox(height: 26),
              _section('Health', "Anything your doctor has mentioned about ${_child.name}."),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                for (final c in HealthCondition.values)
                  _chip(c.label, _p.hasCondition(c), () { _p.toggleCondition(c); _p.markAsked(ProfileField.health); }),
              ])),

              const SizedBox(height: 24),
              _section('Feeding', 'How ${_child.name} is fed right now.'),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                for (final f in FeedingMethod.values)
                  _chip(f.label, _p.feeding == f, () => _p.setFeeding(_p.feeding == f ? null : f)),
              ])),

              const SizedBox(height: 24),
              _section('Sleep', "How ${_child.name}'s sleep is going."),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                for (final s in SleepPattern.values)
                  _chip(s.label, _p.sleep == s, () => _p.setSleep(_p.sleep == s ? null : s)),
              ])),

              const SizedBox(height: 24),
              _section('What you want help with', 'This gently surfaces the most relevant guidance first.'),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                for (final pr in Priority.values) _chip(pr.label, _p.wants(pr), () => _p.togglePriority(pr)),
              ])),

              const SizedBox(height: 24),
              _section('How you like to learn', 'We match articles, videos and Ask Veda to your style.'),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                for (final l in LearningStyle.values)
                  _chip(l.label, _p.learning == l, () => _p.setLearning(_p.learning == l ? null : l)),
              ])),

              const SizedBox(height: 24),
              _section('Gentle reminders', 'Only what you choose — never noise.'),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                for (final n in NotifyTopic.values) _chip(n.label, _p.notify.contains(n), () => _p.toggleNotify(n)),
              ])),

              const SizedBox(height: 28),
              _pad(Text('Your profile keeps growing as you use trackers, the journal and Ask Veda — no need to fill everything now.',
                  textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meter(BuildContext context) {
    final pct = _p.completenessPercent;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF3ECFA), Color(0xFFFDF3F5)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ppBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_awesome_rounded, size: 18, color: ppPurple),
          const SizedBox(width: 8),
          Expanded(child: Text('$pct% personalised', style: ppJakarta(16), maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          if (!_p.onboarded)
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const FamilyIntelligenceOnboarding())),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(999)),
                child: Text(pct == 0 ? 'Start setup' : 'Continue', style: ppBody(12.5, color: Colors.white, w: FontWeight.w700)),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(value: pct / 100, minHeight: 7, backgroundColor: Colors.white, valueColor: const AlwaysStoppedAnimation(ppPurple)),
        ),
      ]),
    );
  }

  Widget _section(String title, String sub) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: ppJakarta(16)),
          const SizedBox(height: 3),
          Text(sub, style: ppBody(12.5, color: ppMuted, h: 1.4)),
          const SizedBox(height: 12),
        ]),
      );

  Widget _chip(String label, bool on, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: on ? ppPurple : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: on ? ppPurple : ppLine),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (on) ...[const Icon(Icons.check_rounded, size: 14, color: Colors.white), const SizedBox(width: 6)],
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(label, style: ppBody(13, color: on ? Colors.white : ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ]),
        ),
      );
}
