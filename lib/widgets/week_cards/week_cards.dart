// =============================================================================
//  Week cards (rich, bilingual)
// -----------------------------------------------------------------------------
//  The unified 8-card stack for every week, in this fixed order:
//    1 Size Reveal      2 Baby's Update   3 Mom's Journey   4 Nourishment
//    5 Action Plan      6 Bonding Ritual  7 Reflect & Remember
//    8 Share Your Journey  ← always the LAST card
//  (Week 40 appends a celebration finale — see celebration_card.dart.)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../localization/app_language.dart';
import '../../models/week_content.dart';
import '../../screens/journal_writer_screen.dart';
import '../../services/baby_voice_service.dart';
import '../../services/memory_store.dart';
import '../../services/size_view_pref.dart';
import '../../theme/app_theme.dart';
import '../baby_voice/baby_avatar.dart';
import '../baby_voice/speaker_button.dart';
import '../cards/card_shell.dart';
import '../cards/raga_player.dart';
import '../memories/memories_section.dart';
import 'living_halo.dart';

/// Ordered card list for a week. Reflect & Remember is second-last, Share Your
/// Journey is always last.
List<Widget> buildWeekCards(WeekContent w, AppLanguage lang) => [
      SizeRevealCard(w: w, lang: lang),
      BabyUpdateCard(w: w, lang: lang),
      MomJourneyCard(w: w, lang: lang),
      NourishmentCard(w: w, lang: lang),
      ActionPlanCard(w: w, lang: lang),
      BondingRitualCard(w: w, lang: lang),
      ReflectRememberCard(w: w, lang: lang),
      ShareJourneyCard(w: w, lang: lang),
    ];

// ---------------------------------------------------------------------------
//  Shared small pieces
// ---------------------------------------------------------------------------

class _Block extends StatelessWidget {
  const _Block({required this.label, required this.body, this.color, this.icon});
  final String label;
  final String body;
  final Color? color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = color ?? AppTheme.primary500;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (icon != null) ...[Icon(icon, size: 15, color: c), const SizedBox(width: 6)],
            Text(label.toUpperCase(),
                style: text.labelSmall?.copyWith(color: c, letterSpacing: 1, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          Text(body, style: text.bodyLarge?.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text, required this.tint, this.icon, this.label});
  final String text;
  final Color tint;
  final IconData? icon;
  final String? label;
  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint.withValues(alpha: 0.10), AppTheme.surfaceContainer],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Icon(icon ?? Icons.favorite_rounded, size: 15, color: tint),
                const SizedBox(width: 6),
                Text(label!.toUpperCase(),
                    style: styles.labelSmall
                        ?.copyWith(color: tint, letterSpacing: 1, fontWeight: FontWeight.w700)),
              ]),
            ),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (label == null) ...[
              Icon(icon ?? Icons.favorite_rounded, size: 17, color: tint),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(text,
                  style: styles.bodyMedium?.copyWith(height: 1.5, color: AppTheme.neutral800)),
            ),
          ]),
        ],
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.items, required this.bg, required this.border, required this.fg});
  final List<String> items;
  final Color bg;
  final Color border;
  final Color fg;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final it in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: border, width: 1),
            ),
            child: Text(it, style: text.labelLarge?.copyWith(color: fg)),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  1 · Size Reveal
// ---------------------------------------------------------------------------

