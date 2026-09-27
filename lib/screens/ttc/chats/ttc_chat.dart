// =============================================================================
//  The scripted chat - one widget, three conversations
// -----------------------------------------------------------------------------
//  "Should I test?", "My period came" and "My cycle report" are conversations
//  rather than screens because each one is a question she would ask a friend,
//  and the answer depends on her own dates. A screen shows every branch at
//  once; a conversation shows only hers.
//
//  ⚠️ NO AI. Every line is written in advance and chosen by rules over her own
//  data. There is no model, no network call and no free text box. Ask Veda is
//  the place for open questions, and it lives in another repository with its
//  own safety routing (CLAUDE.md). This is the opposite on purpose: it can only
//  ever say what a person wrote and reviewed.
//
//  ---------------------------------------------------------------------------
//  HOW A SCRIPT IS SHAPED
//  ---------------------------------------------------------------------------
//
//  A [TtcChatScript] returns a first [TtcChatStep]. A step is some lines from
//  ParentVeda and the chips she can answer with. A chip either:
//
//    * continues   ([TtcChatChoice.next]), and her chip becomes her bubble;
//    * opens       ([TtcChatChoice.open]) a surface, and the chat waits for her
//                  to come back, chips still there;
//    * acts        ([TtcChatChoice.action]), like a date picker, and may
//                  continue with what she picked as her bubble;
//    * ends        ([TtcChatChoice.done]).
//
//  Steps are built lazily by closures, so a script can read what she answered
//  earlier without the widget knowing anything about it. The widget knows
//  about bubbles, chips and a pause. Nothing else.
//
//  ⚠️ A CHIP THAT OPENS NOTHING IS NOT DRAWN. [TtcChatChoice.open] is a list of
//  surface ids, best first, and the chip only renders when one resolves. A read
//  that is not in the library yet falls through to the next id, and if none
//  resolves she never sees a chip that does nothing when tapped.
//
//  ⚠️ THE ANSWERS LIVE IN A TRAY AT THE FOOT (review C1, 2026-09-26). They
//  scrolled with the conversation, right-aligned and mid-screen, padded clear
//  of the Ask button. Now they are pinned in a white tray under a hairline,
//  in the thumb zone (DESIGN-SYSTEM §5.9), stacked full width at 48pt, with
//  "Done" as the one ink commit pill; the Ask button steps aside on
//  `ttc_chat/*` routes (global_ask_fab.dart), as it does on search. Under the
//  answers, always, one grey line: general information, not medical advice
//  (C3; CLAUDE.md "anything clinical ends with a disclaimer"). Every answer
//  presses and answers with a haptic (C2, §4.0c). Mobbin: Flo's Health
//  Assistant, answers pinned in a bottom tray (FLO-CHAT-TRAY,
//  https://mobbin.com/screens/ed0558ae-4f28-4cf8-8fac-0f34c0ac83bc), its one
//  full-width Finish pill (FLO-CHAT-END,
//  https://mobbin.com/screens/ce2b3ee0-142c-48d4-9e2b-5c702c0556c9), its
//  "not a substitute for medical advice" (FLO-CHAT-DISCL,
//  https://mobbin.com/screens/b5c73333-d632-4436-8051-4cf130fe6651); Cash
//  App's assistant, stacked answers at the foot with a small caution line
//  under them (https://mobbin.com/screens/56ff5f1d-e0ad-4657-90e3-ab6ba37081e2).
// =============================================================================

import 'package:flutter/material.dart';

import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../ttc_common.dart';
import '../ttc_surface_router.dart';

/// What an action chip returns when the chat should continue: the words for
/// her bubble, and the step that answers them.
class TtcChatReply {
  const TtcChatReply(this.echo, this.next);
  final String echo;
  final TtcChatStep next;
}

typedef TtcChatAction = Future<TtcChatReply?> Function(BuildContext context);

/// One answer chip.
class TtcChatChoice {
  const TtcChatChoice(
    this.label, {
    this.next,
    this.open,
    this.action,
    this.done = false,
  });

