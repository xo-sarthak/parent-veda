// =============================================================================
//  Garbh Sanskar Journey v2.0 - a daily 5-ritual companion (Tools)
// -----------------------------------------------------------------------------
//  Not a content library - a 5–15 minute daily pregnancy ritual. The home is
//  "Today": greeting, week/day, baby size, progress (N/5) and a streak, then the
//  five pillars - Shravan (sound), Vichara (mindset), Samvad (connection),
//  Kriya (movement & breath), Ahara (nourishment). Each is trimester-aware and
//  answers "what to do / why it matters / how long", with a completion tick.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/garbh_data.dart';
import '../data/read_to_baby_data.dart';
import '../data/spiritual_reading_data.dart';
import '../localization/app_language.dart';
import '../models/garbh_content.dart';
import '../services/garbh_store.dart';
import '../services/pregnancy_controller.dart';
import '../services/read_to_baby_saved_store.dart';
import '../services/read_to_baby_store.dart';
import '../services/samvad_pool.dart';
import '../theme/app_theme.dart';
import '../widgets/cards/raga_player.dart';
// TalkComposerScreen parked - the Samvad record/write composer was removed when
// "Read to your baby" folded into Samvad. Kept commented for revert.
// import 'home_detail_screens.dart' show TalkComposerScreen;
import 'tools/ask_veda_screen.dart';
import 'tools/garbh_games.dart';

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

// Route a Vichara brain-fitness puzzle card to its real game.
Widget _gameFor(GarbhPuzzle p, PregnancyController c,
    {bool markComplete = true}) {
  switch (p.title) {
    case 'Sudoku':
      return SudokuGame(controller: c, markComplete: markComplete);
    case 'Logic Puzzle':
      return LogicGame(controller: c, markComplete: markComplete);
    case 'Memory Match':
      return MemoryMatchGame(controller: c, markComplete: markComplete);
    case 'Word Search':
    default:
      return WordSearchGame(controller: c, markComplete: markComplete);
  }
}

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

    // Tools Garbh Sanskar = a calm LIBRARY (NO "today" framing - that lives only
    // in the daily Garbh section on Home). Intro → four pillar tiles → each opens
    // the FULL repository of that pillar (daily == false).
    final pillars = <({String id, String name, String desc})>[
      (id: 'shravan', name: s.gsShravan, desc: s.gsShravanDesc),
      // Vichara pillar removed from the hub - its brain-fitness games now live
      // inside Kriya (Brain Fitness) and its reflective reads move under Samvad.
      // The daily Home Garbh section still uses VicharaScreen(daily:true), so the
      // class + data stay. (Kept commented for revert.)
      // (id: 'vichara', name: s.gsVichara, desc: s.gsVicharaDesc),
      // Samvad renamed to "Samvad & Vichara" at the call site (inline, per the
      // no-edit-app_language rule). Content inside SamvadScreen is unchanged.
      (
        id: 'samvad',
        name: lang.isHinglish ? 'Samvad & Vichara' : 'Samvad & Vichara',
        desc: s.gsSamvadDesc
      ),
      (id: 'kriya', name: s.gsKriya, desc: s.gsKriyaDesc),
    ];

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
          backgroundColor: AppTheme.surfaceContainer,
          elevation: 0,
          foregroundColor: AppTheme.primary900),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
        children: [
          // Intro - what Garbh Sanskar is + why it matters (no kicker/title hero,
          // no raga "video" hero, no progress/streak, no "today's rituals").
          Text(s.garbhSanskar,
              style: GoogleFonts.fraunces(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary900)),
          const SizedBox(height: 10),
          Text(s.gsAboutBody,
              style: text.bodyMedium?.copyWith(color: _ink, height: 1.55)),
          const SizedBox(height: 8),
          Text(s.gsAboutMeaning,
              style: text.bodySmall
                  ?.copyWith(color: _muted, fontStyle: FontStyle.italic)),
          const SizedBox(height: 22),
          for (final p in pillars) ...[
            _LibraryTile(
              id: p.id,
              name: p.name,
              desc: p.desc,
              onTap: () => _openPillar(context, p.id),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  void _openPillar(BuildContext context, String id) {
    switch (id) {
      case 'shravan':
        _push(context, ShravanScreen(controller: controller));
        break;
      // Vichara pillar removed from the hub (see pillars list above). Kept for
      // revert - VicharaScreen is still used by the daily Home Garbh section.
      // case 'vichara':
      //   _push(context, VicharaScreen(controller: controller));
      //   break;
      case 'samvad':
        _push(context,
            SamvadScreen(controller: controller, hubTitle: 'Samvad & Vichara'));
        break;
      case 'kriya':
        _push(context, KriyaScreen(controller: controller));
        break;
      default:
        _push(context, AharaScreen(controller: controller));
    }
  }
}

// A plain library tile (name + description) - no done-tick, no "today's todo".
class _LibraryTile extends StatelessWidget {
  const _LibraryTile(
      {required this.id,
      required this.name,
      required this.desc,
      required this.onTap});
  final String id;
  final String name;
  final String desc;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final v = _pillarVisual(id);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [v.accent.withValues(alpha: 0.14), _surface],
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: text.titleMedium
                      ?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(desc,
                  style: text.bodySmall?.copyWith(color: _muted, height: 1.35)),
            ]),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              color: v.accent.withValues(alpha: 0.7)),
        ]),
      ),
    );
  }
}

