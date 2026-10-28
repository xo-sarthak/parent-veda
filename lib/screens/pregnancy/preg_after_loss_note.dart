// =============================================================================
//  The after-loss note: a tool stays, and says once what has changed
// -----------------------------------------------------------------------------
//  P3 D5 (user, 2026-10-28): "everything stays, with the baby wording
//  dropped... just provide a prompt when the user clicks on those tools that
//  need a baby." So no tool is hidden after a loss. A tool that only makes
//  sense with a pregnancy still opens, and this quiet line at its top says
//  what is different now, so nothing on the page reads as if the baby is
//  still coming. It draws nothing unless `PregnancyEndedStore.ended`.
//
//  A note, not a dialog: she opened the tool on purpose, and a box to dismiss
//  before every visit would be one more thing to get past on a hard day.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/pregnancy_ended_store.dart';
import '../../theme/pv_fonts.dart';
import '../products/pv_store_chrome.dart' show kPvLine, pvStorePalette;

/// Baby movement after a loss.
const String kAfterLossMovement =
    'This tracker is for a baby\'s movements. It stays here if you want it, '
    'and nothing in the app will ask you to use it.';

/// The due date after a loss.
const String kAfterLossDueDate =
    'Since your loss the app has stopped counting weeks. A date saved here '
    'is kept for if you go back to your pregnancy view.';

/// The Calendar after a loss.
const String kAfterLossCalendar =
    'Since your loss the countdown and the usual pregnancy checks are put '
    'away. Your own appointments stay here, and so do their reminders.';

/// The scans timeline after a loss.
const String kAfterLossScans =
    'Since your loss nothing here is coming up. The scans you had are '
    'kept, with their dates and notes.';

class PregAfterLossNote extends StatelessWidget {
  const PregAfterLossNote(this.text, {super.key, this.bottom = 16});
  final String text;

  /// Space under the note when it shows; nothing when it does not.
  final double bottom;

  @override
  Widget build(BuildContext context) {
    final ended = PregnancyEndedStore.instance;
    return ListenableBuilder(
      listenable: ended,
      builder: (context, _) {
        if (!ended.ended) return const SizedBox.shrink();
        final p = pvStorePalette;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Container(
            key: const ValueKey('preg_after_loss_note'),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            // White with a hairline: no tinted block behind text.
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kPvLine),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: p.ink2),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(text,
                      style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