  final String label;

  /// Continue the conversation. Her chip becomes her bubble.
  final TtcChatStep Function()? next;

  /// Open the first of these surfaces that resolves. The chat stays.
  final List<String>? open;

  /// Do something that needs a context (a date picker, a confirm dialog).
  final TtcChatAction? action;

  /// Close the chat.
  final bool done;
}

/// Lines from ParentVeda, then her choices.
class TtcChatStep {
  const TtcChatStep(this.say, [this.choices = const []]);
  final List<String> say;
  final List<TtcChatChoice> choices;
}

/// A whole conversation.
abstract class TtcChatScript {
  /// The bar title.
  String get title;

  TtcChatStep start();
}

/// The line under every chat's answers (C3). English only.
const String kTtcChatDisclaimer =
    "General information, not medical advice. Your doctor's word comes first.";

/// The tray's key, for tests and for anyone looking for it.
const Key kTtcChatTrayKey = ValueKey('ttc_chat_tray');

/// The first surface id in [ids] that opens a screen, or null.
String? ttcFirstOpenable(List<String> ids) {
  for (final id in ids) {
    if (ttcScreenForSurface(id) != null) return id;
  }
  return null;
}

/// The chat itself.
class TtcChatScreen extends StatefulWidget {
  const TtcChatScreen({
    super.key,
    required this.script,
    this.pause = const Duration(milliseconds: 650),
  });

  final TtcChatScript script;

  /// The typing pause before each line. A beat, so the words arrive at the
  /// speed of someone saying them rather than as a wall. Zero in tests.
  final Duration pause;

  @override
  State<TtcChatScreen> createState() => _TtcChatScreenState();
}

class _Line {
  const _Line(this.text, {this.fromHer = false});
  final String text;
  final bool fromHer;
}

class _TtcChatScreenState extends State<TtcChatScreen> {
  late final TtcChatScript _script = widget.script;
  final List<_Line> _lines = [];
  final ScrollController _scroll = ScrollController();
  List<TtcChatChoice> _choices = const [];
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    _play(_script.start());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _play(TtcChatStep step) async {
    setState(() => _choices = const []);
    for (final line in step.say) {
      if (!mounted) return;
      setState(() => _typing = true);
      _toBottom();
      await Future<void>.delayed(widget.pause);
      if (!mounted) return;
      setState(() {
        _typing = false;
        _lines.add(_Line(line));
      });
      _toBottom();
    }
    if (!mounted) return;
    setState(() => _choices = step.choices);
    _toBottom();
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _pick(TtcChatChoice c) async {
    // Every answer is a commit tap (§4.0c): the press shows it, this says it.
    pvCommitFeedback();
    if (c.done) {
      Navigator.of(context).maybePop();
      return;
    }
    final open = c.open;
    if (open != null) {
      final id = ttcFirstOpenable(open);
      if (id != null) openTtcSurface(context, id);
      return;
    }
    final action = c.action;
    if (action != null) {
      final reply = await action(context);
      if (reply == null || !mounted) return;
      setState(() => _lines.add(_Line(reply.echo, fromHer: true)));
      await _play(reply.next);
      return;
    }
    final next = c.next;
    if (next != null) {
      setState(() => _lines.add(_Line(c.label, fromHer: true)));
      await _play(next());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Chips that would open nothing are not drawn. See the header.
    final chips = _choices
        .where((c) => c.open == null || ttcFirstOpenable(c.open!) != null)
        .toList();
    return Scaffold(
      backgroundColor: ttcBg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(ttcGutter, 8, ttcGutter, 6),
            child: TtcBackBar(title: _script.title),
          ),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(ttcGutter, 12, ttcGutter, 16),
              children: [
                for (var i = 0; i < _lines.length; i++)
                  _Bubble(
                    line: _lines[i],
                    // The name sits over the first line of each of our runs,
                    // not over every line. A name on every bubble is a form.
                    showName: !_lines[i].fromHer &&
                        (i == 0 || _lines[i - 1].fromHer),
                  ),
                if (_typing) const _Typing(),
                // Kept for revert (C1): the chips as a right-aligned Wrap at
                // the end of the conversation, then `SizedBox(height:
                // ttcBottomInset)` to clear the Ask button.
              ],
            ),
          ),
          _Tray(
            chips: [
              for (final c in chips)
                _Answer(label: c.label, done: c.done, onTap: () => _pick(c)),
            ],
          ),
        ]),
      ),
    );
  }
}