// The design's calm raga/breathing hero - no longer on the Tools hub (kept for
// revert).
// ignore: unused_element
class _RagaHero extends StatelessWidget {
  const _RagaHero({required this.controller, required this.onTap});
  final PregnancyController controller;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final audio = shravanForTrimester(garbhTrimester(controller.currentWeek));
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary400, AppTheme.primary700],
            ),
          ),
          child: Stack(alignment: Alignment.center, children: [
            for (final d in const [110.0, 170.0, 230.0])
              Container(
                width: d,
                height: d,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
              ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 92,
                height: 92,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle),
                child: Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded,
                      size: 30, color: AppTheme.primary600),
                ),
              ),
              const SizedBox(height: 16),
              Text(audio.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
              const SizedBox(height: 2),
              Text('${audio.subtitle} · ${s.gsMinutes(audio.minutes)}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                      fontSize: 13, color: Colors.white.withValues(alpha: 0.85))),
            ]),
          ]),
        ),
      ),
    );
  }
}

// Today's progress/streak - only on the daily Garbh (Home); kept for revert.
// ignore: unused_element
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

// Old "today's ritual" card (done-tick + todo) - replaced by _LibraryTile on the
// Tools hub; kept for revert.
// ignore: unused_element
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
  const _LearnMore({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    // Ask Veda is live - open it (it can pull the whole app for guidance).
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AskVedaScreen(controller: controller),
        )),
        icon: const Icon(Icons.auto_awesome_rounded, size: 16),
        label: Text(s.gsLearnMore),
      ),
    );
  }
}

// ===========================================================================
//  Pillar 1 - Shravan
// ===========================================================================

class ShravanScreen extends StatelessWidget {
  const ShravanScreen({super.key, required this.controller, this.daily = false});
  final PregnancyController controller;

  /// Daily (Home) mode: rotate the raga by day and hide the recommendations.
  final bool daily;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;

    // Tools library: browse listening sessions month-by-month (opens on the
    // current month), each tappable; no mark-complete. (Old flat "all ragas"
    // list kept in git history / _ShravanDetailScreen for revert.)
    if (!daily) {
      return _ShravanLibrary(controller: controller);
    }

    // Daily (Home): today's session + mark-complete.
    final t = garbhTrimester(controller.currentWeek);
    final audio = shravanForDay(controller.currentDay);
    return _PillarScaffold(
      title: s.gsShravan,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
        children: [
          Text(s.gsTodaysSession,
              style: text.labelMedium?.copyWith(color: _muted)),
          const SizedBox(height: 12),
          _ShravanHero(audio: audio, s: s),
          const SizedBox(height: 16),
          _WhyCard(label: s.gsWhyToday, text: shravanWhy(t), accent: _accShravan),
          const SizedBox(height: 16),
          RagaPlayer(title: audio.title, subtitle: '${audio.minutes} min'),
          const SizedBox(height: 8),
          Text(s.gsSampleAudio,
              textAlign: TextAlign.center,
              style: text.labelSmall?.copyWith(color: _muted)),
          const SizedBox(height: 16),
          _MarkComplete(pillarId: 'shravan', accent: _accShravan, lang: lang),
          _LearnMore(controller: controller),
        ],
      ),
    );
  }
}

// One raga's emoji hero + title (shared by daily Shravan + the library detail).
class _ShravanHero extends StatelessWidget {
  const _ShravanHero({required this.audio, required this.s});
  final GarbhAudio audio;
  final S s;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(children: [
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
          style: text.headlineSmall
              ?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
      Text('${audio.subtitle} · ${s.gsMinutes(audio.minutes)}',
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: _muted)),
    ]);
  }
}

