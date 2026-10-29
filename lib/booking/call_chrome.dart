// =============================================================================
//  call_chrome.dart — the parts the three call screens share
// -----------------------------------------------------------------------------
//  The consult screen, the class screen and the pre-join screen each grew
//  their own round button, their own pill and their own "it's over" view, and
//  by the 2026-10-29 polish pass they disagreed with each other: an "off"
//  control was white in the call and red in the green room, buttons were the
//  brand purple instead of the house ink style, and only one of the three bars
//  said anything to a screen reader. One file, so they stay agreed.
//
//  LABELS UNDER EVERY CONTROL. The bar used to be icons only, on the WhatsApp
//  argument that "inverted means off" reads without words. It does, for mic
//  and camera. It does not for a raised hand (white looked like "off"), for
//  speaker versus earpiece, or for the host's "mute everyone" sitting beside
//  her own mic with the same crossed-out icon. Telegram, inDrive and every
//  phone dialler put a word under each circle; so does this.
//
//  BUTTONS ON A DARK GROUND. The house style is one button: ink fill, white
//  text. On the call's near-black that ink disappears, so the same style is
//  inverted here: white fill, ink text for the one thing to do next, a white
//  outline for the other.
//
//  PURPLE AS TEXT ON BLACK FAILS. AppTheme.primary on the call background is
//  about 2.5:1, under the 4.5:1 text needs. [kCallTint] is the same hue
//  lightened until it passes (about 10:1). Purple stays as a FILL behind white
//  text (avatars), where it passes easily.
// =============================================================================

import 'package:flutter/material.dart';

import '../widgets/pv_feedback.dart' show PvPress;

/// The brand purple, lightened to pass contrast as TEXT on the call ground.
const kCallTint = Color(0xFFC9B1F2);

/// The house ink (the switch black), used as text on a white call button.
const kCallInk = Color(0xFF2F2C30);

const _danger = Color(0xFFE5484D);

/// A round call control with its label underneath.
///
/// [on] false inverts it to a white fill: "off" for mic and camera, "raised"
/// for a hand. The label says which, so the colour never has to.
class CallControl extends StatelessWidget {
  const CallControl({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.on = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool on;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: PvPress(
          enabled: onTap != null,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Opacity(
              opacity: onTap == null ? 0.5 : 1,
              child: SizedBox(
                width: 62,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: on
                          ? Colors.white.withValues(alpha: 0.16)
                          : Colors.white,
                    ),
                    child: Icon(icon,
                        size: 23, color: on ? Colors.white : kCallInk),
                  ),
                  const SizedBox(height: 5),
                  ExcludeSemantics(
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        softWrap: false,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
}

/// The red leave pill, wider than the circles so the finger finds it, with
/// its label like the rest.
class CallLeaveControl extends StatelessWidget {
  const CallLeaveControl({super.key, required this.onTap, this.label = 'Leave'});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: PvPress(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 82,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 74,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _danger, borderRadius: BorderRadius.circular(26)),
                  child: const Icon(Icons.call_end_rounded,
                      size: 25, color: Colors.white),
                ),
                const SizedBox(height: 5),
                ExcludeSemantics(
                  child: Text(label,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ),
              ]),
            ),
          ),
        ),
      );
}

/// The house button, inverted for the dark call ground. [primary] is the one
/// thing to do next (white fill, ink text); otherwise a white outline.
Widget callButton(String label, VoidCallback? onTap, {bool primary = true}) =>
    Semantics(
      button: true,
      label: label,
      child: PvPress(
        enabled: onTap != null,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Opacity(
            opacity: onTap == null ? 0.6 : 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: primary
                      ? null
                      : Border.all(color: Colors.white.withValues(alpha: 0.35)),
                ),
                child: Text(label,
                    style: TextStyle(
                        color: primary ? kCallInk : Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      ),
    );

/// A full screen that says what happened and what to do next, in place of
/// the room: host-missed, ended, disconnected, removed.
///
/// The shape follows the end screens that work (Urban Company "Job complete /
/// Book again", Ro's "what happens next" list): a title that says what
/// happened, one line of when, a short checklist of what we have already done
/// for her, then at most two buttons, the first being the next step.
class CallOutcomeView extends StatelessWidget {
  const CallOutcomeView({
    super.key,
    required this.icon,
    required this.title,
    this.line,
    this.meta,
    this.checks = const [],
    required this.actions,
  });

  final IconData icon;
  final String title;
  final String? line;
  final String? meta;
  final List<String> checks;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08)),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      height: 1.3)),
              if (line != null) ...[
                const SizedBox(height: 8),
                Text(line!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14, height: 1.5)),
              ],
              if (meta != null) ...[
                const SizedBox(height: 10),
                Text(meta!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
              if (checks.isNotEmpty) ...[
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Column(children: [
                    for (final c in checks)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 1),
                                child: Icon(Icons.check_circle_outline_rounded,
                                    size: 18, color: Color(0xFF3ECF8E)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(c,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        height: 1.4)),
                              ),
                            ]),
                      ),
                  ]),
                ),
              ],
              const SizedBox(height: 22),
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                actions[i],
              ],
            ]),
          ),
        ),
      );
}

/// "7:50 PM" in her own clock, for the copy that names a time.
String callClockAt(DateTime utc) {
  final d = utc.toLocal();
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
}
