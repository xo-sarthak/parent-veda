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

import '../../data/body_changes.dart';
import '../../data/trimester_tips.dart';
import '../../localization/app_language.dart';
import '../../models/pv_video.dart';
import '../../models/week_content.dart';
import '../../screens/journal_writer_screen.dart';
import '../../services/baby_voice_service.dart';
import '../../services/memory_store.dart';
import '../../services/size_view_pref.dart';
import '../../services/video_store.dart';
import '../../theme/app_theme.dart';
import '../baby_voice/baby_avatar.dart';
import '../baby_voice/speaker_button.dart';
import '../cards/card_shell.dart';
import '../cards/food_emoji.dart';
import '../cards/raga_player.dart';
import '../memories/memories_section.dart';
import 'week_overview_card.dart';
// import 'living_halo.dart'; // ring figure replaced by the striped Size hero
//   (kept for revert: re-add this import + restore the old SizeRevealCard body).

/// Ordered card list for a week. Reflect & Remember is second-last, Share Your
/// Journey is always last.
List<Widget> buildWeekCards(WeekContent w, AppLanguage lang) {
  // ── Week 20 — "ParentVeda Journey" design PREVIEW ────────────────────────
  // An elevated, de-cluttered overview card (progress-ring hero + Baby / Mother
  // / Health accordions) folds the Size, Baby Update and Mom's Journey cards
  // into one. The horizontal carousel stays; each card just reads cleaner.
  // The original cards are NOT removed — every other week keeps them; once this
  // look is approved, roll it out to more weeks.
  if (w.week == 20) {
    return [
      WeekOverviewCard(w: w, lang: lang),
      WeekVideoCard(w: w, lang: lang),
      WeekMilestoneCard(w: w, lang: lang),
      WeekNutritionCard(w: w, lang: lang),
      if (kTrimesterTips.containsKey(w.week))
        WeekTipsCard(w: w, lang: lang),
      WeekActionCard(w: w, lang: lang),
      // Weekly Garbh Sanskar (Bonding) + Journaling (Reflect) removed from the
      // weekly stack per Excel — both are daily-only. Kept for revert:
      // BondingRitualCard(w: w, lang: lang),
      // ReflectRememberCard(w: w, lang: lang),
      WeekShareCard(w: w, lang: lang),
    ];
  }
  return [
    SizeRevealCard(w: w, lang: lang),
    WeeklyVideoCard(w: w, lang: lang),
    BabyUpdateCard(w: w, lang: lang),
    MomJourneyCard(w: w, lang: lang),
    if (kTrimesterTips.containsKey(w.week)) TrimesterTipsCard(w: w, lang: lang),
    NourishmentCard(w: w, lang: lang),
    ActionPlanCard(w: w, lang: lang),
    // Weekly Garbh Sanskar (Bonding) + Journaling (Reflect) removed from the
    // weekly stack per Excel — both are daily-only. Kept for revert:
    // BondingRitualCard(w: w, lang: lang),
    // ReflectRememberCard(w: w, lang: lang),
    ShareJourneyCard(w: w, lang: lang),
  ];
}

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
      // Mockup header: purple filled icon chip, muted eyebrow, purple title,
      // and a calm neutral speaker.
      iconChipColor: AppTheme.primary500,
      eyebrowColor: AppTheme.neutral400,
      titleColor: AppTheme.primary600,
      trailing: SpeakerButton(
        text: snap.reveal.of(lang),
        cardKey: BabyVoiceService.keyFor(w.week, 'size_reveal'),
        lang: lang,
        accent: AppTheme.neutral500,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: SoftPill(label: snap.milestone.of(lang), color: AppTheme.primary500, icon: Icons.flag_rounded)),
          const SizedBox(height: 16),
          // Warm-Nest "Your Week" image hero: a soft striped frame holding the
          // week's figure — the food emoji, or the real in-womb baby image via
          // the Fruit/Baby toggle — with a "baby · week N" tag and Size /
          // Length·Weight corner tags.
          _SizeHero(
            week: w.week,
            lang: lang,
            fruit: snap.fruit.of(lang),
            length: snap.length.of(lang),
            weight: snap.weight.of(lang),
          ),
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

/// A single horizontal segmented pill — two equal halves ("Fruit" / "Baby").
/// Each half fills its side completely and centres its icon + label both
/// horizontally and vertically; the selected half gets a soft coral fill.
class _FruitBabyToggle extends StatelessWidget {
  const _FruitBabyToggle({
    required this.baby,
    required this.onChanged,
  });
  final bool baby;
  final ValueChanged<bool> onChanged;