// A single raga's detail in the Tools library (player only - no mark-complete).
class _ShravanDetailScreen extends StatelessWidget {
  const _ShravanDetailScreen({required this.audio, required this.controller});
  final GarbhAudio audio;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    return _PillarScaffold(
      title: s.gsShravan,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          _ShravanHero(audio: audio, s: s),
          const SizedBox(height: 16),
          RagaPlayer(title: audio.title, subtitle: '${audio.minutes} min'),
          const SizedBox(height: 8),
          Text(s.gsSampleAudio,
              textAlign: TextAlign.center,
              style: text.labelSmall?.copyWith(color: _muted)),
        ],
      ),
    );
  }
}

// A small Morning / Evening badge for a listening item.
class _RagaTimeBadge extends StatelessWidget {
  const _RagaTimeBadge({required this.audio});
  final GarbhAudio audio;
  @override
  Widget build(BuildContext context) {
    final evening = ragaTimeBadge(audio) == 'Evening';
    final color = evening ? _accSamvad : _accShravan;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
            evening
                ? Icons.nightlight_round
                : Icons.wb_sunny_outlined,
            size: 12,
            color: color),
        const SizedBox(width: 4),
        Text(evening ? 'Evening' : 'Morning',
            style: TextStyle(
                fontSize: 10.5, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }
}

// Shravan Tools library - month selector (Month 1-9, opens on current month) +
// that month's listening sessions with Morning/Evening badges.
class _ShravanLibrary extends StatefulWidget {
  const _ShravanLibrary({required this.controller});
  final PregnancyController controller;
  @override
  State<_ShravanLibrary> createState() => _ShravanLibraryState();
}

class _ShravanLibraryState extends State<_ShravanLibrary> {
  late int _month;

  @override
  void initState() {
    super.initState();
    _month = garbhMonth(widget.controller.currentWeek);
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final text = Theme.of(context).textTheme;
    final sessions = shravanForMonth(_month);
    final currentMonth = garbhMonth(widget.controller.currentWeek);
    return _PillarScaffold(
      title: s.gsShravan,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          Text(
              widget.controller.language.isHinglish
                  ? 'Har mahine ke liye chuni gayi listening sessions.'
                  : 'Listening sessions gathered for each month.',
              style: text.bodyMedium?.copyWith(color: _muted)),
          const SizedBox(height: 14),
          // Month selector (1-9).
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 9,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final m = i + 1;
                final selected = m == _month;
                final isCurrent = m == currentMonth;
                return GestureDetector(
                  onTap: () => setState(() => _month = m),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: selected
                          ? _accShravan
                          : _accShravan.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isCurrent && !selected
                              ? _accShravan
                              : Colors.transparent),
                    ),
                    child: Text(
                      widget.controller.language.isHinglish
                          ? 'Mahina $m'
                          : 'Month $m',
                      style: text.labelMedium?.copyWith(
                          color: selected ? Colors.white : _accShravan,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          if (_month == currentMonth)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2),
              child: Text(
                  widget.controller.language.isHinglish
                      ? 'Aap abhi yahan hain'
                      : 'You are here now',
                  style: text.labelSmall?.copyWith(
                      color: _accShravan, fontWeight: FontWeight.w800)),
            ),
          const SizedBox(height: 8),
          if (sessions.isEmpty)
            Text(
                widget.controller.language.isHinglish
                    ? 'Is mahine ke liye abhi koi session nahi.'
                    : 'No sessions for this month yet.',
                style: text.bodyMedium?.copyWith(color: _muted))
          else
            for (final a in sessions)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: _accShravan.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(13)),
                    child: Text(a.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                  title: Row(children: [
                    Flexible(
                      child: Text(a.title,
                          style: text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700, color: _ink)),
                    ),
                    const SizedBox(width: 8),
                    _RagaTimeBadge(audio: a),
                  ]),
                  subtitle: Text('${a.subtitle} · ${s.gsMinutes(a.minutes)}',
                      style: text.labelSmall?.copyWith(color: _muted)),
                  trailing: const Icon(Icons.play_circle_outline_rounded,
                      color: _accShravan),
                  onTap: () => _push(
                      context,
                      _ShravanDetailScreen(
                          audio: a, controller: widget.controller)),
                ),
              ),
        ],
      ),
    );
  }
}

