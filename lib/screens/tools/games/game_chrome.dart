// =============================================================================
//  The chrome the four Buddhi games share
// -----------------------------------------------------------------------------
//  Promoted out of `garbh_games.dart` when Sudoku and the nonogram got their
//  own files (Buddhi to final, 2026-09-12). One scaffold, one "how to play"
//  card, one finish state — so the four games read as one place.
//
//  ⚠️ THE FINISH IS SOFT. "Finish softly (no confetti spam)" — the brief's
//  words, and the app's rule for every practice: no chime, no streak, no
//  "well done" in capitals. A line, a line icon, play again, close.
//
//  ⚠️ NOTHING HERE TIMES OR SCORES. "Do not show a pressuring timer."
//  Memory Match counts moves quietly on its own screen; that is the only
//  number any game shows, and it is not here.
//
//  ⚠️ ON V3's NEUTRALS, WITH BUDDHI'S ACCENT. The games still wore Garbh's
//  old warm cream (#FBF6EE) and Vichara's green after every other Garbh
//  screen moved to V3's ground and ink (see `garbh_screen.dart`'s header for
//  why values rather than a live palette). They match now, and the accent is
//  Buddhi's — the pillar these games belong to — not Vichara's, the pillar
//  that no longer has a row.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../localization/app_language.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../theme/pv_fonts.dart';

const Color kGameAccent = Color(0xFF2F2C30); // Buddhi's indigo
const Color kGameAccentDeep = Color(0xFF2F2C30);
const Color kGameInk = Color(0xFF201C24); // V3 ink1
const Color kGameMuted = Color(0xFF2F2C30); // V3 ink3
const Color kGameLine = Color(0x14000000); // V3 line
const Color kGameGround = Color(0xFFFFFFFF); // V3 ground — white since 2026-09-17; was 0xFFF5F3F6
const Color kGameSurface = Color(0xFFFFFFFF);
const Color kGameSoftRed = Color(0xFFC07A6A);

class GarbhGameChrome extends StatelessWidget {
  const GarbhGameChrome({
    super.key,
    required this.title,
    required this.controller,
    required this.done,
    required this.onAgain,
    required this.child,
    this.onReload,
    this.onNewPuzzle,
    this.onNext,
    this.actions = const [],
  });

  final String title;
  final PregnancyController controller;
  final bool done;
  final VoidCallback onAgain;
  final Widget child;

  /// In-game controls, as app-bar actions while playing:
  ///   onReload    — restart the CURRENT puzzle (clears progress, same board).
  ///   onNewPuzzle — a fresh random puzzle.
  ///   onNext      — the next puzzle in sequence.
  final VoidCallback? onReload;
  final VoidCallback? onNewPuzzle;
  final VoidCallback? onNext;

  /// Anything else a game wants in the bar (Sudoku's size switch).
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final hinglish = controller.language.isHinglish;
    return Scaffold(
      backgroundColor: kGameGround,
      appBar: AppBar(
        backgroundColor: kGameGround,
        surfaceTintColor: Colors.transparent,
        foregroundColor: kGameAccentDeep,
        elevation: 0,
        title: Text(title,
            style: pvFraunces(
                fontSize: 18, fontWeight: FontWeight.w600, color: kGameInk)),
        actions: done
            ? null
            : [
                ...actions,
                if (onReload != null)
                  IconButton(
                    tooltip: hinglish ? 'फिर से शुरू' : 'Reload',
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: onReload,
                  ),
                if (onNewPuzzle != null)
                  IconButton(
                    tooltip: hinglish ? 'नई पहेली' : 'New puzzle',
                    icon: const Icon(Icons.casino_outlined),
                    onPressed: onNewPuzzle,
                  ),
                if (onNext != null)
                  IconButton(
                    tooltip: hinglish ? 'अगली पहेली' : 'Next puzzle',
                    icon: const Icon(Icons.skip_next_rounded),
                    onPressed: onNext,
                  ),
              ],
      ),
      body: SafeArea(child: done ? _completion(context, s) : child),
    );
  }

  Widget _completion(BuildContext context, S s) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.spa_outlined, size: 44, color: kGameAccent),
            const SizedBox(height: 16),
            Text(s.gsGameDone,
                textAlign: TextAlign.center,
                style: pvFraunces(
                    fontSize: 20, fontWeight: FontWeight.w600, color: kGameInk)),
            const SizedBox(height: 28),
            SizedBox(
              width: 220,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: kGameAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                onPressed: onAgain,
                child: Text(s.gsPlayAgain,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(s.gsGameClose,
                  style: const TextStyle(
                      color: kGameMuted, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      );
}

/// The one-line "how to play" card at the top of a game.
Widget garbhHowCard(String text) => Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kGameAccent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGameAccent.withValues(alpha: 0.20)),
      ),
      child: Row(children: [
        const Icon(Icons.spa_outlined, size: 18, color: kGameAccentDeep),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: pvManrope(fontSize: 13, height: 1.4, color: kGameInk))),
      ]),
    );

/// A small round key — the Sudoku pad, the nonogram's mode switch.
class GarbhGameKey extends StatelessWidget {
  const GarbhGameKey({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.selected = false,
    this.width = 44,
  });
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool selected;
  final double width;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? kGameAccent.withValues(alpha: 0.16) : kGameSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? kGameAccent : kGameLine),
          ),
          child: icon != null
              ? Icon(icon, size: 20, color: selected ? kGameAccentDeep : kGameInk)
              : Text(label,
                  style: pvManrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: selected ? kGameAccentDeep : kGameInk)),
        ),
      );
}