class SizeRevealCard extends StatelessWidget {
  const SizeRevealCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final snap = w.snapshot;
    return CardShell(
      eyebrow: s.sizeEyebrow,
      title: s.howBig,
      icon: Icons.spa_rounded,
      accent: AppTheme.secondary500,
      trailing: SpeakerButton(
        text: snap.reveal.of(lang),
        cardKey: BabyVoiceService.keyFor(w.week, 'size_reveal'),
        lang: lang,
        accent: AppTheme.secondary500,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: SoftPill(label: snap.milestone.of(lang), color: AppTheme.primary500, icon: Icons.flag_rounded)),
          const SizedBox(height: 14),
          ValueListenableBuilder<bool>(
            valueListenable: SizeViewPref.babyMode,
            builder: (context, baby, _) {
              // Weeks 4–5: a big floating figure with a single horizontal
              // segmented toggle centred directly below it — a deliberate,
              // calm control rather than side-stacked pills.
              if (w.week <= 5) {
                return Column(children: [
                  SizedBox(
                    height: 200,
                    child: Center(
                        child: LivingHalo(week: w.week, babyMode: baby, lang: lang)),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: _FruitBabyToggle(
                        baby: baby, onChanged: SizeViewPref.set),
                  ),
                ]);
              }
              return Column(children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: _FruitBabyToggle(baby: baby, onChanged: SizeViewPref.set),
                ),
                const SizedBox(height: 8),
                Center(child: LivingHalo(week: w.week, babyMode: baby, lang: lang)),
              ]);
            },
          ),
          const SizedBox(height: 18),
          Center(child: Text(s.sizeOf, style: text.bodyMedium)),
          const SizedBox(height: 4),
          Center(
            child: Text(snap.fruit.of(lang),
                textAlign: TextAlign.center,
                style: text.headlineMedium?.copyWith(color: AppTheme.primary600)),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _Metric(s.lengthLabel, snap.length.of(lang), Icons.straighten_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _Metric(s.weightLabel, snap.weight.of(lang), Icons.monitor_weight_outlined)),
          ]),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppTheme.secondary50, borderRadius: BorderRadius.circular(20)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(snap.weekHeadline.of(lang),
                  style: text.titleMedium?.copyWith(color: AppTheme.secondary800, height: 1.4)),
              const SizedBox(height: 10),
              Text('“${snap.reveal.of(lang)}”',
                  style: text.bodyLarge?.copyWith(fontStyle: FontStyle.italic, color: AppTheme.secondary900, height: 1.5)),
            ]),
          ),
        ],
      ),
    );
  }
}

/// A single horizontal segmented pill — two equal segments ("Fruit" / "Baby")
/// with a soft elevation and a thumb that slides smoothly to the selection.
class _FruitBabyToggle extends StatelessWidget {
  const _FruitBabyToggle({
    required this.baby,
    required this.onChanged,
  });
  final bool baby;
  final ValueChanged<bool> onChanged;

  static const double _width = 208;
  static const double _height = 44;
  static const double _pad = 4;

  @override
  Widget build(BuildContext context) {
    const segW = (_width - _pad * 2) / 2;
    return Container(
      width: _width,
      height: _height,
      padding: const EdgeInsets.all(_pad),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary900.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Sliding thumb behind the selected segment.
          AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: baby ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: segW,
              height: _height - _pad * 2,
              decoration: BoxDecoration(
                color: AppTheme.secondary500,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondary500.withValues(alpha: 0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          Row(children: [
            _seg(context,
                label: 'Fruit',
                icon: Icons.eco_rounded,
                selected: !baby,
                onTap: () => onChanged(false)),
            _seg(context,
                label: 'Baby',
                icon: Icons.child_care_rounded,
                selected: baby,
                onTap: () => onChanged(true)),
          ]),
        ],
      ),
    );
  }

  Widget _seg(BuildContext context,
      {required String label,
      required IconData icon,
      required bool selected,
      required VoidCallback onTap}) {
    final text = Theme.of(context).textTheme;
    final fg = selected ? Colors.white : AppTheme.neutral500;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(icon, key: ValueKey(selected), size: 16, color: fg),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: text.labelMedium
                  ?.copyWith(color: fg, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: AppTheme.neutral500),
        const SizedBox(height: 8),
        Text(label.toUpperCase(), style: text.labelSmall?.copyWith(letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value, style: text.titleMedium),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  2 · Baby's Update
// ---------------------------------------------------------------------------

class BabyUpdateCard extends StatelessWidget {
  const BabyUpdateCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final cardKey = BabyVoiceService.keyFor(w.week, 'baby_update');
    return CardShell(
      eyebrow: s.babyEyebrow,
      title: s.whatImDoing,
      icon: Icons.child_care_rounded,
      accent: AppTheme.primary500,
      trailing: SpeakerButton(
        text: w.development.whatImDoing.of(lang),
        cardKey: cardKey,
        lang: lang,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: BabyAvatar(week: w.week, listenKey: cardKey)),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.primary50, AppTheme.surfaceContainer]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.format_quote_rounded, color: AppTheme.primary300, size: 28),
            const SizedBox(height: 8),
            Text(w.development.whatImDoing.of(lang),
                style: text.titleLarge?.copyWith(height: 1.5, fontWeight: FontWeight.w600, color: AppTheme.primary900)),
          ]),
        ),
        const SizedBox(height: 16),
        if (w.development.funFact != null)
          _Note(text: w.development.funFact!.of(lang), tint: AppTheme.secondary400, icon: Icons.auto_awesome_rounded, label: s.funFact),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  3 · Mom's Journey
