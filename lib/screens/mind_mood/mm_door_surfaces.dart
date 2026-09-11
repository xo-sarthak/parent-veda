// =============================================================================
//  Mind & mood — the screens the door opens that did not exist as screens
// -----------------------------------------------------------------------------
//  Four small surfaces, each wrapping something the area already had:
//
//    · `MmHardDayResetScreen` — the brief's 3.1, a three-minute guided screen
//      on the breathing circle. REBUILT: it used to be a coming-soon film.
//    · `MmAffirmationsScreen` — the brief's 3.2, one at a time on "Show me
//      one". The card on the old Feel tab, given its own screen.
//    · `MmHelplinesScreen` — the crisis path's numbers, listed. The brief
//      marks "Helpline numbers [Guide new]" and gives no prose, and there is
//      none to give: it is four numbers and their hours.
//    · `MmOfferingScreen` — one paid offering, with its price on the face and
//      the booking sheet behind one button. The Talk tab's card, as a page.
//
//  ⚠️ ALL ON THE DOOR'S TOOL CHROME, so a screen opened from Mind & mood looks
//  like a screen opened from any other door. The area's own screens (the
//  breathing circle, the grounding flow, the screener, the crisis path) keep
//  their own chrome — they are shipped and this door reuses them whole.
// =============================================================================

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/mind_mood_data.dart';
import '../../data/mind_mood_extras.dart';
import '../../theme/pv_fonts.dart';
import '../doors/pv_door_chrome.dart';
import '../v2/v2_palette.dart';
import 'mm_talk_tab.dart' show showCounsellingBookingSheet;

// -----------------------------------------------------------------------------
//  A hard-day reset
// -----------------------------------------------------------------------------

class MmHardDayResetScreen extends StatefulWidget {
  const MmHardDayResetScreen({super.key});

  @override
  State<MmHardDayResetScreen> createState() => _MmHardDayResetScreenState();
}

class _MmHardDayResetScreenState extends State<MmHardDayResetScreen>
    with SingleTickerProviderStateMixin {
  /// -1 is the intro; 0..3 the steps; 4 the close.
  int _at = -1;

  /// The circle breathes on every step. A longer out than in, as the copy
  /// says — 4s in, 6s out — with no count shown, because the copy says that
  /// too: "Nothing to count, just a longer out than in."
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(288, p);
    final ink = HSLColor.fromColor(tint)
        .withSaturation(0.40)
        .withLightness(0.36)
        .toColor();

    final String heading;
    final String body;
    if (_at < 0) {
      heading = 'A hard-day reset';
      body = kMmHardDayIntro;
    } else if (_at < kMmHardDaySteps.length) {
      heading = kMmHardDaySteps[_at].title;
      body = kMmHardDaySteps[_at].body;
    } else {
      heading = 'That is it';
      body = kMmHardDayClose;
    }
    final last = _at >= kMmHardDaySteps.length;

    return PvDoorToolScaffold(
      hue: 288,
      eyebrow: 'Feel',
      title: 'A hard-day reset',
      intro: 'About three minutes. No streak, nothing logged.',
      children: [
        pvDoorPad(Center(
          child: AnimatedBuilder(
            animation: _breath,
            builder: (context, _) {
              // 0..0.4 = in, 0.4..1 = out. The out is longer.
              final t = _breath.value;
              final k = t < 0.4
                  ? Curves.easeInOut.transform(t / 0.4)
                  : 1 - Curves.easeInOut.transform((t - 0.4) / 0.6);
              final size = 150 + k * 90;
              return SizedBox(
                width: 240,
                height: 240,
                child: Center(
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        tint.withValues(alpha: 0.9),
                        tint.withValues(alpha: 0.35),
                      ]),
                      border:
                          Border.all(color: ink.withValues(alpha: 0.25), width: 1.2),
                    ),
                  ),
                ),
              );
            },
          ),
        )),
        const SizedBox(height: 18),
        pvDoorPad(AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: Column(
            key: ValueKey(_at),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_at >= 0 && !last)
                Text('${_at + 1} of ${kMmHardDaySteps.length}',
                    style: pvManrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: p.ink3)),
              if (_at >= 0 && !last) const SizedBox(height: 8),
              Text(heading,
                  style: pvFraunces(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                      letterSpacing: -0.5,
                      color: p.ink1)),
              const SizedBox(height: 10),
              Text(body,
                  style: pvManrope(fontSize: 15, height: 1.6, color: p.ink1)),
            ],
          ),
        )),
        const SizedBox(height: 26),
        pvDoorPad(Row(children: [
          if (_at >= 0)
            _Pill(
              p: p,
              label: 'Back',
              strong: false,
              onTap: () => setState(() => _at--),
            ),
          if (_at >= 0) const SizedBox(width: 10),
          Expanded(
            child: _Pill(
              p: p,
              label: _at < 0
                  ? 'Start'
                  : last
                      ? 'Done'
                      : 'Next',
              strong: true,
              onTap: () => last
                  ? Navigator.of(context).maybePop()
                  : setState(() => _at++),
            ),
          ),
        ])),
        // ⚠️ THE CLOSE IS ALSO THE DISCLAIMER. "Nothing to log. Come back
        // whenever a day gets heavy." — the brief's own words, and no legal
        // sentence under a screen whose whole point is that nothing is
        // measured. Not drawn on the last step, where it is the body.
        if (!last) ...[
          const SizedBox(height: 22),
          pvDoorPad(Text(kMmHardDayClose,
              style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink3))),
        ],
      ],
    );
  }
}

