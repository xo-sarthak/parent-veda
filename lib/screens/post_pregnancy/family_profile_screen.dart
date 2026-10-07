// =============================================================================
//  Aarav's profile — the Living Family Profile, editable
// -----------------------------------------------------------------------------
//  The settings home for the ParentVeda Personalization Engine. Everything is
//  editable, nothing hidden; a completeness meter invites (never forces) the
//  profile to grow. Tapping a chip writes straight to [FamilyProfileStore], so
//  content/recommendations/priority-ordering update everywhere at once. It
//  changes WHAT the app shows, never WHERE anything lives.
//
//  ON THE ONE PARENTVEDA LOOK (2026-10-07). This page is reached from You
//  (the child's page, `pv_child_screen.dart`) as well as from parenting, so it
//  now wears You's chrome rather than parenting's old purple one: the
//  `PvYouTopBar` (round back, small eyebrow, serif title), the profile's
//  18 gutter, grey capitalised group headings (`PvProfileGroup`'s heading),
//  white hairline cards and the hairline `PvChip` that fills with ink when
//  chosen. Same store, same chips, same "Other" dialog, same onboarding push.
//  The purple build is kept below as `_buildBeforeShell` for revert.
//
//  Mobbin: Etsy's "What are you looking to shop for?" — chips in headed
//  groups, one serif heading per group, chosen chips filled
//  https://mobbin.com/screens/5f858c10-57a0-4920-993c-b7de045becd6
//  Taken: headed chip groups on the page, no boxes around them. Not taken: the
//  onboarding progress bar on top (this is a settings page; the completeness
//  meter stays a card, as before).
// =============================================================================

import 'package:flutter/material.dart';

import 'family_intelligence_onboarding.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import '../../services/family_profile.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../profile/pv_you_chrome.dart'
    show PvYouTopBar, PvChip, kPvProfileGutter, kPvProfileGroupGap;
import '../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;

class FamilyProfileScreen extends StatelessWidget {
  const FamilyProfileScreen({super.key});

  FamilyProfileStore get _p => FamilyProfileStore.instance;
  ChildProfileStore get _child => ChildProfileStore.instance;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  // ---- the one-ParentVeda build (2026-10-07) --------------------------------

