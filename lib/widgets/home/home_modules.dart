// =============================================================================
//  Home Screen — Daily Moment modules
// -----------------------------------------------------------------------------
//  The vertical stack of soft cards that make up a mother's daily moment:
//    Header → Grow → Read → Talk → Garbh Sanskar → A Moment For You
//    → (Baby Movement, week 28+) → Completion → Emotional Check-In
//
//  Reuses the existing design language (AppTheme tokens, SoftPill, RagaPlayer,
//  BabyVoiceService) so Home feels of-a-piece with the weekly card stack.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../models/home_day.dart';
import '../../models/week_content.dart';
import '../../services/baby_voice_service.dart';
import '../../services/daily_store.dart';
import '../../services/home_content_controller.dart';
import '../../screens/home_detail_screens.dart';
import '../../theme/app_theme.dart';
import '../cards/card_shell.dart';
import '../cards/raga_player.dart';

// ---------------------------------------------------------------------------
//  Shared soft module card
// ---------------------------------------------------------------------------

/// The calm, rounded scaffold every Home module sits in — a softer sibling of
/// [CardShell] sized for a vertical feed (no full-page scroll area).
class HomeCard extends StatelessWidget {
  const HomeCard({
    super.key,
    required this.eyebrow,
    required this.icon,
    required this.accent,
    required this.child,
    this.title,
    this.trailing,
    this.tinted = false,
  });

  final String eyebrow;
  final IconData icon;
  final Color accent;
  final Widget child;
  final String? title;
  final Widget? trailing;

  /// When true, the card gets a faint accent-tinted wash (used for the sacred
  /// Garbh Sanskar card and the warm Nurture card).
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tinted ? null : AppTheme.surface,
        gradient: tinted
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withValues(alpha: 0.07), AppTheme.surface],
              )
            : null,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: tinted ? accent.withValues(alpha: 0.20) : AppTheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary900.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  eyebrow.toUpperCase(),
                  style: text.labelSmall?.copyWith(
                    color: accent,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          if (title != null) ...[
            const SizedBox(height: 10),
            Text(title!, style: text.headlineSmall),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// A full-width primary action used across modules (e.g. "Read More").
class HomePrimaryButton extends StatelessWidget {
  const HomePrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.icon,
    this.trailingArrow = false,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;
  final IconData? icon;
  final bool trailingArrow;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = color ?? AppTheme.primary500;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: c,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 18, color: Colors.white), const SizedBox(width: 8)],
            Text(label,
                style: text.labelLarge?.copyWith(color: Colors.white)),
            if (trailingArrow) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

/// A soft, italic quote box (used for affirmations & motivations).
class QuoteBox extends StatelessWidget {
  const QuoteBox({super.key, required this.text, required this.accent});
  final String text;
  final Color accent;
  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accent.withValues(alpha: 0.5), width: 3)),
      ),
      child: Text('“$text”',
          style: styles.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppTheme.neutral800,
              height: 1.5)),
    );
  }
}