// ---------------------------------------------------------------------------

class MomJourneyCard extends StatelessWidget {
  const MomJourneyCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final m = w.mom;
    return CardShell(
      eyebrow: s.motherEyebrow,
      title: s.yourBody,
      icon: Icons.self_improvement_rounded,
      accent: AppTheme.tertiary400,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Block(label: s.physicalChanges, body: m.physicalChanges.of(lang), color: AppTheme.tertiary500, icon: Icons.accessibility_new_rounded),
        _Block(label: s.howYouFeel, body: m.emotionalState.of(lang), color: AppTheme.primary500, icon: Icons.psychology_rounded),
        if (m.commonSymptoms.isNotEmpty) ...[
          Text(s.commonSymptoms, style: text.titleMedium),
          const SizedBox(height: 10),
          _Chips(items: m.commonSymptoms.map((e) => e.of(lang)).toList(), bg: AppTheme.surfaceContainer, border: AppTheme.outlineVariant, fg: AppTheme.neutral700),
          const SizedBox(height: 16),
        ],
        _Note(text: m.selfCareTip.of(lang), tint: AppTheme.tertiary500, icon: Icons.local_florist_rounded, label: s.selfCare),
        _Note(text: m.reassurance.of(lang), tint: AppTheme.secondary400, icon: Icons.spa_rounded, label: s.reassuranceLabel),
        const SizedBox(height: 4),
        _RedFlag(title: s.gentleHeadsUp, body: w.actionPlan.redFlags.of(lang), footer: s.headsUpFooter),
      ]),
    );
  }
}

class _RedFlag extends StatelessWidget {
  const _RedFlag({required this.title, required this.body, required this.footer});
  final String title;
  final String body;
  final String footer;
  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.secondary50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondary200.withValues(alpha: 0.8), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.health_and_safety_rounded, size: 19, color: AppTheme.secondary600),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: styles.titleMedium?.copyWith(color: AppTheme.secondary800, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 10),
        Text(body, style: styles.bodyMedium?.copyWith(color: AppTheme.secondary900.withValues(alpha: 0.85), height: 1.55)),
        const SizedBox(height: 10),
        Text(footer, style: styles.bodySmall?.copyWith(color: AppTheme.secondary700, fontStyle: FontStyle.italic)),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  4 · Nourishment
// ---------------------------------------------------------------------------

class NourishmentCard extends StatelessWidget {
  const NourishmentCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final n = w.nutrition;
    return CardShell(
      eyebrow: s.nutritionEyebrow,
      title: s.whatToEat,
      icon: Icons.restaurant_rounded,
      accent: AppTheme.tertiary500,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 8, children: [
          SoftPill(label: n.nutritionTheme.of(lang), color: AppTheme.tertiary500, icon: Icons.eco_rounded),
          for (final fn in n.focusNutrients) SoftPill(label: fn.of(lang), color: AppTheme.primary500, icon: Icons.bolt_rounded),
        ]),
        const SizedBox(height: 14),
        Text(n.whyNow.of(lang), style: text.bodyLarge?.copyWith(height: 1.5)),
        const SizedBox(height: 18),
        Text(s.foodsToFavour, style: text.titleMedium),
        const SizedBox(height: 12),
        _Chips(items: n.foods.map((e) => e.of(lang)).toList(), bg: AppTheme.tertiary50, border: AppTheme.tertiary100, fg: AppTheme.tertiary700),
        const SizedBox(height: 18),
        if (n.superfood != null) _Superfood(s: s, sf: n.superfood!, lang: lang),
        _Note(text: n.mealIdea.of(lang), tint: AppTheme.tertiary500, icon: Icons.ramen_dining_rounded, label: s.mealIdeaLabel),
        _Note(text: n.tip.of(lang), tint: AppTheme.primary400, icon: Icons.tips_and_updates_rounded),
        const SizedBox(height: 2),
        Center(
          child: Text(s.nourishTwoLives,
              textAlign: TextAlign.center,
              style: text.labelMedium?.copyWith(color: AppTheme.tertiary600, fontStyle: FontStyle.italic)),
        ),
      ]),
    );
  }
}

