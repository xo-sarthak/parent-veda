// =============================================================================
//  NarrateButton - a speaker for one passage
// -----------------------------------------------------------------------------
//  Give it the passage's manifest key and the text it shows, and it plays the
//  recording where we have one and the device voice where we do not. The screen
//  does not need to know which.
//
//  It is ALWAYS shown, never hidden when audio is missing - this codebase's
//  rule is that a feature is never hidden, and a speaker that appears on some
//  cards and not others reads as broken rather than as partial coverage. The
//  fallback means it always does something.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../services/narration_service.dart';

class NarrateButton extends StatelessWidget {
  const NarrateButton({
    super.key,
    required this.narrationKey,
    required this.text,
    required this.lang,
    this.englishText,
    this.size = 20,
    this.color,
  });

  /// The manifest key, e.g. `week20.babySnapshot.reveal`.
  final String narrationKey;

  /// What the passage says - only used if the device voice has to read it.
  final String text;
  final AppLanguage lang;

  /// The same passage in English, for phones with no Hindi voice installed.
  final String? englishText;

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final n = NarrationService.instance;
    return AnimatedBuilder(
      animation: n,
      builder: (context, _) {
        final playing = n.isPlaying(narrationKey);
        return IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: size + 16, height: size + 16),
          tooltip: playing ? S.now.stopLabel : S.now.listenLabel,
          onPressed: () => n.play(
            narrationKey,
            text: text,
            lang: lang,
            englishText: englishText,
          ),
          icon: Icon(
            playing ? Icons.stop_rounded : Icons.volume_up_rounded,
            size: size,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}
