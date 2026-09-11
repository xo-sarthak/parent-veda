// =============================================================================
//  PpInteractiveScreen — a step-through she taps, in two kinds
// -----------------------------------------------------------------------------
//  ⚠️ TWO KINDS, ONE SCREEN, AND THE DIFFERENCE IS WHO IS HOLDING THE PHONE.
//
//  **Night.** "What to do at 3am" was a seven-step list with a heading. The
//  brief's objection is the honest one: "not a long list to read in the dark".
//  So: one step per screen, set large, on a ground dark enough not to light
//  the room, and the whole screen advances on a tap. The last screen is what
//  to do if nothing worked, with the doctor page one tap away. It is the same
//  seven steps; what changed is that she never has to find her place in a list
//  with one eye open.
//
//  **Checklist.** "Her sleep space, checked" was eleven cards. Walking them
//  one at a time with "done" / "not yet" ends on the short list of what to
//  change tonight, which is the thing a list of eleven cards cannot produce:
//  she reads them all and remembers none. Nothing is stored. A checklist
//  that remembers its ticks becomes a score, and the section's own rule is
//  that it must never become an anxiety tool.
//
//  ⚠️ THE NIGHT GROUND IS NOT THE PALETTE'S DARK MODE, because there is none.
//  It is one fixed deep blue, chosen once here and read by the launch card in
//  `pp_content.dart` so the card and the screen agree. Not pure black: an OLED
//  black next to white type is the harshest contrast a screen can show, and
//  this is read by someone trying to stay half asleep.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_content.dart';

class PpInteractiveScreen extends StatefulWidget {
  const PpInteractiveScreen({super.key, required this.block, this.onPage});

  final PpInteractive block;
  final void Function(BuildContext context, String pageId)? onPage;

  /// The night kind's ground and accent. Shared with the launch card.
  static const Color nightGround = Color(0xFF17203A);
  static const Color nightAccent = Color(0xFFB9C4F2);

  @override
  State<PpInteractiveScreen> createState() => _PpInteractiveScreenState();
}

class _PpInteractiveScreenState extends State<PpInteractiveScreen> {
  int _index = 0;

  /// Checklist kind: which items she said "not yet" to. Session only.
  final Set<int> _notYet = {};

  PpInteractive get b => widget.block;
  bool get _night => b.kind == PpInteractiveKind.night;
  int get _count => b.items.length;

  /// The closing screen sits one past the last item.
  bool get _onClosing => _index >= _count;

