// =============================================================================
//  Garbh Sanskar Journey v2.0 — a daily 5-ritual companion (Tools)
// -----------------------------------------------------------------------------
//  Not a content library — a 5–15 minute daily pregnancy ritual. The home is
//  "Today": greeting, week/day, baby size, progress (N/5) and a streak, then the
//  five pillars — Shravan (sound), Vichara (mindset), Samvad (connection),
//  Kriya (movement & breath), Ahara (nourishment). Each is trimester-aware and
//  answers "what to do / why it matters / how long", with a completion tick.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/garbh_data.dart';
import '../localization/app_language.dart';
import '../models/garbh_content.dart';
import '../services/garbh_store.dart';
import '../services/pregnancy_controller.dart';
import '../widgets/cards/raga_player.dart';
import 'home_detail_screens.dart' show TalkComposerScreen;

// --- warm palette ---
const _cream = Color(0xFFFBF6EE);
const _surface = Color(0xFFFFFFFF);
const _ink = Color(0xFF4A463E);
const _muted = Color(0xFF8C857A);
const _line = Color(0xFFE9E0D2);
const _accShravan = Color(0xFFBE9C4E); // gold
const _accVichara = Color(0xFF6E8C74); // muted green
const _accSamvad = Color(0xFFB98A7E); // warm rose
const _accKriya = Color(0xFF5E8B7E); // teal-green
const _accAhara = Color(0xFFC97B4A); // terracotta
const _green = Color(0xFF3FA56A);

void _push(BuildContext c, Widget w) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));

({String emoji, Color accent}) _pillarVisual(String id) {
  switch (id) {
    case 'shravan':
      return (emoji: '🎵', accent: _accShravan);
    case 'vichara':
      return (emoji: '📖', accent: _accVichara);
    case 'samvad':
      return (emoji: '🎙️', accent: _accSamvad);
    case 'kriya':
      return (emoji: '🌿', accent: _accKriya);
    default:
      return (emoji: '🍲', accent: _accAhara);
  }
}

// ===========================================================================
//  Today (home)
// ===========================================================================

class GarbhScreen extends StatelessWidget {
  const GarbhScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final week = controller.currentWeek;
    final t = garbhTrimester(week);
    final dayInWeek = controller.dayOfWeek;
    final snapshot = controller.weekData(week)?.snapshot;
    final hour = DateTime.now().hour;

