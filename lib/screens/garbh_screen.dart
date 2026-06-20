// =============================================================================
//  Garbh Sanskar Journey™  — the deep practice layer (Tools tab)
// -----------------------------------------------------------------------------
//  A premium, calm destination — not a 4-tab library. Entering feels like a
//  sacred, quiet space: a soft hero, a "continue your practice" card, and four
//  beautiful pillars:
//    Shravan (Sacred Listening, Spotify-like) · Samvad (Womb Connection →
//    Memory Vault) · Vichara (Positive Contemplation, Kindle-like) ·
//    Kriya (Breath & Grounding, Headspace-like).
//  Warm creams, muted greens, subtle gold. No gamification; the only "progress"
//  is a gentle reflective tally.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/garbh_data.dart';
import '../localization/app_language.dart';
import '../models/garbh_content.dart';
import '../services/daily_store.dart';
import '../services/garbh_store.dart';
import '../services/pregnancy_controller.dart';
import '../widgets/cards/raga_player.dart';
import 'home_detail_screens.dart' show TalkComposerScreen;

// --- warm palette (local to the feature) ---
const _cream = Color(0xFFFBF6EE);
const _surface = Color(0xFFFFFFFF);
const _ink = Color(0xFF4A463E);
const _muted = Color(0xFF8C857A);
const _line = Color(0xFFE9E0D2);
const _accShravan = Color(0xFFBE9C4E); // gold
const _accSamvad = Color(0xFFB98A7E); // warm rose-beige
const _accVichara = Color(0xFF6E8C74); // muted green
const _accKriya = Color(0xFF5E8B7E); // teal-green

void _push(BuildContext c, Widget w) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));

// ===========================================================================
//  Home — the sacred calm space
// ===========================================================================

class GarbhScreen extends StatelessWidget {
  const GarbhScreen({super.key, required this.controller});
  final PregnancyController controller;

  void _openLast(BuildContext context) {
    final st = GarbhStore.instance;
    final lang = controller.language;
    switch (st.lastType) {
      case 'shravan':
        final a = shravanById(st.lastId ?? '');
        if (a != null) _push(context, _ShravanPlayer(audio: a, lang: lang));
        break;
      case 'vichara':
        final s = vicharaById(st.lastId ?? '');
        if (s != null) _push(context, _VicharaReader(story: s, lang: lang));
        break;
      case 'kriya':
        final p = kriyaById(st.lastId ?? '');
        if (p != null) _push(context, _BreathingScreen(practice: p, lang: lang));
        break;
      case 'samvad':
        _push(context, SamvadScreen(controller: controller));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        foregroundColor: _ink,
        actions: [
          IconButton(
            tooltip: s.gsFavorites,
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () => _push(context, _FavoritesScreen(controller: controller)),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: GarbhStore.instance,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            // Hero
            Center(
              child: Column(children: [
                Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEDE6D6), Color(0xFFDDE7DC)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🌿', style: TextStyle(fontSize: 38)),
                ),
                const SizedBox(height: 16),
                Text(s.gsTitle,
                    textAlign: TextAlign.center,
                    style: text.headlineMedium
                        ?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(s.gsSubtitle,
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(color: _muted, height: 1.5)),
                ),
              ]),
            ),
            const SizedBox(height: 26),

            // Continue your practice
            if (GarbhStore.instance.hasLast)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _ContinueCard(
                  label: s.gsContinue,
                  title: GarbhStore.instance.lastTitle ?? '',
                  cta: s.gsContinueCta,
                  onTap: () => _openLast(context),
                ),
              ),

            // Pillars
            _PillarCard(
              emoji: '🎵',
              title: s.gsShravan,
              tagline: s.gsShravanTag,
              accent: _accShravan,
              onTap: () => _push(context, ShravanScreen(controller: controller)),
            ),
            const SizedBox(height: 14),
            _PillarCard(
              emoji: '🎙️',
              title: s.gsSamvad,
              tagline: s.gsSamvadTag,
              accent: _accSamvad,
              onTap: () => _push(context, SamvadScreen(controller: controller)),
            ),
            const SizedBox(height: 14),
            _PillarCard(
              emoji: '📖',
              title: s.gsVichara,
              tagline: s.gsVicharaTag,
              accent: _accVichara,
              onTap: () => _push(context, VicharaScreen(controller: controller)),
            ),
            const SizedBox(height: 14),
            _PillarCard(
              emoji: '🌿',
              title: s.gsKriya,
              tagline: s.gsKriyaTag,
              accent: _accKriya,
              onTap: () => _push(context, KriyaScreen(controller: controller)),
            ),

            const SizedBox(height: 28),
            _JourneyStats(s: s),
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.label,
    required this.title,
    required this.cta,
    required this.onTap,
  });
  final String label, title, cta;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
        decoration: BoxDecoration(
          color: _ink,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: text.labelSmall?.copyWith(
                      color: Colors.white70, letterSpacing: 0.6, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleMedium
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(cta,
                  style: text.labelLarge
                      ?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
              const SizedBox(width: 4),
              const Icon(Icons.play_arrow_rounded, size: 18, color: _ink),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  const _PillarCard({
    required this.emoji,
    required this.title,
    required this.tagline,
    required this.accent,
    required this.onTap,
  });
  final String emoji, title, tagline;
  final Color accent;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent.withValues(alpha: 0.16), _surface],
            stops: const [0.0, 0.85],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withValues(alpha: 0.22), width: 1),
        ),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: text.titleLarge?.copyWith(
                      color: _ink, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(tagline, style: text.bodyMedium?.copyWith(color: _muted)),
            ]),
          ),
          Icon(Icons.arrow_forward_rounded, color: accent, size: 20),
        ]),
      ),
    );
  }
}

