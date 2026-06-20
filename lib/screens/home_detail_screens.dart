// =============================================================================
//  Home detail screens
// -----------------------------------------------------------------------------
//  The reading / composing surfaces a mother reaches from the Home daily moment:
//    * GrowReaderScreen   — expanded parenting insight + optional deep dive
//    * StoryReaderScreen  — full "Read To Your Baby" story (with Listen)
//    * TalkComposerScreen — write or speak a message saved into Dear Baby
//  Plus showGarbhInfoSheet() — the little "i" explainer for Garbh Sanskar.
//
//  All reuse the existing design language (AppTheme, BabyVoiceService, speech).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../localization/app_language.dart';
import '../models/father_day.dart';
import '../models/home_day.dart';
import '../services/baby_voice_service.dart';
import '../services/daily_store.dart';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
//  Grow reader
// ---------------------------------------------------------------------------

class GrowReaderScreen extends StatelessWidget {
  const GrowReaderScreen({super.key, required this.grow, required this.lang});
  final GrowContent grow;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(s.growEyebrow, style: text.headlineSmall),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('“${grow.title.of(lang)}”',
                style: text.headlineLarge?.copyWith(color: AppTheme.primary700, height: 1.2)),
            const SizedBox(height: 18),
            Text(grow.insight.of(lang),
                style: text.titleMedium?.copyWith(height: 1.5, color: AppTheme.neutral800)),
            const SizedBox(height: 18),
            Text(grow.expanded.of(lang),
                style: text.bodyLarge?.copyWith(height: 1.6)),
            if (grow.deepDive != null && grow.deepDive!.of(lang).trim().isNotEmpty) ...[
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.science_rounded, size: 16, color: AppTheme.primary500),
                    const SizedBox(width: 6),
                    Text(s.deepDiveLabel.toUpperCase(),
                        style: text.labelSmall?.copyWith(
                            color: AppTheme.primary600, letterSpacing: 1, fontWeight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 10),
                  Text(grow.deepDive!.of(lang), style: text.bodyMedium?.copyWith(height: 1.6)),
                ]),
              ),
            ],
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primary100, AppTheme.surface],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.rememberLabel.toUpperCase(),
                    style: text.labelSmall?.copyWith(
                        color: AppTheme.primary600, letterSpacing: 1, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(grow.remember.of(lang),
                    style: text.titleMedium?.copyWith(
                        color: AppTheme.primary900, fontStyle: FontStyle.italic, height: 1.45)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Father Learn reader — expanded fatherhood lesson + optional deep dive
// ---------------------------------------------------------------------------

class FatherLearnReaderScreen extends StatelessWidget {
  const FatherLearnReaderScreen({super.key, required this.lesson, required this.lang});
  final FatherLesson lesson;
  final AppLanguage lang;

  static const Color _slate = AppTheme.fatherSlate500;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final deepDive = lesson.deepDive?.of(lang).trim() ?? '';
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(s.learnReaderTitle, style: text.headlineSmall),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lesson.module.of(lang).toUpperCase(),
                style: text.labelSmall?.copyWith(
                    color: _slate, letterSpacing: 1.1, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(lesson.title.of(lang),
                style: text.headlineLarge?.copyWith(
                    color: AppTheme.fatherSlate700, height: 1.2)),
            const SizedBox(height: 18),
            Text(lesson.insight.of(lang),
                style: text.titleMedium?.copyWith(height: 1.5, color: AppTheme.neutral800)),
            const SizedBox(height: 18),
            Text(lesson.expanded.of(lang),
                style: text.bodyLarge?.copyWith(height: 1.6)),
            if (deepDive.isNotEmpty) ...[
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.menu_book_rounded, size: 16, color: _slate),
                    const SizedBox(width: 6),
                    Text(s.deepDiveLabel.toUpperCase(),
                        style: text.labelSmall?.copyWith(
                            color: AppTheme.fatherSlate600,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 10),
                  Text(deepDive, style: text.bodyMedium?.copyWith(height: 1.6)),
                ]),
              ),
            ],
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.fatherSlate100, AppTheme.surface],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.rememberLabel.toUpperCase(),
                    style: text.labelSmall?.copyWith(
                        color: AppTheme.fatherSlate600,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(lesson.remember.of(lang),
                    style: text.titleMedium?.copyWith(
                        color: AppTheme.fatherSlate900,
                        fontStyle: FontStyle.italic,
                        height: 1.45)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Story reader
// ---------------------------------------------------------------------------

class StoryReaderScreen extends StatelessWidget {
  const StoryReaderScreen({super.key, required this.story, required this.lang});
  final ReadStory story;
  final AppLanguage lang;

  static const String _key = 'story_reader';

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final paras = story.body.of(lang).split('\n\n');
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(s.readEyebrow, style: text.headlineSmall),
        actions: [
          if (story.audioAvailable)
            AnimatedBuilder(
              animation: BabyVoiceService.instance,
              builder: (context, _) {
                final playing = BabyVoiceService.instance.isPlaying(_key);
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TextButton.icon(
                    onPressed: () => BabyVoiceService.instance.toggleCard(
                      // Always narrate the English text with an English voice —
                      // TTS can't read Roman-script Hinglish. (UI text below
                      // still follows the selected language.)
                      story.body.en,
                      cardKey: _key,
                      lang: AppLanguage.english,
                      scope: VoiceScope.home,
                    ),
                    icon: Icon(playing ? Icons.stop_rounded : Icons.graphic_eq_rounded, size: 18),
                    label: Text(s.listenCta),
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('“${story.title.of(lang)}”',
                style: text.headlineLarge?.copyWith(color: AppTheme.secondary700, height: 1.2)),
            const SizedBox(height: 8),
            Text(story.summary.of(lang),
                style: text.titleMedium?.copyWith(color: AppTheme.neutral600, height: 1.4)),
            const SizedBox(height: 20),
            for (final p in paras)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(p, style: text.bodyLarge?.copyWith(height: 1.7)),
              ),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Talk composer (write or speak → Dear Baby)
// ---------------------------------------------------------------------------

class TalkComposerScreen extends StatefulWidget {
  const TalkComposerScreen({
    super.key,
    required this.day,
    required this.week,
    required this.prompt,
    required this.motivation,
    required this.lang,
    required this.startWithVoice,
  });

  final int day;
  final int week;
  final String prompt;
  final String motivation;
  final AppLanguage lang;
  final bool startWithVoice;

  @override
  State<TalkComposerScreen> createState() => _TalkComposerScreenState();
}

class _TalkComposerScreenState extends State<TalkComposerScreen> {
  late final TextEditingController _ctrl;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _listening = false;
  bool _usedVoice = false;
  String _dictationBase = '';

  @override
  void initState() {
    super.initState();
    final existing = DailyStore.instance.talkForDay(widget.day);
    _ctrl = TextEditingController(text: existing?.text ?? '');
    if (widget.startWithVoice) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _toggleMic());
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    final s = S(widget.lang);
    final messenger = ScaffoldMessenger.of(context);
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final available = await _speech.initialize(
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          setState(() => _listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (!available) {
      messenger.showSnackBar(SnackBar(content: Text(s.micPermissionNeeded)));
      return;
    }
    _dictationBase = _ctrl.text;
    _usedVoice = true;
    setState(() => _listening = true);
    await _speech.listen(onResult: (result) {
      final words = result.recognizedWords;
      final sep = _dictationBase.isEmpty || _dictationBase.endsWith(' ') ? '' : ' ';
      final next = '$_dictationBase$sep$words';
      _ctrl.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    });
  }

  Future<void> _save() async {
    final s = S(widget.lang);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_listening) await _speech.stop();
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      navigator.pop();
      return;
    }
    await DailyStore.instance.saveTalk(
      day: widget.day,
      week: widget.week,
      prompt: widget.prompt,
      text: text,
      spoken: _usedVoice,
    );
    messenger.showSnackBar(SnackBar(content: Text(s.talkSaved)));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(widget.lang);
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(s.talkEyebrow, style: text.headlineSmall),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(s.talkSaveCta),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('“${widget.prompt}”',
                style: text.headlineSmall?.copyWith(color: AppTheme.primary700, height: 1.3)),
            const SizedBox(height: 8),
            Text(widget.motivation,
                style: text.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _ctrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                style: text.bodyLarge?.copyWith(height: 1.6),
                decoration: InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: _listening ? s.talkListening : s.talkWriteHint,
                  hintStyle: text.bodyLarge?.copyWith(
                      color: AppTheme.neutral400, fontStyle: FontStyle.italic),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(s.talkSpeakHint, style: text.bodySmall),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _toggleMic,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _listening ? AppTheme.secondary500 : AppTheme.secondary50,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: _listening ? AppTheme.secondary500 : AppTheme.secondary100,
                    width: 1.2,
                  ),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded,
                      size: 20, color: _listening ? Colors.white : AppTheme.secondary600),
                  const SizedBox(width: 10),
                  Text(_listening ? s.talkListening : s.recordCta,
                      style: text.labelLarge?.copyWith(
                          color: _listening ? Colors.white : AppTheme.secondary700,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Garbh Sanskar info sheet (the little "i")
// ---------------------------------------------------------------------------

Future<void> showGarbhInfoSheet(
  BuildContext context, {
  required GarbhSanskarDaily g,
  required AppLanguage lang,
  required Color accent,
}) {
  final s = S(lang);
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      final text = Theme.of(context).textTheme;
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.self_improvement_rounded, color: accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(s.aboutGarbhTitle,
                    style: text.headlineSmall),
              ),
            ]),
            const SizedBox(height: 20),
            _InfoSection(
              label: s.whyItMatters,
              body: g.about.of(lang),
              accent: accent,
              icon: Icons.favorite_rounded,
            ),
            const SizedBox(height: 18),
            _InfoSection(
              label: s.howToUseIt,
              body: g.howToUse.of(lang),
              accent: accent,
              icon: Icons.spa_rounded,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(s.gotIt),
              ),
            ),
          ]),
        ),
      );
    },
  );
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.label,
    required this.body,
    required this.accent,
    required this.icon,
  });
  final String label;
  final String body;
  final Color accent;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 16, color: accent),
        const SizedBox(width: 7),
        Text(label.toUpperCase(),
            style: text.labelSmall?.copyWith(
                color: accent, letterSpacing: 1, fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height: 8),
      Text(body, style: text.bodyLarge?.copyWith(height: 1.6)),
    ]);
  }
}
