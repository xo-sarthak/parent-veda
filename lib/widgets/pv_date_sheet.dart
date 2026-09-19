// =============================================================================
//  showPvDateSheet — the one way a date is picked
// -----------------------------------------------------------------------------
//  Built for the scan timeline (2026-09-19, Mobbin: Rodeo, Todoist, Alta,
//  Freenow) and shared from here the same day, when the user saw the
//  Material dialog on onboarding's "When is the baby due?" — lavender
//  surface, violet day, a dialog floating over the page. Every app that sets
//  a date today draws the month INSIDE a sheet, the chosen day a filled
//  disc, today ringed. So: a bottom sheet, a heading in the display face,
//  the month grid (`CalendarDatePicker`, which takes the app's ink picker
//  theme), and one Save pill. Returns the date, or null.
//
//  ⚠️ NEVER `showDatePicker` IN NEW CODE. It is the dialog this replaces.
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/v2/v2_palette.dart';
import '../theme/pv_fonts.dart';
import 'pv_feedback.dart';

Future<DateTime?> showPvDateSheet(
  BuildContext context, {
  required String title,
  String? eyebrow,
  required DateTime initial,
  required DateTime first,
  required DateTime last,
}) async {
  final p = V2PaletteStore.instance.current;
  var date = initial.isBefore(first) ? first : (initial.isAfter(last) ? last : initial);
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20, 18, 20, 20 + MediaQuery.paddingOf(ctx).bottom),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(eyebrow.toUpperCase(),
                    style: pvManrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        color: p.ink3)),
                const SizedBox(height: 4),
              ],
              Text(title,
                  style: pvFraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: p.ink1)),
              const SizedBox(height: 6),
              Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: Theme.of(ctx).colorScheme.copyWith(
                      primary: p.ink1,
                      onPrimary: Colors.white,
                      surface: p.surface,
                      surfaceContainerHigh: p.surface,
                      surfaceTint: Colors.transparent),
                ),
                child: CalendarDatePicker(
                  initialDate: date,
                  firstDate: first,
                  lastDate: last,
                  onDateChanged: (d) => setSheet(() => date = d),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  pvCommitFeedback();
                  Navigator.pop(ctx, date);
                },
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('Save'),
              ),
            ]),
      ),
    ),
  );
}
