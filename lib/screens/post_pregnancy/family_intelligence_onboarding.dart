// =============================================================================
//  ParentVeda Intelligence — the setup flow (NOT an onboarding form)
// -----------------------------------------------------------------------------
//  One gentle card at a time (~90 seconds), every question with an obvious
//  benefit, everything skippable, a quiet progress bar. It writes to the Living
//  Family Profile ([FamilyProfileStore]) + child basics ([ChildProfileStore]).
//  It never changes the app; it just teaches the intelligence layer about the
//  family so content/recommendations/priority-ordering become relevant.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_family_profile.dart';

const List<String> _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

class FamilyIntelligenceOnboarding extends StatefulWidget {
  const FamilyIntelligenceOnboarding({super.key});

  @override
  State<FamilyIntelligenceOnboarding> createState() => _FamilyIntelligenceOnboardingState();
}

class _FamilyIntelligenceOnboardingState extends State<FamilyIntelligenceOnboarding> {
  final _p = FamilyProfileStore.instance;
  final _child = ChildProfileStore.instance;
  int _step = 0;

  // welcome · child · health · feeding · sleep · priorities · learning · notify · done
  static const _total = 9;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _next() => setState(() => _step = (_step + 1).clamp(0, _total - 1));

  void _finish() {
    _p.markOnboarded();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final isWelcome = _step == 0;
    final isDone = _step == _total - 1;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([_p, _child]),
          builder: (context, _) => Column(children: [
            // top bar + progress
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Row(children: [
                GestureDetector(
                  onTap: () => _step == 0 ? Navigator.of(context).maybePop() : setState(() => _step--),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 34, height: 34, alignment: Alignment.center,
                    decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                    child: Icon(_step == 0 ? Icons.close_rounded : Icons.arrow_back, size: 17, color: ppInk),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: (_step) / (_total - 1),
                      minHeight: 6,
                      backgroundColor: ppPanel,
                      valueColor: const AlwaysStoppedAnimation(ppPurple),
                    ),
                  ),
                ),
                if (!isWelcome && !isDone) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _next,
                    behavior: HitTestBehavior.opaque,
                    child: Text('Skip', style: ppBody(13, color: ppMuted, w: FontWeight.w700)),
                  ),
                ],
              ]),
            ),
            Expanded(child: SingleChildScrollView(padding: const EdgeInsets.only(top: 8, bottom: 16), child: _stepBody())),
            _footer(isWelcome, isDone),
          ]),
        ),
      ),
    );
  }

  Widget _footer(bool isWelcome, bool isDone) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 6, 24, 18),
        child: GestureDetector(
          onTap: isDone ? _finish : _next,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16), boxShadow: ppCardShadow),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                isWelcome ? "Let's begin" : (isDone ? 'Finish' : 'Continue'),
                style: ppBody(15.5, color: Colors.white, w: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              const Text('→', style: TextStyle(color: Colors.white)),
            ]),
          ),
        ),
      );

  // ---- step content -------------------------------------------------------
  Widget _stepBody() {
    switch (_step) {
      case 0:
        return _welcome();
      case 1:
        return _child1();
      case 2:
        return _health();
      case 3:
        return _feeding();
      case 4:
        return _sleep();
      case 5:
        return _priorities();
      case 6:
        return _learning();
      case 7:
        return _notify();
      default:
        return _done();
    }
  }

  Widget _head(String eyebrow, String title, String why) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _pad(ppEyebrow(eyebrow, color: ppPurple)),
        const SizedBox(height: 10),
        _pad(Text(title, style: ppFraunces(27, h: 1.15))),
        const SizedBox(height: 10),
        _pad(Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.auto_awesome_outlined, size: 15, color: ppPurple),
            const SizedBox(width: 9),
            Expanded(child: Text(why, style: ppBody(12.5, color: ppInk, h: 1.5))),
          ]),
        )),
        const SizedBox(height: 22),
      ]);

  Widget _welcome() => Padding(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 66, height: 66, alignment: Alignment.center,
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.auto_awesome_rounded, size: 30, color: ppPurple),
          ),
          const SizedBox(height: 22),
          ppEyebrow('ParentVeda Intelligence', color: ppPurple),
          const SizedBox(height: 10),
          Text('Let\'s make ParentVeda\nyours.', style: ppFraunces(32, h: 1.15)),
          const SizedBox(height: 14),
          Text('A few quick taps — around 90 seconds — help us show the right articles, videos, recipes, activities and guidance for your family. The more we know, the more useful ParentVeda becomes.',
              style: ppBody(14.5, h: 1.6)),
          const SizedBox(height: 16),
          Text('Skip anything you like. Nothing is ever required.', style: ppBody(12.5, color: ppMuted)),
        ]),
      );

  Widget _child1() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _head('About your child', 'The basics on ${_child.name}', 'We use this to personalise development, growth and age-specific guidance.'),
      _pad(_label('Date of birth')),
      _pad(GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _child.dob,
            firstDate: DateTime(2018),
            lastDate: DateTime.now(),
          );
          if (picked != null) _child.update(dob: picked);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: ppPurple),
            const SizedBox(width: 10),
            Flexible(child: Text('${_child.dob.day} ${_months[_child.dob.month - 1]} ${_child.dob.year}', style: ppBody(14.5, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Text(_child.ageLabel, style: ppBody(12.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      )),
      _pad(_label('Sex (optional)')),
      _pad(Row(children: [
        _single('Boy', _child.isBoy, () => _child.update(isBoy: true)),
        const SizedBox(width: 8),
        _single('Girl', !_child.isBoy, () => _child.update(isBoy: false)),
      ])),
      const SizedBox(height: 16),
      _pad(_label('Anything from the birth? (optional)')),
      _pad(Wrap(spacing: 8, runSpacing: 8, children: [
        _toggle('Premature', _p.premature, () => _p.setBirth(premature: !_p.premature)),
        _toggle('NICU stay', _p.nicu, () => _p.setBirth(nicu: !_p.nicu)),
        _toggle('Twins / multiple', _p.multiple, () => _p.setBirth(multiple: !_p.multiple)),
      ])),
    ]);
  }

  Widget _health() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _head('Child health', 'Has your doctor mentioned any of these?',
            'This quietly tailors articles, products, recipes, videos and Ask Veda — so you see what fits ${_child.name}, not generic advice.'),
        _pad(Wrap(spacing: 8, runSpacing: 8, children: [
          for (final c in HealthCondition.values)
            _toggle(c.label, _p.hasCondition(c), () {
              _p.toggleCondition(c);
              _p.markAsked(ProfileField.health);
            }),
          _toggle('None', _p.conditions.isEmpty, () {
            _p.clearConditions();
            _p.markAsked(ProfileField.health);
          }),
        ])),
      ]);

  Widget _feeding() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _head('Feeding', 'How is ${_child.name} fed right now?',
            'Personalises the feeding tracker, recipes, articles and product suggestions.'),
        _pad(Wrap(spacing: 8, runSpacing: 8, children: [
          for (final f in FeedingMethod.values)
            _toggle(f.label, _p.feeding == f, () => _p.setFeeding(_p.feeding == f ? null : f)),
        ])),
      ]);

  Widget _sleep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _head('Sleep', "How would you describe ${_child.name}'s sleep?",
            'Shapes the sleep tracker, home, articles, videos and Ask Veda.'),
        _pad(Column(children: [
          for (final s in SleepPattern.values) ...[
            _wideChoice(s.label, _p.sleep == s, () => _p.setSleep(_p.sleep == s ? null : s)),
            const SizedBox(height: 8),
          ],
        ])),
      ]);

  Widget _priorities() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _head('Your priorities', 'What would you most like help with?',
            'Pick as many as you like. This is what quietly moves the most relevant guidance to the top for you.'),
        _pad(Wrap(spacing: 8, runSpacing: 8, children: [
          for (final p in Priority.values) _toggle(p.label, _p.wants(p), () => _p.togglePriority(p)),
        ])),
      ]);

  Widget _learning() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _head('How you like to learn', 'What suits you best?',
            'We\'ll match articles, Ask Veda, videos and the daily journey to your style.'),
        _pad(Column(children: [
          for (final l in LearningStyle.values) ...[
            _wideChoice(l.label, _p.learning == l, () => _p.setLearning(_p.learning == l ? null : l)),
            const SizedBox(height: 8),
          ],
        ])),
      ]);

  Widget _notify() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _head('Gentle reminders', 'What would you like nudges about?',
            'Entirely optional — only what you choose, never noise.'),
        _pad(Wrap(spacing: 8, runSpacing: 8, children: [
          for (final n in NotifyTopic.values) _toggle(n.label, _p.notify.contains(n), () => _p.toggleNotify(n)),
        ])),
      ]);

  Widget _done() => Padding(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 66, height: 66, alignment: Alignment.center,
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.check_rounded, size: 32, color: ppPurple),
          ),
          const SizedBox(height: 22),
          ppEyebrow('All set', color: ppPurple),
          const SizedBox(height: 10),
          Text('That was quick — and ParentVeda is already smarter.', style: ppFraunces(28, h: 1.2)),
          const SizedBox(height: 14),
          Text('Your recommendations, articles, recipes and daily focus will now fit ${_child.name}. The more you use ParentVeda — trackers, journal, Ask Veda — the more personal it becomes. You can edit anything any time in My Family Profile.',
              style: ppBody(14.5, h: 1.6)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.auto_awesome_rounded, size: 16, color: ppPurple),
              const SizedBox(width: 10),
              Expanded(child: Text('Profile ${_p.completenessPercent}% complete — it grows as you go.', style: ppBody(13, color: ppInk, w: FontWeight.w600))),
            ]),
          ),
        ]),
      );

  // ---- small parts --------------------------------------------------------
  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: ppBody(12, color: ppSoft, w: FontWeight.w700)),
      );

  Widget _single(String label, bool on, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? ppPurple : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: on ? ppPurple : ppLine),
            ),
            child: Text(label, style: ppBody(14, color: on ? Colors.white : ppInk, w: FontWeight.w700)),
          ),
        ),
      );

  Widget _toggle(String label, bool on, VoidCallback onTap) => GestureDetector(
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

  Widget _wideChoice(String label, bool on, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: on ? const Color(0xFFF6F0FA) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: on ? ppPurple : ppLine, width: on ? 2 : 1),
          ),
          child: Row(children: [
            Container(
              width: 22, height: 22, alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: on ? ppPurple : Colors.transparent, border: Border.all(color: on ? ppPurple : const Color(0xFFD8C8EA), width: 2)),
              child: on ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
            const SizedBox(width: 13),
            Expanded(child: Text(label, style: ppBody(14.5, color: ppInk, w: on ? FontWeight.w700 : FontWeight.w400))),
          ]),
        ),
      );
}
