// =============================================================================
//  The shared-phone switch, offered once where it matters
// -----------------------------------------------------------------------------
//  "Hide sex and intimacy content" lives in You, under What you see. Someone
//  who needs it (a phone shared with family) may never look there. So the
//  first time she opens the Sex and closeness tab of a door, it is offered
//  once, gently, in a small sheet: what it hides, what always stays, and where
//  to change it later. Added 2026-09-27 (TTC tools pass, notes: "also offer it
//  once, gently, the first time she opens the Sex and closeness tab").
//
//  ⚠️ NOTHING CHANGES UNTIL SHE SAYS SO, AND THEN IT CAN BE UNDONE. The sheet
//  says what "Hide it" does before she taps it, and the change is confirmed
//  with an Undo (the user's rule: tell her before anything changes). Closing
//  the sheet any other way changes nothing.
//
//  ⚠️ ONCE, WHATEVER SHE ANSWERED. Asked a second time it becomes a nag on a
//  tab that is about something private.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_content_prefs.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_common.dart' show ttcTitleInk;

const String kTtcIntimateOfferTitle = 'Sharing this phone?';
const String kTtcIntimateOfferBody =
    'This tab is about sex and closeness. If someone else uses this phone, '
    'you can hide it, along with its reads in Learn. Your fertile days and '
    'timing always stay. You can change this any time in You, under What you '
    'see.';
// Kept for revert (2026-09-28): 'Hide it', 'Keep showing it'. The buttons
// name the tab they act on.
const String kTtcIntimateOfferHide = 'Hide Sex and closeness';
const String kTtcIntimateOfferKeep = 'Keep the tab showing';
const String kTtcIntimateHiddenSnack = 'Sex and closeness is hidden';

/// Offers the switch if it has never been offered and is not already on.
Future<void> ttcMaybeOfferIntimateSwitch(BuildContext context) async {
  final prefs = TtcContentPrefs.instance;
  await prefs.init();
  if (prefs.intimateOffered || prefs.hideIntimate) return;
  if (!context.mounted) return;
  await prefs.markIntimateOffered();
  if (!context.mounted) return;
  final hide = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _OfferSheet(),
  );
  if (hide != true || !context.mounted) return;
  await prefs.setHideIntimate(true);
  if (!context.mounted) return;
  pvSnack(
    context,
    kTtcIntimateHiddenSnack,
    action: 'Undo',
    onAction: () => prefs.setHideIntimate(false),
    lift: 16,
    icon: Icons.check_rounded,
  );
}

class _OfferSheet extends StatelessWidget {
  const _OfferSheet();

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Material(
      key: const ValueKey('ttc_intimate_offer'),
      color: p.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Icon(Icons.lock_outline_rounded, size: 20, color: p.ink2),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(kTtcIntimateOfferTitle,
                      style: pvFraunces(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          color: p.ink1)),
                ),
              ]),
              const SizedBox(height: 10),
              Text(kTtcIntimateOfferBody,
                  style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: ttcTitleInk,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(kTtcIntimateOfferHide,
                      style: pvManrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: BorderSide(color: p.line, width: 1.2),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(kTtcIntimateOfferKeep,
                      style: pvManrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: p.ink1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