    // Per-pillar "what to do today" + duration.
    final pillars = <({String id, String name, String tag, String todo, String duration})>[
      (id: 'shravan', name: s.gsShravan, tag: s.gsShravanTag, todo: shravanForTrimester(t).title, duration: s.gsMinutes(shravanForTrimester(t).minutes)),
      (id: 'vichara', name: s.gsVichara, tag: s.gsVicharaTag, todo: 'A reflection, a gentle puzzle, or an uplifting read', duration: '2–5 min'),
      (id: 'samvad', name: s.gsSamvad, tag: s.gsSamvadTag, todo: promptForDay(controller.currentDay).text, duration: '3 min'),
      (id: 'kriya', name: s.gsKriya, tag: s.gsKriyaTag, todo: kriyaForTrimester(t).title, duration: s.gsMinutes(kriyaForTrimester(t).minutes)),
      (id: 'ahara', name: s.gsAhara, tag: s.gsAharaTag, todo: nutritionForTrimester(t).tip, duration: '2 min'),
    ];

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(backgroundColor: _cream, elevation: 0, foregroundColor: _ink),
      body: AnimatedBuilder(
        animation: GarbhStore.instance,
        builder: (context, _) {
          final store = GarbhStore.instance;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
            children: [
              // Header
              Text(s.greeting(hour, controller.motherName),
                  style: text.headlineMedium?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Week $week · ${s.gsDayOfWeek(dayInWeek, week)}',
                  style: text.titleSmall?.copyWith(color: _muted)),
              if (snapshot != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('${s.gsBabySize}: ${snapshot.fruit.of(lang)}',
                      style: text.bodyMedium?.copyWith(color: _muted)),
                ),
              const SizedBox(height: 18),
              // Progress + streak
              _ProgressCard(done: store.doneCount, streak: store.streak, s: s),
              const SizedBox(height: 22),
              Text(s.gsTodaysRituals,
                  style: text.titleMedium?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              for (final p in pillars) ...[
                _PillarCard(
                  pillar: p,
                  done: store.isDone(p.id),
                  onTap: () => _openPillar(context, p.id),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 6),
              if (store.doneCount >= GarbhStore.dailyGoal)
                Center(
                  child: Text(s.gsAllDone,
                      textAlign: TextAlign.center,
                      style: text.titleSmall?.copyWith(color: _green, fontWeight: FontWeight.w800)),
                )
              else
                Center(
                  child: Text(s.gsDailyGoalLine(GarbhStore.dailyGoal),
                      style: text.labelMedium?.copyWith(color: _muted)),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openPillar(BuildContext context, String id) {
    switch (id) {
      case 'shravan':
        _push(context, ShravanScreen(controller: controller));
        break;
      case 'vichara':
        _push(context, VicharaScreen(controller: controller));
        break;
      case 'samvad':
        _push(context, SamvadScreen(controller: controller));
        break;
      case 'kriya':
        _push(context, KriyaScreen(controller: controller));
        break;
      default:
        _push(context, AharaScreen(controller: controller));
    }
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.done, required this.streak, required this.s});
  final int done;
  final int streak;
  final S s;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final frac = (done / GarbhStore.dailyGoal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Row(children: [
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                value: frac,
                strokeWidth: 6,
                backgroundColor: _line,
                valueColor: const AlwaysStoppedAnimation(_green),
              ),
            ),
            Text('$done/${GarbhStore.dailyGoal}',
                style: text.labelMedium?.copyWith(fontWeight: FontWeight.w800, color: _ink)),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.gsTodaysProgress,
                style: text.titleSmall?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(s.gsRitualsDone(done, GarbhStore.dailyGoal),
                style: text.bodyMedium?.copyWith(color: _muted)),
            if (streak > 0) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text(s.gsDayStreak(streak),
                    style: text.labelMedium?.copyWith(
                        color: _accAhara, fontWeight: FontWeight.w800)),
              ]),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _PillarCard extends StatelessWidget {
  const _PillarCard({required this.pillar, required this.done, required this.onTap});
  final ({String id, String name, String tag, String todo, String duration}) pillar;
  final bool done;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final v = _pillarVisual(pillar.id);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [v.accent.withValues(alpha: done ? 0.10 : 0.16), _surface],
            stops: const [0.0, 0.85],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: v.accent.withValues(alpha: 0.22)),
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: v.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(v.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(pillar.name,
                    style: text.titleMedium?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Text('· ${pillar.duration}',
                    style: text.labelSmall?.copyWith(color: _muted)),
              ]),
              Text(pillar.tag, style: text.labelSmall?.copyWith(color: v.accent, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(pillar.todo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(color: _muted, height: 1.3)),
            ]),
          ),
          const SizedBox(width: 10),
          // completion circle
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? _green : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: done ? _green : _line, width: 2),
            ),
            child: done
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : null,
          ),
        ]),
      ),
    );
  }
}

// ===========================================================================
//  Shared widgets
// ===========================================================================

class _PillarScaffold extends StatelessWidget {
  const _PillarScaffold({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _cream,
        appBar: AppBar(
            backgroundColor: _cream, elevation: 0, foregroundColor: _ink, title: Text(title)),
        body: child,
      );
}

class _WhyCard extends StatelessWidget {
  const _WhyCard({required this.label, required this.text, required this.accent});
  final String label;
  final String text;
  final Color accent;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: t.labelSmall?.copyWith(color: accent, letterSpacing: 0.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(text, style: t.bodyMedium?.copyWith(height: 1.45, color: _ink)),
      ]),
    );
  }
}