// ===========================================================================
//  Pillar 2 - Vichara (3 tabs)
// ===========================================================================

class VicharaScreen extends StatelessWidget {
  const VicharaScreen({super.key, required this.controller, this.daily = false});
  final PregnancyController controller;
  final bool daily;
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
          _SacredTab(controller: controller, daily: daily),
          _BrainTab(controller: controller, daily: daily),
          _UpliftingTab(controller: controller, daily: daily),
        ]),
      ),
    );
  }
}

class _SacredTab extends StatelessWidget {
  const _SacredTab({required this.controller, this.daily = false});
  final PregnancyController controller;
  final bool daily;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    // Tools library: ALL Sacred Insights, no mark-complete.
    if (!daily) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          for (final ins in garbhAllInsights()) _insightCard(context, s, ins),
        ],
      );
    }
    // Daily: today's insight + mark-complete.
    final ins = insightForDay(controller.currentDay);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      children: [
        _insightCard(context, s, ins),
        _MarkComplete(pillarId: 'vichara', accent: _accVichara, lang: lang),
      ],
    );
  }

  Widget _insightCard(BuildContext context, S s, GarbhInsight ins) {
    final text = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [_accVichara.withValues(alpha: 0.14), _surface]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _accVichara.withValues(alpha: 0.22)),
        ),
        child: Text('"${ins.sloka}"',
            style: text.headlineSmall?.copyWith(
                color: _ink,
                height: 1.4,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600)),
      ),
      const SizedBox(height: 16),
      _miniSection(context, s.gsMeaning, ins.meaning),
      _miniSection(context, s.gsLesson, ins.lesson),
      const SizedBox(height: 6),
      _WhyCard(
          label: s.gsReflectMoment, text: ins.reflection, accent: _accVichara),
      const SizedBox(height: 18),
    ]);
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
  const _BrainTab({required this.controller, this.daily = false});
  final PregnancyController controller;

  /// In the Tools library (daily == false), finishing a game does NOT mark the
  /// Vichara ritual done - it's just play.
  final bool daily;
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
                // Opens the real game; in DAILY mode finishing marks Vichara done
                // (inside each game). In the Tools library (daily=false) it does
                // not - it's just play. (gsPuzzleSoon kept for revert.)
                onPressed: () => _push(
                    context, _gameFor(p, controller, markComplete: daily)),
                child: Text(s.gsStart),
              ),
            ]),
          ),
      ],
    );
  }
}

class _UpliftingTab extends StatelessWidget {
  const _UpliftingTab({required this.controller, this.daily = false});
  final PregnancyController controller;
  final bool daily;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    // Daily (Home) mode shows a single read; the full library is hidden.
    final stories =
        daily ? [vicharaStoryForDay(controller.currentDay)] : kVichara;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      children: [
        for (final story in stories)
          GestureDetector(
            onTap: () => _push(context,
                _VicharaReader(story: story, controller: controller, daily: daily)),
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
  const _VicharaReader(
      {required this.story, required this.controller, this.daily = false});
  final GarbhStory story;
  final PregnancyController controller;
  final bool daily;
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
          // Mark-complete only in DAILY mode (Tools library = no "today's done").
          if (daily)
            _MarkComplete(pillarId: 'vichara', accent: _accVichara, lang: lang),
        ],
      ),
    );
  }
}

// ===========================================================================
//  Pillar 3 - Samvad
// ===========================================================================

class SamvadScreen extends StatefulWidget {
  const SamvadScreen(
      {super.key, required this.controller, this.daily = false, this.hubTitle});
  final PregnancyController controller;

  /// Daily (Home): today's speaking card + mark-complete. Tools (daily=false):
  /// the full library of speaking cards, browsable, no mark-complete.
  final bool daily;

  /// Optional app-bar title override (the Tools hub passes "Samvad & Vichara").
  /// Content is unchanged; only the header label differs. Null = s.gsSamvad.
  final String? hubTitle;
  @override
  State<SamvadScreen> createState() => _SamvadScreenState();
}

typedef _SP = ({String? title, String body, String saveKey, String group});