class _JourneyStats extends StatelessWidget {
  const _JourneyStats({required this.s});
  final S s;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final st = GarbhStore.instance;
    Widget stat(String label, int value, Color c) => Expanded(
          child: Column(children: [
            Text('$value',
                style: text.headlineSmall
                    ?.copyWith(color: c, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: text.labelSmall?.copyWith(color: _muted)),
          ]),
        );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line, width: 1),
      ),
      child: Column(children: [
        Text(s.gsYourJourney,
            style: text.titleSmall?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        Row(children: [
          stat(s.gsStatListening, st.listening, _accShravan),
          stat(s.gsStatConnections, st.connection, _accSamvad),
          stat(s.gsStatReflections, st.reflection, _accVichara),
          stat(s.gsStatBreathing, st.breathing, _accKriya),
        ]),
      ]),
    );
  }
}

// ===========================================================================
//  Shravan — Sacred Listening
// ===========================================================================

class ShravanScreen extends StatelessWidget {
  const ShravanScreen({super.key, required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final featured = kShravan.first;
    final rest = kShravan.skip(1).toList();
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
          backgroundColor: _cream,
          elevation: 0,
          foregroundColor: _ink,
          title: Text(s.gsShravan)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(s.gsShravanTag, style: text.bodyMedium?.copyWith(color: _muted)),
          const SizedBox(height: 16),
          // Featured
          GestureDetector(
            onTap: () => _push(context, _ShravanPlayer(audio: featured, lang: lang)),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_accShravan.withValues(alpha: 0.22), _surface],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _accShravan.withValues(alpha: 0.25)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(featured.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(featured.title,
                    style: text.headlineSmall
                        ?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${featured.subtitle} · ${s.gsMinutes(featured.minutes)}',
                    style: text.bodyMedium?.copyWith(color: _muted)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                      color: _accShravan, borderRadius: BorderRadius.circular(30)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(s.gsPlay,
                        style: text.labelLarge
                            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                  ]),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          for (final a in rest) ...[
            _AudioRow(
                audio: a,
                lang: lang,
                onTap: () => _push(context, _ShravanPlayer(audio: a, lang: lang))),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _AudioRow extends StatelessWidget {
  const _AudioRow({required this.audio, required this.lang, required this.onTap});
  final GarbhAudio audio;
  final AppLanguage lang;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _line, width: 1),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _accShravan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(audio.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(audio.title,
                  style: text.titleSmall?.copyWith(color: _ink, fontWeight: FontWeight.w700)),
              Text('${audio.subtitle} · ${s.gsMinutes(audio.minutes)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall?.copyWith(color: _muted)),
            ]),
          ),
          const Icon(Icons.play_circle_outline_rounded, color: _accShravan),
        ]),
      ),
    );
  }
}

class _ShravanPlayer extends StatefulWidget {
  const _ShravanPlayer({required this.audio, required this.lang});
  final GarbhAudio audio;
  final AppLanguage lang;
  @override
  State<_ShravanPlayer> createState() => _ShravanPlayerState();
}