class _MarkComplete extends StatelessWidget {
  const _MarkComplete({required this.pillarId, required this.accent, this.lang});
  final String pillarId;
  final Color accent;
  final AppLanguage? lang;
  @override
  Widget build(BuildContext context) {
    final s = S(lang ?? AppLanguage.english);
    final text = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: GarbhStore.instance,
      builder: (context, _) {
        final done = GarbhStore.instance.isDone(pillarId);
        return SizedBox(
          width: double.infinity,
          child: done
              ? OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _green,
                    side: const BorderSide(color: _green, width: 1.4),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(s.gsCompletedToday),
                )
              : FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: accent, padding: const EdgeInsets.symmetric(vertical: 13)),
                  onPressed: () => GarbhStore.instance.markDone(pillarId),
                  child: Text(s.gsMarkDone,
                      style: text.labelLarge?.copyWith(color: Colors.white)),
                ),
        );
      },
    );
  }
}

class _LearnMore extends StatelessWidget {
  const _LearnMore({required this.lang});
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.gsLearnMoreSoon))),
        icon: const Icon(Icons.auto_awesome_rounded, size: 16),
        label: Text(s.gsLearnMore),
      ),
    );
  }
}

// ===========================================================================
//  Pillar 1 — Shravan
// ===========================================================================

class ShravanScreen extends StatelessWidget {
  const ShravanScreen({super.key, required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final t = garbhTrimester(controller.currentWeek);
    final audio = shravanForTrimester(t);
    final more = kShravan.where((a) => a.id != audio.id).take(4).toList();
    return _PillarScaffold(
      title: s.gsShravan,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
        children: [
          Text(s.gsTodaysSession, style: text.labelMedium?.copyWith(color: _muted)),
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 150,
              height: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  _accShravan.withValues(alpha: 0.30),
                  const Color(0xFFEDE6D6),
                ]),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Text(audio.emoji, style: const TextStyle(fontSize: 64)),
            ),
          ),
          const SizedBox(height: 16),
          Text(audio.title,
              textAlign: TextAlign.center,
              style: text.headlineSmall?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
          Text('${audio.subtitle} · ${s.gsMinutes(audio.minutes)}',
              textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: _muted)),
          const SizedBox(height: 16),
          _WhyCard(label: s.gsWhyToday, text: shravanWhy(t), accent: _accShravan),
          const SizedBox(height: 16),
          RagaPlayer(title: audio.title, subtitle: '${audio.minutes} min'),
          const SizedBox(height: 8),
          Text(s.gsSampleAudio,
              textAlign: TextAlign.center, style: text.labelSmall?.copyWith(color: _muted)),
          const SizedBox(height: 16),
          _MarkComplete(pillarId: 'shravan', accent: _accShravan, lang: lang),
          _LearnMore(lang: lang),
          const SizedBox(height: 12),
          for (final a in more)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(a.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(a.title, style: text.titleSmall),
              subtitle: Text('${a.subtitle} · ${s.gsMinutes(a.minutes)}',
                  style: text.labelSmall?.copyWith(color: _muted)),
              trailing: const Icon(Icons.play_circle_outline_rounded, color: _accShravan),
              onTap: () {},
            ),
        ],
      ),
    );
  }
}

// ===========================================================================
//  Pillar 2 — Vichara (3 tabs)
// ===========================================================================

class VicharaScreen extends StatelessWidget {
  const VicharaScreen({super.key, required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _cream,
        appBar: AppBar(
          backgroundColor: _cream,
          elevation: 0,
          foregroundColor: _ink,
          title: Text(s.gsVichara),
          bottom: TabBar(
            labelColor: _accVichara,
            unselectedLabelColor: _muted,
            indicatorColor: _accVichara,
            isScrollable: true,
            tabs: [
              Tab(text: s.gsTabSacred),
              Tab(text: s.gsTabBrain),
              Tab(text: s.gsTabUplifting),
            ],
          ),
        ),
        body: TabBarView(children: [
          _SacredTab(controller: controller),
          _BrainTab(controller: controller),
          _UpliftingTab(controller: controller),
        ]),
      ),
    );
  }
}

