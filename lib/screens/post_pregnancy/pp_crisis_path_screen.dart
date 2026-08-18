// =============================================================================
//  PpCrisisPathScreen — the one screen in the app that has to work at 3am
// -----------------------------------------------------------------------------
//  ⚠️ THIS EXISTS BECAUSE SEVEN PAGES IN "YOU, MAA" LINKED TO `pp_crisis_path`
//  AND NOTHING WAS THERE.
//
//  Every one of those links sat on a page about intrusive thoughts, rage,
//  psychosis, or not feeling like herself — and each rendered as a live, tappable
//  row that did nothing. Found by `test/pp_sleep_check_test.dart`, which resolves
//  every link in every section, because there is no other way to find a dead link
//  except to tap all of them.
//
//  ⚠️ WHAT THIS SCREEN IS FOR, AND WHAT IT REFUSES TO BE.
//
//  It is a path, not an assessment. A mother reaching this screen has already
//  decided something is wrong; asking her to answer questions first would put a
//  form between her and help. So there is no questionnaire, no score, no "you may
//  be experiencing", and nothing is logged.
//
//  The order is deliberate and it is the opposite of the order these screens
//  usually take:
//
//    1. If someone is in danger right now — the emergency number, first, biggest.
//    2. A person she can talk to today.
//    3. Only then, what to say, because "I don't know how to start" is the actual
//       barrier for most people and a script removes it.
//    4. Last, the reassurance — because reassurance placed FIRST reads as being
//       talked out of it, which is what she has already had from everyone else.
//
//  ⚠️ IT NEVER SAYS "YOU ARE FINE" AND IT NEVER SAYS "YOU ARE ILL." Both are
//  diagnoses. It says: this is common, it is treatable, and here is who to tell.
//
//  ⚠️ EVERY PHONE NUMBER IS MARKED `REQUIRED_TO_CONFIRM` AND NONE IS INVENTED.
//  A wrong helpline number on this screen is worse than no screen at all, so the
//  numbers below are the ones commonly published for India and MUST be verified
//  against the current government listing before this ships. That is a hard gate,
//  not a nicety.
//
//  ⚠️ ENGLISH ONLY FOR NOW. This is also the screen where that debt costs the
//  most: a mother in crisis reads in her first language or she does not read.
//  Flagged in docs/PP-SECTIONS-STATE.md as the highest-priority translation.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_content.dart';

/// One way to reach a person.
class _Line {
  const _Line({
    required this.name,
    required this.number,
    required this.who,
  });
  final String name;
  final String number;
  final String who;

  /// Every line here is 24-hour, so this is a constant rather than a field. If a
  /// line with limited hours is ever added, this becomes a field again -- and a
  /// helpline that is closed when she calls is worse than one she never saw, so
  /// it would have to be shown, not defaulted.
  static const String hours = 'Open 24 hours';
}

// ⚠️ REQUIRED_TO_CONFIRM — every number below. Verify against the current
// Ministry of Social Justice / Ministry of Health listing before shipping.
// Do not add a number to this list without a source.
const List<_Line> _lines = [
  _Line(
    // REQUIRED_TO_CONFIRM: Tele-MANAS, the national mental health helpline.
    name: 'Tele-MANAS',
    number: '14416',
    who: 'The national mental health helpline. Free, in many Indian languages, '
        'and you do not need to give your name.',
  ),
  _Line(
    // REQUIRED_TO_CONFIRM: KIRAN, MoSJE mental health rehabilitation helpline.
    name: 'KIRAN',
    number: '1800-599-0019',
    who: 'A second national line, also free and also in many languages, if the '
        'first is busy.',
  ),
];

class PpCrisisPathScreen extends StatelessWidget {
  const PpCrisisPathScreen({super.key});