// ---------------------------------------------------------------------------
//  Header
// ---------------------------------------------------------------------------

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.name,
    required this.week,
    required this.snapshot,
    required this.babyLearning,
    required this.lang,
    required this.hour,
    required this.onLanguageChanged,
  });

  final String name;
  final int week;
  final BabySnapshot snapshot;
  final LocalizedText babyLearning;
  final AppLanguage lang;
  final int hour;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar + notification bell.
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary500, AppTheme.secondary500],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'P',
                  style: text.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
            const Spacer(),
            LangToggle(lang: lang, onChanged: onLanguageChanged),
            const SizedBox(width: 10),
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.notifications_none_rounded,
                  color: AppTheme.neutral600, size: 22),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(s.greeting(hour, name),
            style: text.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(s.journeyLine(week),
            style: text.titleMedium?.copyWith(
                color: AppTheme.primary600, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        // Baby size callout.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.secondary50, AppTheme.primary50],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: AppTheme.surface, shape: BoxShape.circle),
                child: const Icon(Icons.child_friendly_rounded,
                    color: AppTheme.secondary500, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.littleOneSize(snapshot.fruit.of(lang)),
                      style: text.titleMedium?.copyWith(height: 1.35),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.sizeAndLearning(
                          snapshot.length.of(lang), babyLearning.of(lang)),
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Compact EN / Hi toggle for the Home header (mirrors the weekly stack's).
class LangToggle extends StatelessWidget {
  const LangToggle({super.key, required this.lang, required this.onChanged});
  final AppLanguage lang;
  final ValueChanged<AppLanguage> onChanged;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget seg(String label, bool selected, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primary500 : Colors.transparent,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(label,
                style: text.labelMedium?.copyWith(
                    color: selected ? Colors.white : AppTheme.neutral500,
                    fontWeight: FontWeight.w700)),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        seg('EN', lang.isEnglish, () => onChanged(AppLanguage.english)),
        seg('Hi', lang.isHinglish, () => onChanged(AppLanguage.hinglish)),
      ]),
    );
  }
}

/// Mother / Father mode switch shown at the very top of the Home tab.
/// Father's mode is a placeholder for now; content arrives later.
class ModeToggle extends StatelessWidget {
  const ModeToggle({super.key, required this.fatherMode, required this.onChanged});
  final bool fatherMode;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget seg(String label, IconData icon, bool selected, VoidCallback onTap) =>
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary500 : Colors.transparent,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      size: 18,
                      color: selected ? Colors.white : AppTheme.neutral500),
                  const SizedBox(width: 7),
                  Text(label,
                      style: text.labelLarge?.copyWith(
                          color: selected ? Colors.white : AppTheme.neutral500,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(children: [
        seg('Mother', Icons.pregnant_woman_rounded, !fatherMode, () => onChanged(false)),
        seg('Father', Icons.man_rounded, fatherMode, () => onChanged(true)),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  Daily-moment summary strip ("Today's Moment · ~6 min")
// ---------------------------------------------------------------------------

class MomentSummary extends StatelessWidget {
  const MomentSummary({super.key, required this.lang});
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.todaysMoment.toUpperCase(),
                  style: text.labelSmall?.copyWith(
                      color: AppTheme.primary600,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(s.momentSummary, style: text.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SoftPill(label: s.momentMinutes, color: AppTheme.secondary500),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  1 · Grow
// ---------------------------------------------------------------------------

class GrowModule extends StatelessWidget {
  const GrowModule({super.key, required this.day, required this.lang, required this.home});
  final HomeDay day;
  final AppLanguage lang;
  final HomeContentController home;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final g = day.grow;
    return HomeCard(
      eyebrow: s.growEyebrow,
      icon: Icons.eco_rounded,
      accent: AppTheme.primary500,
      title: '“${g.title.of(lang)}”',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(g.insight.of(lang), style: text.bodyLarge?.copyWith(height: 1.5)),
        const SizedBox(height: 16),
        HomePrimaryButton(
          label: s.readMore,
          trailingArrow: true,
          onTap: () {
            home.markEngaged(DailyModule.grow);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => GrowReaderScreen(grow: g, lang: lang),
            ));
          },
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  2 · Read To Your Baby
// ---------------------------------------------------------------------------

class ReadModule extends StatelessWidget {
  const ReadModule({super.key, required this.day, required this.lang, required this.home});
  final HomeDay day;
  final AppLanguage lang;
  final HomeContentController home;

  String get _listenKey => 'home_day_${day.day}_story';

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final st = day.story;
    return HomeCard(
      eyebrow: s.readEyebrow,
      icon: Icons.menu_book_rounded,
      accent: AppTheme.secondary500,
      title: '“${st.title.of(lang)}”',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(st.summary.of(lang), style: text.bodyLarge?.copyWith(height: 1.5)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                home.markEngaged(DailyModule.read);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => StoryReaderScreen(story: st, lang: lang),
                ));
              },
              icon: const Icon(Icons.menu_book_rounded, size: 18),
              label: Text(s.readCta),
            ),
          ),
          if (st.audioAvailable) ...[
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedBuilder(
                animation: BabyVoiceService.instance,
                builder: (context, _) {
                  final playing = BabyVoiceService.instance.isPlaying(_listenKey);
                  return FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.secondary500,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      home.markEngaged(DailyModule.read);
                      BabyVoiceService.instance.toggleCard(
                        st.body.of(lang),
                        cardKey: _listenKey,
                        lang: lang,
                      );
                    },
                    icon: Icon(playing ? Icons.stop_rounded : Icons.graphic_eq_rounded,
                        size: 18, color: Colors.white),
                    label: Text(playing ? s.listenCta : s.listenCta,
                        style: text.labelLarge?.copyWith(color: Colors.white)),
                  );
                },
              ),
            ),
          ],
        ]),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  3 · Talk To Your Baby
// ---------------------------------------------------------------------------

class TalkModule extends StatelessWidget {
  const TalkModule({super.key, required this.day, required this.lang, required this.home});
  final HomeDay day;
  final AppLanguage lang;
  final HomeContentController home;

  Future<void> _compose(BuildContext context, {required bool voice}) async {
    home.markEngaged(DailyModule.talk);
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TalkComposerScreen(
        day: day.day,
        week: day.week,
        prompt: day.talk.title.of(lang),
        motivation: day.talk.motivation.of(lang),
        lang: lang,
        startWithVoice: voice,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final t = day.talk;
    return HomeCard(
      eyebrow: s.talkEyebrow,
      icon: Icons.chat_bubble_rounded,
      accent: AppTheme.primary500,
      title: '“${t.title.of(lang)}”',
      child: ListenableBuilder(
        listenable: DailyStore.instance,
        builder: (context, _) {
          final saved = DailyStore.instance.talkForDay(day.day);
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            QuoteBox(text: t.motivation.of(lang), accent: AppTheme.primary400),
            const SizedBox(height: 16),
            if (saved != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.favorite_rounded, size: 14, color: AppTheme.primary500),
                    const SizedBox(width: 6),
                    Text(s.talkSavedBadge,
                        style: text.labelSmall?.copyWith(
                            color: AppTheme.primary600, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 6),
                  Text(saved.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium?.copyWith(color: AppTheme.neutral800)),
                ]),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _compose(context, voice: false),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text(s.edit),
              ),
            ] else
              Wrap(spacing: 10, runSpacing: 10, children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.secondary500,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  onPressed: () => _compose(context, voice: true),
                  icon: const Icon(Icons.mic_rounded, size: 18, color: Colors.white),
                  label: Text(s.recordCta, style: text.labelLarge?.copyWith(color: Colors.white)),
                ),
                OutlinedButton.icon(
                  onPressed: () => _compose(context, voice: false),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: Text(s.writeCta),
                ),
                TextButton(
                  onPressed: () => home.markEngaged(DailyModule.talk),
                  child: Text(s.maybeLater,
                      style: text.labelLarge?.copyWith(color: AppTheme.neutral500)),
                ),
              ]),
          ]);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  4 · Garbh Sanskar
// ---------------------------------------------------------------------------

class GarbhSanskarModule extends StatelessWidget {
  const GarbhSanskarModule({super.key, required this.day, required this.lang, required this.home});
  final HomeDay day;
  final AppLanguage lang;
  final HomeContentController home;

  static const Color _saffron = Color(0xFFC9831F);

  String _typeLabel(S s, GarbhType t) {
    switch (t) {
      case GarbhType.meditation:
        return s.meditationLabel;
      case GarbhType.affirmation:
        return s.affirmationLabel;
      case GarbhType.raga:
        return s.ragaLabel;
    }
  }

  void _openInfo(BuildContext context) {
    home.markEngaged(DailyModule.garbhSanskar);
    showGarbhInfoSheet(context, g: day.garbhSanskar, lang: lang, accent: _saffron);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final g = day.garbhSanskar;
    return HomeCard(
      eyebrow: s.garbhSanskar,
      icon: Icons.self_improvement_rounded,
      accent: _saffron,
      tinted: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.todaysPractice, style: text.titleLarge),
        const SizedBox(height: 14),
        // Type badge + the little "i" info button, by the raga's side.
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _saffron.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_typeLabel(s, g.type),
                style: text.labelSmall?.copyWith(
                    color: _saffron, letterSpacing: 1, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),
          _InfoButton(color: _saffron, tooltip: s.infoTooltip, onTap: () => _openInfo(context)),
        ]),
        const SizedBox(height: 10),
        if (g.type == GarbhType.affirmation) ...[
          QuoteBox(text: g.affirmation.of(lang), accent: _saffron),
          const SizedBox(height: 14),
          _KeepButton(textToKeep: g.affirmation.of(lang), accent: _saffron, lang: lang),
        ] else ...[
          Text(g.title.of(lang),
              style: text.headlineSmall?.copyWith(color: AppTheme.tertiary700)),
          const SizedBox(height: 2),
          Text('${s.minutesShort(g.durationMinutes)} · ${g.description.of(lang)}',
              style: text.bodyMedium),
          const SizedBox(height: 14),
          // Reuse the existing raga player (placeholder drone) for playback.
          RagaPlayer(title: g.title.of(lang), subtitle: g.description.of(lang)),
          if (g.type == GarbhType.meditation && g.introduction.of(lang).isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(g.introduction.of(lang), style: text.bodyMedium?.copyWith(height: 1.5)),
          ],
          const SizedBox(height: 14),
          QuoteBox(text: g.affirmation.of(lang), accent: _saffron),
        ],
      ]),
    );
  }
}