  static const double _width = 224;
  static const double _height = 46;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: _height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary900.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _seg(context,
                label: 'Fruit',
                icon: Icons.eco_rounded,
                selected: !baby,
                onTap: () => onChanged(false)),
          ),
          Expanded(
            child: _seg(context,
                label: 'Baby',
                icon: Icons.child_care_rounded,
                selected: baby,
                onTap: () => onChanged(true)),
          ),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppTheme.secondary500 : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.secondary500.withValues(alpha: 0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(label,
                style: text.labelMedium
                    ?.copyWith(color: fg, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Size hero — striped "image" frame (Warm-Nest "Your Week" design)
// ---------------------------------------------------------------------------

/// The redesigned Size centrepiece: a soft diagonally-striped "image" frame.
/// The figure crossfades between the week's food emoji and the real in-womb
/// baby image (assets/baby/week_NN.jpg) via the Fruit/Baby toggle below. A
/// "baby · week N" tag sits top-centre; Size (food) bottom-left; Length &
/// Weight bottom-right — matching the Claude-Design weekly screen.
class _SizeHero extends StatelessWidget {
  const _SizeHero({
    required this.week,
    required this.lang,
    required this.fruit,
    required this.length,
    required this.weight,
  });
  final int week;
  final AppLanguage lang;
  final String fruit;
  final String length;
  final String weight;

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    return ValueListenableBuilder<bool>(
      valueListenable: SizeViewPref.babyMode,
      builder: (context, baby, _) {
        return Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _StripePainter())),
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: baby
                          ? _BabyHeroImage(week: week, key: const ValueKey('baby'))
                          : Text(
                              foodEmojiForWeek(week),
                              key: const ValueKey('food'),
                              style: const TextStyle(fontSize: 92),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _HeroPill('baby · ${s.weekWord.toLowerCase()} $week'),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: _HeroTag(
                      label: s.sizeWord,
                      value: '${foodEmojiForWeek(week)} $fruit',
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _HeroTag(
                      label: s.lengthLabel,
                      value: length,
                      label2: s.weightLabel,
                      value2: weight,
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: _FruitBabyToggle(baby: baby, onChanged: SizeViewPref.set)),
        ]);
      },
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(
        text,
        style: styles.labelMedium?.copyWith(
          color: AppTheme.primary500,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({
    required this.label,
    required this.value,
    this.label2,
    this.value2,
    this.alignEnd = false,
  });
  final String label;
  final String value;
  final String? label2;
  final String? value2;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).textTheme;
    final cross = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    Widget pair(String l, String v) => Column(
          crossAxisAlignment: cross,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.toUpperCase(),
              style: styles.labelSmall?.copyWith(
                color: AppTheme.neutral500,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              v,
              textAlign: alignEnd ? TextAlign.end : TextAlign.start,
              style: styles.titleMedium?.copyWith(
                color: AppTheme.primary900,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: cross,
        mainAxisSize: MainAxisSize.min,
        children: [
          pair(label, value),
          if (label2 != null && value2 != null) ...[
            const SizedBox(height: 8),
            pair(label2!, value2!),
          ],
        ],
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppTheme.secondary50);
    final stripe = Paint()
      ..color = AppTheme.secondary100.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;
    const gap = 30.0;
    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), stripe);
    }
  }

  @override
  bool shouldRepaint(covariant _StripePainter oldDelegate) => false;
}

/// Real in-womb baby image for the hero (assets/baby/week_NN.jpg), with the
/// food emoji as a graceful fallback until artwork for a week is provided.
class _BabyHeroImage extends StatelessWidget {
  const _BabyHeroImage({super.key, required this.week});
  final int week;
  String get _asset =>
      'assets/baby/week_${week.toString().padLeft(2, '0')}.jpg';
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.asset(
        _asset,
        width: 190,
        height: 190,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) =>
            Text(foodEmojiForWeek(week), style: const TextStyle(fontSize: 92)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Weekly Video — first carousel slot after the Size hero
// ---------------------------------------------------------------------------

/// The recommended Watch & Learn video for [week] (the nearest one if the week
/// falls between curated ranges).
PvVideo? _weekVideo(int week) {
  final recs =
      kVideos.where((v) => v.category == VideoCategory.recommended).toList();
  for (final v in recs) {
    if (v.matchesWeek(week)) return v;
  }
  if (recs.isEmpty) return null;
  int dist(PvVideo v) => week < v.weekStart
      ? v.weekStart - week
      : (week > v.weekEnd ? week - v.weekEnd : 0);
  recs.sort((a, b) => dist(a).compareTo(dist(b)));
  return recs.first;
}

class WeeklyVideoCard extends StatelessWidget {
  const WeeklyVideoCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final v = _weekVideo(w.week);
    if (v == null) return const SizedBox.shrink();
    final meta = videoMeta(v.category);
    return CardShell(
      eyebrow: s.wkVideoEyebrow,
      title: v.title.of(lang),
      icon: Icons.play_circle_rounded,
      accent: AppTheme.primary500,
      trailing: AnimatedBuilder(
        animation: VideoStore.instance,
        builder: (context, _) {
          final saved = VideoStore.instance.isSaved(v.id);
          return IconButton(
            icon: Icon(
                saved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: AppTheme.primary500),
            onPressed: () => VideoStore.instance.toggle(v.id),
          );
        },
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(s.wkVideoSoon))),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [meta.color, AppTheme.primary700],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded,
                        size: 34, color: AppTheme.primary600),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(40)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(meta.icon, size: 13, color: meta.color),
                      const SizedBox(width: 5),
                      Text(s.wkVideoEyebrow,
                          style: text.labelSmall?.copyWith(
                              color: meta.color, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(40)),
                    child: Text(v.duration,
                        style: text.labelSmall?.copyWith(color: Colors.white)),
                  ),
                ),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(v.reason.of(lang), style: text.bodyLarge?.copyWith(height: 1.5)),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.info_outline_rounded,
              size: 14, color: AppTheme.neutral400),
          const SizedBox(width: 6),
          Expanded(
            child: Text(s.wkVideoSoon,
                style: text.bodySmall?.copyWith(color: AppTheme.neutral500)),
          ),
        ]),
      ]),
    );
  }
}