  Widget _g(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: kPvProfileGutter), child: c);

  @override
  Widget build(BuildContext context) {
    // Ensure the store is loaded when reached directly.
    _p.init();
    final p = pvStorePalette;
    return Scaffold(
      backgroundColor: p.ground,
      body: AnimatedBuilder(
        animation: Listenable.merge([_p, _child]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.only(bottom: kAskFabReserve),
          children: [
            PvYouTopBar(eyebrow: 'Personalize ParentVeda', title: "${_child.name}'s profile"),
            const SizedBox(height: 8),
            _g(Text(
                'The more ${_child.nameMid} and your family are known, the more ParentVeda quietly tailors what you see — articles, videos, recipes, products and your daily focus. It never changes where things live.',
                style: pvManrope(fontSize: 13.5, height: 1.6, color: p.ink2))),
            const SizedBox(height: 18),
            _g(_meterV2(context)),
            _groupV2('Health', "Anything your doctor has mentioned about ${_child.nameMid}.", [
              for (final c in HealthCondition.values)
                _chipV2(c.label, _p.hasCondition(c), () { _p.toggleCondition(c); _p.markAsked(ProfileField.health); }),
              _otherChipV2(context, 'health'),
            ]),
            _groupV2('Feeding', 'How ${_child.nameMid} is fed right now.', [
              for (final f in FeedingMethod.values)
                _chipV2(f.label, _p.feedings.contains(f), () => _p.toggleFeeding(f)),
              _otherChipV2(context, 'feeding'),
            ]),
            _groupV2('Sleep', "How ${_child.nameMid}'s sleep is going.", [
              for (final s in SleepPattern.values)
                _chipV2(s.label, _p.sleeps.contains(s), () => _p.toggleSleep(s)),
              _otherChipV2(context, 'sleep'),
            ]),
            _groupV2('What you want help with', 'This gently surfaces the most relevant guidance first.', [
              for (final pr in Priority.values) _chipV2(pr.label, _p.wants(pr), () => _p.togglePriority(pr)),
              _otherChipV2(context, 'priorities'),
            ]),
            _groupV2('How you like to learn', 'We match articles, videos and Ask Veda to your style.', [
              for (final l in LearningStyle.values)
                _chipV2(l.label, _p.learnings.contains(l), () => _p.toggleLearning(l)),
              _otherChipV2(context, 'learning'),
            ]),
            _groupV2('Gentle reminders', 'Only what you choose — never noise.', [
              for (final n in NotifyTopic.values) _chipV2(n.label, _p.notify.contains(n), () => _p.toggleNotify(n)),
              _otherChipV2(context, 'notify'),
            ]),
            const SizedBox(height: kPvProfileGroupGap),
            _g(Text('Your profile keeps growing as you use trackers, the journal and Ask Veda — no need to fill everything now.',
                textAlign: TextAlign.center, style: pvManrope(fontSize: 12, height: 1.55, color: p.ink3))),
          ],
        ),
      ),
    );
  }

  /// The completeness meter: white, one hairline, an ink fill on a grey track.
  Widget _meterV2(BuildContext context) {
    final p = pvStorePalette;
    final pct = _p.completenessPercent;
    return Container(
      key: const ValueKey('family_profile_meter'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kPvLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('$pct% personalised',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
          ),
          const SizedBox(width: 8),
          if (!_p.onboarded)
            InkWell(
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (_) => const FamilyIntelligenceOnboarding())),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(color: kPvInk, borderRadius: BorderRadius.circular(999)),
                child: Text(pct == 0 ? 'Start setup' : 'Continue',
                    style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          // The track is a recessed grey, the fill ink: empty reads empty.
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 6,
            backgroundColor: p.line,
            valueColor: const AlwaysStoppedAnimation(kPvInk),
          ),
        ),
      ]),
    );
  }

  /// A group: the profile's grey capitalised heading, one quiet line, chips.
  Widget _groupV2(String title, String lead, List<Widget> chips) {
    final p = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(kPvProfileGutter, kPvProfileGroupGap, kPvProfileGutter, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Semantics(
          header: true,
          child: Text(title.toUpperCase(),
              style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: p.ink2)),
        ),
        const SizedBox(height: 4),
        Text(lead, style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ]),
    );
  }

  Widget _chipV2(String label, bool on, VoidCallback onTap) => PvChip(
        label: label,
        selected: on,
        onTap: onTap,
        leading: on ? Icons.check_rounded : null,
      );

  Widget _otherChipV2(BuildContext context, String field) {
    final existing = _p.otherFor(field);
    final has = existing != null && existing.isNotEmpty;
    return _chipV2(has ? existing : 'Other…', has, () => _askOther(context, field, existing));
  }

  // ---- the purple build, before the one-ParentVeda look ---------------------
  // Kept for revert (2026-10-07).
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
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
              // Renamed: everything below is about the CHILD, so calling it a family
              // profile set the wrong expectation about what was being asked.
              _pad(Text("${_child.name}'s profile", style: ppFraunces(30, h: 1.1))),
              const SizedBox(height: 8),
              _pad(Text('The more ${_child.nameMid} and your family are known, the more ParentVeda quietly tailors what you see — articles, videos, recipes, products and your daily focus. It never changes where things live.',
                  style: ppBody(14, h: 1.55))),
              const SizedBox(height: 18),
              _pad(_meter(context)),

              const SizedBox(height: 26),
              _section('Health', "Anything your doctor has mentioned about ${_child.nameMid}."),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                for (final c in HealthCondition.values)
                  _chip(c.label, _p.hasCondition(c), () { _p.toggleCondition(c); _p.markAsked(ProfileField.health); }),
                _otherChip(context, 'health'),
              ])),

              const SizedBox(height: 24),
              _section('Feeding', 'How ${_child.nameMid} is fed right now.'),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                for (final f in FeedingMethod.values)
                  _chip(f.label, _p.feedings.contains(f), () => _p.toggleFeeding(f)),
                _otherChip(context, 'feeding'),
              ])),

              const SizedBox(height: 24),
              _section('Sleep', "How ${_child.nameMid}'s sleep is going."),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                for (final s in SleepPattern.values)
                  _chip(s.label, _p.sleeps.contains(s), () => _p.toggleSleep(s)),
                _otherChip(context, 'sleep'),
              ])),

              const SizedBox(height: 24),
              _section('What you want help with', 'This gently surfaces the most relevant guidance first.'),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                for (final pr in Priority.values) _chip(pr.label, _p.wants(pr), () => _p.togglePriority(pr)),
                _otherChip(context, 'priorities'),
              ])),

              const SizedBox(height: 24),
              _section('How you like to learn', 'We match articles, videos and Ask Veda to your style.'),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                for (final l in LearningStyle.values)
                  _chip(l.label, _p.learnings.contains(l), () => _p.toggleLearning(l)),
                _otherChip(context, 'learning'),
              ])),

              const SizedBox(height: 24),
              _section('Gentle reminders', 'Only what you choose — never noise.'),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                for (final n in NotifyTopic.values) _chip(n.label, _p.notify.contains(n), () => _p.toggleNotify(n)),
                _otherChip(context, 'notify'),
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
          // The TRACK has to look emptier than the FILL, and white did the
          // opposite: on this soft pink card a white bar reads as a solid bar,
          // so "0% personalised" arrived under what looked like a full one.
          // A tinted track is recessed at 0% and still clearly behind the
          // purple fill at 100%.
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 7,
            backgroundColor: ppPurple.withValues(alpha: 0.14),
            valueColor: const AlwaysStoppedAnimation(ppPurple),
          ),
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

  /// "Other", with somewhere to actually type it. No option list ever covers a
  /// real family, and a profile that cannot accept "none of these" quietly
  /// teaches a parent the app is not listening. Shows what she wrote once set.
  Widget _otherChip(BuildContext context, String field) {
    final existing = _p.otherFor(field);
    final has = existing != null && existing.isNotEmpty;
    return _chip(has ? existing : 'Other…', has, () => _askOther(context, field, existing));
  }

  Future<void> _askOther(BuildContext context, String field, String? existing) async {
    final ctl = TextEditingController(text: existing ?? '');
    final saved = await showDialog<String>(
      context: context,
      // The one-ParentVeda look (2026-10-07): the store palette's ground,
      // Manrope, ink for Save instead of purple. Same three answers.
      // Kept for revert: backgroundColor ppBg, ppJakarta title, ppPurple Save.
      builder: (ctx) => AlertDialog(
        backgroundColor: pvStorePalette.ground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Tell us in your words',
            style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: pvStorePalette.ink1)),
        content: TextField(
          controller: ctl,
          autofocus: true,
          maxLines: 2,
          style: pvManrope(fontSize: 14, color: pvStorePalette.ink1),
          decoration: InputDecoration(
            hintText: 'Anything the options above missed',
            hintStyle: pvManrope(fontSize: 14, color: pvStorePalette.ink3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          if (existing != null && existing.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(''),
              child: Text('Remove',
                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: pvStorePalette.ink2)),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: pvStorePalette.ink2)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctl.text),
            child: Text('Save', style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: kPvInk)),
          ),
        ],
      ),
    );
    // ⚠️ NOT DISPOSED THE MOMENT THE ROUTE CLOSES (2026-10-02, the red screen '_dependents.isEmpty'): the TextField is still on screen for the exit animation and still listening. Same fix as the add-child sheet.
    Future<void>.delayed(const Duration(milliseconds: 600), ctl.dispose);
    if (saved != null) _p.setOther(field, saved);
  }

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