class _Superfood extends StatelessWidget {
  const _Superfood({required this.s, required this.sf, required this.lang});
  final S s;
  final Superfood sf;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.tertiary50, AppTheme.surfaceContainer]),
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: AppTheme.tertiary500, width: 3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.star_rounded, size: 17, color: AppTheme.tertiary500),
          const SizedBox(width: 6),
          Expanded(
            child: Text(s.superfoodOfWeek.toUpperCase(),
                style: text.labelSmall?.copyWith(color: AppTheme.tertiary600, letterSpacing: 0.8, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(sf.food.of(lang), style: text.headlineSmall?.copyWith(color: AppTheme.tertiary700)),
        const SizedBox(height: 6),
        Text(sf.benefit.of(lang), style: text.bodyMedium?.copyWith(height: 1.5)),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.restaurant_menu_rounded, size: 15, color: AppTheme.neutral500),
          const SizedBox(width: 6),
          Expanded(child: Text(sf.howToConsume.of(lang), style: text.bodySmall)),
        ]),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  5 · Action Plan (do / skip / myth + red flags)
// ---------------------------------------------------------------------------

class ActionPlanCard extends StatelessWidget {
  const ActionPlanCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final a = w.actionPlan;
    return CardShell(
      eyebrow: s.guidanceEyebrow,
      title: s.doSkipTruth,
      icon: Icons.checklist_rounded,
      accent: AppTheme.primary500,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Block(label: s.doThisWeek, body: a.doThisWeek.of(lang), color: const Color(0xFF3FA37A), icon: Icons.check_circle_rounded),
        _Block(label: s.skipThisWeek, body: a.skipThisWeek.of(lang), color: AppTheme.secondary500, icon: Icons.do_not_disturb_on_rounded),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.primary50, AppTheme.surfaceContainer]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.lightbulb_rounded, size: 18, color: AppTheme.primary400),
              const SizedBox(width: 8),
              Text(s.mythBuster, style: text.labelMedium?.copyWith(color: AppTheme.primary600, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),
            Text('${s.mythLabel}: ${a.mythBuster.myth.of(lang)}',
                style: text.bodyMedium?.copyWith(color: AppTheme.neutral700, fontStyle: FontStyle.italic)),
            const SizedBox(height: 6),
            Text('${s.truthLabel}: ${a.mythBuster.truth.of(lang)}',
                style: text.bodyLarge?.copyWith(color: AppTheme.neutral900, height: 1.5)),
          ]),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  6 · Bonding Ritual (Garbh Sanskar)
// ---------------------------------------------------------------------------

class BondingRitualCard extends StatelessWidget {
  const BondingRitualCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final g = w.garbhSanskar;
    return CardShell(
      eyebrow: s.garbhSanskar,
      title: s.bondingRitual,
      icon: Icons.music_note_rounded,
      accent: AppTheme.primary500,
      trailing: g.hasSpokenLine
          ? SpeakerButton(
              text: g.spokenLine!.of(lang),
              cardKey: BabyVoiceService.keyFor(w.week, 'bonding'),
              lang: lang,
            )
          : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.primary100, AppTheme.surfaceContainer]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.todaysAffirmation, style: text.labelSmall?.copyWith(color: AppTheme.primary600, letterSpacing: 1)),
            const SizedBox(height: 8),
            Text('“${g.affirmation.of(lang)}”',
                style: text.titleLarge?.copyWith(color: AppTheme.primary900, height: 1.45, fontStyle: FontStyle.italic)),
          ]),
        ),
        const SizedBox(height: 18),
        if (w.audioEnabled) RagaPlayer(title: s.ragaNamed(g.raga), subtitle: s.soothingRaga),
        if (g.hasSpokenLine) ...[
          const SizedBox(height: 18),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // A real, working speaker that shares the header's card key, so both
            // controls stay in sync, respect mute and stop any other audio first.
            SpeakerButton(
              text: g.spokenLine!.of(lang),
              cardKey: BabyVoiceService.keyFor(w.week, 'bonding'),
              lang: lang,
              accent: AppTheme.secondary500,
              size: 36,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('“${g.spokenLine!.of(lang)}”',
                    style: text.bodyLarge?.copyWith(fontStyle: FontStyle.italic, color: AppTheme.neutral800)),
                if (lang.isHinglish)
                  Padding(padding: const EdgeInsets.only(top: 2), child: Text(g.spokenLine!.en, style: text.bodySmall)),
              ]),
            ),
          ]),
        ],
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  7 · Reflect & Remember
// ---------------------------------------------------------------------------

