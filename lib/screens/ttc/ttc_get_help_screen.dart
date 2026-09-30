// =============================================================================
//  Get help now: one calm page of who to call, for the trying stage
// -----------------------------------------------------------------------------
//  The user's decision (2026-09-28, option B for the emergency callouts at the
//  top of the TTC door tabs): the tinted "When to get help for low mood or
//  anxiety" rows come off the top of the tabs (the words still live in each
//  read's own "When to see someone" section), and ONE calm page takes their
//  place as the way to a person. It is reached from three places, each a tap
//  she makes rather than a banner she is shown:
//
//    · the end of Mind & body › Hard days ("Need to talk to someone now?")
//    · the end of Mind & body › Today, the tab the door opens on (see
//      `kTtcDoorGetHelpTabs` in `doors/ttc_door_screen.dart` for why there)
//    · You › Your health › Get help now
//
//  ⚠️ THE RULES, THE SAME AS `MmCrisisPathScreen` (pregnancy's Mind & Mood):
//    · Help first, and nothing else. No read, no product, no booking here.
//    · It never names a condition or says why she might be here. It routes to
//      a person; it does not label her (CLAUDE.md: never a diagnosis).
//    · Calm, not alarming. White ground, ink pills, hairline rows. No red, no
//      siren words, no warning glyph.
//
//  ⚠️ NO NUMBER IS TYPED HERE. Tele-MANAS and 112 come from the constants in
//  `lib/data/mind_mood_data.dart`, the one place a helpline number lives, so
//  when that number is confirmed or changes every crisis surface in the app
//  moves together. The wording ("the Government of India's free mental health
//  helpline", "1-800-891-4416") is the TTC reads' own, from
//  `lib/ttc/reads/ttc_reads_hard_days.dart`.
//
//  ⚠️ YOUR DOCTOR HAS NO CALL BUTTON, ON PURPOSE. The app does not hold her
//  clinic's number, and inventing a way to reach one would be worse than
//  saying plainly who to call. The row says when to call them; the number is
//  hers.
//
//  Mobbin: Alan "Help is available"
//  (https://mobbin.com/screens/aa6b489c-b86c-4492-b477-f3ee9f295810), a short
//  title, one reassuring line, then one row per line of help with its own
//  call action; Wysa's SOS page
//  (https://mobbin.com/screens/de96d391-118b-4684-add3-62a5634d2d7e),
//  helplines as calm rows with a call button each and a line on when to use
//  them; Bumble "Helpful resources"
//  (https://mobbin.com/screens/d99af55c-f3db-4dda-8517-b215717326bb), a name
//  and one plain line of what each service is for.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/mind_mood_data.dart'
    show
        kCrisisHelplineName,
        kCrisisHelplineNumber,
        kCrisisHelplineNumberAlt,
        kCrisisHelplineHours,
        kEmergencyNumber,
        kAmbulanceNumber;
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../doors/pv_list_row.dart' show PvMarkWell, PvRowGroup;
import '../v2/v2_palette.dart';
import 'ttc_tool_chrome.dart';
import 'ttc_common.dart' show ttcTitleInk;

/// The route name, so the rest of the app (and `global_ask_fab.dart`, which
/// reads route names) can tell this page is on screen.
const String kTtcGetHelpRoute = 'ttc/get_help';

/// The page's title, and the name every entry to it uses.
const String kTtcGetHelpTitle = 'Get help now';

/// The door row's question (Mind & body › Hard days and Today).
const String kTtcGetHelpAsk = 'Need to talk to someone now?';

/// Keys a test can find.
const Key kTtcGetHelpRowKey = ValueKey('ttc-get-help-row');
Key ttcGetHelpCallKey(String number) => ValueKey('ttc-get-help-call-$number');

/// How a number is dialled. A test swaps it to record the call.
typedef TtcDial = Future<void> Function(String number);

/// Opens the dialler with [number] ready. Fire and forget: a phone that cannot
/// call (a tablet, an emulator) must not crash a help page, and the number is
/// on screen to dial by hand. The same shape as `MmCrisisPathScreen._call`.
Future<void> ttcDialNumber(String number) async {
  try {
    await launchUrl(Uri(scheme: 'tel', path: number));
  } catch (_) {}
}

/// Push the page. Every entry point calls this, so there is one page.
Future<void> openTtcGetHelp(BuildContext context) {
  pvCommitFeedback();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: kTtcGetHelpRoute),
      builder: (_) => const TtcGetHelpScreen(),
    ),
  );
}

/// "1-800-891-4416", from the constant's digits, as the reads print it.
String _tollFree(String digits) => digits.length == 11
    ? '${digits.substring(0, 1)}-${digits.substring(1, 4)}-'
          '${digits.substring(4, 7)}-${digits.substring(7)}'
    : digits;

class TtcGetHelpScreen extends StatelessWidget {
  const TtcGetHelpScreen({super.key, this.dial = ttcDialNumber});

