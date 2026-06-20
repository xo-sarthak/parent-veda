// =============================================================================
//  SpeakerButton
// -----------------------------------------------------------------------------
//  Per-card speaker control. Plays this card's baby dialogue when tapped, stops
//  it if already playing. Reflects global mute. Independent of the global mute
//  toggle (tapping here never changes the global setting).
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../services/baby_voice_service.dart';
import '../../theme/app_theme.dart';

/// The single shared speaker control used by every card. Tapping plays this
/// card's [text] (stopping any other card's audio first, via the service),
/// tapping again stops it. Reflects global mute and live playback state. Any
/// card that narrates content should use THIS widget so behaviour never drifts.
class SpeakerButton extends StatelessWidget {
  const SpeakerButton({
    super.key,
    required this.text,
    required this.cardKey,
    required this.lang,
    this.accent,
    this.size = 42,
    this.scope = VoiceScope.journey,
  });

  final String text;
  final String cardKey;
  final AppLanguage lang;
  final Color? accent;

  /// Which mute scope this speaker belongs to (defaults to the Weekly Journey).
  final VoiceScope scope;

  /// Diameter of the round button. Defaults to the header size (42).
  final double size;

  @override
  Widget build(BuildContext context) {
    final svc = BabyVoiceService.instance;
    final tint = accent ?? AppTheme.primary500;
    // Nothing to speak → don't show a dead control.
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: svc,
      builder: (context, _) {
        final playing = svc.isPlaying(cardKey);
        final muted = svc.isMutedFor(scope);
        final IconData icon = muted
            ? Icons.volume_off_rounded
            : (playing ? Icons.volume_up_rounded : Icons.volume_up_outlined);
        return Semantics(
          button: true,
          label: 'Play baby voice',
          child: GestureDetector(
            onTap: muted
                ? null
                : () => svc.toggleCard(text,
                    cardKey: cardKey, lang: lang, scope: scope),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: playing
                    ? tint
                    : tint.withValues(alpha: muted ? 0.06 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: size * 0.48,
                color: playing
                    ? Colors.white
                    : (muted ? AppTheme.neutral400 : tint),
              ),
            ),
          ),
        );
      },
    );
  }
}