class _SamvadScreenState extends State<SamvadScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  ReadToBabyStore get _store => ReadToBabyStore.instance;
  int get _trimester => garbhTrimester(widget.controller.currentWeek);

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    // Vichara-style: 4 fixed tabs, one section each. Daily = one piece per tab;
    // Tools = the full library per tab. (The old vertical customize-feed scroll
    // is replaced; category on/off is gone - only Spiritual keeps a chooser.)
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        foregroundColor: _ink,
        title: Text(widget.hubTitle ?? s.gsSamvad),
        bottom: TabBar(
          controller: _tab,
          labelColor: _accSamvad,
          unselectedLabelColor: _muted,
          indicatorColor: _accSamvad,
          isScrollable: true,
          tabs: [
            Tab(text: s.gsSamvadTabAffirm),
            Tab(text: s.gsSamvadTabStories),
            Tab(text: s.gsSamvadTabMantras),
            Tab(text: s.gsSamvadTabSpiritual),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _listTab(_affirmationPieces()),
          _listTab(_storyPieces()),
          _listTab(_mantraLullabyPieces()),
          _spiritualTab(s),
        ],
      ),
    );
  }

  // ---- Content per section (record: title?, body, saveKey, group) ----------
  List<_SP> _affirmationPieces() => [
        for (final p in readAloudByCategory(kRtbAffirmations))
          (
            title: p.title,
            body: p.body,
            saveKey: p.title,
            group: 'Affirmations & Blessings'
          ),
      ];

  List<_SP> _storyPieces() => [
        for (final p in readAloudByCategory(kRtbStories))
          (
            title: p.title,
            body: p.body,
            saveKey: p.title,
            group: 'Stories & Fables'
          ),
      ];

  // Mantras (this trimester's speaking cards) + lullabies (rhymes).
  List<_SP> _mantraLullabyPieces() => [
        for (final p in samvadForTrimester(_trimester))
          (
            title: null,
            body: p.text,
            saveKey: 'mantra_${p.id}',
            group: 'Mantras & Lullabies'
          ),
        for (final p in readAloudByCategory(kRtbRhymes))
          (
            title: p.title,
            body: p.body,
            saveKey: p.title,
            group: 'Mantras & Lullabies'
          ),
      ];

  // Spiritual reading - only from the traditions/sections the mother enabled.
  List<_SP> _spiritualPieces() {
    final out = <_SP>[];
    for (final tr in kSpiritualTraditions) {
      if (!_store.isReligionOn(tr.id)) continue;
      for (var i = 0; i < tr.sections.length; i++) {
        if (!_store.isSectionOn(tr.id, i)) continue;
        for (final r in tr.sections[i].reads) {
          out.add((
            title: r.title,
            body: r.body,
            saveKey: r.title,
            group: tr.name
          ));
        }
      }
    }
    return out;
  }

  // ---- Generic tab: daily = today's one piece; tools = the full list -------
  Widget _listTab(List<_SP> pieces) {
    final s = S(widget.controller.language);
    final text = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: ReadToBabySavedStore.instance,
      builder: (context, _) {
        if (pieces.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: [_emptyHint(text)],
          );
        }
        if (!widget.daily) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: [
              for (final p in pieces) _pieceCard(text, s, p, compact: true),
            ],
          );
        }
        final day = widget.controller.currentDay.clamp(1, 280);
        final p = pieces[(day - 1) % pieces.length];
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            _pieceCard(text, s, p),
            const SizedBox(height: 12),
            _WhyCard(
                label: s.gsWhyMatters,
                text: samvadThemeForTrimester(_trimester),
                accent: _accSamvad),
            const SizedBox(height: 6),
            _MarkComplete(
                pillarId: 'samvad',
                accent: _accSamvad,
                lang: widget.controller.language),
          ],
        );
      },
    );
  }

  // ---- Spiritual tab: Customize control (mother) + the chosen reading ------
  Widget _spiritualTab(S s) {
    final text = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: Listenable.merge([_store, ReadToBabySavedStore.instance]),
      builder: (context, _) {
        final pieces = _spiritualPieces();
        final children = <Widget>[
          Align(
              alignment: Alignment.centerRight,
              child: _customizeButton(s, text)),
          const SizedBox(height: 4),
        ];
        if (pieces.isEmpty) {
          children.add(_emptyHint(text));
        } else if (!widget.daily) {
          for (final p in pieces) {
            children.add(_pieceCard(text, s, p, compact: true));
          }
        } else {
          final day = widget.controller.currentDay.clamp(1, 280);
          children.add(_pieceCard(text, s, pieces[(day - 1) % pieces.length]));
          children.add(const SizedBox(height: 12));
          children.add(_WhyCard(
              label: s.gsWhyMatters,
              text: samvadThemeForTrimester(_trimester),
              accent: _accSamvad));
          children.add(const SizedBox(height: 6));
          children.add(_MarkComplete(
              pillarId: 'samvad',
              accent: _accSamvad,
              lang: widget.controller.language));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: children,
        );
      },
    );
  }

  // ---- A card (optional title + body) with a Save toggle -------------------
  Widget _pieceCard(TextTheme text, S s, _SP p, {bool compact = false}) {
    final saved = ReadToBabySavedStore.instance.isSaved(p.saveKey);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _samvadCard(text, p.body, title: p.title, compact: compact),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => ReadToBabySavedStore.instance
              .toggleSave(p.saveKey, p.body, p.group),
          icon: Icon(
              saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              size: 18,
              color: _accSamvad),
          label: Text(s.rtbSave,
              style: text.labelLarge?.copyWith(color: _accSamvad)),
        ),
      ),
      if (compact) const SizedBox(height: 6),
    ]);
  }

  Widget _customizeButton(S s, TextTheme text) => TextButton.icon(
        onPressed: () => _openCustomize(context, s),
        icon: const Icon(Icons.tune_rounded, size: 18, color: _accSamvad),
        label: Text(s.rtbCustomize,
            style: text.labelLarge?.copyWith(color: _accSamvad)),
      );

  Widget _emptyHint(TextTheme text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _accSamvad.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _accSamvad.withValues(alpha: 0.2)),
        ),
        child: Text(
            'Nothing selected yet. Tap Customize to choose what to read to your baby.',
            style: text.bodyMedium?.copyWith(color: _ink, height: 1.5)),
      );

  // A single rose-tinted speaking card (optional title + body).
  Widget _samvadCard(TextTheme text, String body,
          {String? title, bool compact = false}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: compact ? const EdgeInsets.only(bottom: 12) : EdgeInsets.zero,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [_accSamvad.withValues(alpha: 0.16), _surface]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _accSamvad.withValues(alpha: 0.22)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (title != null && title.trim().isNotEmpty) ...[
            Text(title,
                style: text.titleMedium
                    ?.copyWith(color: _accSamvad, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
          ],
          Text(body,
              style:
                  (compact ? text.titleMedium : text.headlineSmall)?.copyWith(
                      color: _ink, height: 1.45, fontWeight: FontWeight.w700)),
        ]),
      );

  // A library group (heading + all its cards) for the Tools repository.
  // ignore: unused_element
  Widget _samvadGroup(
          TextTheme text, String heading, List<SamvadPiece> cards) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 10),
          child: Text(heading.toUpperCase(),
              style: text.labelMedium?.copyWith(
                  color: _accSamvad,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5)),
        ),
        for (final c in cards)
          _samvadCard(text, c.body, title: c.title, compact: true),
        const SizedBox(height: 10),
      ]);

  // -------------------------------------------------------------------------
  //  Customize sheet - the single owner of "read to your baby" preferences.
  //  Ported from the old mother ReadModule; this is now the mother's ONLY
  //  control, and the source the father's daily card mirrors (he has none).
  // -------------------------------------------------------------------------
  void _openCustomize(BuildContext context, S s) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AnimatedBuilder(
        animation: _store,
        builder: (ctx, _) {
          final store = _store;
          return Container(
            decoration: const BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: _line,
                          borderRadius: BorderRadius.circular(99))),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(s.rtbCustomizeTitle,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _ink)),
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(s.rtbCustomizeSub,
                        style: const TextStyle(fontSize: 13, color: _muted)),
                  ),
                  const SizedBox(height: 10),
                  // Spiritual-only customization now (category on/off retired -
                  // the 4 sections are fixed tabs). _catTile kept for revert.
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(s.rtbPickReligions,
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: _ink)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tr in kSpiritualTraditions)
                        FilterChip(
                          label: Text('${tr.symbol} ${tr.name}',
                              style: TextStyle(
                                  fontWeight: store.isReligionOn(tr.id)
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: _ink)),
                          selected: store.isReligionOn(tr.id),
                          onSelected: (_) => store.toggleReligion(tr.id),
                          backgroundColor: _surface,
                          selectedColor: _accSamvad.withValues(alpha: 0.14),
                          showCheckmark: true,
                          checkmarkColor: _accSamvad,
                          side: store.isReligionOn(tr.id)
                              ? const BorderSide(color: _accSamvad, width: 2)
                              : const BorderSide(color: _line, width: 1),
                        ),
                    ],
                  ),
                  // For each chosen tradition, pick which sub-sections to read.
                  for (final tr in kSpiritualTraditions)
                    if (store.isReligionOn(tr.id)) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('${tr.symbol} ${tr.name}',
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: _ink)),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < tr.sections.length; i++)
                            FilterChip(
                              label: Text(tr.sections[i].title,
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: store.isSectionOn(tr.id, i)
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: _ink)),
                              selected: store.isSectionOn(tr.id, i),
                              onSelected: (_) => store.toggleSection(tr.id, i),
                              backgroundColor: _surface,
                              selectedColor: _accSamvad.withValues(alpha: 0.14),
                              showCheckmark: true,
                              checkmarkColor: _accSamvad,
                              side: store.isSectionOn(tr.id, i)
                                  ? const BorderSide(color: _accSamvad, width: 2)
                                  : const BorderSide(color: _line, width: 1),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                        ],
                      ),
                    ],
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  // ignore: unused_element
  Widget _catTile(
      ReadToBabyStore store, String key, String label, IconData icon) {
    final on = store.isCategoryOn(key);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.fromLTRB(12, 2, 6, 2),
      decoration: BoxDecoration(
        color: on ? _accSamvad.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: on ? _accSamvad.withValues(alpha: 0.55) : _line,
          width: on ? 1.6 : 1,
        ),
      ),
      child: Row(children: [
        Icon(icon, size: 20, color: on ? _accSamvad : _muted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                  color: _ink)),
        ),
        Switch(
          value: on,
          onChanged: (_) => store.toggleCategory(key),
          activeThumbColor: _accSamvad,
        ),
      ]),
    );
  }
}