class _SacredTab extends StatelessWidget {
  const _SacredTab({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final ins = insightForTrimester(garbhTrimester(controller.currentWeek));
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_accVichara.withValues(alpha: 0.14), _surface]),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _accVichara.withValues(alpha: 0.22)),
          ),
          child: Text('"${ins.sloka}"',
              style: text.headlineSmall?.copyWith(
                  color: _ink, height: 1.4, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 16),
        _miniSection(context, s.gsMeaning, ins.meaning),
        _miniSection(context, s.gsLesson, ins.lesson),
        const SizedBox(height: 6),
        _WhyCard(label: s.gsReflectMoment, text: ins.reflection, accent: _accVichara),
        const SizedBox(height: 18),
        _MarkComplete(pillarId: 'vichara', accent: _accVichara, lang: lang),
      ],
    );
  }
}

Widget _miniSection(BuildContext context, String label, String body) {
  final t = Theme.of(context).textTheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(),
          style: t.labelSmall?.copyWith(color: _muted, letterSpacing: 0.5, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(body, style: t.bodyLarge?.copyWith(color: _ink, height: 1.5)),
    ]),
  );
}

class _BrainTab extends StatelessWidget {
  const _BrainTab({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      children: [
        Text('A few quiet minutes of focused calm.',
            style: text.bodyMedium?.copyWith(color: _muted)),
        const SizedBox(height: 14),
        for (final p in kPuzzles)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _line),
            ),
            child: Row(children: [
              Text(p.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                  Text(p.blurb, style: text.labelSmall?.copyWith(color: _muted)),
                ]),
              ),
              TextButton(
                onPressed: () {
                  GarbhStore.instance.markDone('vichara');
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(s.gsPuzzleSoon)));
                },
                child: Text(s.gsStart),
              ),
            ]),
          ),
      ],
    );
  }
}

class _UpliftingTab extends StatelessWidget {
  const _UpliftingTab({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      children: [
        for (final story in kVichara)
          GestureDetector(
            onTap: () => _push(context, _VicharaReader(story: story, controller: controller)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _line),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accVichara.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(story.theme,
                      style: text.labelSmall?.copyWith(color: _accVichara, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 10),
                Text(story.title,
                    style: text.titleLarge?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(story.blurb, style: text.bodyMedium?.copyWith(color: _muted, height: 1.4)),
                const SizedBox(height: 10),
                Row(children: [
                  Text(s.gsRead,
                      style: text.labelLarge?.copyWith(color: _accVichara, fontWeight: FontWeight.w800)),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: _accVichara),
                  const Spacer(),
                  Text(s.gsMinRead(story.minutes),
                      style: text.labelSmall?.copyWith(color: _muted)),
                ]),
              ]),
            ),
          ),
      ],
    );
  }
}

class _VicharaReader extends StatelessWidget {
  const _VicharaReader({required this.story, required this.controller});
  final GarbhStory story;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    return _PillarScaffold(
      title: story.theme,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 32),
        children: [
          Text(story.title,
              style: text.headlineMedium?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(s.gsMinRead(story.minutes), style: text.labelSmall?.copyWith(color: _muted)),
          const SizedBox(height: 18),
          for (final para in story.body.split('\n\n')) ...[
            Text(para, style: text.bodyLarge?.copyWith(color: _ink, height: 1.7, fontSize: 17)),
            const SizedBox(height: 16),
          ],
          _WhyCard(label: s.gsReflectMoment, text: story.reflection, accent: _accVichara),
          const SizedBox(height: 18),
          _MarkComplete(pillarId: 'vichara', accent: _accVichara, lang: lang),
        ],
      ),
    );
  }
}

// ===========================================================================
//  Pillar 3 — Samvad
// ===========================================================================

