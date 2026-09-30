// =============================================================================
//  Home detail screens
// -----------------------------------------------------------------------------
//  The reading / composing surfaces a mother reaches from the Home daily moment:
//    * GrowReaderScreen   - expanded parenting insight + optional deep dive
//    * StoryReaderScreen  - full "Read To Your Baby" story (with Listen)
//    * TalkComposerScreen - write or speak a message saved into Dear Baby
//  Plus showGarbhInfoSheet() - the little "i" explainer for Garbh Sanskar.
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
import '../services/narration_service.dart';
import '../widgets/narration/narrate_button.dart';
import '../theme/app_theme.dart';
import 'brackets/hub/hub_intent_art.dart' show IntentMark;
import 'doors/pv_list_row.dart' show PvMarkWell;
import 'pregnancy/preg_chrome.dart' show PregCard, pregFilledStyle, pregGroupLabelStyle;
import 'products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;

/// A remembered line, in the tip form (DESIGN-SYSTEM §4.0 addendum): a left
/// hairline in the ink, the group label, the line. What the gradient
/// "Remember" panels became on 2026-09-30, since a tint is never behind text.
class _RememberAside extends StatelessWidget {
  const _RememberAside({required this.label, required this.body, this.bodyColor});
  final String label;
  final String body;
  final Color? bodyColor;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: kPvInk, width: 2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: pregGroupLabelStyle()),
        const SizedBox(height: 8),
        Text(body,
            style: text.titleMedium?.copyWith(
                color: bodyColor ?? kPvInk, fontStyle: FontStyle.italic, height: 1.45)),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  Grow reader
// ---------------------------------------------------------------------------

class GrowReaderScreen extends StatelessWidget {
  const GrowReaderScreen(
      {super.key,
      required this.grow,
      required this.lang,
      this.week,
      this.dayOfPregnancy});
  final GrowContent grow;
  final AppLanguage lang;

  /// Which day this reader is showing, used ONLY to build the narration
  /// key. Nullable because the father surface reuses this screen through a
  /// different path and has no recording of its own yet - a null week means
  /// no speaker rather than a speaker that plays somebody else's passage.
  final int? week;
  final int? dayOfPregnancy;

