// =============================================================================
//  One way to ask "remove this?" across the TTC record tools
// -----------------------------------------------------------------------------
//  Added 2026-09-27 in the tools pass. Supplements, appointments and medication
//  each had a small "x" (or a quiet link) that deleted at once, with no
//  question and no way back. A supplement carries every day she ticked it; a
//  clinic visit carries a date she copied off a printout. Losing either to a
//  stray thumb is the kind of thing that makes a record feel unsafe to keep.
//
//  ⚠️ A CONFIRM, NOT AN UNDO SNACKBAR, and the trade-off is worth naming. An
//  undo is one tap cheaper when she meant it, but it needs the store to hold
//  the deleted row (and, for a supplement, its ticks) somewhere until the
//  snackbar times out, and a cloud delete that has already gone out has to be
//  re-inserted. A confirm costs one extra tap and needs nothing from any store.
//  Deletes here are rare and deliberate, so the extra tap is the cheaper side.
//
//  Shape from Mobbin (Perplexity "Delete memory?", Noom "clear your list"):
//  the question names the thing, one line says what goes with it, the
//  destructive word sits on the right and the safe choice beside it.
// =============================================================================

import 'package:flutter/material.dart';

import 'ttc_common.dart';

/// Asks before something she keeps is removed. True only when she says yes.
Future<bool> ttcConfirmRemove(
  BuildContext context, {
  required String title,
  required String body,
  String yes = 'Remove',
  String no = 'Keep it',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    routeSettings: const RouteSettings(name: 'ttc/confirm_remove'),
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(title, style: ttcJakarta(16)),
      content: Text(body, style: ttcBody(13.5, h: 1.5)),
      actions: [
        TextButton(
          key: const ValueKey('ttc_confirm_no'),
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(no,
              style: ttcBody(13, color: ttcSoft, w: FontWeight.w700)),
        ),
        TextButton(
          key: const ValueKey('ttc_confirm_yes'),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(yes,
              style: ttcBody(13,
                  color: const Color(0xFFD92D20), w: FontWeight.w800)),
        ),
      ],
    ),
  );
  return ok == true;
}

/// A short line under a form that says why its button cannot save yet.
///
/// ⚠️ THE ANSWER TO A DEAD TAP. A Save that silently ignores a tap reads as a
/// broken app; a Save that says "Add a name to save" reads as a form. The
/// button stays tappable and the tap shows this line, so the reason arrives at
/// the moment she asks for it rather than as a warning before she has typed.
class TtcFormHint extends StatelessWidget {
  const TtcFormHint({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, size: 14, color: ttcBrown),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: ttcBody(12.5, color: ttcBrown, w: FontWeight.w700)),
          ),
        ]),
      );
}