class SamvadScreen extends StatefulWidget {
  const SamvadScreen({super.key, required this.controller});
  final PregnancyController controller;
  @override
  State<SamvadScreen> createState() => _SamvadScreenState();
}

class _SamvadScreenState extends State<SamvadScreen> {
  late int _index;
  @override
  void initState() {
    super.initState();
    _index = (widget.controller.currentDay.clamp(1, 280) - 1) % kSamvad.length;
  }

  GarbhPrompt get _prompt => kSamvad[_index];

  Future<void> _compose(bool voice) async {
    final c = widget.controller;
    final s = S(c.language);
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TalkComposerScreen(
        day: c.currentDay,
        week: c.currentWeek,
        prompt: _prompt.text,
        motivation: s.gsSamvadTag,
        lang: c.language,
        startWithVoice: voice,
      ),
    ));
    if (!mounted) return;
    GarbhStore.instance.markDone('samvad');
    _push(context, _MemorySavedScreen(controller: c));
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final t = garbhTrimester(widget.controller.currentWeek);
    return _PillarScaffold(
      title: s.gsSamvad,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        children: [
          Text(s.gsTodaysConnection,
              style: text.labelMedium?.copyWith(
                  color: _accSamvad, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_accSamvad.withValues(alpha: 0.16), _surface]),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _accSamvad.withValues(alpha: 0.22)),
            ),
            child: Text(_prompt.text,
                style: text.headlineSmall?.copyWith(color: _ink, height: 1.4, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          _WhyCard(label: s.gsWhyMatters, text: samvadThemeForTrimester(t), accent: _accSamvad),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _index = (_index + 1) % kSamvad.length),
              icon: const Icon(Icons.refresh_rounded, size: 18, color: _accSamvad),
              label: Text(s.gsAnotherPrompt, style: text.labelLarge?.copyWith(color: _accSamvad)),
            ),
          ),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: _accSamvad, padding: const EdgeInsets.symmetric(vertical: 13)),
                onPressed: () => _compose(true),
                icon: const Icon(Icons.mic_rounded, size: 18, color: Colors.white),
                label: Text(s.gsRecordVoice, style: text.labelLarge?.copyWith(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _accSamvad,
                  side: const BorderSide(color: _accSamvad, width: 1.4),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onPressed: () => _compose(false),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text(s.gsWriteMessage),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          _MarkComplete(pillarId: 'samvad', accent: _accSamvad, lang: lang),
        ],
      ),
    );
  }
}

class _MemorySavedScreen extends StatelessWidget {
  const _MemorySavedScreen({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    return _PillarScaffold(
      title: s.gsSamvad,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('❤️', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 18),
            Text(s.gsMemorySaved,
                style: text.headlineSmall?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(s.gsMemorySavedBody,
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: _muted, height: 1.5)),
            const SizedBox(height: 28),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: _accSamvad,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 13)),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ]),
        ),
      ),
    );
  }
}

// ===========================================================================
//  Pillar 4 — Kriya
// ===========================================================================

class KriyaScreen extends StatelessWidget {
  const KriyaScreen({super.key, required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final t = garbhTrimester(controller.currentWeek);
    final practice = kriyaForTrimester(t);
    return _PillarScaffold(
      title: s.gsKriya,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        children: [
          Text(s.gsTodaysPractice, style: text.labelMedium?.copyWith(color: _muted)),
          const SizedBox(height: 12),
          Center(child: Text(practice.emoji, style: const TextStyle(fontSize: 52))),
          const SizedBox(height: 10),
          Text(practice.title,
              textAlign: TextAlign.center,
              style: text.headlineSmall?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
          Text('${practice.blurb} · ${s.gsMinutes(practice.minutes)}',
              textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: _muted)),
          const SizedBox(height: 16),
          _WhyCard(label: s.gsSafetyNotes, text: kriyaSafety(t), accent: _accKriya),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: _accKriya, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () => _push(context, _BreathingScreen(practice: practice, lang: lang)),
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: Text(s.gsStart, style: text.labelLarge?.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
          _MarkComplete(pillarId: 'kriya', accent: _accKriya, lang: lang),
        ],
      ),
    );
  }
}

class _BreathingScreen extends StatefulWidget {
  const _BreathingScreen({required this.practice, required this.lang});
  final GarbhPractice practice;
  final AppLanguage lang;
  @override
  State<_BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<_BreathingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _scale;
  int _index = 0;
  double _current = 0.5;
  String _label = '';