  void _advance() {
    if (_onClosing) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _index++);
  }

  void _back() {
    if (_index == 0) return;
    setState(() => _index--);
  }

  void _answer(bool done) {
    if (!done) _notYet.add(_index);
    if (done) _notYet.remove(_index);
    _advance();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) => _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) {
    final ground = _night ? PpInteractiveScreen.nightGround : p.ground;
    final ink = _night ? Colors.white : p.ink1;
    final ink2 = _night ? Colors.white.withValues(alpha: 0.7) : p.ink2;
    final accent = _night ? PpInteractiveScreen.nightAccent : p.action;

    return Scaffold(
      backgroundColor: ground,
      body: SafeArea(
        child: Column(children: [
          // ---- progress and close --------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(children: [
              for (var i = 0; i <= _count; i++) ...[
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: ink.withValues(alpha: i <= _index ? 0.7 : 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                if (i != _count) const SizedBox(width: 5),
              ],
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 2, 6, 0),
            child: Row(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(b.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                          color: ink2)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                color: ink,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ]),
          ),

          // ---- the step ------------------------------------------------------
          Expanded(
            child: _night
                ? _nightBody(context, ink, ink2, accent)
                : _checklistBody(context, p, ink, ink2, accent),
          ),
        ]),
      ),
    );
  }

  // ---- night: tap anywhere to advance ---------------------------------------

  Widget _nightBody(
      BuildContext context, Color ink, Color ink2, Color accent) {
    final item = _onClosing ? null : b.items[_index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _advance,
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 26, 26, 26),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                _onClosing
                    ? 'IF NONE OF THAT WORKED'
                    : 'STEP ${_index + 1} OF $_count',
                style: pvManrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: accent)),
            const SizedBox(height: 22),
            // ⚠️ SET LARGE. This is the one screen in the section read at
            // arm's length in the dark, so the step is the biggest type in
            // the parenting app. The detail underneath is for the second
            // glance, if there is one.
            Text(item?.title ?? (b.closing ?? 'That is the list.'),
                style: pvFraunces(
                    fontSize: item == null ? 24 : 30,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.6,
                    color: ink)),
            if (item?.detail != null) ...[
              const SizedBox(height: 18),
              Text(item!.detail!,
                  style: pvManrope(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: ink2)),
            ],
            const Spacer(),
            if (_onClosing && b.closingPageId != null && widget.onPage != null)
              _Pill(
                label: b.closingLabel ?? 'Open the doctor page',
                fill: Colors.white.withValues(alpha: 0.14),
                ink: Colors.white,
                onTap: () => widget.onPage!(context, b.closingPageId!),
              )
            else
              Text(_onClosing ? 'Tap to close' : 'Tap anywhere for the next step',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: ink2)),
          ]),
        ),
        if (_index > 0)
          Positioned(
            left: 8,
            bottom: 22,
            child: IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              color: ink2,
              onPressed: _back,
            ),
          ),
      ]),
    );
  }

  // ---- checklist: done / not yet, then the fix list --------------------------

  Widget _checklistBody(BuildContext context, V2Palette p, Color ink,
      Color ink2, Color accent) {
    if (_onClosing) return _checklistClosing(context, p, ink, ink2, accent);
    final item = b.items[_index];
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 26),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            [
              if (item.group != null) item.group!.toUpperCase(),
              'CHECK ${_index + 1} OF $_count',
            ].join('  ·  '),
            style: pvManrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
                color: accent)),
        const SizedBox(height: 22),
        Text(item.title,
            style: pvFraunces(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.6,
                color: ink)),
        if (item.detail != null) ...[
          const SizedBox(height: 16),
          Text(item.detail!,
              style: pvManrope(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                  color: ink2)),
        ],
        const Spacer(),
        Row(children: [
          Expanded(
            child: _Pill(
              label: 'Done',
              fill: p.action,
              ink: Colors.white,
              onTap: () => _answer(true),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Pill(
              label: 'Not yet',
              fill: p.surface,
              ink: p.ink1,
              edge: p.line,
              onTap: () => _answer(false),
            ),
          ),
        ]),
        if (_index > 0) ...[
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: _back,
              child: Text('Back one',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: ink2)),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _checklistClosing(BuildContext context, V2Palette p, Color ink,
      Color ink2, Color accent) {
    final todo = [for (final i in _notYet) b.items[i]];
    return ListView(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 30),
      children: [
        Text(todo.isEmpty ? 'ALL CHECKED' : 'TO CHANGE TONIGHT',
            style: pvManrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
                color: accent)),
        const SizedBox(height: 18),
        Text(
            todo.isEmpty
                ? 'Her sleep space is set up the safe way.'
                : '${todo.length} ${todo.length == 1 ? 'thing' : 'things'} to fix, '
                    'and none of them take long.',
            style: pvFraunces(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.6,
                color: ink)),
        if (b.closing != null) ...[
          const SizedBox(height: 14),
          Text(b.closing!,
              style: pvManrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                  color: ink2)),
        ],
        const SizedBox(height: 22),
        for (final t in todo) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.line),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.title,
                  style: pvManrope(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      color: p.ink1)),
              if (t.detail != null) ...[
                const SizedBox(height: 4),
                Text(t.detail!,
                    style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: p.ink2)),
              ],
            ]),
          ),
          const SizedBox(height: 9),
        ],
        const SizedBox(height: 14),
        _Pill(
          label: 'Done for now',
          fill: p.action,
          ink: Colors.white,
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.fill,
    required this.ink,
    required this.onTap,
    this.edge,
  });

  final String label;
  final Color fill;
  final Color ink;
  final Color? edge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(999),
            border: edge == null ? null : Border.all(color: edge!),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 14, fontWeight: FontWeight.w800, color: ink)),
        ),
      );
}