class _ShravanPlayerState extends State<_ShravanPlayer> {
  @override
  void initState() {
    super.initState();
    GarbhStore.instance.addListening();
    GarbhStore.instance
        .setLast(type: 'shravan', id: widget.audio.id, title: widget.audio.title);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.audio;
    final text = Theme.of(context).textTheme;
    final s = S(widget.lang);
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(backgroundColor: _cream, elevation: 0, foregroundColor: _ink),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        children: [
          Center(
            child: Container(
              width: 180,
              height: 180,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_accShravan.withValues(alpha: 0.30), const Color(0xFFEDE6D6)],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Text(a.emoji, style: const TextStyle(fontSize: 76)),
            ),
          ),
          const SizedBox(height: 22),
          Text(a.title,
              textAlign: TextAlign.center,
              style: text.headlineSmall?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(a.subtitle,
              textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: _muted)),
          const SizedBox(height: 20),
          RagaPlayer(title: a.title, subtitle: '${a.minutes} min'),
          const SizedBox(height: 14),
          Center(child: _HeartButton(id: a.id)),
          const SizedBox(height: 12),
          Text(s.gsSampleAudio,
              textAlign: TextAlign.center,
              style: text.labelSmall?.copyWith(color: _muted)),
        ],
      ),
    );
  }
}

// ===========================================================================
//  Samvad — Womb Connection
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
    final lang = c.language;
    final s = S(lang);
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TalkComposerScreen(
        day: c.currentDay,
        week: c.currentWeek,
        prompt: _prompt.text,
        motivation: s.gsSamvadTag,
        lang: lang,
        startWithVoice: voice,
      ),
    ));
    if (!mounted) return;
    final saved = DailyStore.instance.talkForDay(c.currentDay);
    if (saved != null) {
      GarbhStore.instance.addConnection();
      GarbhStore.instance
          .setLast(type: 'samvad', id: _prompt.id, title: s.gsTodaysConnection);
      if (!mounted) return;
      _push(context, _MemorySavedScreen(controller: c));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
          backgroundColor: _cream,
          elevation: 0,
          foregroundColor: _ink,
          title: Text(s.gsSamvad)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(s.gsTodaysConnection,
              style: text.labelMedium?.copyWith(
                  color: _accSamvad, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_accSamvad.withValues(alpha: 0.16), _surface],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _accSamvad.withValues(alpha: 0.22)),
            ),
            child: Text(_prompt.text,
                style: text.headlineSmall
                    ?.copyWith(color: _ink, height: 1.4, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(
                  () => _index = (_index + 1) % kSamvad.length),
              icon: const Icon(Icons.refresh_rounded, size: 18, color: _accSamvad),
              label: Text(s.gsAnotherPrompt,
                  style: text.labelLarge?.copyWith(color: _accSamvad)),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _accSamvad,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _compose(true),
                icon: const Icon(Icons.mic_rounded, size: 18, color: Colors.white),
                label: Text(s.gsRecordVoice,
                    style: text.labelLarge?.copyWith(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _accSamvad,
                  side: const BorderSide(color: _accSamvad, width: 1.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _compose(false),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text(s.gsWriteMessage),
              ),
            ),
          ]),
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
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(backgroundColor: _cream, elevation: 0, foregroundColor: _ink),
      body: Center(
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
//  Vichara — Positive Contemplation
// ===========================================================================

class VicharaScreen extends StatelessWidget {
  const VicharaScreen({super.key, required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
          backgroundColor: _cream,
          elevation: 0,
          foregroundColor: _ink,
          title: Text(s.gsVichara)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(s.gsVicharaTag, style: text.bodyMedium?.copyWith(color: _muted)),
          const SizedBox(height: 16),
          for (final story in kVichara) ...[
            _StoryCard(
                story: story,
                readLabel: s.gsRead,
                minLabel: s.gsMinRead(story.minutes),
                onTap: () => _push(context, _VicharaReader(story: story, lang: lang))),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.story,
    required this.readLabel,
    required this.minLabel,
    required this.onTap,
  });
  final GarbhStory story;
  final String readLabel, minLabel;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _line, width: 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _accVichara.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(story.theme,
                style: text.labelSmall
                    ?.copyWith(color: _accVichara, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 10),
          Text(story.title,
              style: text.titleLarge?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(story.blurb,
              style: text.bodyMedium?.copyWith(color: _muted, height: 1.4)),
          const SizedBox(height: 12),
          Row(children: [
            Text(readLabel,
                style: text.labelLarge
                    ?.copyWith(color: _accVichara, fontWeight: FontWeight.w800)),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 16, color: _accVichara),
            const Spacer(),
            Text(minLabel, style: text.labelSmall?.copyWith(color: _muted)),
          ]),
        ]),
      ),
    );
  }
}

class _VicharaReader extends StatefulWidget {
  const _VicharaReader({required this.story, required this.lang});
  final GarbhStory story;
  final AppLanguage lang;
  @override
  State<_VicharaReader> createState() => _VicharaReaderState();
}