// -----------------------------------------------------------------------------
//  Affirmations
// -----------------------------------------------------------------------------

class MmAffirmationsScreen extends StatefulWidget {
  const MmAffirmationsScreen({super.key});

  @override
  State<MmAffirmationsScreen> createState() => _MmAffirmationsScreenState();
}

class _MmAffirmationsScreenState extends State<MmAffirmationsScreen> {
  final _rng = Random();
  MmAffirmation? _current;

  void _next() {
    if (kMmAffirmations.isEmpty) return;
    MmAffirmation next;
    do {
      next = kMmAffirmations[_rng.nextInt(kMmAffirmations.length)];
    } while (kMmAffirmations.length > 1 && next.text.en == _current?.text.en);
    setState(() => _current = next);
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(288, p);
    return PvDoorToolScaffold(
      hue: 288,
      eyebrow: 'Feel',
      title: 'A gentle word',
      intro: 'One at a time. For you, never about the baby.',
      children: [
        pvDoorPad(AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(_current?.text.en ?? ''),
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
                _current?.text.en ?? 'Tap below whenever you want one.',
                style: pvFraunces(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    letterSpacing: -0.5,
                    color: _current == null ? p.ink3 : p.ink1)),
          ),
        )),
        const SizedBox(height: 18),
        pvDoorPad(_Pill(
          p: p,
          label: _current == null ? 'Show me one' : 'Another one',
          strong: true,
          onTap: _next,
        )),
        const SizedBox(height: 22),
        pvDoorPad(PvDoorDisclaimer(
            p: p,
            text: 'Nothing here is logged or counted. Read one, or read '
                'all of them, whenever you like.')),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
//  Helpline numbers
// -----------------------------------------------------------------------------

class MmHelplinesScreen extends StatelessWidget {
  const MmHelplinesScreen({super.key});