// Parked - only used by the removed Samvad record/write composer. Kept for revert.
// ignore: unused_element
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
//  Pillar 4 - Kriya
// ===========================================================================

class KriyaScreen extends StatelessWidget {
  const KriyaScreen({super.key, required this.controller, this.daily = false});
  final PregnancyController controller;
  final bool daily;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final t = garbhTrimester(controller.currentWeek);

    // Tools library: TWO sections in tabs -
    //   1) Breathing & Meditation - kKriya practices as large cards.
    //   2) Brain Fitness - the former Vichara brain-fitness games as a 2-column
    //      grid (each: cover + description + tap-to-play).
    if (!daily) {
      final hinglish = lang.isHinglish;
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: _cream,
          appBar: AppBar(
            backgroundColor: _cream,
            elevation: 0,
            foregroundColor: _ink,
            title: Text(s.gsKriya),
            bottom: TabBar(
              labelColor: _accKriya,
              unselectedLabelColor: _muted,
              indicatorColor: _accKriya,
              tabs: [
                Tab(text: hinglish ? 'Saans & Dhyan' : 'Breathing & Meditation'),
                Tab(text: hinglish ? 'Brain Fitness' : 'Brain Fitness'),
              ],
            ),
          ),
          body: TabBarView(children: [
            _KriyaBreathingList(controller: controller),
            _KriyaBrainFitnessGrid(controller: controller),
          ]),
        ),
      );
    }

    // Daily (Home): today's practice + mark-complete.
    final practice = kriyaForDay(controller.currentDay);
    return _PillarScaffold(
      title: s.gsKriya,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        children:
            _kriyaPracticeBody(context, s, text, t, practice, lang, daily: true),
      ),
    );
  }
}