class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.color, required this.tooltip, required this.onTap});
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.45), width: 1),
          ),
          child: Icon(Icons.info_outline_rounded, size: 15, color: color),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  5 · A Moment For You (Nurture)
// ---------------------------------------------------------------------------

class NurtureModule extends StatelessWidget {
  const NurtureModule({super.key, required this.day, required this.lang, required this.home});
  final HomeDay day;
  final AppLanguage lang;
  final HomeContentController home;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final n = day.nurture;
    return HomeCard(
      eyebrow: s.momentForYouEyebrow,
      icon: Icons.spa_rounded,
      accent: AppTheme.secondary500,
      tinted: true,
      title: '“${n.title.of(lang)}”',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        QuoteBox(text: n.content.of(lang), accent: AppTheme.secondary500),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.favorite_border_rounded, size: 14, color: AppTheme.secondary600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(n.remember.of(lang),
                style: text.bodySmall?.copyWith(color: AppTheme.secondary700)),
          ),
        ]),
        const SizedBox(height: 14),
        _KeepButton(textToKeep: n.content.of(lang), accent: AppTheme.secondary500, lang: lang, onKept: () => home.markEngaged(DailyModule.nurture)),
      ]),
    );
  }
}

class _KeepButton extends StatelessWidget {
  const _KeepButton({required this.textToKeep, required this.accent, required this.lang, this.onKept});
  final String textToKeep;
  final Color accent;
  final AppLanguage lang;
  final VoidCallback? onKept;
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    return ListenableBuilder(
      listenable: DailyStore.instance,
      builder: (context, _) {
        final kept = DailyStore.instance.isKept(textToKeep);
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: accent,
              side: BorderSide(color: accent.withValues(alpha: 0.5), width: 1.2),
              backgroundColor: kept ? accent.withValues(alpha: 0.10) : null,
            ),
            onPressed: () {
              DailyStore.instance.toggleKept(textToKeep);
              onKept?.call();
            },
            icon: Icon(kept ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 18),
            label: Text(kept ? s.keptLabel : s.keepThisWithMe),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
//  6 · Baby Movement Check-In (Week 28+ only)
// ---------------------------------------------------------------------------

class MovementModule extends StatelessWidget {
  const MovementModule({super.key, required this.day, required this.lang, required this.home});
  final HomeDay day;
  final AppLanguage lang;
  final HomeContentController home;
  static const Color _green = Color(0xFF3FA37A);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return HomeCard(
      eyebrow: s.movementEyebrow,
      icon: Icons.favorite_border_rounded,
      accent: _green,
      title: s.movementQuestion,
      child: ListenableBuilder(
        listenable: DailyStore.instance,
        builder: (context, _) {
          final answer = DailyStore.instance.movementForDay(day.day);
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.movementSubtext, style: text.bodyMedium),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: answer == 'yes' ? _green : _green.withValues(alpha: 0.14),
                    foregroundColor: answer == 'yes' ? Colors.white : _green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    DailyStore.instance.setMovement(day.day, 'yes');
                    home.markEngaged(DailyModule.movement);
                  },
                  icon: const Icon(Icons.favorite_rounded, size: 18),
                  label: Text(s.yesWord),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: answer == 'not_yet' ? AppTheme.surfaceContainer : null,
                  ),
                  onPressed: () {
                    DailyStore.instance.setMovement(day.day, 'not_yet');
                    home.markEngaged(DailyModule.movement);
                  },
                  child: Text(s.notYet),
                ),
              ),
            ]),
            if (answer == 'yes') ...[
              const SizedBox(height: 14),
              Text(s.movementYes,
                  style: text.bodyMedium?.copyWith(color: _green, fontWeight: FontWeight.w600)),
            ],
            if (answer == 'not_yet') ...[
              const SizedBox(height: 14),
              Text(s.movementNotYet, style: text.bodyMedium?.copyWith(height: 1.5)),
              const SizedBox(height: 8),
              Text(s.movementEscalation,
                  style: text.bodySmall?.copyWith(
                      color: AppTheme.secondary700, fontStyle: FontStyle.italic)),
            ],
          ]);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Completion acknowledgement