  final TtcDial dial;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return TtcToolScaffold(
      // 160: the calm green this stage uses for Today and her own logs.
      hue: 160,
      // Kept for revert (2026-09-28): 'Help is here'
      // Not 'Get help now': that is the title right under it.
      eyebrow: 'Helplines and support',
      title: kTtcGetHelpTitle,
      intro: "If you're struggling or something feels wrong right now, you "
          "don't have to wait.",
      children: [
        const SizedBox(height: 22),
        ttcToolPad(
          PvRowGroup(
            p: p,
            children: [
              _HelpRow(
                key: const ValueKey('ttc-get-help-telemanas'),
                p: p,
                icon: Icons.phone_in_talk_outlined,
                name: '$kCrisisHelplineName, $kCrisisHelplineNumber',
                what: "The Government of India's free mental health "
                    'helpline. $kCrisisHelplineHours.',
                when: 'Call when you feel very low, anxious or '
                    'overwhelmed, or have thoughts of harming yourself.',
                number: kCrisisHelplineNumber,
                callLabel: 'Call $kCrisisHelplineNumber',
                alsoNumber: kCrisisHelplineNumberAlt,
                alsoLabel: "If $kCrisisHelplineNumber doesn't connect, call "
                    '${_tollFree(kCrisisHelplineNumberAlt)}.',
                dial: dial,
              ),
              _HelpRow(
                key: const ValueKey('ttc-get-help-emergency'),
                p: p,
                icon: Icons.local_hospital_outlined,
                name: 'Emergency, $kEmergencyNumber',
                what: "India's emergency number, for police or an ambulance.",
                when: 'Call if you or someone is in danger.',
                number: kEmergencyNumber,
                callLabel: 'Call $kEmergencyNumber',
                // The ambulance line, on the same row's second-number slot
                // Tele-MANAS uses (2026-09-28).
                alsoNumber: kAmbulanceNumber,
                alsoLabel: 'For an ambulance, you can also call '
                    '$kAmbulanceNumber.',
                dial: dial,
              ),
              _HelpRow(
                key: const ValueKey('ttc-get-help-doctor'),
                p: p,
                icon: Icons.medical_services_outlined,
                name: 'Your doctor or clinic',
                what: 'They know you and your history.',
                when: 'Call them for pregnancy or treatment worries.',
                dial: dial,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        ttcToolPad(
          Text(
            'You can come back here any time from You, under Your health.',
            style: pvManrope(fontSize: 12, height: 1.5, color: p.ink3),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

/// One line of help: a well, the name, what it is, when to use it, and a
/// Call pill when there is a number to call.
class _HelpRow extends StatelessWidget {
  const _HelpRow({
    super.key,
    required this.p,
    required this.icon,
    required this.name,
    required this.what,
    required this.when,
    required this.dial,
    this.number,
    this.callLabel,
    this.alsoNumber,
    this.alsoLabel,
  });

  final V2Palette p;
  final IconData icon;
  final String name;
  final String what;
  final String when;
  final TtcDial dial;
  final String? number;
  final String? callLabel;
  final String? alsoNumber;
  final String? alsoLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PvMarkWell(p: p, hue: 160, size: 40, icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: pvManrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: p.ink1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  what,
                  style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2),
                ),
                const SizedBox(height: 4),
                Text(
                  when,
                  style: pvManrope(
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: p.ink1,
                  ),
                ),
                if (number case final n?) ...[
                  const SizedBox(height: 12),
                  _CallPill(
                    key: ttcGetHelpCallKey(n),
                    p: p,
                    label: callLabel ?? 'Call $n',
                    onTap: () => dial(n),
                  ),
                ],
                if (alsoNumber case final alt?) ...[
                  const SizedBox(height: 6),
                  Semantics(
                    button: true,
                    child: InkWell(
                      key: ttcGetHelpCallKey(alt),
                      onTap: () => dial(alt),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            alsoLabel ?? alt,
                            style: pvManrope(
                              fontSize: 12.5,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: p.ink2,
                            ).copyWith(decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The ink pill: dark fill, light words. The one action on a row.
class _CallPill extends StatelessWidget {
  const _CallPill({
    super.key,
    required this.p,
    required this.label,
    required this.onTap,
  });

  final V2Palette p;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: PvPress(
        child: Material(
          color: ttcTitleInk,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              pvCommitFeedback();
              onTap();
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.call_outlined, size: 17, color: p.ground),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: p.ground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  The door row: a calm way to the page, at the END of a tab
// -----------------------------------------------------------------------------
//  Unboxed, on the page gutter, between two hairlines, like every other list
//  row in the stage (`PvListRow`). A question, not a warning: it is an offer
//  she can take after she has read the tab, never the first thing she sees.
// =============================================================================

class TtcGetHelpRow extends StatelessWidget {
  const TtcGetHelpRow({super.key, required this.p, required this.onTap});

  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PvRowGroup(
      p: p,
      children: [
        Semantics(
          button: true,
          label: '$kTtcGetHelpAsk Opens $kTtcGetHelpTitle',
          excludeSemantics: true,
          child: PvPress(
            child: InkWell(
              key: kTtcGetHelpRowKey,
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      PvMarkWell(
                        p: p,
                        hue: 160,
                        size: 40,
                        icon: Icons.phone_in_talk_outlined,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              kTtcGetHelpAsk,
                              style: pvManrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                color: p.ink1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Helplines you can call now, and who to call '
                              'when.',
                              style: pvManrope(
                                fontSize: 12.5,
                                height: 1.4,
                                color: p.ink2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: p.ink3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