// Shared practice view (emoji + title + safety + Start). Mark-complete + the
// breathing screen's markDone happen ONLY in daily mode.
List<Widget> _kriyaPracticeBody(BuildContext context, S s, TextTheme text,
    int t, GarbhPractice practice, AppLanguage lang,
    {required bool daily}) {
  return [
    if (daily) ...[
      Text(s.gsTodaysPractice,
          style: text.labelMedium?.copyWith(color: _muted)),
      const SizedBox(height: 12),
    ],
    Center(child: Text(practice.emoji, style: const TextStyle(fontSize: 52))),
    const SizedBox(height: 10),
    Text(practice.title,
        textAlign: TextAlign.center,
        style: text.headlineSmall
            ?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
    Text('${practice.blurb} · ${s.gsMinutes(practice.minutes)}',
        textAlign: TextAlign.center,
        style: text.bodyMedium?.copyWith(color: _muted)),
    const SizedBox(height: 16),
    _WhyCard(label: s.gsSafetyNotes, text: kriyaSafety(t), accent: _accKriya),
    const SizedBox(height: 16),
    SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
            backgroundColor: _accKriya,
            padding: const EdgeInsets.symmetric(vertical: 14)),
        onPressed: () => _push(context,
            _BreathingScreen(practice: practice, lang: lang, daily: daily)),
        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
        label:
            Text(s.gsStart, style: text.labelLarge?.copyWith(color: Colors.white)),
      ),
    ),
    if (daily) ...[
      const SizedBox(height: 12),
      _MarkComplete(pillarId: 'kriya', accent: _accKriya, lang: lang),
    ],
  ];
}