// ignore: unused_element  (superseded by the Size hero corner tags; kept for revert)
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
        if (kBodyChanges.containsKey(w.week))
          _BodyChangesBlock(week: w.week, lang: lang, title: s.physicalChanges)
        else
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

/// Mother's Body Changes — week-by-week biological sections (shown inside the
/// Mom's Journey card when this week has authored content in kBodyChanges).
class _BodyChangesBlock extends StatelessWidget {
  const _BodyChangesBlock(
      {required this.week, required this.lang, required this.title});
  final int week;
  final AppLanguage lang;
  final String title;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final changes = kBodyChanges[week] ?? const <BodyChange>[];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.accessibility_new_rounded,
              size: 15, color: AppTheme.tertiary500),
          const SizedBox(width: 6),
          Text(title.toUpperCase(),
              style: text.labelSmall?.copyWith(
                  color: AppTheme.tertiary500,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        for (final ch in changes)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ch.label.of(lang),
                  style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.tertiary700)),
              const SizedBox(height: 2),
              Text(ch.detail.of(lang),
                  style: text.bodyMedium
                      ?.copyWith(height: 1.45, color: AppTheme.neutral800)),
            ]),
          ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  Trimester Tips — 2-3 gentle tips for the week (kTrimesterTips)
// ---------------------------------------------------------------------------
class TrimesterTipsCard extends StatelessWidget {
  const TrimesterTipsCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final tips = kTrimesterTips[w.week] ?? const <LocalizedText>[];
    return CardShell(
      eyebrow: s.ttEyebrow,
      title: s.ttTitle(w.week),
      icon: Icons.tips_and_updates_rounded,
      accent: AppTheme.tertiary500,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (int i = 0; i < tips.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppTheme.tertiary500.withValues(alpha: 0.14),
                    shape: BoxShape.circle),
                child: Text('${i + 1}',
                    style: text.labelMedium?.copyWith(
                        color: AppTheme.tertiary700,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(tips[i].of(lang),
                    style: text.bodyLarge?.copyWith(height: 1.5)),
              ),
            ]),
          ),
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
        // "What to do this week" removed per Deepti ruling — keep only "what to
        // skip" + the myth buster. Kept for revert:
        // _Block(label: s.doThisWeek, body: a.doThisWeek.of(lang), color: const Color(0xFF3FA37A), icon: Icons.check_circle_rounded),
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