// ---------------------------------------------------------------------------

class CompletionBanner extends StatelessWidget {
  const CompletionBanner({super.key, required this.lang});
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return Column(children: [
      Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.secondary50,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.spa_rounded, color: AppTheme.secondary500, size: 28),
      ),
      const SizedBox(height: 14),
      Text(s.completionTitle,
          textAlign: TextAlign.center,
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text(s.completionSubtitle,
          textAlign: TextAlign.center, style: text.bodyMedium),
    ]);
  }
}

// ---------------------------------------------------------------------------
//  7 · Emotional Check-In
// ---------------------------------------------------------------------------

class _Mood {
  const _Mood(this.id, this.icon, this.color);
  final String id;
  final IconData icon;
  final Color color;
}

class EmotionalCheckIn extends StatelessWidget {
  const EmotionalCheckIn({super.key, required this.day, required this.lang});
  final int day;
  final AppLanguage lang;

  static const List<_Mood> _moods = [
    _Mood('happy', Icons.sentiment_satisfied_rounded, Color(0xFFF2B705)),
    _Mood('grateful', Icons.volunteer_activism_rounded, AppTheme.secondary500),
    _Mood('calm', Icons.spa_rounded, Color(0xFF3FA37A)),
    _Mood('hopeful', Icons.auto_awesome_rounded, AppTheme.primary500),
    _Mood('tired', Icons.bedtime_rounded, AppTheme.primary400),
    _Mood('anxious', Icons.psychology_rounded, Color(0xFF976F38)),
    _Mood('overwhelmed', Icons.waves_rounded, Color(0xFF4A7BC8)),
    _Mood('loved', Icons.favorite_rounded, AppTheme.secondary500),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary900.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: ListenableBuilder(
        listenable: DailyStore.instance,
        builder: (context, _) {
          final selected = DailyStore.instance.moodForDay(day);
          return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(s.feelingQuestion,
                textAlign: TextAlign.center,
                style: text.headlineSmall),
            const SizedBox(height: 6),
            Text(s.feelingSubtext,
                textAlign: TextAlign.center, style: text.bodyMedium),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
              children: [
                for (final m in _moods)
                  _MoodTile(
                    mood: m,
                    label: s.moodLabel(m.id),
                    selected: selected == m.id,
                    onTap: () {
                      if (selected == m.id) {
                        DailyStore.instance.clearMood(day);
                      } else {
                        DailyStore.instance.setMood(day, m.id);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 6),
            if (selected != null)
              Text(s.moodSaved,
                  style: text.labelMedium?.copyWith(color: AppTheme.secondary600))
            else
              TextButton(
                onPressed: () {},
                child: Text(s.maybeLater,
                    style: text.labelLarge?.copyWith(color: AppTheme.neutral500)),
              ),
          ]);
        },
      ),
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({required this.mood, required this.label, required this.selected, required this.onTap});
  final _Mood mood;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? mood.color.withValues(alpha: 0.16) : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? mood.color.withValues(alpha: 0.6) : AppTheme.outlineVariant,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(mood.icon, size: 24, color: selected ? mood.color : AppTheme.neutral500),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.labelSmall?.copyWith(
                    color: selected ? mood.color : AppTheme.neutral700,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}