// A single practice's detail in the Tools library (no mark-complete).
class _KriyaDetailScreen extends StatelessWidget {
  const _KriyaDetailScreen({required this.practice, required this.controller});
  final GarbhPractice practice;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final t = garbhTrimester(controller.currentWeek);
    return _PillarScaffold(
      title: practice.title,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: _kriyaPracticeBody(context, s, text, t, practice, lang,
            daily: false),
      ),
    );
  }
}

// Kriya › Breathing & Meditation - kKriya practices as LARGE cards
// (cover placeholder + title + description). Tap opens the practice detail.
class _KriyaBreathingList extends StatelessWidget {
  const _KriyaBreathingList({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        for (final p in kKriya)
          GestureDetector(
            onTap: () => _push(context,
                _KriyaDetailScreen(practice: p, controller: controller)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _line),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Cover placeholder (emoji on a soft gradient).
                Container(
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      _accKriya.withValues(alpha: 0.28),
                      _accKriya.withValues(alpha: 0.10),
                    ]),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                  child: Text(p.emoji, style: const TextStyle(fontSize: 54)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(p.title,
                                style: text.titleMedium?.copyWith(
                                    color: _ink, fontWeight: FontWeight.w800)),
                          ),
                          Text(s.gsMinutes(p.minutes),
                              style: text.labelSmall?.copyWith(color: _muted)),
                        ]),
                        const SizedBox(height: 4),
                        Text(p.blurb,
                            style: text.bodyMedium
                                ?.copyWith(color: _muted, height: 1.4)),
                      ]),
                ),
              ]),
            ),
          ),
      ],
    );
  }
}

// Kriya › Brain Fitness - the former Vichara brain-fitness games as a 2-column
// grid. Each card = cover (emoji) + description + tap-to-play. Games open with
// markComplete:false (Tools library play does not tick a daily ritual).
class _KriyaBrainFitnessGrid extends StatelessWidget {
  const _KriyaBrainFitnessGrid({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final hinglish = controller.language.isHinglish;
    return GridView.count(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.82,
      children: [
        for (final p in kPuzzles)
          GestureDetector(
            onTap: () =>
                _push(context, _gameFor(p, controller, markComplete: false)),
            child: Container(
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _line),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover.
                    Container(
                      height: 84,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          _accKriya.withValues(alpha: 0.24),
                          _accKriya.withValues(alpha: 0.08),
                        ]),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                      ),
                      child: Text(p.emoji, style: const TextStyle(fontSize: 38)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title,
                                  style: text.titleSmall?.copyWith(
                                      color: _ink,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 3),
                              Expanded(
                                child: Text(p.blurb,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.labelSmall?.copyWith(
                                        color: _muted, height: 1.35)),
                              ),
                              Row(children: [
                                Icon(Icons.play_circle_outline_rounded,
                                    size: 16, color: _accKriya),
                                const SizedBox(width: 5),
                                Text(hinglish ? 'Khelein' : 'Play',
                                    style: text.labelSmall?.copyWith(
                                        color: _accKriya,
                                        fontWeight: FontWeight.w800)),
                              ]),
                            ]),
                      ),
                    ),
                  ]),
            ),
          ),
      ],
    );
  }
}

class _BreathingScreen extends StatefulWidget {
  const _BreathingScreen(
      {required this.practice, required this.lang, this.daily = true});
  final GarbhPractice practice;
  final AppLanguage lang;

  /// Marks Kriya done on finish only in daily mode (Tools library = no "today").
  final bool daily;
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
              if (widget.daily) GarbhStore.instance.markDone('kriya');
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${s.gsWellDone} - ${s.gsWellDoneBody}')),
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
//  Pillar 5 - Ahara
// ===========================================================================

class AharaScreen extends StatelessWidget {
  const AharaScreen({super.key, required this.controller, this.daily = false});
  final PregnancyController controller;
  final bool daily;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final n = daily
        ? nutritionForDay(controller.currentDay)
        : nutritionForTrimester(garbhTrimester(controller.currentWeek));
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
          _LearnMore(controller: controller),
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