  String? _key(String path) => (week == null || dayOfPregnancy == null)
      ? null
      : NarrationService.homeKey(week!, dayOfPregnancy!, path);

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
                style: text.headlineLarge?.copyWith(color: AppTheme.neutral900, height: 1.2)),
            const SizedBox(height: 18),
            Text(grow.insight.of(lang),
                style: text.titleMedium?.copyWith(height: 1.5, color: AppTheme.neutral800)),
            const SizedBox(height: 18),
            // The speaker sits WITH the long text, not on the card that
            // opened this screen. This is the wall of Hindi she may prefer to
            // hear rather than read, so the control belongs here.
            if (_key('grow.expanded') != null)
              Row(children: [
                NarrateButton(
                  narrationKey: _key('grow.expanded')!,
                  text: grow.expanded.of(lang),
                  englishText: grow.expanded.en,
                  lang: lang,
                ),
                Text(S.now.listenLabel,
                    style: text.labelMedium
                        ?.copyWith(color: AppTheme.neutral900)),
              ]),
            Text(grow.expanded.of(lang),
                style: text.bodyLarge?.copyWith(height: 1.6)),
            if (grow.deepDive != null && grow.deepDive!.of(lang).trim().isNotEmpty) ...[
              const SizedBox(height: 22),
              // A white card with the hairline, not a tinted panel behind text
              // (2026-09-30). Kept for revert: a Container on
              // `AppTheme.surfaceContainer`, radius 20, its label in
              // labelSmall w800 +1 neutral900.
              PregCard(
                padding: const EdgeInsets.all(18),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.science_outlined, size: 16, color: pvStorePalette.ink2),
                    const SizedBox(width: 6),
                    Text(s.deepDiveLabel.toUpperCase(), style: pregGroupLabelStyle()),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    if (_key('grow.deepDive') != null)
                      NarrateButton(
                        narrationKey: _key('grow.deepDive')!,
                        text: grow.deepDive!.of(lang),
                        englishText: grow.deepDive!.en,
                        lang: lang,
                        size: 18,
                      ),
                  ]),
                  Text(grow.deepDive!.of(lang), style: text.bodyMedium?.copyWith(height: 1.6)),
                ]),
                ),
              ),
            ],
            const SizedBox(height: 22),
            // The tip form, not a gradient panel (2026-09-30). Kept for revert:
            // a Container with a neutral100 to surface gradient, radius 20,
            // padding 18, the label in labelSmall w800 and the line italic.
            _RememberAside(label: s.rememberLabel, body: grow.remember.of(lang)),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Father Learn reader - expanded fatherhood lesson + optional deep dive
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
              // A white card with the hairline (2026-09-30). Kept for revert:
              // a Container on `AppTheme.surfaceContainer`, radius 20, the
              // label in fatherSlate600 labelSmall w800 +1.
              PregCard(
                padding: const EdgeInsets.all(18),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.menu_book_outlined, size: 16, color: _slate),
                      const SizedBox(width: 6),
                      Text(s.deepDiveLabel.toUpperCase(), style: pregGroupLabelStyle()),
                    ]),
                    const SizedBox(height: 10),
                    Text(deepDive, style: text.bodyMedium?.copyWith(height: 1.6)),
                  ]),
                ),
              ),
            ],
            const SizedBox(height: 22),
            // The tip form, not a gradient panel (2026-09-30). Kept for revert:
            // a Container with a fatherSlate100 to surface gradient, radius 20,
            // the label fatherSlate600, the line italic in fatherSlate900.
            _RememberAside(
                label: s.rememberLabel,
                body: lesson.remember.of(lang),
                bodyColor: AppTheme.fatherSlate900),
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
                      // Narrate in the language she is READING in.
                      //
                      // This used to force English, with the note "TTS can't
                      // read Roman-script Hinglish". That was true, and it was
                      // the whole reason for the Devanagari migration. Now
                      // that weekContent.json is 99% Devanagari the hi-IN
                      // voice can read it, so the workaround has outlived its
                      // cause - a mother reading in Hindi was tapping listen
                      // and hearing English.
                      story.body.of(lang),
                      cardKey: _key,
                      lang: lang,
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
                style: text.headlineLarge?.copyWith(color: kPvInk, height: 1.2)),
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
                style: text.headlineSmall?.copyWith(color: AppTheme.neutral900, height: 1.3)),
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
                // The one ink for what is pressed; white with the hairline at
                // rest (2026-09-30). Kept for revert: secondary500 when
                // listening, a secondary50 fill with a secondary100 border and
                // coral words at rest.
                decoration: BoxDecoration(
                  color: _listening ? kPvInk : Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: _listening ? kPvInk : kPvLine,
                    width: 1.2,
                  ),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_listening ? Icons.stop_rounded : Icons.mic_none_rounded,
                      size: 20, color: _listening ? Colors.white : kPvInk),
                  const SizedBox(width: 10),
                  Text(_listening ? s.talkListening : s.recordCta,
                      style: text.labelLarge?.copyWith(
                          color: _listening ? Colors.white : kPvInk,
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
              // A drawn mark in its well, in the accent's hue (2026-09-30).
              // Kept for revert: a 42pt `accent` 0.14 box holding
              // Icon(Icons.self_improvement_rounded, color: accent).
              PvMarkWell(
                  p: pvStorePalette,
                  hue: HSLColor.fromColor(accent).hue,
                  size: 42,
                  mark: IntentMark.lotusMark),
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
                // The one ink (2026-09-30). Was `backgroundColor: accent`.
                style: pregFilledStyle(),
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
      // The grey group label, inside a sheet (2026-09-30). Kept for revert:
      // the icon and the label in `accent`, labelSmall w800 +1.
      Row(children: [
        Icon(icon, size: 16, color: pvStorePalette.ink3),
        const SizedBox(width: 7),
        Text(label.toUpperCase(), style: pregGroupLabelStyle()),
      ]),
      const SizedBox(height: 8),
      Text(body, style: text.bodyLarge?.copyWith(height: 1.6)),
    ]);
  }
}