  Future<void> _dial(String number) async {
    // Opens the dialler with the number filled in; it does not place the call.
    // She presses the green button, which keeps the last step hers.
    final uri = Uri(scheme: 'tel', path: number.replaceAll('-', ''));
    try {
      await launchUrl(uri);
    } catch (_) {
      // A failed launch must never be a crash on this screen of all screens.
      // The number is printed in full above the button for exactly this case.
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) =>
            _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) => Scaffold(
        backgroundColor: p.ground,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 44),
            children: [
              ppV3Back(context, p),
              const SizedBox(height: 16),

              // ---- 1. RIGHT NOW ------------------------------------------
              // ⚠️ FIRST AND LOUDEST. Everything else on this screen assumes
              // there is time. This is the part that assumes there is not.
              Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  color: ppAlertTint(p),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ppAlertInk(p).withValues(alpha: 0.5)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('If you or your baby are in danger right now',
                          style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
                      const SizedBox(height: 8),
                      Text(
                          'Put the baby somewhere safe, like the cot or the '
                          'floor. Then call. It does not matter that you cannot '
                          'explain it properly.',
                          style: pvManrope(fontSize: 14, fontWeight: FontWeight.w500, height: 1.6, color: p.ink1)),
                      const SizedBox(height: 14),
                      _CallButton(
                        // REQUIRED_TO_CONFIRM: 112 is the all-India emergency
                        // number. Confirm it is the right one to surface here
                        // rather than 108 (ambulance) in some states.
                        label: 'Call 112',
                        onTap: () => _dial('112'),
                        filled: true,
                      ),
                    ]),
              ),

              const SizedBox(height: 26),

              // ---- 2. SOMEONE TO TALK TO ---------------------------------
              Text('Someone to talk to today',
                  style: pvFraunces(fontSize: 21, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
              const SizedBox(height: 8),
              Text(
                  'These are free, they are confidential, and the person '
                  'answering has heard this before.',
                  style: pvManrope(fontSize: 14, fontWeight: FontWeight.w500, height: 1.6, color: p.ink2)),
              const SizedBox(height: 14),
              for (final l in _lines) ...[
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: p.line),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(l.name,
                                style: pvFraunces(fontSize: 17, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
                          ),
                          Text(_Line.hours,
                              style: pvManrope(fontSize: 11, fontWeight: FontWeight.w700, height: 1.55, color: p.ink3)
                                  .copyWith(letterSpacing: 0.6)),
                        ]),
                        const SizedBox(height: 6),
                        Text(l.who, style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
                        const SizedBox(height: 12),
                        // ⚠️ THE NUMBER IS PRINTED, NOT ONLY DIALLED. If the
                        // dialler fails to open, or she is reading this on a
                        // tablet, or she wants to call from another phone, the
                        // number is still there in full.
                        Text(l.number,
                            style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
                        const SizedBox(height: 10),
                        _CallButton(
                            label: 'Call ${l.name}',
                            onTap: () => _dial(l.number)),
                      ]),
                ),
                const SizedBox(height: 10),
              ],

              const SizedBox(height: 20),

              // ---- 3. WHAT TO SAY ----------------------------------------
              // The real barrier is almost never the number. It is not knowing
              // how to begin, and being afraid of what saying it out loud will
              // set in motion.
              Text('If you do not know how to start',
                  style: pvFraunces(fontSize: 21, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
              const SizedBox(height: 10),
              const _Say(
                  'I had a baby recently and I am not okay. I do not know how '
                  'to explain it.'),
              const _Say(
                  'I am having thoughts that frighten me. I do not want to act '
                  'on them.'),
              const _Say(
                  'I have not slept properly in weeks and I cannot think '
                  'straight.'),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.line),
                ),
                child: Text(
                    'Saying you are having frightening thoughts about the baby '
                    'does not mean anyone will take your baby away. Those '
                    'thoughts are extremely common after birth, doctors know '
                    'that, and telling someone is how they stop.',
                    style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.6, color: p.ink1)),
              ),

              const SizedBox(height: 26),

              // ---- 4. THE REASSURANCE, LAST ------------------------------
              // ⚠️ DELIBERATELY AT THE BOTTOM. Put first, "this is common and
              // treatable" reads as being talked out of it, which is what she
              // has already had from everyone around her. Put last, after she
              // has been given somewhere to go, it is what it is meant to be.
              Text(
                  'What you are feeling has a name, it is common, and it gets '
                  'better with help. Not with time alone, and not by trying '
                  'harder. With help.',
                  style: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, height: 1.65, color: p.ink1)),
              const SizedBox(height: 12),
              Text(
                  'Nothing on this screen is recorded anywhere, and nothing '
                  'here is a diagnosis.',
                  style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.55, color: p.ink3)),
            ],
          ),
        ),
      );
}

class _CallButton extends StatelessWidget {
  const _CallButton(
      {required this.label, required this.onTap, this.filled = false});

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: filled ? ppAlertInk(p) : p.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: filled ? ppAlertInk(p) : p.action, width: 1.4),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.call_rounded,
                size: 18, color: filled ? p.surface : p.action),
            const SizedBox(width: 9),
            Text(label,
                style: pvManrope(fontSize: 15, fontWeight: FontWeight.w800, height: 1.55, color: p.ink2)),
          ]),
        ),
      );
  }
}
class _Say extends StatelessWidget {
  const _Say(this.line);
  final String line;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
        ),
        child: Text('"$line"',
            style: pvFraunces(fontSize: 15, fontWeight: FontWeight.w500, height: 1.2, letterSpacing: -0.4, color: p.ink1).copyWith(height: 1.5)),
      );
  }
}