  List<BreathPhase> get _phases => widget.practice.phases;
  BreathPhase get _phase => _phases[_index % _phases.length];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
    _ctrl.addStatusListener((st) {
      if (st == AnimationStatus.completed && mounted) {
        _index++;
        _run();
      }
    });
    _run();
  }

  void _run() {
    final p = _phase;
    _scale = Tween<double>(begin: _current, end: p.scale)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _current = p.scale;
    _label = p.label;
    _ctrl
      ..duration = Duration(seconds: p.seconds)
      ..reset()
      ..forward();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.lang);
    final text = Theme.of(context).textTheme;
    return _PillarScaffold(
      title: widget.practice.title,
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final v = _scale.value;
              final remaining = (_phase.seconds * (1 - _ctrl.value)).ceil();
              return Column(children: [
                SizedBox(
                  height: 260,
                  width: 260,
                  child: Center(
                    child: Container(
                      width: 120 + 130 * v,
                      height: 120 + 130 * v,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          _accKriya.withValues(alpha: 0.30),
                          _accKriya.withValues(alpha: 0.10),
                        ]),
                      ),
                      child: Text('$remaining',
                          style: text.displaySmall?.copyWith(color: _ink, fontWeight: FontWeight.w300)),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(_label,
                    style: text.headlineSmall?.copyWith(color: _ink, fontWeight: FontWeight.w700)),
              ]);
            },
          ),
          const SizedBox(height: 40),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: _accKriya,
              side: const BorderSide(color: _accKriya, width: 1.4),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 13),
            ),
            onPressed: () {
              GarbhStore.instance.markDone('kriya');
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${s.gsWellDone} — ${s.gsWellDoneBody}')),
              );
            },
            child: Text(s.gsFinish),
          ),
        ]),
      ),
    );
  }
}

// ===========================================================================
//  Pillar 5 — Ahara
// ===========================================================================

class AharaScreen extends StatelessWidget {
  const AharaScreen({super.key, required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final n = nutritionForTrimester(garbhTrimester(controller.currentWeek));
    return _PillarScaffold(
      title: s.gsAhara,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        children: [
          Text(s.gsTodaysNutrition, style: text.labelMedium?.copyWith(color: _muted)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_accAhara.withValues(alpha: 0.14), _surface]),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _accAhara.withValues(alpha: 0.22)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('🍲', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(n.tip,
                      style: text.titleMedium?.copyWith(color: _ink, fontWeight: FontWeight.w700, height: 1.3)),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          _WhyCard(label: s.gsWhyMatters, text: n.why, accent: _accAhara),
          const SizedBox(height: 14),
          _aharaRow(context, '🍽️', s.gsRecipe, n.recipe),
          _aharaRow(context, '🔄', s.gsFoodSwap, n.swap),
          _aharaRow(context, '🌙', s.gsLifestyleHabit, n.habit),
          const SizedBox(height: 14),
          _MarkComplete(pillarId: 'ahara', accent: _accAhara, lang: lang),
          _LearnMore(lang: lang),
        ],
      ),
    );
  }
}

Widget _aharaRow(BuildContext context, String emoji, String label, String body) {
  final t = Theme.of(context).textTheme;
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _line),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(emoji, style: const TextStyle(fontSize: 22)),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: t.labelSmall?.copyWith(color: _muted, letterSpacing: 0.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(body, style: t.bodyMedium?.copyWith(color: _ink, height: 1.4)),
        ]),
      ),
    ]),
  );
}