/// The answers, pinned at the foot: a white tray under a hairline, the
/// answers stacked full width, and the disclaimer line under them. Drawn even
/// while ParentVeda is typing, so the line never jumps in and out.
class _Tray extends StatelessWidget {
  const _Tray({required this.chips});
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: kTtcChatTrayKey,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ttcLine)),
      ),
      padding: EdgeInsets.fromLTRB(
          ttcGutter, 12, ttcGutter, 10 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < chips.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  chips[i],
                ],
                if (chips.isNotEmpty) const SizedBox(height: 10),
              ],
            ),
          ),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(Icons.info_outline_rounded, size: 14, color: ttcMuted),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(kTtcChatDisclaimer,
                  style: pvManrope(fontSize: 11.5, height: 1.4, color: ttcMuted)),
            ),
          ]),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.line, required this.showName});
  final _Line line;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final her = line.fromHer;
    return Padding(
      padding: EdgeInsets.only(top: showName ? 10 : 6),
      child: Column(
        crossAxisAlignment:
            her ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showName)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              // C5: grey, not violet (violet is for eyebrows, links,
              // switches and progress, §4.0). Was color: ttcPurple.
              child: Text('ParentVeda',
                  style: ttcBody(11.5,
                      color: ttcMuted, w: FontWeight.w700, h: 1.2)),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: her ? ttcTitleInk : ttcPanel,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(her ? 18 : 6),
                  bottomRight: Radius.circular(her ? 6 : 18),
                ),
              ),
              child: Text(
                line.text,
                style: ttcBody(14.5,
                    color: her ? Colors.white : ttcInk, h: 1.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three still dots. Still on purpose: a looping animation would be one more
/// thing moving on a screen meant to be calm, and it never lets a widget test
/// settle.
class _Typing extends StatelessWidget {
  const _Typing();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
              color: ttcPanel, borderRadius: BorderRadius.circular(18)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: 6,
                height: 6,
                margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
                decoration: const BoxDecoration(
                    color: ttcMuted, shape: BoxShape.circle),
              ),
          ]),
        ),
      ),
    );
  }
}

/// One answer: a full-width outlined pill at 48pt (C2: 44 is the floor),
/// or, for "Done", the one ink commit pill. Presses like every tile.
class _Answer extends StatelessWidget {
  const _Answer({required this.label, required this.onTap, this.done = false});
  final String label;
  final VoidCallback onTap;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return PvPress(
      child: Material(
        color: done ? ttcTitleInk : Colors.white,
        shape: StadiumBorder(
            side: done
                ? BorderSide.none
                : BorderSide(color: ttcTitleInk.withValues(alpha: 0.35))),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Center(
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: ttcBody(14,
                        color: done ? Colors.white : ttcTitleInk,
                        w: FontWeight.w700,
                        h: 1.25)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Kept for revert (C1, C2): the 36pt outlined chip, with no press.
// class _Chip extends StatelessWidget {
//   const _Chip({required this.label, required this.onTap});
//   final String label;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       shape: StadiumBorder(
//           side: BorderSide(color: ttcTitleInk.withValues(alpha: 0.55))),
//       child: InkWell(
//         customBorder: const StadiumBorder(),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           child: Text(label,
//               style:
//                   ttcBody(13.5, color: ttcTitleInk, w: FontWeight.w700, h: 1.2)),
//         ),
//       ),
//     );
//   }
// }
