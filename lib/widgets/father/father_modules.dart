// =============================================================================
//  Father Mode — Daily Moment modules
// -----------------------------------------------------------------------------
//  The vertical stack of soft cards that make up a father's daily moment:
//    Header → Today's Moment → Learn → Talk To Your Baby → Mission
//    → Completion → Emotional Check-In
//
//  Same design language and four-colour palette as the mother experience, but
//  the signature accent shifts from purple to the grounded slate (AppTheme
//  .fatherSlate) — coral stays for warmth, amber marks the daily Mission.
//  Shared scaffolding (HomeCard, HomePrimaryButton, LangToggle, ModeToggle) is
//  reused from the mother modules so both modes feel of-a-piece.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../models/father_day.dart';
import '../../models/father_week.dart';
import '../../screens/home_detail_screens.dart';
import '../../services/daily_store.dart';
import '../../services/father_content_controller.dart';
import '../../theme/app_theme.dart';
import '../home/home_modules.dart' show HomeCard, LangToggle;

// Father Mode accent roles, drawn from the shared palette.
const Color _slate = AppTheme.fatherSlate500;
const Color _amber = AppTheme.fatherAmber;
const Color _coral = AppTheme.secondary500;

// ---------------------------------------------------------------------------
//  Header
// ---------------------------------------------------------------------------

class FatherHeader extends StatelessWidget {
  const FatherHeader({
    super.key,
    required this.name,
    required this.week,
    required this.day,
    required this.lang,
    required this.hour,
    required this.onLanguageChanged,
  });

  final String name;
  final int week;
  final int day;
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
        // Wordmark + language toggle + notification bell.
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.fatherSlate500, AppTheme.fatherSlate700],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.family_restroom_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Text(s.fatherWordmark,
                style: text.titleLarge?.copyWith(
                    color: AppTheme.fatherSlate600, fontWeight: FontWeight.w800)),
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
        const SizedBox(height: 20),
        Text(s.fatherGreeting(hour, name),
            style: text.headlineLarge?.copyWith(
                color: AppTheme.fatherSlate600, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(s.fatherDayLine(week, day),
            style: text.titleMedium?.copyWith(
                color: AppTheme.neutral500, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  Today's Moment card (the gentle invitation, ~4 min)
// ---------------------------------------------------------------------------

class FatherMomentCard extends StatelessWidget {
  const FatherMomentCard({
    super.key,
    required this.intro,
    required this.lang,
  });

  final String intro;
  final AppLanguage lang;

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
            color: AppTheme.fatherSlate900.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      // A faint warm corner wash, echoing the reference's soft glow.
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [_amber.withValues(alpha: 0.07), AppTheme.surface],
            stops: const [0.0, 0.5],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.wb_sunny_rounded, size: 20, color: _amber),
              const SizedBox(width: 9),
              Expanded(
                child: Text(s.todaysMoment,
                    style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(s.fatherMomentMinutes,
                    style: text.labelSmall?.copyWith(
                        color: AppTheme.neutral600, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 10),
            Text(intro, style: text.bodyLarge?.copyWith(height: 1.45)),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  1 · Learn — a fatherhood lesson
// ---------------------------------------------------------------------------

class FatherLearnModule extends StatelessWidget {
  const FatherLearnModule({
    super.key,
    required this.day,
    required this.lang,
    required this.father,
  });

  final FatherDay day;
  final AppLanguage lang;
  final FatherContentController father;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final l = day.learn;
    return HomeCard(
      eyebrow: l.module.of(lang),
      icon: Icons.eco_rounded,
      accent: _slate,
      title: l.title.of(lang),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.insight.of(lang), style: text.bodyLarge?.copyWith(height: 1.5)),
        const SizedBox(height: 14),
        InkWell(
          onTap: () {
            father.markEngaged(FatherModule.learn);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => FatherLearnReaderScreen(lesson: l, lang: lang),
            ));
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(s.learnOpen,
                  style: text.labelLarge?.copyWith(
                      color: _slate, fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, size: 18, color: _slate),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  2 · Talk To Your Baby — bonding before birth
// ---------------------------------------------------------------------------

class FatherTalkModule extends StatelessWidget {
  const FatherTalkModule({
    super.key,
    required this.day,
    required this.lang,
    required this.father,
  });

  final FatherDay day;
  final AppLanguage lang;
  final FatherContentController father;

  Future<void> _compose(BuildContext context, {required bool voice}) async {
    father.markEngaged(FatherModule.talk);
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TalkComposerScreen(
        day: day.day,
        week: day.week,
        prompt: day.talk.prompt.of(lang),
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
      accent: _coral,
      title: t.title.of(lang),
      child: ListenableBuilder(
        listenable: DailyStore.instance,
        builder: (context, _) {
          final saved = DailyStore.instance.talkForDay(day.day);
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.prompt.of(lang), style: text.bodyLarge?.copyWith(height: 1.5)),
            const SizedBox(height: 6),
            Text(t.motivation.of(lang),
                style: text.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic, color: AppTheme.neutral600)),
            const SizedBox(height: 16),
            if (saved != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.secondary50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.favorite_rounded, size: 14, color: _coral),
                    const SizedBox(width: 6),
                    Text(s.talkSavedBadge,
                        style: text.labelSmall?.copyWith(
                            color: AppTheme.secondary700, fontWeight: FontWeight.w700)),
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
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _coral,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _compose(context, voice: true),
                  icon: const Icon(Icons.mic_rounded, size: 18, color: Colors.white),
                  label: Text(s.recordCta,
                      style: text.labelLarge?.copyWith(color: Colors.white)),
                ),
              ),
          ]);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  3 · Mission — one small, real-world action
// ---------------------------------------------------------------------------

class FatherMissionModule extends StatelessWidget {
  const FatherMissionModule({
    super.key,
    required this.day,
    required this.lang,
    required this.father,
  });

  final FatherDay day;
  final AppLanguage lang;
  final FatherContentController father;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final m = day.mission;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.fatherSlate900.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      // The amber "mission" accent bar down the left edge. IntrinsicHeight lets
      // the bar stretch to the card's content height inside the unbounded list.
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          width: 5,
          decoration: BoxDecoration(
            color: _amber,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(26)),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.handyman_rounded, size: 16, color: _amber),
                const SizedBox(width: 7),
                Text(s.missionEyebrow.toUpperCase(),
                    style: text.labelSmall?.copyWith(
                        color: _amber, letterSpacing: 1.1, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 10),
              Text(m.title.of(lang), style: text.headlineSmall),
              const SizedBox(height: 8),
              Text(m.action.of(lang), style: text.bodyLarge?.copyWith(height: 1.5)),
              const SizedBox(height: 16),
              ListenableBuilder(
                listenable: DailyStore.instance,
                builder: (context, _) {
                  final done = DailyStore.instance.isMissionDone(day.day);
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: done ? _amber : _slate,
                        side: BorderSide(
                          color: done ? _amber : AppTheme.fatherSlate200,
                          width: 1.4,
                        ),
                        backgroundColor:
                            done ? _amber.withValues(alpha: 0.10) : null,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        DailyStore.instance.toggleMissionDone(day.day);
                        father.markEngaged(FatherModule.mission);
                      },
                      icon: Icon(
                          done
                              ? Icons.check_circle_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 20),
                      label: Text(done ? s.missionDoneLabel : s.missionMarkDone),
                    ),
                  );
                },
              ),
            ]),
          ),
        ),
      ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Completion acknowledgement
// ---------------------------------------------------------------------------

class FatherCompletionBanner extends StatelessWidget {
  const FatherCompletionBanner({super.key, required this.lang});
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
          color: AppTheme.fatherSlate50,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.emoji_events_rounded, color: _slate, size: 28),
      ),
      const SizedBox(height: 14),
      Text(s.fatherCompletionTitle,
          textAlign: TextAlign.center,
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text(s.fatherCompletionSubtitle,
          textAlign: TextAlign.center, style: text.bodyMedium),
    ]);
  }
}