  Future<void> _call(String number) async {
    try {
      await launchUrl(Uri(scheme: 'tel', path: number));
    } catch (_) {
      // A phone without a dialler should not crash this screen. The number
      // is on screen to dial by hand.
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return PvDoorToolScaffold(
      hue: 344,
      eyebrow: 'When it is more than this',
      title: 'Helpline numbers',
      intro: 'Free, any hour, and nobody asks who you are. Tap a number to '
          'call it.',
      children: [
        pvDoorPad(_NumberCard(
          p: p,
          name: kCrisisHelplineName,
          number: kCrisisHelplineNumber,
          alt: kCrisisHelplineNumberAlt,
          line: kCrisisHelplineHours,
          onCall: _call,
        )),
        const SizedBox(height: 12),
        pvDoorPad(_NumberCard(
          p: p,
          name: 'Emergency',
          number: kEmergencyNumber,
          line: 'Police, ambulance, fire — the one number for all three.',
          onCall: _call,
        )),
        const SizedBox(height: 22),
        pvDoorPad(PvDoorDisclaimer(
            p: p,
            text: 'If you are in danger right now, call $kEmergencyNumber '
                'first. Everything else on this door can wait until you are '
                'safe.')),
      ],
    );
  }
}

class _NumberCard extends StatelessWidget {
  const _NumberCard({
    required this.p,
    required this.name,
    required this.number,
    required this.line,
    required this.onCall,
    this.alt,
  });
  final V2Palette p;
  final String name;
  final String number;
  final String? alt;
  final String line;
  final ValueChanged<String> onCall;

  @override
  Widget build(BuildContext context) => PvDoorCard(
        p: p,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style: pvFraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: p.ink1)),
          const SizedBox(height: 4),
          Text(line, style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
          const SizedBox(height: 12),
          _Pill(p: p, label: 'Call $number', strong: true, onTap: () => onCall(number)),
          if (alt case final a?) ...[
            const SizedBox(height: 8),
            _Pill(p: p, label: 'Or $a', strong: false, onTap: () => onCall(a)),
          ],
        ]),
      );
}

// -----------------------------------------------------------------------------
//  One paid offering
// -----------------------------------------------------------------------------

class MmOfferingScreen extends StatelessWidget {
  const MmOfferingScreen({super.key, required this.offering});
  final MmTalkOffering offering;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final o = offering;
    return PvDoorToolScaffold(
      hue: 186,
      eyebrow: 'Talk',
      title: o.title.en,
      intro: o.whoFor.en,
      children: [
        pvDoorPad(PvDoorCard(
          p: p,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(o.description.en,
                style: pvManrope(fontSize: 14, height: 1.6, color: p.ink1)),
            const SizedBox(height: 14),
            Container(height: 1, color: p.line),
            const SizedBox(height: 12),
            // A Wrap, not a Row: at 360dp the price, its unit and the
            // ANONYMOUS mark do not fit on one line, and a Row overflows
            // by exactly the width of the mark. Caught by the render test.
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Text('₹${o.priceInr.toStringAsFixed(0)}',
                    style: pvFraunces(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        color: p.ink1)),
                Text(o.priceUnit.en,
                    style: pvManrope(fontSize: 13, color: p.ink3)),
                if (o.anonymous)
                  Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    decoration: BoxDecoration(
                      color: p.ground,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: p.line),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('ANONYMOUS',
                          style: pvManrope(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: p.ink3)),
                    ]),
                  ),
              ],
            ),
          ]),
        )),
        const SizedBox(height: 14),
        pvDoorPad(_Pill(
          p: p,
          label: 'Book a session',
          strong: true,
          onTap: () => showCounsellingBookingSheet(context),
        )),
        const SizedBox(height: 22),
        pvDoorPad(PvDoorDisclaimer(
            p: p,
            text: 'A counsellor is not a replacement for your doctor. If '
                'something feels urgent, the crisis path on this door is free '
                'and open now.')),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
//  The one button these screens share — white with a hairline
// -----------------------------------------------------------------------------

class _Pill extends StatelessWidget {
  const _Pill({
    required this.p,
    required this.label,
    required this.strong,
    required this.onTap,
  });
  final V2Palette p;
  final String label;
  final bool strong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: strong ? p.ink1 : p.line, width: strong ? 1.2 : 1),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: strong ? p.ink1 : p.ink2)),
        ),
      );
}