class _VicharaReaderState extends State<_VicharaReader> {
  @override
  void initState() {
    super.initState();
    GarbhStore.instance.addReflection();
    GarbhStore.instance
        .setLast(type: 'vichara', id: widget.story.id, title: widget.story.title);
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final s = S(widget.lang);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        foregroundColor: _ink,
        actions: [_HeartButton(id: story.id)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 36),
        children: [
          Text(story.theme.toUpperCase(),
              style: text.labelSmall?.copyWith(
                  color: _accVichara, letterSpacing: 1.0, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(story.title,
              style: text.headlineMedium?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(s.gsMinRead(story.minutes),
              style: text.labelSmall?.copyWith(color: _muted)),
          const SizedBox(height: 20),
          for (final para in story.body.split('\n\n')) ...[
            Text(para,
                style: text.bodyLarge?.copyWith(color: _ink, height: 1.7, fontSize: 17)),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _accVichara.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accVichara.withValues(alpha: 0.22)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('❤️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(s.gsReflectMoment,
                    style: text.labelLarge
                        ?.copyWith(color: _accVichara, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 10),
              Text(story.reflection,
                  style: text.titleMedium?.copyWith(color: _ink, height: 1.45)),
            ]),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
//  Kriya — Breath & Grounding
// ===========================================================================

class KriyaScreen extends StatelessWidget {
  const KriyaScreen({super.key, required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
          backgroundColor: _cream,
          elevation: 0,
          foregroundColor: _ink,
          title: Text(s.gsKriya)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(s.gsKriyaTag, style: text.bodyMedium?.copyWith(color: _muted)),
          const SizedBox(height: 16),
          for (final p in kKriya) ...[
            GestureDetector(
              onTap: () => _push(context, _BreathingScreen(practice: p, lang: lang)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _line, width: 1),
                ),
                child: Row(children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _accKriya.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(p.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.title,
                          style: text.titleSmall
                              ?.copyWith(color: _ink, fontWeight: FontWeight.w700)),
                      Text('${p.blurb} · ${s.gsMinutes(p.minutes)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.labelSmall?.copyWith(color: _muted)),
                    ]),
                  ),
                  const Icon(Icons.play_circle_outline_rounded, color: _accKriya),
                ]),
              ),
            ),
            const SizedBox(height: 10),
          ],
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
    GarbhStore.instance.addBreathing();
    GarbhStore.instance.setLast(
        type: 'kriya', id: widget.practice.id, title: widget.practice.title);
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
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
          backgroundColor: _cream,
          elevation: 0,
          foregroundColor: _ink,
          title: Text(widget.practice.title)),
      body: Center(
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
                          style: text.displaySmall
                              ?.copyWith(color: _ink, fontWeight: FontWeight.w300)),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(_label,
                    style: text.headlineSmall
                        ?.copyWith(color: _ink, fontWeight: FontWeight.w700)),
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
//  Favorites
// ===========================================================================

class _FavoritesScreen extends StatelessWidget {
  const _FavoritesScreen({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
          backgroundColor: _cream,
          elevation: 0,
          foregroundColor: _ink,
          title: Text(s.gsFavorites)),
      body: AnimatedBuilder(
        animation: GarbhStore.instance,
        builder: (context, _) {
          final ids = GarbhStore.instance.favIds;
          final audios = ids.map(shravanById).whereType<GarbhAudio>().toList();
          final stories = ids.map(vicharaById).whereType<GarbhStory>().toList();
          if (audios.isEmpty && stories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.favorite_border_rounded, size: 44, color: _muted),
                  const SizedBox(height: 14),
                  Text(s.gsFavEmpty,
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(color: _muted)),
                ]),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              for (final a in audios) ...[
                _AudioRow(
                    audio: a,
                    lang: lang,
                    onTap: () => _push(context, _ShravanPlayer(audio: a, lang: lang))),
                const SizedBox(height: 10),
              ],
              for (final story in stories) ...[
                _StoryCard(
                    story: story,
                    readLabel: s.gsRead,
                    minLabel: s.gsMinRead(story.minutes),
                    onTap: () => _push(context, _VicharaReader(story: story, lang: lang))),
                const SizedBox(height: 14),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ===========================================================================
//  Shared: heart / favorite toggle
// ===========================================================================

class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.id});
  final String id;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GarbhStore.instance,
      builder: (context, _) {
        final fav = GarbhStore.instance.isFav(id);
        return IconButton(
          icon: Icon(fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: fav ? _accSamvad : _muted),
          onPressed: () => GarbhStore.instance.toggleFav(id),
        );
      },
    );
  }
}