// ---------------------------------------------------------------------------
//  Today | This Week — the segmented toggle between Daily Moment & Weekly Journey
// ---------------------------------------------------------------------------

class FatherSectionToggle extends StatelessWidget {
  const FatherSectionToggle({
    super.key,
    required this.thisWeek,
    required this.lang,
    required this.onChanged,
  });

  final bool thisWeek;
  final AppLanguage lang;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(children: [
        Expanded(
            child: _seg(context, s.fatherTabToday, !thisWeek,
                () => onChanged(false))),
        Expanded(
            child:
                _seg(context, s.fatherTabThisWeek, thisWeek, () => onChanged(true))),
      ]),
    );
  }

  Widget _seg(BuildContext context, String label, bool selected, VoidCallback onTap) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _slate : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(label,
            style: text.labelLarge?.copyWith(
                color: selected ? Colors.white : AppTheme.neutral600,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Weekly Journey — the deeper once-a-week experience (4 sections)
// ---------------------------------------------------------------------------

class FatherWeeklyView extends StatelessWidget {
  const FatherWeeklyView({super.key, required this.week, required this.lang});

  final FatherWeek week;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(s.fatherWeeklyIntro,
          style: text.bodyMedium?.copyWith(color: AppTheme.neutral600)),
      const SizedBox(height: 14),
      _section(context, s.fatherSecInsight, Icons.lightbulb_rounded, _slate,
          week.insight),
      const SizedBox(height: 14),
      _section(context, s.fatherSecSupport, Icons.volunteer_activism_rounded,
          _coral, week.support),
      const SizedBox(height: 14),
      _section(context, s.fatherSecConnect, Icons.child_care_rounded, _slate,
          week.connect),
      const SizedBox(height: 14),
      _section(context, s.fatherSecMission, Icons.handyman_rounded, _amber,
          week.mission),
    ]);
  }

  Widget _section(BuildContext context, String label, IconData icon, Color accent,
      FatherWeekSection sec) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.fatherSlate900.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label.toUpperCase(),
                style: text.labelSmall?.copyWith(
                    color: accent,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 12),
        Text(sec.title.of(lang),
            style: text.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700, height: 1.35)),
        if (sec.hasBody) ...[
          const SizedBox(height: 8),
          Text(sec.body!.of(lang),
              style: text.bodyMedium
                  ?.copyWith(color: AppTheme.neutral700, height: 1.5)),
        ],
      ]),
    );
  }
}
