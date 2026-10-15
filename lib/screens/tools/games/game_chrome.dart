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
import '../../../widgets/pv_feedback.dart' show PvPress;
import '../../garbh/garbh_marks.dart';

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

  /// In-game controls, as labelled pills under the title while playing:
  ///   onReload    — restart the CURRENT puzzle (clears progress, same board).
  ///   onNewPuzzle — a fresh random puzzle.
  ///   onNext      — the next puzzle in sequence.
  final VoidCallback? onReload;
  final VoidCallback? onNewPuzzle;
  final VoidCallback? onNext;

  /// Anything else a game wants beside them (Sudoku's size switch).
  final List<Widget> actions;

  // ⚠️ NO MATERIAL APP BAR, NO ICON-ONLY ACTIONS (2026-10-15, the Garbh pillars
  // pass). The user: games "inside each and every game as well to use the
  // glyphs and the new UI", and every screen "easy to use and to understand".
  // The bar's three bare icons (refresh, dice, skip) asked her to guess; now
  // each is a drawn glyph WITH its word, in a quiet row under the title, and
  // the back is the same round button every Garbh screen has (top-left).
  // Kept for revert: Scaffold(appBar: AppBar(title, actions: IconButton x3)).
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final hindi = controller.language.isHinglish;
    final top = MediaQuery.paddingOf(context).top;
    // ⚠️ AT MOST TWO, IN THE TITLE ROW. "New" and "Next" both hand her a
    // different puzzle, and in Memory Match "Restart" and "New" are the same
    // reshuffle: two controls for one wish is a choice she does not need (the
    // calm rule). And a separate row of pills pushed Sudoku's keypad below a
    // 360dp screen, where a keypad she must scroll to is one she cannot use.
    final fresh = onNewPuzzle ?? onNext;
    final pills = <Widget>[
      ...actions,
      if (onReload != null && onReload != fresh)
        _ActionPill(
            key: const ValueKey('game_reload'),
            glyph: GarbhGameMark.reload,
            label: hindi ? 'फिर से' : 'Restart',
            onTap: onReload!),
      if (fresh != null)
        _ActionPill(
            key: const ValueKey('game_new'),
            glyph: GarbhGameMark.newGame,
            label: hindi ? 'नई' : 'New',
            onTap: fresh),
    ];
    return Scaffold(
      backgroundColor: kGameGround,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.fromLTRB(12, top + 8, 18, 0),
          child: Row(children: [
            PvPress(
              child: GestureDetector(
                key: const ValueKey('game_back'),
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kGameSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x1F000000)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 20, color: kGameInk),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvFraunces(
                      fontSize: 19, fontWeight: FontWeight.w600, color: kGameInk)),
            ),
            if (!done)
              for (final p in pills) ...[const SizedBox(width: 6), p],
          ]),
        ),
        Expanded(
          child: SafeArea(
            top: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: done
                  ? KeyedSubtree(key: const ValueKey('done'), child: _completion(context, s))
                  : KeyedSubtree(key: const ValueKey('play'), child: child),
            ),
          ),
        ),
      ]),
    );
  }

  // The finish: the Buddhi mark, one line, one ink pill, and a way out as a
  // text link (Opal's "Nevermind"). No confetti, no score.
  // Kept for revert: Icons.spa_outlined, a radius-14 FilledButton.
  Widget _completion(BuildContext context, S s) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            garbhPillarMark('buddhi', size: 64),
            const SizedBox(height: 18),
            Text(s.gsGameDone,
                textAlign: TextAlign.center,
                style: pvFraunces(
                    fontSize: 22, fontWeight: FontWeight.w600, color: kGameInk)),
            const SizedBox(height: 28),
            PvPress(
              child: GestureDetector(
                key: const ValueKey('game_again'),
                behavior: HitTestBehavior.opaque,
                onTap: onAgain,
                child: Container(
                  width: 240,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kGameAccent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Text(s.gsPlayAgain,
                      style: pvManrope(
                          fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(s.gsGameClose,
                  style: pvManrope(
                      fontSize: 14, color: kGameMuted, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      );
}

/// A quiet action under a game's title: a drawn glyph and its word.
class _ActionPill extends StatelessWidget {
  const _ActionPill({
    super.key,
    required this.glyph,
    required this.label,
    required this.onTap,
  });
  final GarbhGameMark glyph;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PvPress(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            decoration: BoxDecoration(
              color: kGameSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0x1F000000)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              garbhKeyGlyph(glyph, color: kGameInk, size: 15),
              const SizedBox(width: 7),
              Text(label,
                  style: pvManrope(
                      fontSize: 13, fontWeight: FontWeight.w700, color: kGameInk)),
            ]),
          ),
        ),
      );
}

/// The one-line "how to play" card at the top of a game. A hairline white
/// card with the Buddhi mark: never a tinted box behind text (2026-10-15;
/// kept for revert: accent at 10% fill, Icons.spa_outlined).
Widget garbhHowCard(String text) => Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: kGameSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1F000000)),
      ),
      child: Row(children: [
        garbhPillarMark('buddhi', size: 30),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text,
                style: pvManrope(fontSize: 13, height: 1.45, color: kGameInk))),
      ]),
    );

/// A small key: the Sudoku pad, the nonogram's mode switch.
///
/// With [glyph], a drawn mark AND its word under it (the ease rule: a glyph
/// never stands alone where meaning matters); [icon] stays for the chrome
/// verbs the app draws in Material (backspace).
class GarbhGameKey extends StatelessWidget {
  const GarbhGameKey({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.glyph,
    this.selected = false,
    this.width = 44,
  });
  final String label;
  final IconData? icon;
  final GarbhGameMark? glyph;
  final VoidCallback onTap;
  final bool selected;
  final double width;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : kGameInk;
    final Widget face;
    if (glyph != null) {
      // Scales down rather than spilling at a large text size.
      face = FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          garbhKeyGlyph(glyph!, color: fg, size: 16),
          const SizedBox(height: 3),
          Text(label,
              style: pvManrope(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
        ]),
      );
    } else if (icon != null) {
      face = Icon(icon, size: 20, color: fg);
    } else {
      face = Text(label,
          style: pvManrope(fontSize: 16, fontWeight: FontWeight.w700, color: fg));
    }
    return PvPress(
        child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: width,
        height: glyph != null ? 54 : 44,
        padding: glyph != null ? const EdgeInsets.symmetric(vertical: 5) : null,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // Selected is the one ink fill (a mode that is ON), not a tint.
          color: selected ? kGameAccent : kGameSurface,
          borderRadius: BorderRadius.circular(glyph != null ? 16 : 12),
          border: Border.all(color: selected ? kGameAccent : const Color(0x1F000000)),
        ),
        child: face,
      ),
    ));
  }
}