class ReflectRememberCard extends StatelessWidget {
  const ReflectRememberCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    // Weeks 4–5 preview: a single, week-scoped "Your Week" entry inline (one
    // note + up to two photos for THIS week only). Weeks 6–40 keep the existing
    // CTA + full memory-book list until the preview is approved.
    final bool weekScoped = w.week <= 5;
    return CardShell(
      eyebrow: s.reflectEyebrow,
      title: s.reflectTitle,
      icon: Icons.auto_stories_rounded,
      accent: AppTheme.tertiary400,
      child: weekScoped
          ? WeekEntryView(lang: lang, week: w.week)
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _WeeklyJournalCta(lang: lang, week: w.week),
              const SizedBox(height: 20),
              MemoriesSection(lang: lang, week: w.week),
            ]),
    );
  }
}

/// The single, friendly "How was your last week?" call-to-action that opens the
/// merged write-or-speak journal composer.
class _WeeklyJournalCta extends StatelessWidget {
  const _WeeklyJournalCta({required this.lang, required this.week});
  final AppLanguage lang;
  final int week;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => JournalWriterScreen(
          lang: lang,
          week: week,
          source: 'reflect_remember',
          prompt: s.howWasYourWeek,
          // Open this week's existing entry (if any) so saving updates it rather
          // than creating a duplicate — each week holds a single entry now.
          existing: MemoryStore.instance.journalForWeek(week),
        ),
      )),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary100, AppTheme.surfaceContainer],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.primary100, width: 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(s.howWasYourWeek,
                  style: text.titleLarge?.copyWith(
                      color: AppTheme.primary800, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: AppTheme.primary500, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward_rounded,
                  size: 18, color: Colors.white),
            ),
          ]),
          const SizedBox(height: 8),
          Text(s.journalCardSubtitle,
              style: text.bodyMedium?.copyWith(color: AppTheme.neutral700, height: 1.4)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _CtaChip(icon: Icons.edit_rounded, label: s.writeOrSpeak),
            _CtaChip(icon: Icons.mic_rounded, label: s.tapMicToSpeak),
          ]),
        ]),
      ),
    );
  }
}

class _CtaChip extends StatelessWidget {
  const _CtaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppTheme.primary600),
        const SizedBox(width: 6),
        Text(label,
            style: text.labelSmall?.copyWith(
                color: AppTheme.primary700, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  8 · Share Your Journey (always LAST)
// ---------------------------------------------------------------------------

class ShareJourneyCard extends StatelessWidget {
  const ShareJourneyCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;

  Future<void> _share(BuildContext context, S s) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final msg = '👶 ${s.partnerShareHeader(w.week)}\n\n${w.partner.shareMessage.of(lang)}\n\n${s.partnerShareFooter} 💜';
      await Share.share(msg, subject: s.partnerShareSubject(w.week));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.shareFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final p = w.partner;
    return CardShell(
      eyebrow: s.partnerEyebrow,
      title: s.shareJourneyTitle,
      icon: Icons.volunteer_activism_rounded,
      accent: AppTheme.secondary500,
      footer: _ForwardButton(label: s.forwardWhatsapp, onTap: () => _share(context, s)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Block(label: s.whatSheMayFeel, body: p.whatSheMayFeel.of(lang), color: AppTheme.secondary500, icon: Icons.favorite_rounded),
        _Block(label: s.whatYouCanDo, body: p.whatYouCanDo.of(lang), color: AppTheme.primary500, icon: Icons.handshake_rounded),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.secondary50, AppTheme.surfaceContainer]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.flag_rounded, size: 17, color: AppTheme.secondary500),
              const SizedBox(width: 8),
              Text(s.oneMission, style: text.labelMedium?.copyWith(color: AppTheme.secondary700, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),
            Text(p.oneMission.of(lang), style: text.bodyLarge?.copyWith(height: 1.5)),
          ]),
        ),
      ]),
    );
  }
}

class _ForwardButton extends StatelessWidget {
  const _ForwardButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  static const Color _whatsapp = Color(0xFF25D366);
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(backgroundColor: AppTheme.primary500, padding: const EdgeInsets.symmetric(vertical: 14)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 26, height: 26,
            decoration: const BoxDecoration(color: _whatsapp, shape: BoxShape.circle),
            child: const Icon(Icons.chat_rounded, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Flexible(child: Text(label, textAlign: TextAlign.center, style: text.labelLarge?.copyWith(color: Colors.white))),
        ]),
      ),
    );
  }
}
